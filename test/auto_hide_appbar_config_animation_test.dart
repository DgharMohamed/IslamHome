// Feature: auto-hide-appbar
// Property 6: Animation Configuration
// **Validates: Requirements 4.1, 4.2**
//
// This test verifies that AutoHideAppBarConfig properly configures animation
// parameters according to the design specification:
// - Animation duration must be within 200-300 milliseconds
// - Animation curve must be an easing curve (not linear)
//
// Property being tested: For any AutoHideAppBarConfig instance,
// it should be configured with an easing curve and complete animations
// within 200-300 milliseconds.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_config.dart';

void main() {
  group('Property 6: Animation Configuration', () {
    test('default config has animation duration within 200-300ms', () {
      // Arrange: Create default config
      const config = AutoHideAppBarConfig();

      // Assert: Duration should be within the specified range
      expect(
        config.animationDuration.inMilliseconds,
        greaterThanOrEqualTo(200),
        reason: 'Animation duration must be at least 200ms',
      );
      expect(
        config.animationDuration.inMilliseconds,
        lessThanOrEqualTo(300),
        reason: 'Animation duration must not exceed 300ms',
      );
    });

    test('default config uses easing curve (not linear)', () {
      // Arrange: Create default config
      const config = AutoHideAppBarConfig();

      // Assert: Curve should not be linear
      expect(
        config.animationCurve,
        isNot(equals(Curves.linear)),
        reason: 'Animation curve must be an easing curve, not linear',
      );

      // Assert: Curve should provide smooth transitions
      // At t=0, curve should be 0 (start)
      expect(
        config.animationCurve.transform(0.0),
        equals(0.0),
        reason: 'Curve should start at 0',
      );

      // At t=1, curve should be 1 (end)
      expect(
        config.animationCurve.transform(1.0),
        equals(1.0),
        reason: 'Curve should end at 1',
      );
    });

    test('default config uses easeInOutCubic curve', () {
      // Arrange: Create default config
      const config = AutoHideAppBarConfig();

      // Assert: Should use easeInOutCubic as specified in design
      expect(
        config.animationCurve,
        equals(Curves.easeInOutCubic),
        reason: 'Default curve should be easeInOutCubic',
      );
    });

    test('easeInOutCubic provides smooth acceleration and deceleration', () {
      // Arrange: Create default config
      const config = AutoHideAppBarConfig();
      final curve = config.animationCurve;

      // Assert: Early in animation (t=0.1), value should be small (slower than linear)
      final early = curve.transform(0.1);
      expect(
        early,
        lessThan(0.1),
        reason: 'Curve should provide smooth acceleration (slower than linear)',
      );

      // Assert: Late in animation (t=0.9), value should be close to 1 (slower than linear)
      final late = curve.transform(0.9);
      expect(
        late,
        greaterThan(0.9),
        reason: 'Curve should provide smooth deceleration',
      );
    });

    test('custom config with valid duration within range is accepted', () {
      // Arrange & Act: Create config with duration at lower bound
      const configLower = AutoHideAppBarConfig(
        animationDuration: Duration(milliseconds: 200),
      );

      // Assert: Should accept 200ms
      expect(configLower.animationDuration.inMilliseconds, equals(200));

      // Arrange & Act: Create config with duration at upper bound
      const configUpper = AutoHideAppBarConfig(
        animationDuration: Duration(milliseconds: 300),
      );

      // Assert: Should accept 300ms
      expect(configUpper.animationDuration.inMilliseconds, equals(300));

      // Arrange & Act: Create config with duration in middle of range
      const configMiddle = AutoHideAppBarConfig(
        animationDuration: Duration(milliseconds: 250),
      );

      // Assert: Should accept 250ms
      expect(configMiddle.animationDuration.inMilliseconds, equals(250));
    });

    test('custom config with different easing curves maintains smoothness', () {
      // Test various easing curves to ensure they all provide smooth transitions
      final curves = [
        Curves.easeIn,
        Curves.easeOut,
        Curves.easeInOut,
        Curves.easeInOutCubic,
        Curves.easeInOutQuad,
        Curves.easeInOutSine,
      ];

      for (final curve in curves) {
        // Arrange & Act: Create config with different curve
        final config = AutoHideAppBarConfig(animationCurve: curve);

        // Assert: All curves should start at 0 and end at 1
        expect(
          config.animationCurve.transform(0.0),
          equals(0.0),
          reason: '$curve should start at 0',
        );
        expect(
          config.animationCurve.transform(1.0),
          equals(1.0),
          reason: '$curve should end at 1',
        );

        // Assert: None should be linear
        expect(
          config.animationCurve,
          isNot(equals(Curves.linear)),
          reason: '$curve should not be linear',
        );
      }
    });

    test('copyWith preserves animation configuration when not overridden', () {
      // Arrange: Create config with specific animation settings
      const original = AutoHideAppBarConfig(
        animationDuration: Duration(milliseconds: 250),
        animationCurve: Curves.easeInOutCubic,
      );

      // Act: Copy without overriding animation settings
      final copied = original.copyWith(hideThreshold: 60.0);

      // Assert: Animation settings should be preserved
      expect(
        copied.animationDuration,
        equals(original.animationDuration),
        reason: 'Animation duration should be preserved',
      );
      expect(
        copied.animationCurve,
        equals(original.animationCurve),
        reason: 'Animation curve should be preserved',
      );
    });

    test('copyWith allows overriding animation configuration', () {
      // Arrange: Create default config
      const original = AutoHideAppBarConfig();

      // Act: Override animation settings
      final modified = original.copyWith(
        animationDuration: const Duration(milliseconds: 200),
        animationCurve: Curves.easeInOut,
      );

      // Assert: Animation settings should be updated
      expect(
        modified.animationDuration.inMilliseconds,
        equals(200),
        reason: 'Animation duration should be updated',
      );
      expect(
        modified.animationCurve,
        equals(Curves.easeInOut),
        reason: 'Animation curve should be updated',
      );

      // Assert: New values should still meet requirements
      expect(
        modified.animationDuration.inMilliseconds,
        greaterThanOrEqualTo(200),
      );
      expect(modified.animationDuration.inMilliseconds, lessThanOrEqualTo(300));
      expect(modified.animationCurve, isNot(equals(Curves.linear)));
    });

    test('animation configuration works together for smooth experience', () {
      // Arrange: Create default config
      const config = AutoHideAppBarConfig();

      // Assert: Duration is appropriate for smooth animation
      expect(
        config.animationDuration.inMilliseconds,
        greaterThanOrEqualTo(200),
        reason: 'Duration should be long enough for smooth animation',
      );
      expect(
        config.animationDuration.inMilliseconds,
        lessThanOrEqualTo(300),
        reason: 'Duration should not be too long to feel sluggish',
      );

      // Assert: Curve provides smooth transitions
      final midPoint = config.animationCurve.transform(0.5);
      expect(
        midPoint,
        greaterThan(0.4),
        reason: 'Curve should provide smooth mid-point transition',
      );
      expect(
        midPoint,
        lessThan(0.6),
        reason: 'Curve should provide smooth mid-point transition',
      );
    });
  });
}
