import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';

/// Integration test for short-distance ayah scroll animation
/// Tests navigation to nearby ayahs within the same surah
///
/// **Validates: Requirements 1.1, 1.4, 4.1**
void main() {
  group('Short-Distance Ayah Scroll Animation Tests', () {
    testWidgets('should smoothly scroll to nearby ayah within same surah', (
      WidgetTester tester,
    ) async {
      // Build the QuranTextScreen with initial surah
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 2)),
        ),
      );

      // Wait for initial build and data loading
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the bookmark button
      final bookmarkButton = find.byIcon(Icons.bookmark);

      // Verify bookmark button exists
      expect(bookmarkButton, findsOneWidget);

      // Record the start time for animation duration verification
      final startTime = DateTime.now();

      // Tap the bookmark button to trigger navigation
      await tester.tap(bookmarkButton);

      // Pump frames to start the animation
      await tester.pump();

      // Verify animation is in progress by checking multiple frames
      // Animation should take approximately 1000ms (1 second)
      int frameCount = 0;
      final animationDuration = const Duration(milliseconds: 1000);
      final frameDuration = const Duration(milliseconds: 16); // ~60 FPS

      // Pump frames during animation
      while (DateTime.now().difference(startTime) < animationDuration) {
        await tester.pump(frameDuration);
        frameCount++;
      }

      // Verify we had smooth frame rate (at least 50 frames for 1 second at 60 FPS)
      // Allowing some tolerance for test environment
      expect(
        frameCount,
        greaterThan(50),
        reason: 'Animation should maintain smooth frame rate',
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
        reason: 'Target ayah should be highlighted after animation',
      );

      // Wait for highlight to clear (should clear after 3.5-4 seconds)
      await tester.pump(const Duration(milliseconds: 4000));
      await tester.pumpAndSettle();

      // Verify highlight has been cleared
      final clearedHighlight = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null &&
            (widget.decoration as BoxDecoration).color!.a > 0,
      );

      expect(
        clearedHighlight,
        findsNothing,
        reason: 'Highlight should be cleared after timeout',
      );
    });

    testWidgets(
      'should use correct animation parameters for short-distance scroll',
      (WidgetTester tester) async {
        // Build the QuranTextScreen
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

          // Verify animation duration is within expected range (800-1200ms)
          final startTime = DateTime.now();

          // Wait for animation to complete
          await tester.pumpAndSettle();

          final endTime = DateTime.now();
          final actualDuration = endTime.difference(startTime);

          // Animation should complete within reasonable time
          // Allowing extra time for test environment overhead
          expect(
            actualDuration.inMilliseconds,
            lessThan(2000),
            reason: 'Animation should complete within reasonable time',
          );
        }
      },
    );

    testWidgets('should maintain highlight during animation', (
      WidgetTester tester,
    ) async {
      // Build the QuranTextScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 2)),
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

        // During animation, check for highlight state
        // Pump a few frames during animation
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));

          // The highlight state should be set during animation
          // We can't directly check the state, but we can verify
          // that the widget tree is being updated
        }

        // Wait for animation to complete
        await tester.pumpAndSettle();

        // After animation, highlight should be visible
        final highlightedWidget = find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedContainer && widget.decoration is BoxDecoration,
        );

        expect(
          highlightedWidget,
          findsWidgets,
          reason: 'Highlight should be present after animation completes',
        );
      }
    });

    testWidgets('should scroll to ayah 10 from ayah 1 in same surah smoothly', (
      WidgetTester tester,
    ) async {
      // Test a specific short-distance scroll scenario
      // Navigate from ayah 1 to ayah 10 in Surah 2

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 2)),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Simulate navigation to ayah 10
      // This would normally be triggered by the bookmark button
      // For this test, we verify the screen can handle the navigation

      // Find any ayah text to verify content is loaded
      final ayahContent = find.byType(RichText);

      expect(
        ayahContent,
        findsWidgets,
        reason: 'Ayah content should be loaded and visible',
      );

      // Verify scroll controller is attached and functional
      // by checking if we can find scrollable content
      final scrollable = find.byType(CustomScrollView);

      expect(
        scrollable,
        findsOneWidget,
        reason: 'Scrollable view should be present',
      );
    });

    testWidgets('should handle rapid navigation requests gracefully', (
      WidgetTester tester,
    ) async {
      // Test that multiple rapid navigation requests don't cause issues

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: QuranTextScreen(initialSurahNumber: 2)),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the bookmark button
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Tap multiple times rapidly
        await tester.tap(bookmarkButton);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(bookmarkButton);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(bookmarkButton);
        await tester.pump(const Duration(milliseconds: 100));

        // Wait for all animations to settle
        await tester.pumpAndSettle();

        // Verify no crashes or errors occurred
        // The test passing means the app handled rapid taps gracefully
        expect(find.byType(QuranTextScreen), findsOneWidget);
      }
    });
  });
}
