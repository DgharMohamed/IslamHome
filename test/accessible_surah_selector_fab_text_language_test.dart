// Feature: accessible-surah-selector
// Property 3: تحديث النص بناءً على اللغة
// **Validates: Requirements 2.4, 4.1, 4.2**
//
// This test verifies that the FAB text updates correctly based on language:
// - Arabic locale: "السور"
// - English locale: "Surahs"
//
// The property being tested: For any supported language (Arabic or English),
// the FAB must display the appropriate text from l10n.surahs.
//
// This property test verifies that the text is correctly localized for both
// languages and that the FAB uses the l10n system properly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

void main() {
  group('Property 3: FAB Text Based on Language', () {
    testWidgets(
      'Property: FAB displays Arabic text "السور" when locale is Arabic',
      (WidgetTester tester) async {
        // Arrange: Build the app with Arabic locale
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
              locale: const Locale('ar'), // Force Arabic locale
              home: const QuranTextScreen(initialSurahNumber: 1),
            ),
          ),
        );

        // Wait for the widget to build and settle
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Act: Find the FAB with menu_book icon (surah selector)
        final fabFinder = find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        );

        expect(fabFinder, findsOneWidget, reason: 'FAB should exist');

        // Assert: Should find the Arabic text "السور"
        final arabicTextFinder = find.descendant(
          of: fabFinder,
          matching: find.text('السور'),
        );

        expect(
          arabicTextFinder,
          findsOneWidget,
          reason: 'FAB should display "السور" when locale is Arabic',
        );

        // Also verify the tooltip
        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(
          fab.tooltip,
          equals('السور'),
          reason: 'FAB tooltip should be "السور" when locale is Arabic',
        );
      },
    );
  });

  group('Property 3: FAB Text Based on Language - English', () {
    testWidgets(
      'Property: FAB displays English text "Surahs" when locale is English',
      (WidgetTester tester) async {
        // Arrange: Build the app with English locale
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
              locale: const Locale('en'), // Force English locale
              home: const QuranTextScreen(initialSurahNumber: 1),
            ),
          ),
        );

        // Wait for the widget to build and settle
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Act: Find the FAB with menu_book icon (surah selector)
        final fabFinder = find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        );

        expect(fabFinder, findsOneWidget, reason: 'FAB should exist');

        // Assert: Should find the English text "Surahs"
        final englishTextFinder = find.descendant(
          of: fabFinder,
          matching: find.text('Surahs'),
        );

        expect(
          englishTextFinder,
          findsOneWidget,
          reason: 'FAB should display "Surahs" when locale is English',
        );

        // Also verify the tooltip
        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(
          fab.tooltip,
          equals('Surahs'),
          reason: 'FAB tooltip should be "Surahs" when locale is English',
        );
      },
    );
  });
}
