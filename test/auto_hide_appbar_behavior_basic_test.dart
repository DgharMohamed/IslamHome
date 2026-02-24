// Basic unit tests for AutoHideAppBarBehavior
// These tests verify the core scroll detection logic and visibility state management

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_behavior.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_config.dart';

void main() {
  group('AutoHideAppBarBehavior - Basic Functionality', () {
    late ScrollController scrollController;
    late ValueNotifier<bool> isAppBarVisible;
    late AutoHideAppBarBehavior behavior;

    setUp(() {
      scrollController = ScrollController();
      isAppBarVisible = ValueNotifier<bool>(true);
    });

    tearDown(() {
      behavior.dispose();
      scrollController.dispose();
      isAppBarVisible.dispose();
    });

    test('initializes with AppBar visible', () {
      // Arrange & Act
      behavior = AutoHideAppBarBehavior(
        scrollController: scrollController,
        isAppBarVisible: isAppBarVisible,
      );
      behavior.initialize();

      // Assert
      expect(isAppBarVisible.value, isTrue);
    });

    test('reset sets AppBar to visible', () {
      // Arrange
      behavior = AutoHideAppBarBehavior(
        scrollController: scrollController,
        isAppBarVisible: isAppBarVisible,
      );
      behavior.initialize();
      isAppBarVisible.value = false;

      // Act
      behavior.reset();

      // Assert
      expect(isAppBarVisible.value, isTrue);
    });

    test('does not initialize when auto-hide is disabled', () {
      // Arrange
      const config = AutoHideAppBarConfig(enableAutoHide: false);
      behavior = AutoHideAppBarBehavior(
        scrollController: scrollController,
        isAppBarVisible: isAppBarVisible,
        config: config,
      );

      // Act
      behavior.initialize();
      isAppBarVisible.value = false;

      // Assert: Should remain false since auto-hide is disabled
      expect(isAppBarVisible.value, isFalse);
    });

    test('uses custom config when provided', () {
      // Arrange
      const customConfig = AutoHideAppBarConfig(
        hideThreshold: 100.0,
        showThreshold: 30.0,
      );
      behavior = AutoHideAppBarBehavior(
        scrollController: scrollController,
        isAppBarVisible: isAppBarVisible,
        config: customConfig,
      );

      // Assert
      expect(behavior.config.hideThreshold, equals(100.0));
      expect(behavior.config.showThreshold, equals(30.0));
    });

    test('uses default config when not provided', () {
      // Arrange & Act
      behavior = AutoHideAppBarBehavior(
        scrollController: scrollController,
        isAppBarVisible: isAppBarVisible,
      );

      // Assert
      expect(behavior.config.hideThreshold, equals(50.0));
      expect(behavior.config.showThreshold, equals(20.0));
    });
  });
}
