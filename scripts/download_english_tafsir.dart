// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🕌 بدء تحميل التفاسير الإنجليزية...\n');

  final tafasir = {
    'en.ahmedali': 'Ahmed Ali',
    'en.asad': 'Muhammad Asad',
    'en.hilali': 'Hilali & Khan',
    'en.pickthall': 'Pickthall',
    'en.yusufali': 'Yusuf Ali',
  };

  for (var entry in tafasir.entries) {
    final edition = entry.key;
    final name = entry.value;

    print('📥 جاري تحميل $name ($edition)...');

    try {
      final url = 'https://api.alquran.cloud/v1/quran/$edition';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final filePath = 'assets/data/quran/$edition.json';

        // Create directory if it doesn't exist
        final file = File(filePath);
        await file.parent.create(recursive: true);

        // Write the file
        await file.writeAsString(JsonEncoder.withIndent('  ').convert(data));

        print('✅ تم تحميل $name بنجاح!\n');
      } else {
        print('❌ فشل تحميل $name (Status: ${response.statusCode})\n');
      }
    } catch (e) {
      print('❌ خطأ في تحميل $name: $e\n');
    }

    // Wait a bit between requests to be respectful to the API
    await Future.delayed(Duration(seconds: 2));
  }

  print('✨ اكتمل التحميل!');
  print('📁 الملفات محفوظة في: assets/data/quran/');
}
