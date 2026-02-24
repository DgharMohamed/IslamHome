// Feature: accessible-surah-selector
// Unit Test: Verify FAB exists with correct icon and elevation
// **Validates: Requirements 1.1, 2.3, 6.4**
//
// This test verifies that:
// 1. FloatingActionButton exists in the widget tree
// 2. The FAB has the correct icon (Icons.menu_book)
// 3. The FAB has elevation greater than 0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

void main() {
  group('Unit Test: FAB Existence and Properties', () {
    testWidgets('Should find FloatingActionButton with Icons.menu_book', (
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

      // Act: Find the menu_book icon
      final iconFinder = find.byIcon(Icons.menu_book);

      // Assert: Should find the menu_book icon
      expect(
        iconFinder,
        findsAtLeastNWidgets(1),
        reason: 'FAB should have Icons.menu_book icon',
      );

      // Assert: The icon should be inside a FloatingActionButton
      final fabWithIcon = find.ancestor(
        of: iconFinder,
        matching: find.byType(FloatingActionButton),
      );

      expect(
        fabWithIcon,
        findsAtLeastNWidgets(1),
        reason: 'Icons.menu_book should be inside a FloatingActionButton',
      );
    });

    testWidgets('FAB should have elevation greater than 0', (
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

      // Act: Find the FAB with menu_book icon (surah selector)
      final surahSelectorFab = tester.widget<FloatingActionButton>(
        find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        ),
      );

      // Assert: Elevation should be greater than 0
      expect(
        surahSelectorFab.elevation,
        greaterThan(0),
        reason: 'FAB should have elevation greater than 0 to appear raised',
      );
    });

    testWidgets('FAB should have elevation of 4 as per design spec', (
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

      // Act: Find the FAB with menu_book icon (surah selector)
      final surahSelectorFab = tester.widget<FloatingActionButton>(
        find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        ),
      );

      // Assert: Elevation should be exactly 4 (as per design spec)
      expect(
        surahSelectorFab.elevation,
        equals(4),
        reason: 'FAB should have elevation of 4 as per design specification',
      );
    });

    testWidgets('FAB with menu_book icon exists at Surah 114', (
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

      // Act: Find the surah selector FAB with menu_book icon
      final iconFinder = find.byIcon(Icons.menu_book);

      // Assert: Should find the menu_book icon even at Surah 114
      expect(
        iconFinder,
        findsOneWidget,
        reason: 'Icons.menu_book should exist at Surah 114',
      );

      // Assert: The icon should be inside a FloatingActionButton
      final fabWithIcon = find.ancestor(
        of: iconFinder,
        matching: find.byType(FloatingActionButton),
      );

      expect(
        fabWithIcon,
        findsOneWidget,
        reason:
            'Surah selector FAB with Icons.menu_book should exist at Surah 114',
      );

      // Assert: The FAB should have elevation > 0
      final surahSelectorFab = tester.widget<FloatingActionButton>(fabWithIcon);
      expect(
        surahSelectorFab.elevation,
        greaterThan(0),
        reason: 'Surah selector FAB should have elevation > 0 at Surah 114',
      );
    });
  });
}
