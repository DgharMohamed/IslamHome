// Feature: auto-hide-appbar
// Property 5: State Persistence During Scrolling
// **Validates: Requirements 2.4, 3.4**
//
// This test verifies that AutoHideAppBarBehavior correctly maintains state
// persistence during scrolling:
// - When AppBar is hidden and no upward scroll occurs, it remains hidden
// - When AppBar is visible at the top of content, it remains visible
// - State persists across multiple scroll events in the same direction
//
// Property being tested: For any hidden AppBar state, if no upward scroll
// occurs, the AppBar should remain hidden, and for any visible AppBar state
// at the top of content, the AppBar should remain visible.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_behavior.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_config.dart';

void main() {
  group('Property 5: State Persistence During Scrolling', () {
    testWidgets(
      'hidden AppBar remains hidden during continued downward scrolling',
      (WidgetTester tester) async {
        // Property test with multiple iterations
        final random = Random(200);
        const iterations = 20; // Reduced to avoid hitting scroll bounds

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(true);

          const config = AutoHideAppBarConfig(
            hideThreshold: 50.0,
            showThreshold: 20.0,
          );

          final behavior = AutoHideAppBarBehavior(
            scrollController: scrollController,
            isAppBarVisible: isAppBarVisible,
            config: config,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  controller: scrollController,
                  itemCount: 100,
                  itemBuilder: (context, index) =>
                      SizedBox(height: 100, child: Text('Item $index')),
                ),
              ),
            ),
          );

          behavior.initialize();
          await tester.pumpAndSettle();

          // First, hide the AppBar by scrolling down past threshold
          // Use a larger scroll distance to ensure we exceed the threshold
          await tester.drag(find.byType(ListView), const Offset(0, -150));
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isFalse,
            reason: 'AppBar should be hidden after initial scroll',
          );

          // Continue scrolling down multiple times
          final numScrolls = 2 + random.nextInt(5); // 2-6 additional scrolls
          for (int j = 0; j < numScrolls; j++) {
            final scrollDistance = 20.0 + random.nextDouble() * 80.0;
            await tester.drag(
              find.byType(ListView),
              Offset(0, -scrollDistance),
            );
            await tester.pump();

            expect(
              isAppBarVisible.value,
              isFalse,
              reason:
                  'AppBar should remain hidden during continued downward scroll '
                  '(scroll $j of $numScrolls, distance: $scrollDistance) - iteration $i',
            );
          }

          await tester.pumpAndSettle();

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets(
      'hidden AppBar remains hidden when scrolling down below threshold',
      (WidgetTester tester) async {
        final random = Random(201);
        const iterations = 20; // Reduced to avoid hitting scroll bounds

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(true);

          const config = AutoHideAppBarConfig(
            hideThreshold: 50.0,
            showThreshold: 20.0,
          );

          final behavior = AutoHideAppBarBehavior(
            scrollController: scrollController,
            isAppBarVisible: isAppBarVisible,
            config: config,
          );

          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey('iteration_$i'),
              home: Scaffold(
                body: ListView.builder(
                  key: ValueKey('listview_$i'),
                  controller: scrollController,
                  itemCount: 100,
                  itemBuilder: (context, index) =>
                      SizedBox(height: 100, child: Text('Item $index')),
                ),
              ),
            ),
          );

          behavior.initialize();
          await tester.pumpAndSettle();

          // Hide the AppBar
          await tester.drag(find.byType(ListView), const Offset(0, -150));
          await tester.pumpAndSettle();

          expect(isAppBarVisible.value, isFalse);

          // Perform small downward scrolls that don't reach any threshold
          final numSmallScrolls = 2 + random.nextInt(4);
          for (int j = 0; j < numSmallScrolls; j++) {
            final smallScroll = 5.0 + random.nextDouble() * 10.0;
            await tester.drag(find.byType(ListView), Offset(0, -smallScroll));
            await tester.pump();
          }
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isFalse,
            reason:
                'AppBar should remain hidden after $numSmallScrolls small downward scrolls - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets('visible AppBar remains visible at top of content', (
      WidgetTester tester,
    ) async {
      final random = Random(202);
      const iterations = 20; // Reduced to avoid hitting scroll bounds

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        const config = AutoHideAppBarConfig(
          hideThreshold: 50.0,
          showThreshold: 20.0,
        );

        final behavior = AutoHideAppBarBehavior(
          scrollController: scrollController,
          isAppBarVisible: isAppBarVisible,
          config: config,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) =>
                    SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Verify AppBar is visible at top
        expect(
          isAppBarVisible.value,
          isTrue,
          reason: 'AppBar should be visible at top initially',
        );

        // Try to scroll up (which should have no effect at top)
        final numAttempts = 1 + random.nextInt(3);
        for (int j = 0; j < numAttempts; j++) {
          final upwardScroll = 10.0 + random.nextDouble() * 30.0;
          await tester.drag(find.byType(ListView), Offset(0, upwardScroll));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isTrue,
          reason:
              'AppBar should remain visible at top after $numAttempts upward scroll attempts - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets(
      'visible AppBar remains visible during small downward scrolls below threshold',
      (WidgetTester tester) async {
        final random = Random(203);
        const iterations = 20; // Reduced to avoid hitting scroll bounds

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(true);

          final hideThreshold = 50.0 + random.nextDouble() * 30.0;
          final config = AutoHideAppBarConfig(
            hideThreshold: hideThreshold,
            showThreshold: 20.0,
          );

          final behavior = AutoHideAppBarBehavior(
            scrollController: scrollController,
            isAppBarVisible: isAppBarVisible,
            config: config,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  controller: scrollController,
                  itemCount: 100,
                  itemBuilder: (context, index) =>
                      SizedBox(height: 100, child: Text('Item $index')),
                ),
              ),
            ),
          );

          behavior.initialize();
          await tester.pumpAndSettle();

          // Perform multiple small scrolls that don't accumulate to threshold
          final numScrolls = 2 + random.nextInt(4);
          for (int j = 0; j < numScrolls; j++) {
            // Each scroll is well below threshold
            final smallScroll = 5.0 + random.nextDouble() * 10.0;
            await tester.drag(find.byType(ListView), Offset(0, -smallScroll));
            await tester.pump();

            // Scroll back up slightly to reset accumulation
            await tester.drag(
              find.byType(ListView),
              Offset(0, smallScroll / 2),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isTrue,
            reason:
                'AppBar should remain visible after $numScrolls small scrolls '
                'with direction changes (threshold: $hideThreshold) - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets('state persists correctly after hide-show-hide sequence', (
      WidgetTester tester,
    ) async {
      final random = Random(204);
      const iterations = 20; // Reduced to avoid hitting scroll bounds

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        const config = AutoHideAppBarConfig(
          hideThreshold: 50.0,
          showThreshold: 20.0,
        );

        final behavior = AutoHideAppBarBehavior(
          scrollController: scrollController,
          isAppBarVisible: isAppBarVisible,
          config: config,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) =>
                    SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // 1. Hide the AppBar
        await tester.drag(find.byType(ListView), const Offset(0, -150));
        await tester.pumpAndSettle();
        expect(isAppBarVisible.value, isFalse, reason: 'Should be hidden');

        // 2. Continue scrolling down - should remain hidden
        final additionalDown = 30.0 + random.nextDouble() * 50.0;
        await tester.drag(find.byType(ListView), Offset(0, -additionalDown));
        await tester.pumpAndSettle();
        expect(
          isAppBarVisible.value,
          isFalse,
          reason: 'Should remain hidden after additional downward scroll',
        );

        // 3. Show the AppBar by scrolling up
        await tester.drag(find.byType(ListView), const Offset(0, 50));
        await tester.pumpAndSettle();
        expect(isAppBarVisible.value, isTrue, reason: 'Should be visible');

        // 4. Hide again
        await tester.drag(find.byType(ListView), const Offset(0, -150));
        await tester.pumpAndSettle();
        expect(
          isAppBarVisible.value,
          isFalse,
          reason: 'Should be hidden again',
        );

        // 5. Continue scrolling down - should remain hidden
        final finalDown = 20.0 + random.nextDouble() * 40.0;
        await tester.drag(find.byType(ListView), Offset(0, -finalDown));
        await tester.pumpAndSettle();
        expect(
          isAppBarVisible.value,
          isFalse,
          reason:
              'Should remain hidden after final downward scroll - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets('hidden state persists when pausing between scrolls', (
      WidgetTester tester,
    ) async {
      final random = Random(205);
      const iterations = 20; // Reduced to avoid hitting scroll bounds

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        const config = AutoHideAppBarConfig(
          hideThreshold: 50.0,
          showThreshold: 20.0,
        );

        final behavior = AutoHideAppBarBehavior(
          scrollController: scrollController,
          isAppBarVisible: isAppBarVisible,
          config: config,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) =>
                    SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Hide the AppBar
        await tester.drag(find.byType(ListView), const Offset(0, -150));
        await tester.pumpAndSettle();
        expect(isAppBarVisible.value, isFalse);

        // Pause (simulate user stopping scrolling)
        await tester.pump(Duration(milliseconds: 100 + random.nextInt(400)));

        // Verify state persisted during pause
        expect(
          isAppBarVisible.value,
          isFalse,
          reason: 'AppBar should remain hidden during pause',
        );

        // Continue scrolling down after pause
        final scrollAfterPause = 30.0 + random.nextDouble() * 50.0;
        await tester.drag(find.byType(ListView), Offset(0, -scrollAfterPause));
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isFalse,
          reason:
              'AppBar should remain hidden after pause and continued scroll - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets('visible state persists at top boundary across multiple checks', (
      WidgetTester tester,
    ) async {
      const iterations = 20; // Reduced to avoid hitting scroll bounds

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        const config = AutoHideAppBarConfig(
          hideThreshold: 50.0,
          showThreshold: 20.0,
        );

        final behavior = AutoHideAppBarBehavior(
          scrollController: scrollController,
          isAppBarVisible: isAppBarVisible,
          config: config,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) =>
                    SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Scroll down a bit
        await tester.drag(find.byType(ListView), const Offset(0, -30));
        await tester.pumpAndSettle();

        // Scroll back to top
        await tester.drag(find.byType(ListView), const Offset(0, 50));
        await tester.pumpAndSettle();

        // Verify at top and visible
        expect(
          scrollController.offset,
          lessThanOrEqualTo(0.0),
          reason: 'Should be at top',
        );
        expect(
          isAppBarVisible.value,
          isTrue,
          reason: 'AppBar should be visible at top',
        );

        // Try multiple upward scroll attempts at top
        for (int j = 0; j < 3; j++) {
          await tester.drag(find.byType(ListView), const Offset(0, 20));
          await tester.pump();

          expect(
            isAppBarVisible.value,
            isTrue,
            reason:
                'AppBar should remain visible at top (attempt $j) - iteration $i',
          );
        }

        await tester.pumpAndSettle();

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });
  });
}
