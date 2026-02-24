// Feature: auto-hide-appbar
// Property 1: Scroll Direction Detection
// **Validates: Requirements 1.1, 1.2**
//
// This test verifies that AutoHideAppBarBehavior correctly detects scroll
// direction based on scroll offset changes:
// - When offset increases (scrolling down), downward direction is detected
// - When offset decreases (scrolling up), upward direction is detected
//
// Property being tested: For any sequence of scroll offset changes,
// when the offset increases (scrolling down), the Scroll_Controller should
// detect downward direction, and when the offset decreases (scrolling up),
// the Scroll_Controller should detect upward direction.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_behavior.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_config.dart';

void main() {
  group('Property 1: Scroll Direction Detection', () {
    testWidgets(
      'scrolling down (increasing offset) hides AppBar after threshold',
      (WidgetTester tester) async {
        // Property test with multiple iterations
        final random = Random(42);
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(true);

          final hideThreshold = 20.0 + random.nextDouble() * 80.0;
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

          final scrollDistance = hideThreshold + random.nextDouble() * 50.0;

          await tester.drag(find.byType(ListView), Offset(0, -scrollDistance));
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isFalse,
            reason:
                'AppBar should hide when scrolling down $scrollDistance pixels '
                '(threshold: $hideThreshold) - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets(
      'scrolling up (decreasing offset) shows AppBar after threshold',
      (WidgetTester tester) async {
        final random = Random(43);
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(false);

          final showThreshold = 10.0 + random.nextDouble() * 40.0;
          final config = AutoHideAppBarConfig(
            hideThreshold: 50.0,
            showThreshold: showThreshold,
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

          await tester.drag(find.byType(ListView), const Offset(0, -200));
          await tester.pumpAndSettle();

          final scrollDistance = showThreshold + random.nextDouble() * 30.0;

          await tester.drag(find.byType(ListView), Offset(0, scrollDistance));
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isTrue,
            reason:
                'AppBar should show when scrolling up $scrollDistance pixels '
                '(threshold: $showThreshold) - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets(
      'small scroll movements below threshold do not trigger visibility change',
      (WidgetTester tester) async {
        final random = Random(44);
        const iterations = 50;

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(true);

          const hideThreshold = 50.0;
          const config = AutoHideAppBarConfig(
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

          final smallScrollDown =
              5.0 + random.nextDouble() * (hideThreshold - 10);
          await tester.drag(find.byType(ListView), Offset(0, -smallScrollDown));
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isTrue,
            reason:
                'AppBar should stay visible when scrolling down only '
                '$smallScrollDown pixels (below threshold $hideThreshold) - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets('direction changes reset accumulation', (
      WidgetTester tester,
    ) async {
      const iterations = 50;

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

        await tester.drag(find.byType(ListView), const Offset(0, -30));
        await tester.pumpAndSettle();
        expect(
          isAppBarVisible.value,
          isTrue,
          reason: 'Should stay visible after small down scroll',
        );

        await tester.drag(find.byType(ListView), const Offset(0, 15));
        await tester.pumpAndSettle();
        expect(
          isAppBarVisible.value,
          isTrue,
          reason: 'Should stay visible after direction change',
        );

        await tester.drag(find.byType(ListView), const Offset(0, -60));
        await tester.pumpAndSettle();
        expect(
          isAppBarVisible.value,
          isFalse,
          reason: 'Should hide after large down scroll - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets('consecutive scrolls in same direction accumulate', (
      WidgetTester tester,
    ) async {
      final random = Random(47);
      const iterations = 50;

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

        final numScrolls = 3 + random.nextInt(5);
        final scrollAmount = 60.0 / numScrolls;

        for (int j = 0; j < numScrolls; j++) {
          await tester.drag(find.byType(ListView), Offset(0, -scrollAmount));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isFalse,
          reason:
              'AppBar should hide after $numScrolls consecutive down scrolls '
              'totaling 60.0 pixels - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });
  });
}
