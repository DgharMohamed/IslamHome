import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:islam_home/data/models/surah_model.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:islam_home/core/utils/quran_utils.dart';

/// Service for loading Quran data from local JSON assets
class LocalQuranService {
  // Cache for loaded data
  Map<String, dynamic>? _quranUthmaniCache;
  Map<String, dynamic>? _translationCache;
  final Map<String, Map<String, dynamic>> _tafseerCaches = {};
  List<Surah>? _surahsCache;

  /// Load Quran text in Uthmani script
  Future<Map<String, dynamic>> _loadQuranUthmani() async {
    if (_quranUthmaniCache != null) return _quranUthmaniCache!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran/quran-uthmani.json',
      );
      _quranUthmaniCache = await compute(_parseJson, jsonString);
      return _quranUthmaniCache!;
    } catch (e) {
      throw Exception('Failed to load offline Quran data: $e');
    }
  }

  /// Load English translation
  Future<Map<String, dynamic>> _loadTranslation() async {
    if (_translationCache != null) return _translationCache!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran/en.sahih.json',
      );
      _translationCache = await compute(_parseJson, jsonString);
      return _translationCache!;
    } catch (e) {
      throw Exception('Failed to load offline translation: $e');
    }
  }

  /// Load Tafseer by edition
  Future<Map<String, dynamic>> _loadTafseer(String edition) async {
    if (_tafseerCaches.containsKey(edition)) {
      return _tafseerCaches[edition]!;
    }

    try {
      String assetPath;
      switch (edition) {
        case 'ar.jalalayn':
          assetPath = 'assets/data/quran/ar.jalalayn.json';
          break;
        case 'ar.muyassar':
          assetPath = 'assets/data/quran/ar.muyassar.json';
          break;
        case 'ar.tanweer':
          assetPath = 'assets/data/quran/ar.tanweer.json';
          break;
        case 'ar.waseet':
          assetPath = 'assets/data/quran/ar.waseet.json';
          break;
        case 'en.ahmedali':
          assetPath = 'assets/data/quran/en.ahmedali.json';
          break;
        case 'en.asad':
          assetPath = 'assets/data/quran/en.asad.json';
          break;
        case 'en.hilali':
          assetPath = 'assets/data/quran/en.hilali.json';
          break;
        case 'en.pickthall':
          assetPath = 'assets/data/quran/en.pickthall.json';
          break;
        case 'en.yusufali':
          assetPath = 'assets/data/quran/en.yusufali.json';
          break;
        default:
          throw Exception('Unsupported tafseer edition: $edition');
      }

      final jsonString = await rootBundle.loadString(assetPath);
      final data = await compute(_parseJson, jsonString);
      _tafseerCaches[edition] = data;
      return data;
    } catch (e) {
      throw Exception('Failed to load offline tafseer $edition: $e');
    }
  }

  /// Get list of all Surahs
  Future<List<Surah>> getSurahs() async {
    if (_surahsCache != null) return _surahsCache!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/quran/surahs.json',
      );
      final data = json.decode(jsonString);
      final List<dynamic> surahsList = data['data'];
      _surahsCache = surahsList.map((json) => Surah.fromJson(json)).toList();
      return _surahsCache!;
    } catch (e) {
      throw Exception('Failed to load surahs list: $e');
    }
  }

  /// Get Quran Surah content by number
  Future<QuranSurahContent?> getQuranSurah(
    int surahNumber, {
    String edition = 'quran-uthmani',
  }) async {
    try {
      Map<String, dynamic> data;

      if (edition == 'quran-uthmani') {
        data = await _loadQuranUthmani();
      } else if (edition == 'en.sahih') {
        data = await _loadTranslation();
      } else {
        // For other editions, return null (will fallback to online)
        return null;
      }

      // Extract the specific surah from the full Quran data
      final List<dynamic> surahs = data['data']['surahs'];
      final surahData = surahs.firstWhere(
        (s) => s['number'] == surahNumber,
        orElse: () => null,
      );

      if (surahData == null) return null;

      return QuranSurahContent.fromJson(surahData);
    } catch (e) {
      return null;
    }
  }

  /// Get Ayah Tafseer
  Future<String?> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    String edition = 'ar.jalalayn',
  }) async {
    // Check if this edition is supported offline
    final supportedEditions = [
      'ar.jalalayn',
      'ar.muyassar',
      'ar.tanweer',
      'ar.waseet',
      'en.ahmedali',
      'en.asad',
      'en.hilali',
      'en.pickthall',
      'en.yusufali',
    ];

    if (!supportedEditions.contains(edition)) {
      return null;
    }

    try {
      final data = await _loadTafseer(edition);
      final List<dynamic> surahs = data['data']['surahs'];
      final surahData = surahs.firstWhere(
        (s) => s['number'] == surahNumber,
        orElse: () => null,
      );

      if (surahData == null) return null;

      final List<dynamic> ayahs = surahData['ayahs'];
      final ayahData = ayahs.firstWhere(
        (a) => a['numberInSurah'] == ayahNumber,
        orElse: () => null,
      );

      return ayahData?['text'];
    } catch (e) {
      debugPrint('Error loading tafseer $edition: $e');
      return null;
    }
  }

  /// Get Quran page content
  Future<QuranSurahContent?> getQuranPage(
    int pageNumber, {
    String edition = 'quran-uthmani',
  }) async {
    // For pages, we need to filter ayahs by page number
    try {
      final data = await _loadQuranUthmani();
      final List<dynamic> surahs = data['data']['surahs'];

      // Collect all ayahs from all surahs that belong to this page
      List<dynamic> pageAyahs = [];
      for (var surah in surahs) {
        final List<dynamic> ayahs = surah['ayahs'];
        pageAyahs.addAll(ayahs.where((ayah) => ayah['page'] == pageNumber));
      }

      if (pageAyahs.isEmpty) return null;

      // Create a synthetic surah content with these ayahs
      return QuranSurahContent.fromJson({
        'number': pageAyahs.first['surah']['number'],
        'name': pageAyahs.first['surah']['name'],
        'englishName': pageAyahs.first['surah']['englishName'],
        'englishNameTranslation':
            pageAyahs.first['surah']['englishNameTranslation'],
        'revelationType': pageAyahs.first['surah']['revelationType'],
        'numberOfAyahs': pageAyahs.length,
        'ayahs': pageAyahs,
      });
    } catch (e) {
      return null;
    }
  }

  /// Search verses (Ayahs)
  Future<List<Ayah>> searchVerses(String query) async {
    if (query.length < 2) return [];

    final List<Ayah> results = [];
    try {
      final isArabicQuery = QuranUtils.isArabic(query);
      final normalizedQuery = isArabicQuery
          ? QuranUtils.normalizeArabic(query)
          : query.toLowerCase();

      // Search in Uthmani text
      final uthmaniData = await _loadQuranUthmani();
      final List<dynamic> surahs = uthmaniData['data']['surahs'];

      for (var surahJson in surahs) {
        final List<dynamic> ayahs = surahJson['ayahs'];
        for (var ayahJson in ayahs) {
          final String text = ayahJson['text'] ?? '';
          final normalizedAyah = QuranUtils.normalizeArabic(text);

          if (normalizedAyah.contains(normalizedQuery)) {
            // Add surah info to ayah
            final Map<String, dynamic> enrichedAyah = Map.from(ayahJson);
            enrichedAyah['surah'] = {
              'number': surahJson['number'],
              'name': surahJson['name'],
              'englishName': surahJson['englishName'],
            };
            results.add(Ayah.fromJson(enrichedAyah));
          }
        }
      }

      // Also search in translation if query is not Arabic
      if (!isArabicQuery) {
        final transData = await _loadTranslation();
        final List<dynamic> transSurahs = transData['data']['surahs'];

        for (var surahJson in transSurahs) {
          final List<dynamic> ayahs = surahJson['ayahs'];
          for (var ayahJson in ayahs) {
            final String text = ayahJson['text'] ?? '';
            if (text.toLowerCase().contains(normalizedQuery)) {
              // Avoid duplicates if already found in Arabic (unlikely for English query)
              final Map<String, dynamic> enrichedAyah = Map.of(ayahJson);
              enrichedAyah['surah'] = {
                'number': surahJson['number'],
                'name': surahJson['name'],
                'englishName': surahJson['englishName'],
              };
              results.add(Ayah.fromJson(enrichedAyah));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Search Error: $e');
    }

    return results;
  }

  /// Get random Ayah for daily display
  Future<Ayah?> getRandomAyah() async {
    try {
      final uthmaniData = await _loadQuranUthmani();
      final List<dynamic> surahs = uthmaniData['data']['surahs'];

      // Use date to pick a deterministic "random" surah and ayah
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

      final surahIndex = dayOfYear % surahs.length;
      final surahJson = surahs[surahIndex];
      final List<dynamic> ayahs = surahJson['ayahs'];

      if (ayahs.isEmpty) return null;

      final ayahIndex = dayOfYear % ayahs.length;
      final ayahJson = ayahs[ayahIndex];

      // Add surah info
      final Map<String, dynamic> enrichedAyah = Map.from(ayahJson);
      enrichedAyah['surah'] = {
        'number': surahJson['number'],
        'name': surahJson['name'],
        'englishName': surahJson['englishName'],
      };

      return Ayah.fromJson(enrichedAyah);
    } catch (e) {
      debugPrint('Error getting random ayah: $e');
      return null;
    }
  }

  /// Check if offline data is available
  Future<bool> isOfflineDataAvailable() async {
    try {
      await rootBundle.loadString('assets/data/quran/quran-uthmani.json');
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Helper function for compute
Map<String, dynamic> _parseJson(String jsonString) {
  return json.decode(jsonString) as Map<String, dynamic>;
}
