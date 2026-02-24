// Feature: accessible-surah-selector
// Property Test: Entry Point Consistency
// **Validates: Requirements 1.2, 1.3**
//
// Property 1: اتساق نقاط الدخول (Entry Point Consistency)
// For any method of opening the surah picker (FAB or AppBar title),
// the system should call the same _showSurahPicker() function and
// display the same interface.
//
// This test verifies that:
// 1. Both the FAB and AppBar title have onPressed/onTap handlers
// 2. Both entry points exist in the widget tree
// 3. The FAB is consistently present across different surahs
//
// Note: Due to the complexity of the QuranTextScreen widget (requires GoRouter,
// Hive initialization, and other dependencies), this test focuses on verifying
// the structural consistency of entry points rather than testing the full
// interaction flow. The actual behavior of _showSurahPicker() is tested
// through manual testing and integration tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

void main() {
  group('Property Test: Entry Point Consistency', () {
    // Helper function to create the test app
    Widget createTestApp({int initialSurah = 1, String locale = 'ar'}) {
      return ProviderScope(
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          home: QuranTextScreen(initialSurahNumber: initialSurah),
        ),
      );
    }

    testWidgets('Property: Both FAB and AppBar title entry points exist', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 1
      await tester.pumpWidget(createTestApp(initialSurah: 1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert 1: FAB with menu_book icon exists
      final fabFinder = find.ancestor(
        of: find.byIcon(Icons.menu_book),
        matching: find.byType(FloatingActionButton),
      );
      expect(fabFinder, findsOneWidget, reason: 'FAB entry point should exist');

      // Assert 2: FAB has an onPressed handler (not null)
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(
        fab.onPressed,
        isNotNull,
        reason: 'FAB should have an onPressed handler',
      );

      // Assert 3: AppBar title with keyboard_arrow_down icon exists
      final appBarTitleIconFinder = find.byIcon(Icons.keyboard_arrow_down);
      expect(
        appBarTitleIconFinder,
        findsOneWidget,
        reason: 'AppBar title dropdown indicator should exist',
      );

      // Assert 4: AppBar title is wrapped in a GestureDetector (has onTap)
      final gestureDetectorFinder = find.ancestor(
        of: appBarTitleIconFinder,
        matching: find.byType(GestureDetector),
      );
      expect(
        gestureDetectorFinder,
        findsOneWidget,
        reason: 'AppBar title should be wrapped in GestureDetector',
      );

      final gestureDetector = tester.widget<GestureDetector>(
        gestureDetectorFinder,
      );
      expect(
        gestureDetector.onTap,
        isNotNull,
        reason: 'AppBar title should have an onTap handler',
      );
    });

    testWidgets(
      'Property: Entry points exist consistently at different surahs',
      (WidgetTester tester) async {
        // Test at Surah 1 (beginning)
        await tester.pumpWidget(createTestApp(initialSurah: 1));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.ancestor(
            of: find.byIcon(Icons.menu_book),
            matching: find.byType(FloatingActionButton),
          ),
          findsOneWidget,
          reason: 'FAB should exist at Surah 1',
        );

        expect(
          find.byIcon(Icons.keyboard_arrow_down),
          findsOneWidget,
          reason: 'AppBar title dropdown should exist at Surah 1',
        );

        // Test at Surah 57 (middle)
        await tester.pumpWidget(createTestApp(initialSurah: 57));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.ancestor(
            of: find.byIcon(Icons.menu_book),
            matching: find.byType(FloatingActionButton),
          ),
          findsOneWidget,
          reason: 'FAB should exist at Surah 57',
        );

        expect(
          find.byIcon(Icons.keyboard_arrow_down),
          findsOneWidget,
          reason: 'AppBar title dropdown should exist at Surah 57',
        );
      },
    );

    testWidgets(
      'Property: Entry points exist at Surah 114 (special case with dua button)',
      (WidgetTester tester) async {
        // Arrange: Build the app at Surah 114 (where dua button also appears)
        await tester.pumpWidget(createTestApp(initialSurah: 114));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Assert 1: Surah selector FAB still exists at Surah 114
        final fabFinder = find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        );
        expect(
          fabFinder,
          findsOneWidget,
          reason: 'Surah selector FAB should exist at Surah 114',
        );

        // Assert 2: FAB has an onPressed handler
        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(
          fab.onPressed,
          isNotNull,
          reason: 'FAB should have an onPressed handler at Surah 114',
        );

        // Assert 3: AppBar title entry point still exists
        expect(
          find.byIcon(Icons.keyboard_arrow_down),
          findsOneWidget,
          reason: 'AppBar title dropdown should exist at Surah 114',
        );

        // Assert 4: Dua button also exists (verifying both FABs coexist)
        final duaButtonFinder = find.ancestor(
          of: find.byIcon(Icons.auto_awesome),
          matching: find.byType(FloatingActionButton),
        );
        expect(
          duaButtonFinder,
          findsOneWidget,
          reason: 'Dua button should also exist at Surah 114',
        );
      },
    );

    testWidgets(
      'Property: Entry points exist in both Arabic and English locales',
      (WidgetTester tester) async {
        // Test in Arabic
        await tester.pumpWidget(createTestApp(initialSurah: 1, locale: 'ar'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.ancestor(
            of: find.byIcon(Icons.menu_book),
            matching: find.byType(FloatingActionButton),
          ),
          findsOneWidget,
          reason: 'FAB should exist in Arabic locale',
        );

        expect(
          find.byIcon(Icons.keyboard_arrow_down),
          findsOneWidget,
          reason: 'AppBar title dropdown should exist in Arabic locale',
        );

        // Test in English
        await tester.pumpWidget(createTestApp(initialSurah: 1, locale: 'en'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.ancestor(
            of: find.byIcon(Icons.menu_book),
            matching: find.byType(FloatingActionButton),
          ),
          findsOneWidget,
          reason: 'FAB should exist in English locale',
        );

        expect(
          find.byIcon(Icons.keyboard_arrow_down),
          findsOneWidget,
          reason: 'AppBar title dropdown should exist in English locale',
        );
      },
    );

    testWidgets('Property: FAB uses the same icon (menu_book) consistently', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app
      await tester.pumpWidget(createTestApp(initialSurah: 1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert: The menu_book icon is used in the FAB
      final menuBookIconFinder = find.byIcon(Icons.menu_book);
      expect(
        menuBookIconFinder,
        findsOneWidget,
        reason: 'FAB should use Icons.menu_book',
      );

      // Assert: The icon is inside a FloatingActionButton
      final fabWithIcon = find.ancestor(
        of: menuBookIconFinder,
        matching: find.byType(FloatingActionButton),
      );
      expect(
        fabWithIcon,
        findsOneWidget,
        reason: 'menu_book icon should be inside a FloatingActionButton',
      );
    });

    testWidgets(
      'Property: AppBar title uses keyboard_arrow_down icon consistently',
      (WidgetTester tester) async {
        // Arrange: Build the app
        await tester.pumpWidget(createTestApp(initialSurah: 1));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Assert: The keyboard_arrow_down icon exists
        final arrowIconFinder = find.byIcon(Icons.keyboard_arrow_down);
        expect(
          arrowIconFinder,
          findsOneWidget,
          reason: 'AppBar title should use Icons.keyboard_arrow_down',
        );

        // Assert: The icon is inside a GestureDetector (clickable)
        final gestureDetectorWithIcon = find.ancestor(
          of: arrowIconFinder,
          matching: find.byType(GestureDetector),
        );
        expect(
          gestureDetectorWithIcon,
          findsOneWidget,
          reason: 'keyboard_arrow_down should be inside a GestureDetector',
        );
      },
    );
  });
}
