import 'package:islam_home/data/models/quran_page_model.dart';

class QuranTransformationLayer {
  /// Transforms raw API response into a structured QuranPage with exactly 15 lines.
  static QuranPage transform(Map<String, dynamic> apiResponse, int pageNumber) {
    final List<dynamic> verses = apiResponse['verses'] ?? [];

    // Group words by line_number
    final Map<int, List<QuranWord>> linesMap = {};

    String surahName = '';
    int juzNumber = 0;
    int hizbNumber = 0;

    if (verses.isNotEmpty) {
      final firstVerse = verses.first;
      juzNumber = firstVerse['juz_number'] ?? 0;
      hizbNumber = firstVerse['hizb_number'] ?? 0;
      final chapterId = firstVerse['chapter_id'];
      surahName = 'سورة $chapterId'; // Placeholder name
    }

    for (var verse in verses) {
      final String verseKey = verse['verse_key'];

      // We take the surah name from the first verse usually or can be looked up
      // For now, let's keep track of juz/hizb from the first verse

      final List<dynamic> words = verse['words'] ?? [];
      for (var wordJson in words) {
        final int? lineNum = wordJson['line_number'];
        if (lineNum == null) continue;

        final word = QuranWord.fromJson(wordJson, verseKey, pageNumber);

        linesMap.putIfAbsent(lineNum, () => []).add(word);
      }
    }

    // Convert map to List<QuranLine> and ensure 15 lines
    final List<QuranLine> lines = [];

    // Madinah Mushaf always has 15 lines.
    // Sometimes the API might not return all 15 if a page is short (rare for Madinah Mushaf)
    // but usually it starts from 1 up to 15.

    for (int i = 1; i <= 15; i++) {
      final List<QuranWord> words = linesMap[i] ?? [];
      // Even if words are empty, we keep the line for the 15-line layout consistency
      lines.add(QuranLine(lineNumber: i, words: words));
    }

    return QuranPage(
      pageNumber: pageNumber,
      surahName:
          surahName, // This might need a separate lookup for the surah name displayed at the top
      juzNumber: juzNumber,
      hizbNumber: hizbNumber,
      lines: lines,
    );
  }
}
