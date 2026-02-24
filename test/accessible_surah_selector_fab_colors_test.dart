// Feature: accessible-surah-selector
// Property 5: تحديث الألوان بناءً على الوضع
// **Validates: Requirements 2.1, 2.2, 2.6**
//
// This test verifies that the FAB colors update correctly based on night mode:
// - Day mode: Gold background (#D4AF37) with dark brown text (#2C1810)
// - Night mode: Bright gold background (#FFD700) with light beige text (#E8D4B0)
//
// The property being tested: For any night mode state (enabled/disabled),
// the FAB must use the appropriate colors from _goldColor and _textColor.
//
// Note: Since _isNightMode is a private state variable in QuranTextScreen,
// we test the property by:
// 1. Verifying the default (day mode) colors are correct
// 2. Toggling night mode via the UI button
// 3. Verifying the colors update to night mode colors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/screens/quran_text_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

void main() {
  group('Property 5: FAB Colors Based on Night Mode', () {
    // Expected colors based on the design specification
    const dayModeGoldColor = Color(0xFFD4AF37); // Gold for day mode
    const nightModeGoldColor = Color(0xFFFFD700); // Bright gold for night mode
    const dayModeTextColor = Color(0xFF2C1810); // Dark brown for day mode
    const nightModeTextColor = Color(0xFFE8D4B0); // Light beige for night mode

    testWidgets(
      'Property: FAB uses day mode colors by default (night mode disabled)',
      (WidgetTester tester) async {
        // Arrange: Build the app (default is day mode)
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

        // Act: Find the surah selector FAB
        final fabFinder = find.ancestor(
          of: find.byIcon(Icons.menu_book),
          matching: find.byType(FloatingActionButton),
        );

        expect(fabFinder, findsOneWidget, reason: 'FAB should exist');

        final fab = tester.widget<FloatingActionButton>(fabFinder);

        // Assert: Background color should be day mode gold
        expect(
          fab.backgroundColor,
          equals(dayModeGoldColor),
          reason: 'FAB background should be day mode gold (#D4AF37) by default',
        );

        // Assert: Icon color should be day mode text color
        final iconFinder = find.descendant(
          of: fabFinder,
          matching: find.byType(Icon),
        );
        expect(iconFinder, findsOneWidget, reason: 'FAB should have an icon');

        final icon = tester.widget<Icon>(iconFinder);
        expect(
          icon.color,
          equals(dayModeTextColor),
          reason: 'FAB icon should be day mode text color (#2C1810) by default',
        );

        // Assert: Text color should be day mode text color
        final textFinder = find.descendant(
          of: fabFinder,
          matching: find.byType(Text),
        );
        expect(textFinder, findsOneWidget, reason: 'FAB should have text');

        final text = tester.widget<Text>(textFinder);
        expect(
          text.style?.color,
          equals(dayModeTextColor),
          reason: 'FAB text should be day mode text color (#2C1810) by default',
        );
      },
    );

    testWidgets('Property: FAB colors update to night mode when toggled', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the app (default is day mode)
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

      // Act: Toggle night mode by tapping the night mode button
      final nightModeButton = find.byIcon(Icons.dark_mode);
      expect(
        nightModeButton,
        findsOneWidget,
        reason: 'Night mode toggle button should exist',
      );

      await tester.tap(nightModeButton);
      await tester.pumpAndSettle();

      // Find the surah selector FAB after toggling
      final fabFinder = find.ancestor(
        of: find.byIcon(Icons.menu_book),
        matching: find.byType(FloatingActionButton),
      );

      expect(fabFinder, findsOneWidget, reason: 'FAB should exist');

      final fab = tester.widget<FloatingActionButton>(fabFinder);

      // Assert: Background color should be night mode gold
      expect(
        fab.backgroundColor,
        equals(nightModeGoldColor),
        reason:
            'FAB background should be night mode gold (#FFD700) after toggling',
      );

      // Assert: Icon color should be night mode text color
      final iconFinder = find.descendant(
        of: fabFinder,
        matching: find.byType(Icon),
      );
      expect(iconFinder, findsOneWidget, reason: 'FAB should have an icon');

      final icon = tester.widget<Icon>(iconFinder);
      expect(
        icon.color,
        equals(nightModeTextColor),
        reason:
            'FAB icon should be night mode text color (#E8D4B0) after toggling',
      );

      // Assert: Text color should be night mode text color
      final textFinder = find.descendant(
        of: fabFinder,
        matching: find.byType(Text),
      );
      expect(textFinder, findsOneWidget, reason: 'FAB should have text');

      final text = tester.widget<Text>(textFinder);
      expect(
        text.style?.color,
        equals(nightModeTextColor),
        reason:
            'FAB text should be night mode text color (#E8D4B0) after toggling',
      );
    });
  });
}
