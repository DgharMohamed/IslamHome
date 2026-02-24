// Edge case unit tests for AutoHideAppBarBehavior
// Tests Requirements 7.1, 7.2, 7.3: content shorter than screen, top boundary, bottom boundary

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/presentation/widgets/auto_hide_appbar/auto_hide_appbar_behavior.dart';

void main() {
  group('AutoHideAppBarBehavior - Edge Cases', () {
    late ScrollController scrollController;
    late ValueNotifier<bool> isAppBarVisible;
    late AutoHideAppBarBehavior behavior;

    setUp(() {
      scrollController = ScrollController();
      isAppBarVisible = ValueNotifier<bool>(true);
      behavior = AutoHideAppBarBehavior(
        scrollController: scrollController,
        isAppBarVisible: isAppBarVisible,
      );
    });

    tearDown(() {
      behavior.dispose();
      scrollController.dispose();
      isAppBarVisible.dispose();
    });

    group('Content shorter than screen height (Requirement 7.1)', () {
      testWidgets('AppBar remains visible when content is not scrollable', (
        WidgetTester tester,
      ) async {
        // Arrange: Create a widget with content shorter than screen
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100, // Short content
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Act: Attempt to scroll down (should not scroll since content is short)
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
        await tester.pumpAndSettle();

        // Assert: AppBar should remain visible
        expect(isAppBarVisible.value, isTrue);
        expect(scrollController.offset, equals(0.0));
      });

      testWidgets(
        'AppBar remains visible when maxScrollExtent is zero or negative',
        (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: Container(color: const Color(0xFF000000)),
                    ),
                  ),
                ],
              ),
            ),
          );

          behavior.initialize();
          await tester.pumpAndSettle();

          // Assert: maxScrollExtent should be 0 or negative for short content
          expect(
            scrollController.position.maxScrollExtent,
            lessThanOrEqualTo(0),
          );
          expect(isAppBarVisible.value, isTrue);
        },
      );
    });

    group('At top boundary - offset = 0 (Requirement 7.2)', () {
      testWidgets('AppBar remains visible at top boundary', (
        WidgetTester tester,
      ) async {
        // Arrange: Create scrollable content
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000, // Tall content
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Act: Try to scroll up when already at top
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, 100), // Scroll up
        );
        await tester.pumpAndSettle();

        // Assert: Should remain at offset 0 and AppBar visible
        expect(scrollController.offset, equals(0.0));
        expect(isAppBarVisible.value, isTrue);
      });

      testWidgets('AppBar becomes visible when scrolling back to top', (
        WidgetTester tester,
      ) async {
        // Arrange: Create scrollable content and scroll down first
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Scroll down to hide AppBar
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();

        // Verify AppBar is hidden
        expect(isAppBarVisible.value, isFalse);

        // Act: Scroll back to top
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
        await tester.pumpAndSettle();

        // Assert: AppBar should be visible at top
        expect(scrollController.offset, equals(0.0));
        expect(isAppBarVisible.value, isTrue);
      });

      testWidgets('AppBar stays visible when offset is exactly 0', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Assert: At initialization, offset should be 0
        expect(scrollController.offset, equals(0.0));
        expect(isAppBarVisible.value, isTrue);

        // Act: Manually set offset to 0 (simulating programmatic scroll to top)
        scrollController.jumpTo(0.0);
        await tester.pumpAndSettle();

        // Assert: AppBar should remain visible
        expect(scrollController.offset, equals(0.0));
        expect(isAppBarVisible.value, isTrue);
      });
    });

    group('At bottom boundary - max scroll extent (Requirement 7.3)', () {
      testWidgets('AppBar maintains visibility state at bottom boundary', (
        WidgetTester tester,
      ) async {
        // Arrange: Create scrollable content
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Act: Scroll to bottom
        final maxExtent = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(maxExtent);
        await tester.pumpAndSettle();

        // Assert: Should be at max extent
        expect(scrollController.offset, equals(maxExtent));

        // AppBar should be hidden (scrolled down to bottom)
        expect(isAppBarVisible.value, isFalse);

        // Act: Try to scroll down more (should not move)
        final offsetBeforeDrag = scrollController.offset;
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
        await tester.pumpAndSettle();

        // Assert: Should remain at max extent, AppBar state unchanged
        expect(scrollController.offset, equals(offsetBeforeDrag));
        expect(isAppBarVisible.value, isFalse);
      });

      testWidgets('AppBar can be shown when scrolling up from bottom', (
        WidgetTester tester,
      ) async {
        // Arrange: Create scrollable content and scroll to bottom
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Scroll to bottom
        final maxExtent = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(maxExtent);
        await tester.pumpAndSettle();

        // Verify at bottom with AppBar hidden
        expect(scrollController.offset, equals(maxExtent));
        expect(isAppBarVisible.value, isFalse);

        // Act: Scroll up from bottom
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, 100), // Scroll up
        );
        await tester.pumpAndSettle();

        // Assert: AppBar should become visible
        expect(isAppBarVisible.value, isTrue);
        expect(scrollController.offset, lessThan(maxExtent));
      });

      testWidgets('AppBar remains visible if already visible at bottom', (
        WidgetTester tester,
      ) async {
        // Arrange: Create scrollable content
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Scroll down a bit, then scroll up to show AppBar
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(CustomScrollView), const Offset(0, 100));
        await tester.pumpAndSettle();

        // Verify AppBar is visible
        expect(isAppBarVisible.value, isTrue);

        // Act: Continue scrolling down to bottom
        final maxExtent = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(maxExtent);
        await tester.pumpAndSettle();

        // Assert: At bottom, AppBar should be hidden (scrolled down)
        expect(scrollController.offset, equals(maxExtent));
        expect(isAppBarVisible.value, isFalse);
      });
    });

    group('Boundary value tests', () {
      testWidgets('Handles negative offset gracefully', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        // Act: Try to set negative offset (should be clamped to 0)
        scrollController.jumpTo(-10.0);
        await tester.pumpAndSettle();

        // Assert: Should be clamped to 0, AppBar visible
        expect(scrollController.offset, equals(0.0));
        expect(isAppBarVisible.value, isTrue);
      });

      testWidgets('Handles offset beyond maxScrollExtent', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2000,
                    child: Container(color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
        );

        behavior.initialize();
        await tester.pumpAndSettle();

        final maxExtent = scrollController.position.maxScrollExtent;

        // Act: Try to set offset beyond max (should be clamped)
        scrollController.jumpTo(maxExtent + 100);
        await tester.pumpAndSettle();

        // Assert: Should be clamped to maxExtent
        expect(scrollController.offset, equals(maxExtent));
      });
    });
  });
}
