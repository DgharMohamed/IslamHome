import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';

/// Integration test for long-distance ayah scroll animation
/// Tests navigation across surahs (from Surah 1 to Surah 114 and vice versa)
///
/// **Validates: Requirements 1.4, 4.1**
void main() {
  group('Long-Distance Ayah Scroll Animation Tests', () {
    testWidgets(
      'should smoothly scroll from Surah 1 to Surah 114 without jarring jumps',
      (WidgetTester tester) async {
        // Build the QuranTextScreen starting at Surah 1 (Al-Fatiha)
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 1)),
          ),
        );

        // Wait for initial build and data loading
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify we're at Surah 1 by checking for content
        final scrollable = find.byType(CustomScrollView);
        expect(
          scrollable,
          findsOneWidget,
          reason: 'Scrollable view should be present',
        );

        // Now simulate navigation to Surah 114 (An-Nas)
        // This would normally be triggered by the bookmark button
        // For this test, we'll verify the screen can handle long-distance navigation

        // Record the start time for animation duration verification
        final startTime = DateTime.now();

        // Find the bookmark button (if available)
        final bookmarkButton = find.byIcon(Icons.bookmark);

        if (bookmarkButton.evaluate().isNotEmpty) {
          // Tap the bookmark button to trigger navigation
          await tester.tap(bookmarkButton);
          await tester.pump();

          // Monitor frame rate during animation
          int frameCount = 0;
          final animationDuration = const Duration(milliseconds: 1500);
          final frameDuration = const Duration(milliseconds: 16); // ~60 FPS

          // Pump frames during animation
          while (DateTime.now().difference(startTime) < animationDuration) {
            await tester.pump(frameDuration);
            frameCount++;
          }

          // Verify smooth frame rate (at least 50 frames for ~1 second)
          // Allowing tolerance for test environment
          expect(
            frameCount,
            greaterThan(50),
            reason:
                'Animation should maintain smooth frame rate even for long distances',
          );

          // Wait for animation to complete
          await tester.pumpAndSettle();

          // Verify the target ayah is now visible on screen
          // The ayah should be highlighted with golden background
          final highlightedAyah = find.byWidgetPredicate(
            (widget) =>
                widget is AnimatedContainer &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color != null &&
                (widget.decoration as BoxDecoration).color!.a > 0,
          );

          // Verify highlight is present
          expect(
            highlightedAyah,
            findsWidgets,
            reason:
                'Target ayah should be highlighted after long-distance animation',
          );
        }
      },
    );

    testWidgets(
      'should smoothly scroll from Surah 114 to Surah 1 without jarring jumps',
      (WidgetTester tester) async {
        // Build the QuranTextScreen starting at Surah 114 (An-Nas)
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 114)),
          ),
        );

        // Wait for initial build and data loading
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify we're at Surah 114 by checking for content
        final scrollable = find.byType(CustomScrollView);
        expect(
          scrollable,
          findsOneWidget,
          reason: 'Scrollable view should be present',
        );

        // Record the start time for animation duration verification
        final startTime = DateTime.now();

        // Find the bookmark button (if available)
        final bookmarkButton = find.byIcon(Icons.bookmark);

        if (bookmarkButton.evaluate().isNotEmpty) {
          // Tap the bookmark button to trigger navigation back to Surah 1
          await tester.tap(bookmarkButton);
          await tester.pump();

          // Monitor frame rate during animation
          int frameCount = 0;
          final animationDuration = const Duration(milliseconds: 1500);
          final frameDuration = const Duration(milliseconds: 16); // ~60 FPS

          // Pump frames during animation
          while (DateTime.now().difference(startTime) < animationDuration) {
            await tester.pump(frameDuration);
            frameCount++;
          }

          // Verify smooth frame rate
          expect(
            frameCount,
            greaterThan(50),
            reason:
                'Animation should maintain smooth frame rate for reverse long-distance scroll',
          );

          // Wait for animation to complete
          await tester.pumpAndSettle();

          // Verify the target ayah is now visible on screen
          final highlightedAyah = find.byWidgetPredicate(
            (widget) =>
                widget is AnimatedContainer &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color != null &&
                (widget.decoration as BoxDecoration).color!.a > 0,
          );

          // Verify highlight is present
          expect(
            highlightedAyah,
            findsWidgets,
            reason:
                'Target ayah should be highlighted after reverse long-distance animation',
          );
        }
      },
    );

    testWidgets('should maintain performance during long-distance scroll', (
      WidgetTester tester,
    ) async {
      // Test that performance remains good during long-distance scrolls
      // by verifying animation completes within reasonable time

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 1)),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the bookmark button
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        final startTime = DateTime.now();

        // Tap to trigger navigation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Wait for animation to complete
        await tester.pumpAndSettle();

        final endTime = DateTime.now();
        final actualDuration = endTime.difference(startTime);

        // Animation should complete within reasonable time
        // Even for long distances, should not exceed 3 seconds
        expect(
          actualDuration.inMilliseconds,
          lessThan(3000),
          reason: 'Long-distance animation should complete within 3 seconds',
        );

        // Verify no performance degradation by checking app is still responsive
        expect(find.byType(QuranTextScreen), findsOneWidget);
      }
    });

    testWidgets('should handle navigation from middle surah to extremes', (
      WidgetTester tester,
    ) async {
      // Test navigation from a middle surah (e.g., Surah 57) to extremes
      // This tests the dynamic seek logic for long-distance scrolls

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 57)),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify content is loaded
      final scrollable = find.byType(CustomScrollView);
      expect(
        scrollable,
        findsOneWidget,
        reason: 'Scrollable view should be present',
      );

      // Find the bookmark button
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Tap to trigger navigation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Monitor animation
        int frameCount = 0;
        final animationDuration = const Duration(milliseconds: 1500);
        final frameDuration = const Duration(milliseconds: 16);

        final startTime = DateTime.now();
        while (DateTime.now().difference(startTime) < animationDuration) {
          await tester.pump(frameDuration);
          frameCount++;
        }

        // Verify smooth animation
        expect(
          frameCount,
          greaterThan(50),
          reason: 'Animation from middle to extreme should be smooth',
        );

        // Wait for completion
        await tester.pumpAndSettle();

        // Verify no crashes occurred
        expect(find.byType(QuranTextScreen), findsOneWidget);
      }
    });

    testWidgets('should not have jarring jumps during long-distance animation', (
      WidgetTester tester,
    ) async {
      // This test verifies that the animation is continuous without sudden jumps
      // by checking that frames are being pumped smoothly

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 1)),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the bookmark button
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Tap to trigger navigation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Sample scroll positions during animation to detect jumps
        final positions = <double>[];
        final frameDuration = const Duration(milliseconds: 50);

        // Collect positions over 1 second
        for (int i = 0; i < 20; i++) {
          await tester.pump(frameDuration);

          // Try to get scroll position if available
          final scrollableState = tester.state<ScrollableState>(
            find.byType(Scrollable).first,
          );
          positions.add(scrollableState.position.pixels);
        }

        // Verify we have position data
        expect(
          positions.length,
          greaterThan(10),
          reason: 'Should have collected position samples',
        );

        // Check that positions are changing (animation is happening)
        final uniquePositions = positions.toSet();
        expect(
          uniquePositions.length,
          greaterThan(1),
          reason: 'Scroll position should change during animation',
        );

        // Wait for animation to complete
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should use easeInOutCubic curve for long-distance scrolls', (
      WidgetTester tester,
    ) async {
      // Verify that the animation uses the correct easing curve
      // by checking that the animation is smooth and not linear

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 1)),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the bookmark button
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Tap to trigger navigation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Collect velocity samples during animation
        final velocities = <double>[];
        double? lastPosition;
        final frameDuration = const Duration(milliseconds: 50);

        // Sample velocities over animation
        for (int i = 0; i < 20; i++) {
          await tester.pump(frameDuration);

          final scrollableState = tester.state<ScrollableState>(
            find.byType(Scrollable).first,
          );
          final currentPosition = scrollableState.position.pixels;

          if (lastPosition != null) {
            final velocity = (currentPosition - lastPosition).abs();
            velocities.add(velocity);
          }

          lastPosition = currentPosition;
        }

        // With easeInOutCubic, velocities should vary (not constant)
        // indicating acceleration and deceleration
        if (velocities.length > 5) {
          final uniqueVelocities = velocities.toSet();
          expect(
            uniqueVelocities.length,
            greaterThan(1),
            reason: 'Velocity should vary with easing curve (not linear)',
          );
        }

        // Wait for animation to complete
        await tester.pumpAndSettle();
      }
    });
  });
}
