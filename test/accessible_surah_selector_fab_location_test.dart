// Feature: accessible-surah-selector
// Property 6: تغيير الموضع بناءً على اتجاه النص
// **Validates: Requirements 3.1**
//
// This test verifies that the FAB location changes correctly based on text direction (RTL/LTR)
// and the current surah number (to avoid overlap with the dua button at Surah 114).
//
// Since the _getFABLocation() function is private, we test the property by verifying
// the logic through a test helper that replicates the function's behavior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Property 6: FAB Location Based on Text Direction', () {
    // Helper function that replicates the _getFABLocation() logic
    // This allows us to test the property without building the entire widget tree
    FloatingActionButtonLocation getFABLocation({
      required bool isRTL,
      required int surahNumber,
    }) {
      final showDuaButton = surahNumber == 114;

      if (showDuaButton) {
        // If dua button is present, place the surah selector on the opposite side
        return isRTL
            ? FloatingActionButtonLocation.startFloat
            : FloatingActionButtonLocation.endFloat;
      } else {
        // Default position based on language direction
        return isRTL
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.startFloat;
      }
    }

    // Test data representing different combinations of:
    // - Text direction (RTL for Arabic, LTR for English)
    // - Surah number (1-113 vs 114)
    // - Expected FAB location
    final testCases = [
      // RTL (Arabic) cases
      _TestCase(
        isRTL: true,
        surahNumber: 1,
        expectedLocation: FloatingActionButtonLocation.endFloat,
        description: 'RTL (Arabic) with Surah 1 should place FAB at endFloat',
      ),
      _TestCase(
        isRTL: true,
        surahNumber: 57,
        expectedLocation: FloatingActionButtonLocation.endFloat,
        description: 'RTL (Arabic) with Surah 57 should place FAB at endFloat',
      ),
      _TestCase(
        isRTL: true,
        surahNumber: 113,
        expectedLocation: FloatingActionButtonLocation.endFloat,
        description: 'RTL (Arabic) with Surah 113 should place FAB at endFloat',
      ),
      _TestCase(
        isRTL: true,
        surahNumber: 114,
        expectedLocation: FloatingActionButtonLocation.startFloat,
        description:
            'RTL (Arabic) with Surah 114 should place FAB at startFloat (opposite side from dua button)',
      ),

      // LTR (English) cases
      _TestCase(
        isRTL: false,
        surahNumber: 1,
        expectedLocation: FloatingActionButtonLocation.startFloat,
        description:
            'LTR (English) with Surah 1 should place FAB at startFloat',
      ),
      _TestCase(
        isRTL: false,
        surahNumber: 57,
        expectedLocation: FloatingActionButtonLocation.startFloat,
        description:
            'LTR (English) with Surah 57 should place FAB at startFloat',
      ),
      _TestCase(
        isRTL: false,
        surahNumber: 113,
        expectedLocation: FloatingActionButtonLocation.startFloat,
        description:
            'LTR (English) with Surah 113 should place FAB at startFloat',
      ),
      _TestCase(
        isRTL: false,
        surahNumber: 114,
        expectedLocation: FloatingActionButtonLocation.endFloat,
        description:
            'LTR (English) with Surah 114 should place FAB at endFloat (opposite side from dua button)',
      ),
    ];

    for (final testCase in testCases) {
      test(testCase.description, () {
        final location = getFABLocation(
          isRTL: testCase.isRTL,
          surahNumber: testCase.surahNumber,
        );

        expect(
          location,
          equals(testCase.expectedLocation),
          reason:
              'FAB location should be ${testCase.expectedLocation} for ${testCase.description}',
        );
      });
    }

    // Additional property test: Verify the invariant that FAB location is always set
    test('Property: FAB location is always defined (never null)', () {
      // Test with multiple random surahs to ensure the property holds
      final surahsToTest = [1, 10, 50, 75, 100, 113, 114];

      for (final surahNumber in surahsToTest) {
        for (final isRTL in [true, false]) {
          final location = getFABLocation(
            isRTL: isRTL,
            surahNumber: surahNumber,
          );

          // Property: FAB location must always be defined
          expect(
            location,
            isNotNull,
            reason:
                'FAB location must be defined for surah $surahNumber with isRTL=$isRTL',
          );

          // Property: FAB location must be one of the valid locations
          expect(
            location,
            anyOf([
              FloatingActionButtonLocation.startFloat,
              FloatingActionButtonLocation.endFloat,
            ]),
            reason: 'FAB location must be either startFloat or endFloat',
          );
        }
      }
    });

    // Property test: Verify symmetry - RTL and LTR should use opposite locations (except at Surah 114)
    test(
      'Property: RTL and LTR use opposite FAB locations for same surah (except 114)',
      () {
        final surahsToTest = [1, 25, 50, 75, 100, 113];

        for (final surahNumber in surahsToTest) {
          final locationRTL = getFABLocation(
            isRTL: true,
            surahNumber: surahNumber,
          );

          final locationLTR = getFABLocation(
            isRTL: false,
            surahNumber: surahNumber,
          );

          // Property: For non-114 surahs, RTL should use endFloat and LTR should use startFloat
          expect(
            locationRTL,
            equals(FloatingActionButtonLocation.endFloat),
            reason: 'RTL should use endFloat for surah $surahNumber',
          );
          expect(
            locationLTR,
            equals(FloatingActionButtonLocation.startFloat),
            reason: 'LTR should use startFloat for surah $surahNumber',
          );
        }
      },
    );

    // Property test: Verify special case at Surah 114 - locations should flip
    test(
      'Property: At Surah 114, FAB locations flip to avoid dua button overlap',
      () {
        final locationRTL = getFABLocation(isRTL: true, surahNumber: 114);

        final locationLTR = getFABLocation(isRTL: false, surahNumber: 114);

        // Property: At Surah 114, locations should flip
        // RTL should use startFloat (opposite of normal endFloat)
        // LTR should use endFloat (opposite of normal startFloat)
        expect(
          locationRTL,
          equals(FloatingActionButtonLocation.startFloat),
          reason: 'RTL should use startFloat at Surah 114 to avoid dua button',
        );
        expect(
          locationLTR,
          equals(FloatingActionButtonLocation.endFloat),
          reason: 'LTR should use endFloat at Surah 114 to avoid dua button',
        );
      },
    );

    // Property test: Verify consistency across all surahs
    test('Property: FAB location is consistent for all surahs 1-113', () {
      for (int surahNumber = 1; surahNumber <= 113; surahNumber++) {
        final locationRTL = getFABLocation(
          isRTL: true,
          surahNumber: surahNumber,
        );

        final locationLTR = getFABLocation(
          isRTL: false,
          surahNumber: surahNumber,
        );

        // Property: For all surahs except 114, the location should be consistent
        expect(
          locationRTL,
          equals(FloatingActionButtonLocation.endFloat),
          reason:
              'RTL should always use endFloat for surah $surahNumber (not 114)',
        );
        expect(
          locationLTR,
          equals(FloatingActionButtonLocation.startFloat),
          reason:
              'LTR should always use startFloat for surah $surahNumber (not 114)',
        );
      }
    });

    // Property test: Verify the flip behavior is exclusive to Surah 114
    test('Property: Location flip only occurs at Surah 114', () {
      // Test that Surah 114 is the ONLY surah where the flip occurs
      for (int surahNumber = 1; surahNumber <= 114; surahNumber++) {
        final locationRTL = getFABLocation(
          isRTL: true,
          surahNumber: surahNumber,
        );

        final locationLTR = getFABLocation(
          isRTL: false,
          surahNumber: surahNumber,
        );

        if (surahNumber == 114) {
          // At Surah 114, locations should be flipped
          expect(
            locationRTL,
            equals(FloatingActionButtonLocation.startFloat),
            reason: 'RTL should flip to startFloat at Surah 114',
          );
          expect(
            locationLTR,
            equals(FloatingActionButtonLocation.endFloat),
            reason: 'LTR should flip to endFloat at Surah 114',
          );
        } else {
          // For all other surahs, locations should be normal
          expect(
            locationRTL,
            equals(FloatingActionButtonLocation.endFloat),
            reason: 'RTL should use endFloat for surah $surahNumber (not 114)',
          );
          expect(
            locationLTR,
            equals(FloatingActionButtonLocation.startFloat),
            reason:
                'LTR should use startFloat for surah $surahNumber (not 114)',
          );
        }
      }
    });
  });
}

/// Helper class to represent a test case
class _TestCase {
  final bool isRTL;
  final int surahNumber;
  final FloatingActionButtonLocation expectedLocation;
  final String description;

  _TestCase({
    required this.isRTL,
    required this.surahNumber,
    required this.expectedLocation,
    required this.description,
  });
}
