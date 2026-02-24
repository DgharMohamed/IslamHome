import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islam_home/data/models/hadith_model.dart';

class LocalHadithService {
  // Cache for loaded hadiths
  Map<String, List<HadithModel>>? _hadithCache;

  /// Load all Hadiths from local JSON files
  Future<Map<String, List<HadithModel>>> loadAllHadiths() async {
    if (_hadithCache != null) return _hadithCache!;

    try {
      _hadithCache = {};

      // Load Bukhari
      final bukhariHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/bukhari.json',
        'bukhari',
      );
      _hadithCache!['bukhari'] = bukhariHadiths;

      // Load Muslim
      final muslimHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/muslim.json',
        'muslim',
      );
      _hadithCache!['muslim'] = muslimHadiths;

      // Load Abu Dawud
      final abudawudHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/abudawud.json',
        'abudawud',
      );
      _hadithCache!['abudawud'] = abudawudHadiths;

      // Load Tirmidhi
      final tirmidhiHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/tirmidhi.json',
        'tirmidhi',
      );
      _hadithCache!['tirmidhi'] = tirmidhiHadiths;

      // Load Nasa'i
      final nasaiHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/nasai.json',
        'nasai',
      );
      _hadithCache!['nasai'] = nasaiHadiths;

      // Load Ibn Majah
      final ibnmajahHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/ibnmajah.json',
        'ibnmajah',
      );
      _hadithCache!['ibnmajah'] = ibnmajahHadiths;

      // Load Malik
      final malikHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/malik.json',
        'malik',
      );
      _hadithCache!['malik'] = malikHadiths;

      // Load Nawawi
      final nawawiHadiths = await _loadHadithsFromFile(
        'assets/data/nawawi/nawawi.json',
        'nawawi',
      );
      _hadithCache!['nawawi'] = nawawiHadiths;

      // Load Qudsi
      final qudsiHadiths = await _loadHadithsFromFile(
        'assets/data/qudsi/qudsi.json',
        'qudsi',
      );
      _hadithCache!['qudsi'] = qudsiHadiths;

      return _hadithCache!;
    } catch (e) {
      debugPrint('Error loading Hadiths: $e');
      return {};
    }
  }

  /// Load Hadiths from a specific file
  Future<List<HadithModel>> _loadHadithsFromFile(
    String path,
    String bookSlug,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      debugPrint('Loaded $path: ${jsonString.length} chars');
      final jsonData = json.decode(jsonString);

      List<HadithModel> hadiths = [];

      if (jsonData is List) {
        hadiths = jsonData.map((item) {
          final hadithMap = Map<String, dynamic>.from(item as Map);
          hadithMap['bookSlug'] = bookSlug;
          hadithMap['book'] =
              bookSlug; // Should eventually use localized name lookup
          return HadithModel.fromJson(_normalizeHadithMap(hadithMap));
        }).toList();
      } else if (jsonData is Map && jsonData.containsKey('hadiths')) {
        hadiths = (jsonData['hadiths'] as List).map((item) {
          final hadithMap = Map<String, dynamic>.from(item as Map);
          hadithMap['bookSlug'] = bookSlug;
          hadithMap['book'] = bookSlug;
          return HadithModel.fromJson(_normalizeHadithMap(hadithMap));
        }).toList();
      }

      debugPrint('Parsed ${hadiths.length} hadiths from $path');

      return hadiths;
    } catch (e) {
      debugPrint('Error loading from $path: $e');
      return [];
    }
  }

  /// Normalize Hadith Map to match HadithModel keys
  Map<String, dynamic> _normalizeHadithMap(Map<String, dynamic> map) {
    // Helper to safely convert any value to string or null
    String? toString(dynamic val) => val?.toString();

    // Map 'arabic' to 'text' (which is then mapped to 'arab' in HadithModel)
    if (map.containsKey('arabic') && !map.containsKey('text')) {
      map['text'] = toString(map['arabic']);
    } else {
      map['text'] = toString(map['text']);
    }

    // Map 'idInBook' to 'hadithnumber'
    if (map.containsKey('idInBook') && !map.containsKey('hadithnumber')) {
      map['hadithnumber'] = map['idInBook']; // This matches int? in model
    }

    // Map complex 'english' object to flat fields
    if (map['english'] is Map) {
      final englishMap = map['english'] as Map<String, dynamic>;
      map['narrator'] = toString(englishMap['narrator']);
      map['english'] = toString(englishMap['text']);
    } else {
      map['english'] = toString(map['english']);
    }

    // Ensure all other potentially problematic fields are strings
    final hNumber = map['hadithnumber']?.toString() ?? '0';
    map['id'] = toString(map['id']) ?? '${map['bookSlug']}_$hNumber';
    map['chapter'] = toString(map['chapter']);
    map['grade'] = toString(map['grade']);
    map['narrator'] = toString(map['narrator']);

    return map;
  }

  /// Get Hadiths by book
  Future<List<HadithModel>> getHadithsByBook(String bookKey) async {
    final allHadiths = await loadAllHadiths();
    return allHadiths[bookKey] ?? [];
  }

  /// Get all available books
  Future<List<String>> getAvailableBooks() async {
    final allHadiths = await loadAllHadiths();
    return allHadiths.keys.toList();
  }

  /// Search Hadiths
  Future<List<HadithModel>> searchHadiths(String query) async {
    final allHadiths = await loadAllHadiths();
    final results = <HadithModel>[];

    allHadiths.forEach((book, hadiths) {
      results.addAll(
        hadiths.where(
          (hadith) =>
              hadith.arab?.contains(query) == true ||
              hadith.english?.contains(query) == true ||
              hadith.chapter?.contains(query) == true,
        ),
      );
    });

    return results;
  }

  /// Get random Hadith (for daily hadith widget)
  Future<HadithModel?> getRandomHadith({bool requireEnglish = false}) async {
    final allHadiths = await loadAllHadiths();
    if (allHadiths.isEmpty) return null;

    final allHadithsList = <HadithModel>[];
    allHadiths.forEach((book, hadiths) => allHadithsList.addAll(hadiths));

    if (allHadithsList.isEmpty) return null;

    // Filter if english is required
    var validHadiths = allHadithsList;
    if (requireEnglish) {
      final englishHadiths = allHadithsList
          .where((h) => h.english != null && h.english!.trim().isNotEmpty)
          .toList();

      // Only apply filter if we found some English hadiths
      if (englishHadiths.isNotEmpty) {
        validHadiths = englishHadiths;
      }
    }

    // Use a seed based on the date to ensure the same hadith is shown all day
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    // Simple pseudo-random index based on seed
    final index = seed % validHadiths.length;

    return validHadiths[index];
  }

  /// Get all available books as HadithBook objects
  Future<List<HadithBook>> getLocalBooks() async {
    return [
      // Currently available with local data
      // Most popular / important
      HadithBook(
        id: 'nawawi',
        name: "An-Nawawi's Forty",
        nameAr: 'الأربعون النووية',
        available: 42,
        totalHadiths: 42,
      ),
      HadithBook(
        id: 'bukhari',
        name: 'Sahih al-Bukhari',
        nameAr: 'صحيح البخاري',
        available: 7563,
        totalHadiths: 7563,
      ),
      HadithBook(
        id: 'muslim',
        name: 'Sahih Muslim',
        nameAr: 'صحيح مسلم',
        available: 7459,
        totalHadiths: 7459,
      ),
      HadithBook(
        id: 'qudsi',
        name: 'Hadith Qudsi',
        nameAr: 'الأحاديث القدسية',
        available: 40,
        totalHadiths: 40,
      ),
      // Sunan & Others
      HadithBook(
        id: 'tirmidhi',
        name: "Jami' at-Tirmidhi",
        nameAr: 'جامع الترمذي',
        available: 3956,
        totalHadiths: 3956,
      ),
      HadithBook(
        id: 'abudawud',
        name: 'Sunan Abu Dawud',
        nameAr: 'سنن أبي داود',
        available: 5274,
        totalHadiths: 5274,
      ),
      HadithBook(
        id: 'nasai',
        name: "Sunan an-Nasa'i",
        nameAr: 'سنن النسائي',
        available: 5758,
        totalHadiths: 5758,
      ),
      HadithBook(
        id: 'ibnmajah',
        name: 'Sunan Ibn Majah',
        nameAr: 'سنن ابن ماجه',
        available: 4341,
        totalHadiths: 4341,
      ),
      HadithBook(
        id: 'malik',
        name: 'Muwatta Malik',
        nameAr: 'موطأ مالك',
        available: 1849,
        totalHadiths: 1849,
      ),
    ];
  }
}
