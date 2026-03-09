import 'package:dio/dio.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/data/models/tafsir_model.dart';
import 'package:flutter/foundation.dart';

class TafsirRepository {
  final Dio _dio = Dio();
  final String baseUrl = 'https://mp3quran.net/api/v3';

  // Specific IDs for manually added tafasir
  static const int saadiId = 1000;
  static const String saadiBaseUrl =
      'https://archive.org/download/Tafseer_Al-Saadi_mp3/';

  Future<List<TafsirItem>> getAvailableTafasir({String language = 'ar'}) async {
    try {
      final response = await _dio.get('$baseUrl/tafasir?language=$language');
      final data = response.data['tafasir'] as List;
      final apiTafasir = data.map((e) => TafsirItem.fromJson(e)).toList();

      // Inject Saadi Audio Tafsir
      apiTafasir.insert(
        0,
        TafsirItem(
          id: saadiId,
          url: saadiBaseUrl,
          name: language == 'en'
              ? 'Tafseer Al-Saadi (Audio)'
              : 'تفسير السعدي (صوتي)',
        ),
      );

      return apiTafasir;
    } catch (e) {
      debugPrint('Error fetching available tafasir: $e');
      throw Exception('Failed to load tafasir');
    }
  }

  Future<List<TafsirSurah>> getTafsirSurahs(
    int tafsirId, {
    String language = 'ar',
  }) async {
    if (tafsirId == saadiId) {
      return _generateSaadiSurahs(language);
    }
    try {
      final response = await _dio.get(
        '$baseUrl/tafsir?tafsir=$tafsirId&language=$language',
      );
      final data = response.data['tafasir']['soar'] as List;
      return data.map((e) => TafsirSurah.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching tafsir surahs: $e');
      throw Exception('Failed to load tafsir surahs');
    }
  }

  List<TafsirSurah> _generateSaadiSurahs(String language) {
    // Generate 114 surahs for Al-Saadi Archive.org collection
    return List.generate(114, (index) {
      final surahNumber = index + 1;
      final isEn = language == 'en';
      final surahName = isEn
          ? QuranUtils.getSurahName(surahNumber, isEnglish: true)
          : QuranUtils.getSurahName(surahNumber, isEnglish: false);
      final fileName = surahNumber.toString().padLeft(3, '0');

      return TafsirSurah(
        id: 10000 + surahNumber,
        tafsirId: saadiId,
        name: isEn ? 'Surah $surahName' : 'سورة $surahName',
        url: '$saadiBaseUrl$fileName.mp3',
        surahId: surahNumber,
      );
    });
  }
}
