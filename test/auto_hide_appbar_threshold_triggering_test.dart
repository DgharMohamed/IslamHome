// Feature: auto-hide-appbar
// Property 2: Threshold-Based Action Triggering
// **Validates: Requirements 1.3, 1.4**
//
// This test verifies that AutoHideAppBarBehavior correctly triggers hide/show
// actions based on configured thresholds:
// - When scroll distance exceeds hideThreshold while scrolling down, hide action triggers
// - When scroll distance exceeds showThreshold while scrolling up, show action triggers
// - Scroll distances below thresholds do not trigger actions
//
// Property being tested: For any scroll distance that exceeds the Hide_Threshold
// while scrolling down, the hide action should be triggered, and for any scroll
// distance that exceeds the Show_Threshold while scrolling up, the show action
// should be triggered.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_behavior.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_config.dart';

void main() {
  group('Property 2: Threshold-Based Action Triggering', () {
    testWidgets('hide action triggers when scroll distance exceeds hideThreshold', (
      WidgetTester tester,
    ) async {
      // Property test with multiple iterations
      final random = Random(100);
      const iterations = 100;

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        // Generate random threshold between 20 and 100 pixels
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

        // Scroll distance that exceeds threshold by a random amount (1-50 pixels)
        final scrollDistance = hideThreshold + 1.0 + random.nextDouble() * 49.0;

        await tester.drag(find.byType(ListView), Offset(0, -scrollDistance));
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isFalse,
          reason:
              'Hide action should trigger when scrolling down $scrollDistance pixels '
              '(exceeds hideThreshold: $hideThreshold) - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets('show action triggers when scroll distance exceeds showThreshold', (
      WidgetTester tester,
    ) async {
      final random = Random(101);
      const iterations = 100;

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(false);

        // Generate random threshold between 10 and 50 pixels
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

        // First scroll down to hide the AppBar
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();

        // Verify AppBar is hidden
        expect(isAppBarVisible.value, isFalse);

        // Scroll distance that exceeds showThreshold by a random amount (1-30 pixels)
        final scrollDistance = showThreshold + 1.0 + random.nextDouble() * 29.0;

        await tester.drag(find.byType(ListView), Offset(0, scrollDistance));
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isTrue,
          reason:
              'Show action should trigger when scrolling up $scrollDistance pixels '
              '(exceeds showThreshold: $showThreshold) - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets(
      'hide action does not trigger when scroll distance is below hideThreshold',
      (WidgetTester tester) async {
        final random = Random(102);
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(true);

          // Generate random threshold between 30 and 80 pixels
          final hideThreshold = 30.0 + random.nextDouble() * 50.0;
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

          // Scroll distance that is below threshold by at least 5 pixels
          final scrollDistance =
              5.0 + random.nextDouble() * (hideThreshold - 10.0);

          await tester.drag(find.byType(ListView), Offset(0, -scrollDistance));
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isTrue,
            reason:
                'Hide action should NOT trigger when scrolling down only $scrollDistance pixels '
                '(below hideThreshold: $hideThreshold) - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets(
      'show action does not trigger when scroll distance is below showThreshold',
      (WidgetTester tester) async {
        final random = Random(103);
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          final scrollController = ScrollController();
          final isAppBarVisible = ValueNotifier<bool>(false);

          // Generate random threshold between 15 and 40 pixels
          final showThreshold = 15.0 + random.nextDouble() * 25.0;
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

          // First scroll down to hide the AppBar
          await tester.drag(find.byType(ListView), const Offset(0, -200));
          await tester.pumpAndSettle();

          // Verify AppBar is hidden
          expect(isAppBarVisible.value, isFalse);

          // Scroll distance that is below showThreshold by at least 3 pixels
          final scrollDistance =
              3.0 + random.nextDouble() * (showThreshold - 6.0);

          await tester.drag(find.byType(ListView), Offset(0, scrollDistance));
          await tester.pumpAndSettle();

          expect(
            isAppBarVisible.value,
            isFalse,
            reason:
                'Show action should NOT trigger when scrolling up only $scrollDistance pixels '
                '(below showThreshold: $showThreshold) - iteration $i',
          );

          behavior.dispose();
          scrollController.dispose();
          isAppBarVisible.dispose();
        }
      },
    );

    testWidgets('threshold triggering works with accumulated scroll distances', (
      WidgetTester tester,
    ) async {
      final random = Random(104);
      const iterations = 50;

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

        // Perform multiple small scrolls that accumulate to exceed threshold
        final numScrolls = 3 + random.nextInt(4); // 3-6 scrolls
        final totalDistance = hideThreshold + 10.0 + random.nextDouble() * 20.0;
        final scrollAmount = totalDistance / numScrolls;

        for (int j = 0; j < numScrolls; j++) {
          await tester.drag(find.byType(ListView), Offset(0, -scrollAmount));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isFalse,
          reason:
              'Hide action should trigger when $numScrolls consecutive scrolls '
              'accumulate to $totalDistance pixels (exceeds hideThreshold: $hideThreshold) - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets('threshold boundary value triggers action', (
      WidgetTester tester,
    ) async {
      final random = Random(105);
      const iterations = 50;

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        // Generate random threshold
        final hideThreshold = 30.0 + random.nextDouble() * 50.0;
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

        // Scroll at or slightly above threshold to ensure it triggers
        // (adding small buffer to account for gesture simulation precision)
        final scrollDistance = hideThreshold + 0.5;
        await tester.drag(find.byType(ListView), Offset(0, -scrollDistance));
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isFalse,
          reason:
              'Hide action should trigger when scrolling at threshold boundary '
              '($scrollDistance pixels, hideThreshold: $hideThreshold) - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });

    testWidgets('different hide and show thresholds work independently', (
      WidgetTester tester,
    ) async {
      final random = Random(106);
      const iterations = 50;

      for (int i = 0; i < iterations; i++) {
        final scrollController = ScrollController();
        final isAppBarVisible = ValueNotifier<bool>(true);

        // Generate different thresholds
        final hideThreshold = 50.0 + random.nextDouble() * 30.0;
        final showThreshold = 15.0 + random.nextDouble() * 20.0;
        final config = AutoHideAppBarConfig(
          hideThreshold: hideThreshold,
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

        // Test hide threshold
        final hideDistance = hideThreshold + 5.0;
        await tester.drag(find.byType(ListView), Offset(0, -hideDistance));
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isFalse,
          reason: 'Should hide after exceeding hideThreshold',
        );

        // Test show threshold
        final showDistance = showThreshold + 5.0;
        await tester.drag(find.byType(ListView), Offset(0, showDistance));
        await tester.pumpAndSettle();

        expect(
          isAppBarVisible.value,
          isTrue,
          reason:
              'Should show after exceeding showThreshold ($showThreshold) '
              'with hideThreshold ($hideThreshold) - iteration $i',
        );

        behavior.dispose();
        scrollController.dispose();
        isAppBarVisible.dispose();
      }
    });
  });
}
