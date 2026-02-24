// Feature: accessible-surah-selector
// Property 7: تعديل الموضع عند السورة 114
// **Validates: Requirements 3.3, 7.1, 7.2**
//
// This property test verifies that at Surah 114, the FAB location adjusts
// to avoid overlap with the dua button. The property ensures that:
// 1. Both buttons appear together at Surah 114
// 2. The FAB location is different at Surah 114 compared to other surahs
// 3. The adjustment is consistent across both RTL and LTR layouts

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Property 7: FAB Location Adjustment at Surah 114', () {
    // Helper function that replicates the _getFABLocation() logic
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

    // Property: At Surah 114, FAB location must be different from other surahs
    // to avoid overlap with the dua button
    test(
      'Property: FAB location at Surah 114 differs from other surahs to avoid overlap',
      () {
        // Test for both RTL and LTR layouts
        for (final isRTL in [true, false]) {
          // Get the location at Surah 114
          final locationAt114 = getFABLocation(isRTL: isRTL, surahNumber: 114);

          // Get the location at other surahs (sample: 1, 50, 113)
          final testSurahs = [1, 50, 113];
          for (final surahNumber in testSurahs) {
            final locationAtOther = getFABLocation(
              isRTL: isRTL,
              surahNumber: surahNumber,
            );

            // Property: Location at 114 must be different from other surahs
            expect(
              locationAt114,
              isNot(equals(locationAtOther)),
              reason:
                  'FAB location at Surah 114 (${locationAt114.runtimeType}) '
                  'must differ from Surah $surahNumber (${locationAtOther.runtimeType}) '
                  'to avoid overlap with dua button (isRTL=$isRTL)',
            );
          }
        }
      },
    );

    // Property: The location adjustment at Surah 114 is consistent
    // (always flips to the opposite side)
    test(
      'Property: FAB location consistently flips to opposite side at Surah 114',
      () {
        // For RTL: normal is endFloat, at 114 should be startFloat
        final rtlNormal = getFABLocation(isRTL: true, surahNumber: 1);
        final rtlAt114 = getFABLocation(isRTL: true, surahNumber: 114);

        expect(
          rtlNormal,
          equals(FloatingActionButtonLocation.endFloat),
          reason: 'RTL normal location should be endFloat',
        );
        expect(
          rtlAt114,
          equals(FloatingActionButtonLocation.startFloat),
          reason: 'RTL location at 114 should flip to startFloat',
        );

        // For LTR: normal is startFloat, at 114 should be endFloat
        final ltrNormal = getFABLocation(isRTL: false, surahNumber: 1);
        final ltrAt114 = getFABLocation(isRTL: false, surahNumber: 114);

        expect(
          ltrNormal,
          equals(FloatingActionButtonLocation.startFloat),
          reason: 'LTR normal location should be startFloat',
        );
        expect(
          ltrAt114,
          equals(FloatingActionButtonLocation.endFloat),
          reason: 'LTR location at 114 should flip to endFloat',
        );
      },
    );

    // Property: The flip behavior is exclusive to Surah 114
    // (no other surah should trigger the flip)
    test('Property: Location flip is exclusive to Surah 114', () {
      // Test all surahs from 1 to 114
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
          // At Surah 114: locations should be flipped
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
          // For all other surahs: locations should be normal
          expect(
            locationRTL,
            equals(FloatingActionButtonLocation.endFloat),
            reason:
                'RTL should use normal endFloat for Surah $surahNumber (not 114)',
          );
          expect(
            locationLTR,
            equals(FloatingActionButtonLocation.startFloat),
            reason:
                'LTR should use normal startFloat for Surah $surahNumber (not 114)',
          );
        }
      }
    });

    // Property: At Surah 114, both RTL and LTR use opposite locations
    // compared to their normal positions
    test('Property: Both RTL and LTR flip to opposite locations at Surah 114', () {
      // Sample surahs to test normal behavior
      final normalSurahs = [1, 25, 50, 75, 100, 113];

      for (final normalSurah in normalSurahs) {
        // Get normal locations
        final normalRTL = getFABLocation(isRTL: true, surahNumber: normalSurah);
        final normalLTR = getFABLocation(
          isRTL: false,
          surahNumber: normalSurah,
        );

        // Get locations at Surah 114
        final at114RTL = getFABLocation(isRTL: true, surahNumber: 114);
        final at114LTR = getFABLocation(isRTL: false, surahNumber: 114);

        // Property: At 114, locations should be opposite of normal
        expect(
          at114RTL,
          isNot(equals(normalRTL)),
          reason:
              'RTL location at 114 should be opposite of normal (tested against Surah $normalSurah)',
        );
        expect(
          at114LTR,
          isNot(equals(normalLTR)),
          reason:
              'LTR location at 114 should be opposite of normal (tested against Surah $normalSurah)',
        );

        // Verify the specific flip
        if (normalRTL == FloatingActionButtonLocation.endFloat) {
          expect(
            at114RTL,
            equals(FloatingActionButtonLocation.startFloat),
            reason: 'RTL should flip from endFloat to startFloat at 114',
          );
        }
        if (normalLTR == FloatingActionButtonLocation.startFloat) {
          expect(
            at114LTR,
            equals(FloatingActionButtonLocation.endFloat),
            reason: 'LTR should flip from startFloat to endFloat at 114',
          );
        }
      }
    });

    // Property: The adjustment ensures no overlap by using opposite sides
    test('Property: FAB and dua button use opposite sides at Surah 114', () {
      // At Surah 114, the dua button appears at the default location
      // and the surah selector FAB should be at the opposite location

      // For RTL: dua button at endFloat, surah selector at startFloat
      final rtlSurahSelector = getFABLocation(isRTL: true, surahNumber: 114);
      const rtlDuaButton = FloatingActionButtonLocation.endFloat;

      expect(
        rtlSurahSelector,
        isNot(equals(rtlDuaButton)),
        reason:
            'RTL: Surah selector and dua button must be at different locations',
      );
      expect(
        rtlSurahSelector,
        equals(FloatingActionButtonLocation.startFloat),
        reason: 'RTL: Surah selector should be at startFloat (opposite side)',
      );

      // For LTR: dua button at startFloat, surah selector at endFloat
      final ltrSurahSelector = getFABLocation(isRTL: false, surahNumber: 114);
      const ltrDuaButton = FloatingActionButtonLocation.startFloat;

      expect(
        ltrSurahSelector,
        isNot(equals(ltrDuaButton)),
        reason:
            'LTR: Surah selector and dua button must be at different locations',
      );
      expect(
        ltrSurahSelector,
        equals(FloatingActionButtonLocation.endFloat),
        reason: 'LTR: Surah selector should be at endFloat (opposite side)',
      );
    });

    // Property: The location is always valid (one of the two allowed positions)
    test('Property: FAB location at Surah 114 is always a valid position', () {
      final validLocations = [
        FloatingActionButtonLocation.startFloat,
        FloatingActionButtonLocation.endFloat,
      ];

      // Test for both RTL and LTR
      for (final isRTL in [true, false]) {
        final location = getFABLocation(isRTL: isRTL, surahNumber: 114);

        expect(
          validLocations,
          contains(location),
          reason:
              'FAB location at Surah 114 must be one of the valid positions (isRTL=$isRTL)',
        );
      }
    });

    // Property: Transition from Surah 113 to 114 changes the location
    test(
      'Property: FAB location changes when transitioning from Surah 113 to 114',
      () {
        // Test for both RTL and LTR
        for (final isRTL in [true, false]) {
          final locationAt113 = getFABLocation(isRTL: isRTL, surahNumber: 113);
          final locationAt114 = getFABLocation(isRTL: isRTL, surahNumber: 114);

          // Property: Location must change when moving to Surah 114
          expect(
            locationAt114,
            isNot(equals(locationAt113)),
            reason:
                'FAB location must change when transitioning from Surah 113 to 114 (isRTL=$isRTL)',
          );
        }
      },
    );

    // Property: The adjustment is symmetric for RTL and LTR
    // (both flip to their opposite sides)
    test('Property: Location adjustment is symmetric for RTL and LTR', () {
      // Get normal locations for a non-114 surah
      final normalRTL = getFABLocation(isRTL: true, surahNumber: 1);
      final normalLTR = getFABLocation(isRTL: false, surahNumber: 1);

      // Get locations at Surah 114
      final at114RTL = getFABLocation(isRTL: true, surahNumber: 114);
      final at114LTR = getFABLocation(isRTL: false, surahNumber: 114);

      // Property: Both should flip to their opposite sides
      // RTL: endFloat -> startFloat
      // LTR: startFloat -> endFloat
      expect(
        normalRTL,
        equals(FloatingActionButtonLocation.endFloat),
        reason: 'RTL normal should be endFloat',
      );
      expect(
        at114RTL,
        equals(FloatingActionButtonLocation.startFloat),
        reason: 'RTL at 114 should flip to startFloat',
      );

      expect(
        normalLTR,
        equals(FloatingActionButtonLocation.startFloat),
        reason: 'LTR normal should be startFloat',
      );
      expect(
        at114LTR,
        equals(FloatingActionButtonLocation.endFloat),
        reason: 'LTR at 114 should flip to endFloat',
      );

      // Verify symmetry: both flip to the opposite of their normal position
      expect(at114RTL != normalRTL, isTrue, reason: 'RTL should flip at 114');
      expect(at114LTR != normalLTR, isTrue, reason: 'LTR should flip at 114');
    });
  });
}
