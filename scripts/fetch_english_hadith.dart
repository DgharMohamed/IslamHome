import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final booksToUpdate = [
    {
      'localPath': 'assets/data/hadith/bukhari.json',
      'englishApiSlug': 'eng-bukhari',
    },
    {
      'localPath': 'assets/data/nawawi/nawawi.json',
      'englishApiSlug': 'eng-nawawi',
    },
    {
      'localPath': 'assets/data/qudsi/qudsi.json',
      'englishApiSlug': 'eng-qudsi',
    },
  ];

  final client = HttpClient();

  for (final book in booksToUpdate) {
    try {
      stdout.writeln('Processing ${book['localPath']}...');
      final file = File(book['localPath']!);

      if (!await file.exists()) {
        stdout.writeln('Skipping ${book['localPath']} - file not found.');
        continue;
      }

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);

      var hadithsData = data;
      List<dynamic> localHadiths = [];
      if (hadithsData is List) {
        localHadiths = hadithsData;
      } else if (hadithsData is Map && hadithsData.containsKey('hadiths')) {
        localHadiths = hadithsData['hadiths'];
      } else {
        stdout.writeln('Skipping ${book['localPath']} - Unknown format.');
        continue;
      }

      stdout.writeln('Local hadiths: ${localHadiths.length}');

      // Fetch English
      final url =
          'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${book['englishApiSlug']}.min.json';
      stdout.writeln('Fetching $url...');
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        stdout.writeln(
          'Failed to fetch English translations for ${book['englishApiSlug']}. Status: ${response.statusCode}',
        );
        continue;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final englishData = json.decode(responseBody);
      final englishHadiths = englishData['hadiths'] as List<dynamic>;

      final englishMap = <int, String>{};
      for (final h in englishHadiths) {
        final numRaw = h['hadithnumber'];
        final txt = h['text'];
        final num = _parseNumber(numRaw);
        if (num != null && txt is String) {
          englishMap[num] = txt;
        }
      }

      stdout.writeln('Found ${englishMap.length} English translations.');

      // Merge
      var mergedCount = 0;
      for (var i = 0; i < localHadiths.length; i++) {
        final h = localHadiths[i];
        final num =
            _parseNumber(h['hadithnumber']) ??
            _parseNumber(h['idInBook']) ??
            _parseNumber(h['arabicnumber']);

        if (num != null && englishMap.containsKey(num)) {
          final englishText = englishMap[num]!;

          if (h['english'] is Map) {
            h['english']['text'] = englishText;
          } else {
            h['english'] = englishText;
          }
          mergedCount++;
        }
      }

      stdout.writeln('Merged $mergedCount translations. Saving...');
      await file.writeAsString(json.encode(data));
      stdout.writeln('Saved ${book['localPath']} successfully.');
    } catch (e) {
      stderr.writeln('Error processing ${book['localPath']}: $e');
    }
  }
  client.close();
}

int? _parseNumber(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}
