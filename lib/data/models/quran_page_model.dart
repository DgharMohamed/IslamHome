import 'package:hive/hive.dart';

part 'quran_page_model.g.dart';

/// Represents a single word in the Quran text.
@HiveType(typeId: 30)
class QuranWord {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int position;
  @HiveField(2)
  final String textUthmani;
  @HiveField(3)
  final String charTypeName;
  @HiveField(4)
  final int? lineNumber;
  @HiveField(5)
  final String verseKey;
  @HiveField(6)
  final int pageNumber;
  @HiveField(7)
  final String? audioUrl;

  QuranWord({
    required this.id,
    required this.position,
    required this.textUthmani,
    required this.charTypeName,
    this.lineNumber,
    required this.verseKey,
    required this.pageNumber,
    this.audioUrl,
  });

  factory QuranWord.fromJson(
    Map<String, dynamic> json,
    String verseKey,
    int pageNumber,
  ) {
    return QuranWord(
      id: json['id'],
      position: json['position'],
      textUthmani: json['text_uthmani'] ?? '',
      charTypeName: json['char_type_name'],
      lineNumber: json['line_number'],
      verseKey: verseKey,
      pageNumber: pageNumber,
      audioUrl: json['audio_url'],
    );
  }
}

/// Represents a single line in the Madinah Mushaf (fixed 15 lines per page).
@HiveType(typeId: 31)
class QuranLine {
  @HiveField(0)
  final int lineNumber;
  @HiveField(1)
  final List<QuranWord> words;

  QuranLine({required this.lineNumber, required this.words});
}

/// Represents a full Madinah Mushaf page.
@HiveType(typeId: 32)
class QuranPage {
  @HiveField(0)
  final int pageNumber;
  @HiveField(1)
  final String surahName;
  @HiveField(2)
  final int juzNumber;
  @HiveField(3)
  final int hizbNumber;
  @HiveField(4)
  final List<QuranLine> lines; // Exactly 15 lines

  QuranPage({
    required this.pageNumber,
    required this.surahName,
    required this.juzNumber,
    required this.hizbNumber,
    required this.lines,
  }) {
    assert(
      lines.length <= 15,
      'A Quran page cannot have more than 15 lines in Madinah Mushaf',
    );
  }
}
