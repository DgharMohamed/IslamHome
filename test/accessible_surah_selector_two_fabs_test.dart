// Feature: accessible-surah-selector
// Unit Test: Verify two FABs appear at Surah 114 with unique heroTags
// **Validates: Requirements 7.1**
//
// This test verifies that when the user is at Surah 114:
// 1. Two FloatingActionButtons are displayed
// 2. Each button has a unique heroTag to avoid conflicts

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

void main() {
  group('Unit Test: Two FABs at Surah 114', () {
    testWidgets('Should find two FloatingActionButtons at Surah 114', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 114
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: const QuranTextScreen(initialSurahNumber: 114),
          ),
        ),
      );

      // Wait for the widget to build and settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Find all FloatingActionButtons
      final fabFinder = find.byType(FloatingActionButton);

      // Assert: Should find exactly 2 FABs
      expect(
        fabFinder,
        findsNWidgets(2),
        reason:
            'At Surah 114, there should be exactly 2 FABs: '
            'one for surah selector and one for dua khatm',
      );
    });

    testWidgets('Each FAB at Surah 114 should have a unique heroTag', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 114
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: const QuranTextScreen(initialSurahNumber: 114),
          ),
        ),
      );

      // Wait for the widget to build and settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Find all FloatingActionButtons and extract their heroTags
      final fabWidgets = tester.widgetList<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      final heroTags = fabWidgets
          .map((fab) => fab.heroTag)
          .where((tag) => tag != null)
          .toList();

      // Assert: Should have 2 heroTags
      expect(
        heroTags.length,
        equals(2),
        reason: 'Both FABs should have heroTags defined',
      );

      // Assert: heroTags should be unique
      final uniqueHeroTags = heroTags.toSet();
      expect(
        uniqueHeroTags.length,
        equals(2),
        reason: 'Each FAB should have a unique heroTag to avoid conflicts',
      );

      // Assert: Verify the expected heroTags are present
      expect(
        heroTags,
        containsAll(['surah_selector', 'dua_khatm']),
        reason: 'The heroTags should be "surah_selector" and "dua_khatm"',
      );
    });

    testWidgets('Surah selector FAB should have heroTag "surah_selector"', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 114
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: const QuranTextScreen(initialSurahNumber: 114),
          ),
        ),
      );

      // Wait for the widget to build and settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Find the FAB with menu_book icon (surah selector)
      final surahSelectorFab = tester.widget<FloatingActionButton>(
        find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        ),
      );

      // Assert: Should have heroTag 'surah_selector'
      expect(
        surahSelectorFab.heroTag,
        equals('surah_selector'),
        reason: 'Surah selector FAB should have heroTag "surah_selector"',
      );
    });

    testWidgets('Dua khatm FAB should have heroTag "dua_khatm"', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 114
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: const QuranTextScreen(initialSurahNumber: 114),
          ),
        ),
      );

      // Wait for the widget to build and settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Find the FAB with auto_awesome icon (dua khatm)
      final duaKhatmFab = tester.widget<FloatingActionButton>(
        find.ancestor(
          of: find.byIcon(Icons.auto_awesome),
          matching: find.byType(FloatingActionButton),
        ),
      );

      // Assert: Should have heroTag 'dua_khatm'
      expect(
        duaKhatmFab.heroTag,
        equals('dua_khatm'),
        reason: 'Dua khatm FAB should have heroTag "dua_khatm"',
      );
    });

    testWidgets('At Surah 113, should only find one FloatingActionButton', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 113 (not 114)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: const QuranTextScreen(initialSurahNumber: 113),
          ),
        ),
      );

      // Wait for the widget to build and settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Find all FloatingActionButtons
      final fabFinder = find.byType(FloatingActionButton);

      // Assert: Should find exactly 1 FAB (only surah selector)
      expect(
        fabFinder,
        findsOneWidget,
        reason: 'At Surah 113, there should be only 1 FAB (surah selector)',
      );
    });

    testWidgets('At Surah 1, should only find one FloatingActionButton', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app at Surah 1
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: const QuranTextScreen(initialSurahNumber: 1),
          ),
        ),
      );

      // Wait for the widget to build and settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Act: Find all FloatingActionButtons
      final fabFinder = find.byType(FloatingActionButton);

      // Assert: Should find exactly 1 FAB (only surah selector)
      expect(
        fabFinder,
        findsOneWidget,
        reason: 'At Surah 1, there should be only 1 FAB (surah selector)',
      );
    });
  });
}
