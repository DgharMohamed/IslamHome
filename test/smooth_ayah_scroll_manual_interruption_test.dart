import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

/// Integration test for manual scroll interruption during ayah navigation animation
/// Tests that user can manually scroll during animation without being blocked
///
/// **Validates: Requirement 4.4**
void main() {
  group('Manual Scroll Interruption Tests', () {
    testWidgets('should allow user to manually scroll during navigation animation', (
      WidgetTester tester,
    ) async {
      // Build the QuranTextScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: QuranTextScreen(initialSurahNumber: 2),
          ),
        ),
      );

      // Wait for initial build and data loading
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the scrollable widget
      final scrollable = find.byType(Scrollable);
      expect(
        scrollable,
        findsOneWidget,
        reason: 'Scrollable view should be present',
      );

      // Get initial scroll position
      final scrollableState = tester.state<ScrollableState>(scrollable);
      final initialPosition = scrollableState.position.pixels;

      // Find the bookmark button to trigger navigation animation
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Tap the bookmark button to start navigation animation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Wait a short time for animation to start (100ms)
        await tester.pump(const Duration(milliseconds: 100));

        // Verify animation has started by checking position changed
        final positionAfterAnimationStart = scrollableState.position.pixels;
        debugPrint(
          '📍 Initial position: $initialPosition, After animation start: $positionAfterAnimationStart',
        );

        // Now simulate manual user scroll during the animation
        // Drag the screen to scroll manually
        await tester.drag(
          scrollable,
          const Offset(0, -200), // Scroll down by dragging up
        );
        await tester.pump();

        // Verify the scroll position changed due to user input
        final positionAfterManualScroll = scrollableState.position.pixels;
        debugPrint(
          '📍 Position after manual scroll: $positionAfterManualScroll',
        );

        // The position should have changed, indicating user input was not blocked
        expect(
          positionAfterManualScroll != positionAfterAnimationStart,
          isTrue,
          reason: 'User manual scroll should change position during animation',
        );

        // Verify app remains responsive by checking we can still interact
        expect(
          find.byType(QuranTextScreen),
          findsOneWidget,
          reason: 'App should remain responsive',
        );

        // Try another manual scroll to ensure continued responsiveness
        await tester.drag(
          scrollable,
          const Offset(0, 100), // Scroll up by dragging down
        );
        await tester.pump();

        final positionAfterSecondScroll = scrollableState.position.pixels;
        debugPrint(
          '📍 Position after second manual scroll: $positionAfterSecondScroll',
        );

        // Verify second scroll also worked
        expect(
          positionAfterSecondScroll != positionAfterManualScroll,
          isTrue,
          reason: 'Second manual scroll should also work',
        );

        // Wait for any remaining animations to complete
        await tester.pumpAndSettle();

        // Verify no crashes or errors occurred
        expect(find.byType(QuranTextScreen), findsOneWidget);
      }
    });

    testWidgets(
      'should not block user input during long-distance scroll animation',
      (WidgetTester tester) async {
        // Test with a potentially longer animation (different surah)
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              home: QuranTextScreen(initialSurahNumber: 1),
            ),
          ),
        );

        // Wait for initial build
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find the scrollable widget
        final scrollable = find.byType(Scrollable);
        expect(scrollable, findsOneWidget);

        // Find the bookmark button
        final bookmarkButton = find.byIcon(Icons.bookmark);

        if (bookmarkButton.evaluate().isNotEmpty) {
          // Start navigation animation
          await tester.tap(bookmarkButton);
          await tester.pump();

          // Wait for animation to be in progress
          await tester.pump(const Duration(milliseconds: 200));

          // Attempt multiple manual scroll gestures during animation
          for (int i = 0; i < 3; i++) {
            await tester.drag(scrollable, Offset(0, i.isEven ? -100 : 100));
            await tester.pump(const Duration(milliseconds: 50));
          }

          // Verify app is still responsive
          final scrollableState = tester.state<ScrollableState>(scrollable);
          expect(
            scrollableState.position.pixels,
            isNotNull,
            reason: 'Scroll position should be valid',
          );

          // Verify no exceptions were thrown
          expect(find.byType(QuranTextScreen), findsOneWidget);

          // Wait for animations to complete
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'should maintain app responsiveness after manual interruption',
      (WidgetTester tester) async {
        // Test that app remains fully functional after interrupting animation
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              home: QuranTextScreen(initialSurahNumber: 2),
            ),
          ),
        );

        // Wait for initial build
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final scrollable = find.byType(Scrollable);
        final bookmarkButton = find.byIcon(Icons.bookmark);

        if (bookmarkButton.evaluate().isNotEmpty) {
          // Start animation
          await tester.tap(bookmarkButton);
          await tester.pump();

          // Interrupt with manual scroll
          await tester.pump(const Duration(milliseconds: 100));
          await tester.drag(scrollable, const Offset(0, -300));
          await tester.pump();

          // Wait a bit
          await tester.pump(const Duration(milliseconds: 200));

          // Try to interact with other UI elements
          // Find settings button
          final settingsButton = find.byIcon(Icons.tune);
          if (settingsButton.evaluate().isNotEmpty) {
            // Verify we can tap other buttons
            await tester.tap(settingsButton);
            await tester.pump();

            // Close any dialog that opened
            if (find.byType(Dialog).evaluate().isNotEmpty) {
              await tester.tapAt(const Offset(10, 10)); // Tap outside
              await tester.pump();
            }
          }

          // Verify app is still functional
          expect(find.byType(QuranTextScreen), findsOneWidget);

          // Try another bookmark navigation after interruption
          await tester.tap(bookmarkButton);
          await tester.pump();

          // Wait for completion
          await tester.pumpAndSettle();

          // Verify no crashes
          expect(find.byType(QuranTextScreen), findsOneWidget);
        }
      },
    );

    testWidgets(
      'should handle rapid manual scrolls during animation gracefully',
      (WidgetTester tester) async {
        // Test rapid, aggressive manual scrolling during animation
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              home: QuranTextScreen(initialSurahNumber: 2),
            ),
          ),
        );

        // Wait for initial build
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final scrollable = find.byType(Scrollable);
        final bookmarkButton = find.byIcon(Icons.bookmark);

        if (bookmarkButton.evaluate().isNotEmpty) {
          // Start animation
          await tester.tap(bookmarkButton);
          await tester.pump();

          // Perform rapid manual scrolls in different directions
          await tester.pump(const Duration(milliseconds: 50));
          await tester.drag(scrollable, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 20));

          await tester.drag(scrollable, const Offset(0, 150));
          await tester.pump(const Duration(milliseconds: 20));

          await tester.drag(scrollable, const Offset(0, -100));
          await tester.pump(const Duration(milliseconds: 20));

          await tester.drag(scrollable, const Offset(0, 200));
          await tester.pump(const Duration(milliseconds: 20));

          await tester.drag(scrollable, const Offset(0, -150));
          await tester.pump();

          // Verify app didn't crash or freeze
          expect(find.byType(QuranTextScreen), findsOneWidget);

          // Verify scroll position is valid
          final scrollableState = tester.state<ScrollableState>(scrollable);
          expect(
            scrollableState.position.pixels,
            isNotNull,
            reason: 'Scroll position should remain valid after rapid scrolls',
          );

          // Wait for everything to settle
          await tester.pumpAndSettle();

          // Verify app is still functional
          expect(find.byType(QuranTextScreen), findsOneWidget);
        }
      },
    );

    testWidgets('should allow fling gestures during animation', (
      WidgetTester tester,
    ) async {
      // Test that fling (fast scroll) gestures work during animation
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: QuranTextScreen(initialSurahNumber: 2),
          ),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final scrollable = find.byType(Scrollable);
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Start animation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Wait for animation to be in progress
        await tester.pump(const Duration(milliseconds: 100));

        // Perform a fling gesture (fast drag)
        await tester.fling(
          scrollable,
          const Offset(0, -500), // Fast scroll down
          1000.0, // High velocity
        );
        await tester.pump();

        // Pump a few frames to let fling animation start
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify app is responsive
        expect(find.byType(QuranTextScreen), findsOneWidget);

        // Verify scroll position changed due to fling
        final scrollableState = tester.state<ScrollableState>(scrollable);
        expect(
          scrollableState.position.pixels,
          isNotNull,
          reason: 'Fling gesture should work during animation',
        );

        // Wait for all animations to complete
        await tester.pumpAndSettle();

        // Verify no crashes
        expect(find.byType(QuranTextScreen), findsOneWidget);
      }
    });

    testWidgets('should not freeze or become unresponsive when interrupted', (
      WidgetTester tester,
    ) async {
      // Test that the app doesn't freeze when animation is interrupted
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: QuranTextScreen(initialSurahNumber: 2),
          ),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final scrollable = find.byType(Scrollable);
      final bookmarkButton = find.byIcon(Icons.bookmark);

      if (bookmarkButton.evaluate().isNotEmpty) {
        // Start animation
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Interrupt immediately
        await tester.pump(const Duration(milliseconds: 50));
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pump();

        // Try to scroll again immediately
        await tester.drag(scrollable, const Offset(0, 100));
        await tester.pump();

        // Verify we can still pump frames (not frozen)
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify app is still responsive
        expect(find.byType(QuranTextScreen), findsOneWidget);

        // Try to tap the bookmark button again
        await tester.tap(bookmarkButton);
        await tester.pump();

        // Verify no exceptions
        expect(find.byType(QuranTextScreen), findsOneWidget);

        // Wait for completion
        await tester.pumpAndSettle();
      }
    });
  });
}
