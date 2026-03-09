import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/widgets/quran_page_widget.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/quran_page_model.dart';

/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
///
/// Property 2: Preservation - Non-Overflowing Line Behavior
///
/// This test suite verifies that for non-overflowing lines (lines where total word width
/// fits within available space), the system preserves all existing functionality:
/// - Verse highlighting activates golden background when tapping words
/// - Ayah end markers render as circular bordered containers with golden color
/// - Non-overflowing lines display with spaceBetween alignment appearance
/// - Arabic text flows right-to-left with proper RTL direction
///
/// These tests are run on UNFIXED code to establish baseline behavior that must be preserved.
/// EXPECTED OUTCOME: All tests PASS on unfixed code (confirms baseline to preserve).

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Property 2: Preservation - Non-Overflowing Line Behavior', () {
    /// Helper function to create a QuranWord with realistic data
    QuranWord createWord({
      required int id,
      required int position,
      required String textUthmani,
      String charTypeName = 'word',
      required String verseKey,
      int pageNumber = 1,
    }) {
      return QuranWord(
        id: id,
        position: position,
        textUthmani: textUthmani,
        charTypeName: charTypeName,
        lineNumber: 1,
        verseKey: verseKey,
        pageNumber: pageNumber,
      );
    }

    /// Helper function to create a non-overflowing QuranLine
    /// Uses 3-4 short words that will fit within available space
    QuranLine createNonOverflowingLine({
      required int lineNumber,
      int wordCount = 3,
      bool includeAyahMarker = false,
    }) {
      final words = <QuranWord>[];

      // Create short Arabic words that won't overflow
      final shortWords = ['بِسْمِ', 'ٱللَّهِ', 'ٱلرَّحْمَٰنِ', 'ٱلرَّحِيمِ'];

      for (int i = 0; i < wordCount && i < shortWords.length; i++) {
        words.add(
          createWord(
            id: i + 1,
            position: i + 1,
            textUthmani: shortWords[i],
            verseKey: '1:1',
            pageNumber: 1,
          ),
        );
      }

      // Add ayah end marker if requested
      if (includeAyahMarker) {
        words.add(
          createWord(
            id: wordCount + 1,
            position: wordCount + 1,
            textUthmani: '١',
            charTypeName: 'end',
            verseKey: '1:1',
            pageNumber: 1,
          ),
        );
      }

      return QuranLine(lineNumber: lineNumber, words: words);
    }

    /// Helper function to create a QuranPage with non-overflowing lines
    QuranPage createNonOverflowingPage({
      int pageNumber = 1,
      int lineCount = 3,
      bool includeAyahMarkers = false,
    }) {
      final lines = <QuranLine>[];

      for (int i = 0; i < lineCount; i++) {
        lines.add(
          createNonOverflowingLine(
            lineNumber: i + 1,
            wordCount: 3,
            includeAyahMarker: includeAyahMarkers && i == 0,
          ),
        );
      }

      return QuranPage(
        pageNumber: pageNumber,
        surahName: 'الفاتحة',
        juzNumber: 1,
        hizbNumber: 1,
        lines: lines,
      );
    }

    testWidgets(
      'Preservation Test 1: Verse highlighting activates golden background on tap',
      (WidgetTester tester) async {
        // **Validates: Requirement 3.2**
        // Observe: Tapping words activates golden background (0xFFC9A227 with 0.2 alpha)

        final page = createNonOverflowingPage(lineCount: 1);
        const pageNumber = 1;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              quranPageProvider(
                pageNumber,
              ).overrideWithValue(AsyncValue.data(page)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: QuranPageWidget(pageNumber: pageNumber)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the first word (should be a GestureDetector with Text)
        final firstWordFinder = find.text('بِسْمِ');
        expect(firstWordFinder, findsOneWidget);

        // Find the GestureDetector containing the word
        final gestureDetectorFinder = find.ancestor(
          of: firstWordFinder,
          matching: find.byType(GestureDetector),
        );
        expect(gestureDetectorFinder, findsOneWidget);

        // Verify initial state: no golden background
        final GestureDetector gestureDetector = tester.widget<GestureDetector>(
          gestureDetectorFinder,
        );
        final Container wordContainer = gestureDetector.child as Container;

        BoxDecoration? decoration = wordContainer.decoration as BoxDecoration?;
        expect(
          decoration?.color,
          Colors.transparent,
          reason: 'Word should have transparent background initially',
        );

        // Tap the word to activate verse highlighting
        await tester.tap(firstWordFinder);
        await tester.pumpAndSettle();

        // Verify golden background is now active
        final GestureDetector gestureDetectorAfter = tester
            .widget<GestureDetector>(gestureDetectorFinder);
        final Container wordContainerAfter =
            gestureDetectorAfter.child as Container;

        final BoxDecoration? decorationAfter =
            wordContainerAfter.decoration as BoxDecoration?;
        expect(
          decorationAfter?.color,
          const Color(0xFFC9A227).withValues(alpha: 0.2),
          reason: 'Word should have golden background after tap',
        );

        // Verify text color changes to golden
        final Text textWidget = (wordContainerAfter.child as Text);
        expect(
          textWidget.style?.color,
          const Color(0xFFC9A227),
          reason: 'Text should be golden when active',
        );
      },
    );

    testWidgets(
      'Preservation Test 2: Ayah end markers render as circular bordered containers',
      (WidgetTester tester) async {
        // **Validates: Requirement 3.3**
        // Observe: Ayah markers display as circular bordered containers with golden color

        final page = createNonOverflowingPage(
          lineCount: 1,
          includeAyahMarkers: true,
        );
        const pageNumber = 1;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              quranPageProvider(
                pageNumber,
              ).overrideWithValue(AsyncValue.data(page)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: QuranPageWidget(pageNumber: pageNumber)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the ayah marker
        final ayahMarkerFinder = find.text('١');
        expect(ayahMarkerFinder, findsOneWidget);

        // Verify it's wrapped in a Container with circular border
        final containerFinder = find.ancestor(
          of: ayahMarkerFinder,
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        final Container markerContainer = tester.widget<Container>(
          containerFinder.first,
        );

        final BoxDecoration? decoration =
            markerContainer.decoration as BoxDecoration?;

        // Verify circular shape
        expect(
          decoration?.shape,
          BoxShape.circle,
          reason: 'Ayah marker should have circular shape',
        );

        // Verify golden border
        expect(
          decoration?.border,
          isNotNull,
          reason: 'Ayah marker should have a border',
        );

        final border = decoration?.border as Border?;
        expect(
          border?.top.color,
          const Color(0xFFC9A227).withValues(alpha: 0.5),
          reason: 'Ayah marker border should be golden',
        );

        // Verify text styling
        final textWidget = tester.widget<Text>(ayahMarkerFinder);
        expect(
          textWidget.style?.color,
          const Color(0xFFC9A227),
          reason: 'Ayah marker text should be golden',
        );
        expect(
          textWidget.style?.fontFamily,
          'UthmanicHafs',
          reason: 'Ayah marker should use UthmanicHafs font',
        );
      },
    );

    testWidgets(
      'Preservation Test 3: Non-overflowing lines display with spaceBetween alignment',
      (WidgetTester tester) async {
        // **Validates: Requirement 3.1**
        // Observe: Non-overflowing lines use spaceBetween alignment (even spacing between words)

        final page = createNonOverflowingPage(
          lineCount: 1,
          includeAyahMarkers: false,
        );
        const pageNumber = 1;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              quranPageProvider(
                pageNumber,
              ).overrideWithValue(AsyncValue.data(page)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: QuranPageWidget(pageNumber: pageNumber)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the Row widget that contains the words (inside LayoutBuilder)
        final layoutBuilderFinder = find.byType(LayoutBuilder);
        expect(layoutBuilderFinder, findsOneWidget);

        // Build the widget tree to get the Row
        final LayoutBuilder layoutBuilder = tester.widget<LayoutBuilder>(
          layoutBuilderFinder,
        );
        final builtWidget = layoutBuilder.builder(
          tester.element(layoutBuilderFinder),
          const BoxConstraints(maxWidth: 400, maxHeight: 100),
        );

        // The built widget should be a Row
        expect(builtWidget, isA<Row>());
        final Row rowWidget = builtWidget as Row;

        // Verify spaceBetween alignment
        expect(
          rowWidget.mainAxisAlignment,
          MainAxisAlignment.spaceBetween,
          reason: 'Non-overflowing lines should use spaceBetween alignment',
        );

        // Verify all words are present
        expect(find.text('بِسْمِ'), findsOneWidget);
        expect(find.text('ٱللَّهِ'), findsOneWidget);
        expect(find.text('ٱلرَّحْمَٰنِ'), findsOneWidget);
      },
    );

    testWidgets(
      'Preservation Test 4: Arabic text flows right-to-left with RTL direction',
      (WidgetTester tester) async {
        // **Validates: Requirement 3.1**
        // Observe: Arabic text maintains RTL direction

        final page = createNonOverflowingPage(lineCount: 1);
        const pageNumber = 1;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              quranPageProvider(
                pageNumber,
              ).overrideWithValue(AsyncValue.data(page)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: QuranPageWidget(pageNumber: pageNumber)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the Directionality widget
        final directionalityFinder = find.byType(Directionality);
        expect(directionalityFinder, findsWidgets);

        // Get the Directionality widget that wraps the line content
        // (not the one from MaterialApp)
        final directionalityWidgets = tester
            .widgetList<Directionality>(directionalityFinder)
            .toList();

        // Find the one with RTL direction (should be the line wrapper)
        final rtlDirectionality = directionalityWidgets.firstWhere(
          (d) => d.textDirection == TextDirection.rtl,
          orElse: () => throw Exception('No RTL Directionality found'),
        );

        expect(
          rtlDirectionality.textDirection,
          TextDirection.rtl,
          reason: 'Arabic text should flow right-to-left',
        );
      },
    );

    testWidgets(
      'Preservation Test 5: Visual styling remains unchanged (colors, fonts, sizes)',
      (WidgetTester tester) async {
        // **Validates: Requirements 3.4, 3.5**
        // Observe: All visual styling (colors, fonts, sizes) remains identical

        final page = createNonOverflowingPage(lineCount: 1);
        const pageNumber = 1;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              quranPageProvider(
                pageNumber,
              ).overrideWithValue(AsyncValue.data(page)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: QuranPageWidget(pageNumber: pageNumber)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify word text styling
        final firstWordFinder = find.text('بِسْمِ');
        final textWidget = tester.widget<Text>(firstWordFinder);

        expect(
          textWidget.style?.color,
          const Color(0xFFE8E3D6),
          reason: 'Inactive word text should be light colored',
        );
        expect(
          textWidget.style?.fontSize,
          24,
          reason: 'Word text should be 24px',
        );
        expect(
          textWidget.style?.fontFamily,
          'UthmanicHafs',
          reason: 'Word text should use UthmanicHafs font',
        );
        expect(
          textWidget.style?.height,
          1.0,
          reason: 'Word text should have 1.0 line height',
        );

        // Verify header is present
        expect(find.text('الفاتحة'), findsOneWidget);
        expect(find.text('الجزء 1'), findsOneWidget);

        // Verify footer is present
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets(
      'Preservation Test 6: Property-based - Multiple line configurations preserve behavior',
      (WidgetTester tester) async {
        // **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
        // Property-based approach: Test various non-overflowing line configurations

        // Test configurations: varying word counts (1-4 words per line)
        final configurations = [
          {'wordCount': 1, 'includeAyahMarker': false},
          {'wordCount': 2, 'includeAyahMarker': false},
          {'wordCount': 3, 'includeAyahMarker': false},
          {'wordCount': 3, 'includeAyahMarker': true},
          {'wordCount': 4, 'includeAyahMarker': false},
        ];

        for (final config in configurations) {
          final wordCount = config['wordCount'] as int;
          final includeAyahMarker = config['includeAyahMarker'] as bool;

          final line = createNonOverflowingLine(
            lineNumber: 1,
            wordCount: wordCount,
            includeAyahMarker: includeAyahMarker,
          );

          final page = QuranPage(
            pageNumber: 1,
            surahName: 'الفاتحة',
            juzNumber: 1,
            hizbNumber: 1,
            lines: [line],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                quranPageProvider(1).overrideWithValue(AsyncValue.data(page)),
              ],
              child: const MaterialApp(
                home: Scaffold(body: QuranPageWidget(pageNumber: 1)),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify LayoutBuilder exists
          final layoutBuilderFinder = find.byType(LayoutBuilder);
          expect(
            layoutBuilderFinder,
            findsOneWidget,
            reason: 'LayoutBuilder should exist for config: $config',
          );

          // Build the widget to get the Row
          final LayoutBuilder layoutBuilder = tester.widget<LayoutBuilder>(
            layoutBuilderFinder,
          );
          final builtWidget = layoutBuilder.builder(
            tester.element(layoutBuilderFinder),
            const BoxConstraints(maxWidth: 400, maxHeight: 100),
          );

          expect(
            builtWidget,
            isA<Row>(),
            reason: 'Row should exist for config: $config',
          );

          final Row rowWidget = builtWidget as Row;
          expect(
            rowWidget.mainAxisAlignment,
            MainAxisAlignment.spaceBetween,
            reason:
                'spaceBetween alignment should be preserved for config: $config',
          );

          // Verify RTL direction
          final directionalityFinder = find.byType(Directionality);
          final directionalityWidgets = tester
              .widgetList<Directionality>(directionalityFinder)
              .toList();

          final hasRtl = directionalityWidgets.any(
            (d) => d.textDirection == TextDirection.rtl,
          );
          expect(
            hasRtl,
            true,
            reason: 'RTL direction should be preserved for config: $config',
          );

          // If ayah marker is included, verify it renders correctly
          if (includeAyahMarker) {
            final ayahMarkerFinder = find.text('١');
            expect(
              ayahMarkerFinder,
              findsOneWidget,
              reason: 'Ayah marker should render for config: $config',
            );
          }
        }
      },
    );
  });
}
