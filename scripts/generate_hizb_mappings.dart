// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('Processing local quran-uthmani.json...');
  final Map<int, Map<String, int>> hizbMapping = {};

  try {
    final file = File('assets/data/quran/quran-uthmani.json');
    if (!file.existsSync()) {
      print('File not found: ${file.path}');
      return;
    }

    final contents = await file.readAsString();
    final data = jsonDecode(contents)['data'];
    final surahs = data['surahs'] as List;

    for (var surah in surahs) {
      final surahNum = surah['number'] as int;
      final ayahs = surah['ayahs'] as List;
      for (var ayah in ayahs) {
        final ayahNum = ayah['numberInSurah'] as int;

        // Ensure proper division formatting in dart
        double hizbQ = ayah['hizbQuarter'] is int
            ? (ayah['hizbQuarter'] as int).toDouble()
            : ayah['hizbQuarter'] as double;
        final actualHizb = (hizbQ / 4).ceil();

        if (!hizbMapping.containsKey(actualHizb)) {
          hizbMapping[actualHizb] = {'surah': surahNum, 'ayah': ayahNum};
        }
      }
    }

    print('\n--- Hizb Mappings ---');
    print('  static const Map<int, Map<String, int>> hizbMapping = {');
    for (int i = 1; i <= 60; i++) {
      print(
        '    $i: {\'surah\': ${hizbMapping[i]!['surah']}, \'ayah\': ${hizbMapping[i]!['ayah']}},',
      );
    }
    print('  };');
  } catch (e, stack) {
    print('Error: $e\n$stack');
  }
}
