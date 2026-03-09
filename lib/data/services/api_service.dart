import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:islam_home/data/models/surah_model.dart';
import 'package:islam_home/data/models/radio_model.dart';
import 'package:islam_home/data/models/tv_model.dart';
import 'package:islam_home/data/models/prayer_times_model.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/data/models/video_model.dart';
import 'package:islam_home/data/models/riwaya_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:islam_home/data/models/qf_recitation_model.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const String _recitersApi = 'https://mp3quran.net/api/v3';
  static const String _quranCdnApi =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';
  // Legacy API kept as ultimate fallback
  static const String _alQuranApi = 'https://api.alquran.cloud/v1';
  static const String _hadithCdnApi =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
  static const String _hadithApiLegacy = 'https://api.hadith.gading.dev';
  static const String _quranFoundationApi = 'https://api.quran.com/api/v4';
  static const String _quranFoundationAudioBase = 'https://verses.quran.com/';

  String get quranFoundationAudioBase => _quranFoundationAudioBase;

  // Edition mapping: old identifier -> new CDN identifier

  static const Map<String, String> _hadithBookMap = {
    'bukhari': 'ara-bukhari',
    'muslim': 'ara-muslim',
    'abudawud': 'ara-abudawud',
    'tirmidhi': 'ara-tirmidhi',
    'nasai': 'ara-nasai',
    'ibnmajah': 'ara-ibnmajah',
    'malik': 'ara-malik',
    'ahmad': 'ara-ahmad',
    'darimi': 'ara-darimi',
    'qudsi': 'ara-qudsi',
  };

  // --- Reciters Service ---
  Future<List<Reciter>> getReciters({
    String? rewaya,
    String language = 'ar',
  }) async {
    String url = '$_recitersApi/reciters';

    // Build query parameters
    final params = <String, String>{};
    if (rewaya != null) params['rewaya'] = rewaya;
    params['language'] = language == 'en' ? 'eng' : 'ar';

    // Add params to URL
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reciters'];
        return data.map((json) => Reciter.fromJson(json)).toList();
      }
      throw Exception('Failed to load reciters');
    } catch (e) {
      debugPrint('API Error (getReciters): $e');
      rethrow;
    }
  }

  Future<List<Riwaya>> getRewayat({String language = 'ar'}) async {
    try {
      final response = await _dio.get(
        '$_recitersApi/riwayat?language=$language',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['riwayat'];
        return data.map((json) => Riwaya.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getRewayat): $e');
      return [];
    }
  }

  Future<List<RadioModel>> getRadios({String language = 'ar'}) async {
    try {
      final response = await _dio.get(
        '$_recitersApi/radios?language=$language',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['radios'];
        return data.map((json) => RadioModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getRadios): $e');
      return [];
    }
  }

  Future<List<TvModel>> getLiveTV() async {
    try {
      final response = await _dio.get('$_recitersApi/live-tv');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['livetv'];
        return data.map((json) => TvModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getLiveTV): $e');
      return [];
    }
  }

  // --- Quran Foundation Reciters ---
  Future<List<QFRecitation>> getQFReciters({String language = 'ar'}) async {
    try {
      final response = await _dio.get(
        '$_quranFoundationApi/resources/recitations',
        queryParameters: {'language': language},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['recitations'];
        return data.map((json) => QFRecitation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getQFReciters): $e');
      return [];
    }
  }

  /// Fetches audio files for a specific chapter and reciter from Quran Foundation
  Future<List<dynamic>> getQFAudioForChapter(
    int reciterId,
    int chapterId,
  ) async {
    try {
      final response = await _dio.get(
        '$_quranFoundationApi/quran/recitations/$reciterId',
        queryParameters: {'chapter_number': chapterId},
      );
      if (response.statusCode == 200) {
        return response.data['audio_files'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getQFAudioForChapter): $e');
      return [];
    }
  }

  // --- Prayer Times Service ---
  Future<PrayerTimesModel?> getPrayerTimesByCity(
    String city,
    String country, {
    int method = 3,
  }) async {
    try {
      // API: http://api.aladhan.com/v1/timingsByCity?city=Rabat&country=Morocco&method=3
      final response = await _dio.get(
        'https://api.aladhan.com/v1/timingsByCity',
        queryParameters: {
          'city': city.isNotEmpty ? city : 'Rabat',
          'country': country.isNotEmpty ? country : 'Morocco',
          'method': method,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return PrayerTimesModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('API Error (getPrayerTimesByCity): $e');
      return null;
    }
  }

  Future<PrayerTimesModel?> getPrayerTimesByLocation(
    double latitude,
    double longitude, {
    int method = 3,
  }) async {
    try {
      // API: http://api.aladhan.com/v1/timings?latitude=51.508515&longitude=-0.1254872&method=2
      final response = await _dio.get(
        'https://api.aladhan.com/v1/timings',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return PrayerTimesModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('API Error (getPrayerTimesByLocation): $e');
      return null;
    }
  }

  // --- Hadith Service ---
  Future<List<HadithBook>> getHadithBooks() async {
    try {
      final response = await _dio.get('$_hadithCdnApi/editions.json');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<HadithBook> books = [];

        data.forEach((key, value) {
          final collection = value['collection'] as List;
          final arabicEdition = collection.firstWhere(
            (e) => e['language'] == 'Arabic',
            orElse: () => collection.first,
          );

          books.add(
            HadithBook(
              id: arabicEdition['name'], // e.g. ara-bukhari
              name: value['name'],
              nameAr: _getArabicBookName(key),
              available: _getHadithCount(key),
            ),
          );
        });

        return books;
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getHadithBooks): $e');
      // Fallback
      return _getLegacyHadithBooks();
    }
  }

  int _getHadithCount(String key) {
    switch (key) {
      case 'bukhari':
        return 7563;
      case 'muslim':
        return 7459;
      case 'abudawud':
        return 5274;
      case 'tirmidhi':
        return 3956;
      case 'nasai':
        return 5758;
      case 'ibnmajah':
        return 4341;
      case 'malik':
        return 1849;
      case 'ahmad':
        return 26363;
      default:
        return 1; // At least show it as available if it's in the list
    }
  }

  String _getArabicBookName(String key) {
    if (_hadithBookMap.containsKey(key)) {
      switch (key) {
        case 'bukhari':
          return 'صحيح البخاري';
        case 'muslim':
          return 'صحيح مسلم';
        case 'abudawud':
          return 'سنن أبي داود';
        case 'tirmidhi':
          return 'جامع الترمذي';
        case 'nasai':
          return 'سنن النسائي';
        case 'ibnmajah':
          return 'سنن ابن ماجه';
        case 'malik':
          return 'موطأ مالك';
        case 'ahmad':
          return 'مسند أحمد';
        case 'darimi':
          return 'سنن الدارمي';
      }
    }
    return key;
  }

  Future<List<HadithBook>> _getLegacyHadithBooks() async {
    try {
      final response = await _dio.get('$_hadithApiLegacy/books');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => HadithBook.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<HadithModel>> getHadiths(
    String editionName, {
    int? sectionNumber,
  }) async {
    try {
      final url = sectionNumber != null
          ? '$_hadithCdnApi/editions/$editionName/sections/$sectionNumber.min.json'
          : '$_hadithCdnApi/editions/$editionName.min.json';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> hadithsJson = response.data['hadiths'];
        final metadata = response.data['metadata'];
        final bookName = metadata['name'];

        return hadithsJson.map((json) {
          // Fawaz Ahmed's API structure to HadithModel mapping
          final map = Map<String, dynamic>.from(json);
          final isEnglish = editionName.startsWith('eng-');
          if (isEnglish) {
            map['english'] = map['text'];
          } else {
            map['arab'] = map['text'];
          }
          map['book'] = bookName;

          // Grades handle
          if (map['grades'] != null && (map['grades'] as List).isNotEmpty) {
            map['grade'] = (map['grades'] as List).first['grade'];
          }
          return HadithModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getHadiths): $e');
      return [];
    }
  }

  /// Fetches English translation and merges it with existing Arabic hadiths
  Future<List<HadithModel>> enrichHadithsWithEnglish(
    List<HadithModel> arabicHadiths,
    String bookKey,
  ) async {
    try {
      final englishEdition = 'eng-$bookKey';
      final englishHadiths = await getHadiths(englishEdition);

      if (englishHadiths.isEmpty) return arabicHadiths;

      // Create a map for quick lookup by hadith number
      final englishMap = {for (var h in englishHadiths) h.number: h.english};

      // Merge English text into Arabic models
      return arabicHadiths.map((h) {
        if (h.english != null && h.english!.isNotEmpty) return h;
        final englishText = englishMap[h.number];
        if (englishText != null) {
          return HadithModel(
            id: h.id,
            number: h.number,
            arab: h.arab,
            english: englishText,
            narrator: h.narrator,
            book: h.book,
            chapter: h.chapter,
            grade: h.grade,
          );
        }
        return h;
      }).toList();
    } catch (e) {
      debugPrint('Error enriching hadiths: $e');
      return arabicHadiths;
    }
  }

  // --- Adhkar Service ---
  // Using the same endpoint as React project for Adhkar
  Future<Map<String, List<AdhkarModel>>> getAzkar() async {
    try {
      final response = await _dio.get(
        'https://quran.yousefheiba.com/api/azkar',
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return data.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((i) => AdhkarModel.fromJson(i)).toList(),
          ),
        );
      }
      return {};
    } catch (e) {
      debugPrint('API Error (getAzkar): $e');
      return {};
    }
  }

  Future<Map<String, List<AdhkarModel>>> getDuas() async {
    try {
      final response = await _dio.get('https://quran.yousefheiba.com/api/duas');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return data.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((i) => AdhkarModel.fromJson(i)).toList(),
          ),
        );
      }
      return {};
    } catch (e) {
      debugPrint('API Error (getDuas): $e');
      return {};
    }
  }

  // --- Video Service ---
  Future<List<VideoModel>> getVideos({String language = 'ar'}) async {
    try {
      if (language == 'en') {
        return _getEnglishVideos();
      }

      // Load local videos from JSON (Arabic)
      final String jsonString = await rootBundle.loadString(
        'assets/data/videos.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<VideoModel> localVideos = jsonList
          .map((json) => VideoModel.fromJson(json))
          .toList();

      final hewenyVideos = await _getHewenyVideos();
      final alArefeVideos = await _getAlArefeVideos();

      // Try fetching API videos
      final response = await _dio.get('$_recitersApi/videos?language=ar');
      if (response.statusCode == 200) {
        final List<dynamic> apiData = response.data['videos'];
        final List<VideoModel> apiVideos = apiData
            .map((json) => VideoModel.fromJson(json))
            .toList();
        return [
          ...localVideos,
          ...hewenyVideos,
          ...alArefeVideos,
          ...apiVideos,
        ];
      }
      return [...localVideos, ...hewenyVideos, ...alArefeVideos];
    } catch (e) {
      debugPrint('Error in getVideos: $e');
      // If JSON fails, it's a critical error for the library display
      return [];
    }
  }

  Future<List<VideoModel>> _getEnglishVideos() async {
    final List<VideoModel> enVideos = [];
    final String baseUrl =
        'https://archive.org/download/lifeofthelastmessengerbymuftiismailmenk';
    final String thumbUrl = '$baseUrl/__ia_thumb.jpg';

    for (int i = 1; i <= 29; i++) {
      final String fileName = i < 10 ? '0$i' : '$i';
      enVideos.add(
        VideoModel(
          id: 3000 + i,
          title: 'Life of the Last Messenger - Episode $i',
          description:
              'A detailed biography of Prophet Muhammad ﷺ by Mufti Ismail Menk',
          url:
              '$baseUrl/$fileName-%20Life%20of%20the%20Last%20Messenger%20-%20Mufti%20Menk.mp3',
          thumbUrl: thumbUrl,
          reciter: 'Mufti Ismail Menk',
          videoType: 100, // Biography type for English
        ),
      );
    }
    return enVideos;
  }

  Future<List<VideoModel>> _getAlArefeVideos() async {
    const baseUrl = 'https://archive.org/download/islami-586_202402/';
    final List<Map<String, String>> lectures = [
      {
        'title': 'السيرة النبوية',
        'file':
            '%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D8%AF%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٢ )',
        'file':
            '%D8%A7%D9%84%D8%B4%D9%8A%D8%AE%20%D8%AF%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D8%AF%D8%B1%D9%88%D8%B3%20%D9%85%D9%86%20%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A2%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( 3 )',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%203%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٤ )',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A4%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٥ )',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A5%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٦ )',
        'file':
            '%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A6%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٧ )',
        'file':
            '%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A7%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٨ )',
        'file':
            '%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A8%20%29.mp3',
      },
      {
        'title': 'دروس من السيرة النبوية ( ٩ )',
        'file':
            '%D8%AF%D8%B1%20%D9%88%D8%B3%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%28%20%D9%A9%20%29.mp3',
      },
      {
        'title': 'مواقف من السيرة النبوية',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D9%85%D8%AD%D8%A7%D8%B6%D8%B1%D8%A9%20%D8%A8%D8%B9%D9%86%D9%88%D8%A7%D9%86%20%28%20%D9%85%D9%88%D8%A7%D9%82%D9%81%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D9%8A%D8%A9%20%29%20%D9%81%D9%8A%20%D9%85%D8%AF%D9%8A%D9%86%D8%A9%20%D8%AD%D9%81%D8%B1%20%D8%A7%D9%84%D8%A8%D8%A7%D8%B7%D9%86.mp3',
      },
      {
        'title': 'صفحات من السيرة النبوية',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D9%85%D8%AD%D8%A7%D8%B6%D8%B1%D8%A9%20%D8%A8%D8%B9%D9%86%D9%88%D8%A7%D9%86%20%28%20%D8%B5%D9%81%D8%AD%D8%A7%D8%AA%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%29%D9%81%D9%8A%20%D9%85%D8%AF%D9%8A%D9%86%D9%86%D8%A9%20%D8%AD%D9%81%D8%B1%20%D8%A7%D9%84%D8%A8%D8%A7%D8%B7%D9%86.mp3',
      },
      {
        'title': 'نفحات من السيرة النبوية',
        'file':
            '%D8%AF%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%28%20%20%D9%86%D9%81%D8%AD%D8%A7%D8%AA%20%D9%85%D9%86%20%D8%A7%D9%84%D8%B3%D9%8A%D8%B1%D8%A9%20%D8%A7%D9%84%D9%86%D8%A8%D9%88%D9%8A%D8%A9%20%29.mp3',
      },
      {
        'title': 'بداية الإسلام',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D9%85%D9%86%20%D9%82%D8%B5%D8%B5%20%D8%A7%D9%84%D9%86%D8%A8%D9%8A%20%D9%85%D8%AD%D9%85%D8%AF%20%EF%B7%BA%20%D8%A8%D8%AF%D8%A7%D9%8A%D8%A9%20%D8%A7%D9%84%D9%8A%D8%B1%D8%A7%D9%84%D8%A7%D8%B3%D9%84%D8%A7%D9%85.mp3',
      },
      {
        'title': 'هجرة الرسول صلى الله عليه وسلم',
        'file':
            '%D8%AF%20%D8%A7%D9%84%D8%B9%D8%B1%D9%8A%D9%81%D9%8A%20%D9%82%D8%B5%D8%A9%20%D9%87%D8%AC%D8%B1%D8%A9%20%D8%A7%D9%84%D8%B1%D8%B3%D9%88%D9%84%20%D8%B5%D9%84%D9%89%20%D8%A7%D9%84%D9%84%D9%87%20%D8%B9%D9%84%D9%8A%D8%A9%20%D9%88%D9%81%D9%84%D9%85.mp3',
      },
    ];

    return lectures.asMap().entries.map((entry) {
      final index = entry.key;
      final lecture = entry.value;
      return VideoModel(
        id: 2000 + index,
        title: lecture['title']!,
        reciter: 'الشيخ محمد العريفي',
        url: '$baseUrl${lecture['file']}',
        videoType: 99, // Ar Biography type
      );
    }).toList();
  }

  Future<List<VideoModel>> _getHewenyVideos() async {
    final List<VideoModel> arVideos = [];
    final String baseUrl = 'https://archive.org/download/saheeh_assera';
    final String thumbUrl = '$baseUrl/__ia_thumb.jpg';

    for (int i = 1; i <= 14; i++) {
      final String fileName = i < 10 ? '0$i' : '$i';
      arVideos.add(
        VideoModel(
          id: 4000 + i,
          title: 'صحيح السيرة النبوية - الحلقة $fileName',
          description:
              'سلسلة صحيح السيرة النبوية لفضيلة الشيخ أبو إسحاق الحويني',
          url: '$baseUrl/$fileName.mp3',
          thumbUrl: thumbUrl,
          reciter: 'أبو إسحاق الحويني',
          videoType: 99, // Ar Biography type
        ),
      );
    }
    return arVideos;
  }

  Future<List<VideoType>> getVideoTypes({String language = 'ar'}) async {
    final biographyAr = VideoType(id: 99, name: "السيرة النبوية");
    final biographyEn = VideoType(id: 100, name: "Prophetic Biography");
    final biographyType = language == 'en' ? biographyEn : biographyAr;

    try {
      final response = await _dio.get(
        '$_recitersApi/video_types?language=${language == 'en' ? 'eng' : 'ar'}',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['video_types'];
        final List<VideoType> apiTypes = data
            .map((json) => VideoType.fromJson(json))
            .toList();
        return [biographyType, ...apiTypes];
      }
      return [biographyType];
    } catch (e) {
      debugPrint('API Error (getVideoTypes): $e');
      return [biographyType];
    }
  }

  // --- Search Utility ---
  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    if (query.isEmpty) return {'reciters': [], 'surahs': []};

    final results = await Future.wait([getReciters(), getSurahs()]);

    final List<Reciter> allReciters = results[0] as List<Reciter>;
    final List<Surah> allSurahs = results[1] as List<Surah>;

    final filteredReciters = allReciters
        .where((r) => r.name?.contains(query) ?? false)
        .take(10)
        .toList();

    final filteredSurahs = allSurahs
        .where(
          (s) =>
              (s.name?.contains(query) ?? false) ||
              (s.englishName?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .take(10)
        .toList();

    return {'reciters': filteredReciters, 'surahs': filteredSurahs};
  }

  // --- General App Data Needs ---
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await _dio.get('$_quranCdnApi/info.min.json');
      if (response.statusCode == 200 && response.data['chapters'] != null) {
        final List<dynamic> chapters = response.data['chapters'];
        return chapters.map((ch) {
          return Surah.fromJson({
            'number': ch['chapter'],
            'name': ch['arabicname'] ?? ch['name'],
            'englishName': ch['englishname'] ?? ch['name'],
            'revelationType': ch['revelation'] ?? 'Mecca',
            'numberOfAyahs': (ch['verses'] as List?)?.length ?? 0,
          });
        }).toList();
      }
    } catch (e) {
      debugPrint('CDN Surahs fetch error: $e');
    }
    // Fallback
    try {
      final response = await _dio.get('$_alQuranApi/surah');
      final data = response.data['data'] as List;
      return data.map((json) => Surah.fromJson(json)).toList();
    } catch (e2) {
      debugPrint('Legacy Surahs fetch error: $e2');
      return [];
    }
  }

  Future<List<dynamic>> searchQuran(String query) async {
    // Return empty list safely for now as search is being refactored
    return [];
  }
}
