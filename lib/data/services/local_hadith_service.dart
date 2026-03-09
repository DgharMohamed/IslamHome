import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/data/services/api_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalHadithService {
  LocalHadithService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  static const Map<String, String> _bundledAssetByBook = {
    'nawawi': 'assets/data/nawawi/nawawi.json',
    'qudsi': 'assets/data/qudsi/qudsi.json',
  };

  static const Map<String, String> _legacyBundledAssetByBook = {
    'bukhari': 'assets/data/hadith/bukhari.json',
    'muslim': 'assets/data/hadith/muslim.json',
    'abudawud': 'assets/data/hadith/abudawud.json',
    'tirmidhi': 'assets/data/hadith/tirmidhi.json',
    'nasai': 'assets/data/hadith/nasai.json',
    'ibnmajah': 'assets/data/hadith/ibnmajah.json',
    'malik': 'assets/data/hadith/malik.json',
    'nawawi': 'assets/data/nawawi/nawawi.json',
    'qudsi': 'assets/data/qudsi/qudsi.json',
  };

  static const Map<String, String> _remoteEditionByBook = {
    'bukhari': 'ara-bukhari',
    'muslim': 'ara-muslim',
    'abudawud': 'ara-abudawud',
    'tirmidhi': 'ara-tirmidhi',
    'nasai': 'ara-nasai',
    'ibnmajah': 'ara-ibnmajah',
    'malik': 'ara-malik',
    'qudsi': 'ara-qudsi',
  };

  Map<String, List<HadithModel>>? _hadithCache;

  /// Loads already available hadith content (bundled lightweight data + downloaded books).
  Future<Map<String, List<HadithModel>>> loadAllHadiths() async {
    _hadithCache ??= <String, List<HadithModel>>{};

    try {
      await _loadBundledBooksIntoCache();
      await _loadDownloadedBooksIntoCache();

      return _hadithCache!;
    } catch (e) {
      debugPrint('Error loading Hadiths: $e');
      return _hadithCache ?? <String, List<HadithModel>>{};
    }
  }

  Future<Directory> _getHadithDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hadithDir = Directory(p.join(appDir.path, 'hadith_books'));
    if (!await hadithDir.exists()) {
      await hadithDir.create(recursive: true);
    }
    return hadithDir;
  }

  Future<File> _getHadithFile(String bookSlug) async {
    final dir = await _getHadithDirectory();
    return File(p.join(dir.path, '$bookSlug.json'));
  }

  Future<void> _loadBundledBooksIntoCache() async {
    for (final entry in _bundledAssetByBook.entries) {
      if (_hadithCache!.containsKey(entry.key)) continue;
      final hadiths = await _loadHadithsFromAsset(entry.value, entry.key);
      if (hadiths.isNotEmpty) {
        _hadithCache![entry.key] = hadiths;
      }
    }
  }

  Future<void> _loadDownloadedBooksIntoCache() async {
    Directory dir;
    try {
      dir = await _getHadithDirectory();
    } catch (_) {
      return;
    }

    final files = await dir
        .list()
        .where((e) => e is File)
        .cast<File>()
        .toList();
    for (final file in files) {
      if (p.extension(file.path).toLowerCase() != '.json') continue;
      final bookSlug = p.basenameWithoutExtension(file.path);
      if (_hadithCache!.containsKey(bookSlug)) continue;
      final hadiths = await _loadHadithsFromDisk(bookSlug);
      if (hadiths.isNotEmpty) {
        _hadithCache![bookSlug] = hadiths;
      }
    }
  }

  Future<List<HadithModel>> _loadHadithsFromAsset(
    String assetPath,
    String bookSlug,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
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

      return hadiths;
    } catch (e) {
      debugPrint('Error loading from asset $assetPath: $e');
      return [];
    }
  }

  Future<List<HadithModel>> _loadHadithsFromDisk(String bookSlug) async {
    try {
      final file = await _getHadithFile(bookSlug);
      if (!await file.exists()) return [];

      final jsonString = await file.readAsString();
      final decoded = json.decode(jsonString);
      if (decoded is! List) return [];

      return decoded.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        map['bookSlug'] ??= bookSlug;
        map['book'] ??= bookSlug;
        return HadithModel.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error reading downloaded hadith book $bookSlug: $e');
      return [];
    }
  }

  Future<void> _saveHadithsToDisk(
    String bookSlug,
    List<HadithModel> hadiths,
  ) async {
    try {
      final file = await _getHadithFile(bookSlug);
      final serialized = hadiths.map((hadith) {
        final map = hadith.toJson();
        map['bookSlug'] ??= bookSlug;
        map['book'] ??= bookSlug;
        return map;
      }).toList();
      await file.writeAsString(json.encode(serialized));
    } catch (e) {
      debugPrint('Error saving downloaded hadith book $bookSlug: $e');
    }
  }

  Future<List<HadithModel>> _downloadBookFromApi(
    String bookSlug,
    String editionName,
  ) async {
    try {
      final remote = await _apiService.getHadiths(editionName);
      if (remote.isEmpty) return [];

      final normalized = remote.map((hadith) {
        final number = hadith.number ?? 0;
        return HadithModel(
          id: hadith.id ?? '${bookSlug}_$number',
          number: hadith.number,
          arab: hadith.arab,
          english: hadith.english,
          narrator: hadith.narrator,
          book: hadith.book ?? bookSlug,
          bookSlug: bookSlug,
          chapter: hadith.chapter,
          grade: hadith.grade,
        );
      }).toList();

      await _saveHadithsToDisk(bookSlug, normalized);
      return normalized;
    } catch (e) {
      debugPrint('Error downloading hadith book $bookSlug: $e');
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
    final cached = allHadiths[bookKey];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final legacyAsset = _legacyBundledAssetByBook[bookKey];
    if (legacyAsset != null) {
      final legacyData = await _loadHadithsFromAsset(legacyAsset, bookKey);
      if (legacyData.isNotEmpty) {
        allHadiths[bookKey] = legacyData;
        return legacyData;
      }
    }

    final remoteEdition = _remoteEditionByBook[bookKey];
    if (remoteEdition == null) {
      return [];
    }

    final downloaded = await _downloadBookFromApi(bookKey, remoteEdition);
    if (downloaded.isNotEmpty) {
      allHadiths[bookKey] = downloaded;
    }
    return downloaded;
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
