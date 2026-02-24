// Feature: accessible-surah-selector
// Property Test: Content Consistency
// **Validates: Requirements 1.4**
//
// Property 2: اتساق المحتوى المعروض (Content Consistency)
// For any source of opening the surah picker (FAB or AppBar title),
// the system should display the same list of 114 surahs with the same
// formatting and information.
//
// This test verifies that:
// 1. The surah picker always displays exactly 114 surahs
// 2. Each surah has a title (name) and subtitle (number)
// 3. The content is consistent regardless of entry point
// 4. The content is consistent across different initial surahs
// 5. The content is consistent in both Arabic and English locales
//
// Note: Since both entry points call the same _showSurahPicker() method,
// and that method generates the list independently of how it was called,
// this test focuses on verifying the structural consistency of the
// displayed content across different contexts.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

void main() {
  group('Property Test: Content Consistency', () {
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

    // Helper function to open the surah picker via FAB
    Future<void> openSurahPickerViaFAB(WidgetTester tester) async {
      final fabFinder = find.ancestor(
        of: find.byIcon(Icons.menu_book),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();
    }

    // Helper function to open the surah picker via AppBar
    Future<void> openSurahPickerViaAppBar(WidgetTester tester) async {
      final appBarTitleFinder = find.ancestor(
        of: find.byIcon(Icons.keyboard_arrow_down),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(appBarTitleFinder);
      await tester.pumpAndSettle();
    }

    // Helper function to count surah items in the picker
    int countSurahItems(WidgetTester tester) {
      // The surah picker uses ListTile widgets for each surah
      final listTileFinder = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ListTile),
      );
      return tester.widgetList(listTileFinder).length;
    }

    // Helper function to verify surah item structure
    void verifySurahItemStructure(WidgetTester tester, int index) {
      final listTiles = tester.widgetList<ListTile>(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(ListTile),
        ),
      );

      final listTile = listTiles.elementAt(index);

      // Each ListTile should have a title (surah name)
      expect(
        listTile.title,
        isNotNull,
        reason: 'Surah item $index should have a title',
      );

      // Each ListTile should have a subtitle (surah number)
      expect(
        listTile.subtitle,
        isNotNull,
        reason: 'Surah item $index should have a subtitle',
      );
    }

    testWidgets('Property: Surah picker displays exactly 114 surahs via FAB', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app
      await tester.pumpWidget(createTestApp(initialSurah: 1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Open surah picker via FAB
      await openSurahPickerViaFAB(tester);

      // Assert: Exactly 114 surahs are displayed
      final surahCount = countSurahItems(tester);
      expect(
        surahCount,
        equals(114),
        reason: 'Surah picker should display exactly 114 surahs via FAB',
      );
    });

    testWidgets(
      'Property: Surah picker displays exactly 114 surahs via AppBar',
      (WidgetTester tester) async {
        // Arrange: Build the app
        await tester.pumpWidget(createTestApp(initialSurah: 1));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Act: Open surah picker via AppBar
        await openSurahPickerViaAppBar(tester);

        // Assert: Exactly 114 surahs are displayed
        final surahCount = countSurahItems(tester);
        expect(
          surahCount,
          equals(114),
          reason: 'Surah picker should display exactly 114 surahs via AppBar',
        );
      },
    );

    testWidgets('Property: Each surah item has title and subtitle via FAB', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app
      await tester.pumpWidget(createTestApp(initialSurah: 1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Open surah picker via FAB
      await openSurahPickerViaFAB(tester);

      // Assert: Verify structure of first, middle, and last surah items
      verifySurahItemStructure(tester, 0); // First surah
      verifySurahItemStructure(tester, 56); // Middle surah
      verifySurahItemStructure(tester, 113); // Last surah
    });

    testWidgets('Property: Each surah item has title and subtitle via AppBar', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app
      await tester.pumpWidget(createTestApp(initialSurah: 1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Open surah picker via AppBar
      await openSurahPickerViaAppBar(tester);

      // Assert: Verify structure of first, middle, and last surah items
      verifySurahItemStructure(tester, 0); // First surah
      verifySurahItemStructure(tester, 56); // Middle surah
      verifySurahItemStructure(tester, 113); // Last surah
    });

    testWidgets(
      'Property: Content is consistent across different initial surahs',
      (WidgetTester tester) async {
        // Test at Surah 1
        await tester.pumpWidget(createTestApp(initialSurah: 1));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await openSurahPickerViaFAB(tester);

        final countAtSurah1 = countSurahItems(tester);
        expect(countAtSurah1, equals(114));

        // Close the picker
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Test at Surah 57 (middle)
        await tester.pumpWidget(createTestApp(initialSurah: 57));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await openSurahPickerViaFAB(tester);

        final countAtSurah57 = countSurahItems(tester);
        expect(countAtSurah57, equals(114));

        // Close the picker
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Test at Surah 114 (last)
        await tester.pumpWidget(createTestApp(initialSurah: 114));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await openSurahPickerViaFAB(tester);

        final countAtSurah114 = countSurahItems(tester);
        expect(countAtSurah114, equals(114));

        // Assert: All counts are equal
        expect(
          countAtSurah1,
          equals(countAtSurah57),
          reason: 'Surah count should be consistent across different surahs',
        );
        expect(
          countAtSurah57,
          equals(countAtSurah114),
          reason: 'Surah count should be consistent across different surahs',
        );
      },
    );

    testWidgets('Property: Content is consistent in Arabic locale', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app in Arabic
      await tester.pumpWidget(createTestApp(initialSurah: 1, locale: 'ar'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Open surah picker via FAB
      await openSurahPickerViaFAB(tester);

      // Assert: 114 surahs with proper structure
      final surahCount = countSurahItems(tester);
      expect(
        surahCount,
        equals(114),
        reason: 'Should display 114 surahs in Arabic locale',
      );

      verifySurahItemStructure(tester, 0);
      verifySurahItemStructure(tester, 113);
    });

    testWidgets('Property: Content is consistent in English locale', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app in English
      await tester.pumpWidget(createTestApp(initialSurah: 1, locale: 'en'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Open surah picker via FAB
      await openSurahPickerViaFAB(tester);

      // Assert: 114 surahs with proper structure
      final surahCount = countSurahItems(tester);
      expect(
        surahCount,
        equals(114),
        reason: 'Should display 114 surahs in English locale',
      );

      verifySurahItemStructure(tester, 0);
      verifySurahItemStructure(tester, 113);
    });

    testWidgets(
      'Property: Content count is same via FAB and AppBar at same surah',
      (WidgetTester tester) async {
        // Test via FAB
        await tester.pumpWidget(createTestApp(initialSurah: 1));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await openSurahPickerViaFAB(tester);

        final countViaFAB = countSurahItems(tester);

        // Close the picker
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Test via AppBar
        await openSurahPickerViaAppBar(tester);

        final countViaAppBar = countSurahItems(tester);

        // Assert: Both entry points show the same count
        expect(
          countViaFAB,
          equals(countViaAppBar),
          reason: 'FAB and AppBar should display the same number of surahs',
        );
        expect(
          countViaFAB,
          equals(114),
          reason: 'Both entry points should display exactly 114 surahs',
        );
      },
    );

    testWidgets('Property: Surah picker title is displayed correctly', (
      WidgetTester tester,
    ) async {
      // Test in Arabic
      await tester.pumpWidget(createTestApp(initialSurah: 1, locale: 'ar'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await openSurahPickerViaFAB(tester);

      // The title should be present in the bottom sheet
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(Text),
        ),
        findsWidgets,
        reason: 'Surah picker should have text widgets including title',
      );

      // Close the picker
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Test in English
      await tester.pumpWidget(createTestApp(initialSurah: 1, locale: 'en'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await openSurahPickerViaFAB(tester);

      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(Text),
        ),
        findsWidgets,
        reason: 'Surah picker should have text widgets including title',
      );
    });
  });
}
