import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TafsirDownloadService {
  static const String _fawazQuranBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';

  static final TafsirDownloadService _instance =
      TafsirDownloadService._internal();

  factory TafsirDownloadService() => _instance;

  TafsirDownloadService._internal() {
    _dio.options = _dio.options.copyWith(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    );
  }

  final Dio _dio = Dio();
  final Map<String, ValueNotifier<double>> _downloadProgress = {};

  ValueNotifier<double> getDownloadProgress(String sourceId) {
    _downloadProgress.putIfAbsent(sourceId, () => ValueNotifier<double>(0.0));
    return _downloadProgress[sourceId]!;
  }

  Future<File> _getTafsirFile(String sourceId) async {
    final directory = await _getTafsirDirectory();
    return File(p.join(directory.path, '$sourceId.json'));
  }

  Future<Directory> _getTafsirDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final tafsirDir = Directory(p.join(appDir.path, 'tafsirs'));
    if (!await tafsirDir.exists()) {
      await tafsirDir.create(recursive: true);
    }
    return tafsirDir;
  }

  Future<bool> isTafsirDownloaded(String sourceId) async {
    final file = await _getTafsirFile(sourceId);
    return await file.exists();
  }

  Future<void> deleteTafsir(String sourceId) async {
    final file = await _getTafsirFile(sourceId);
    if (await file.exists()) {
      await file.delete();
    }
    _downloadProgress[sourceId]?.value = 0.0;
  }

  Future<String?> getTafsirFromLocal(
    String sourceId,
    int surah,
    int ayah,
  ) async {
    if (!await isTafsirDownloaded(sourceId)) return null;

    try {
      final file = await _getTafsirFile(sourceId);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonString);

      return data['$surah:$ayah']?.toString();
    } catch (e) {
      debugPrint('Error reading local tafsir: $e');
      return null;
    }
  }

  bool isDownloadableSource(String sourceId) {
    final normalized = sourceId.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized.startsWith('qurancom-')) return true;
    return normalized.contains('-');
  }

  Future<void> downloadTafsir(String sourceId) async {
    if (!isDownloadableSource(sourceId)) return;
    if (sourceId.startsWith('qurancom-')) {
      return downloadQuranComTafsir(sourceId);
    }
    return _downloadFawazEditionTafsir(sourceId);
  }

  Future<void> downloadQuranComTafsir(String sourceId) async {
    if (!sourceId.startsWith('qurancom-')) {
      return; // Currently only Quran.com API bulk download is fully supported
    }

    final quranComId = int.tryParse(sourceId.split('-').last);
    if (quranComId == null) return;

    final progressNotifier = getDownloadProgress(sourceId);
    progressNotifier.value = 0.01; // Start progress

    final Map<String, String> tafsirData = {};

    try {
      for (int chapter = 1; chapter <= 114; chapter++) {
        final url =
            'https://api.quran.com/api/v4/tafsirs/$quranComId/by_chapter/$chapter';
        var attempt = 0;
        bool success = false;

        while (attempt < 3 && !success) {
          try {
            final response = await _dio.get(url);
            if (response.statusCode == 200 && response.data != null) {
              final Map<String, dynamic> map = _asMap(response.data);
              if (map.containsKey('tafsirs') && map['tafsirs'] is List) {
                final list = map['tafsirs'] as List;
                for (var item in list) {
                  if (item is Map) {
                    final verseKey = item['verse_key']?.toString() ?? '';
                    final text = _cleanText(item['text']?.toString());
                    if (verseKey.isNotEmpty && text.isNotEmpty) {
                      tafsirData[verseKey] = text;
                    }
                  }
                }
              }
              success = true;
            }
          } catch (e) {
            attempt++;
            if (attempt >= 3) {
              debugPrint('Failed to fetch chapter $chapter for $sourceId: $e');
              progressNotifier.value = 0.0; // Reset on failure
              return;
            }
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }

        // Update progress
        progressNotifier.value = chapter / 114.0;
      }

      // Save to file
      if (tafsirData.isNotEmpty) {
        final file = await _getTafsirFile(sourceId);
        await file.writeAsString(json.encode(tafsirData));
        progressNotifier.value = 1.0; // Complete
      } else {
        progressNotifier.value = 0.0; // Failed
      }
    } catch (e) {
      debugPrint('Error downloading tafsir $sourceId: $e');
      progressNotifier.value = 0.0; // Error
    }
  }

  Future<void> _downloadFawazEditionTafsir(String sourceId) async {
    final progressNotifier = getDownloadProgress(sourceId);
    progressNotifier.value = 0.01;

    try {
      final candidates = <String>{
        sourceId,
        sourceId.replaceAll('-', '_'),
      }.toList();

      Map<String, String> tafsirData = const {};
      for (final edition in candidates) {
        final url = '$_fawazQuranBaseUrl/editions/$edition.min.json';
        try {
          progressNotifier.value = 0.15;
          final response = await _dio.get(url);
          if (response.statusCode == 200 && response.data != null) {
            final map = _asMap(response.data);
            final extracted = _extractVerseMapFromEdition(map);
            if (extracted.isNotEmpty) {
              tafsirData = extracted;
              break;
            }
          }
        } catch (_) {
          continue;
        }
      }

      if (tafsirData.isEmpty) {
        progressNotifier.value = 0.0;
        return;
      }

      progressNotifier.value = 0.9;
      final file = await _getTafsirFile(sourceId);
      await file.writeAsString(json.encode(tafsirData));
      progressNotifier.value = 1.0;
    } catch (e) {
      debugPrint('Error downloading tafsir $sourceId from Fawaz API: $e');
      progressNotifier.value = 0.0;
    }
  }

  Map<String, String> _extractVerseMapFromEdition(Map<String, dynamic> raw) {
    final data = _asMap(raw['data']);
    final surahs = data['surahs'];
    if (surahs is! List) return const {};

    final verses = <String, String>{};
    for (final surahEntry in surahs) {
      if (surahEntry is! Map) continue;
      final surahMap = surahEntry.cast<String, dynamic>();
      final surahNumber = _parseInt(surahMap['number']);
      if (surahNumber == null) continue;

      final ayahs = surahMap['ayahs'];
      if (ayahs is! List) continue;

      for (final ayahEntry in ayahs) {
        if (ayahEntry is! Map) continue;
        final ayahMap = ayahEntry.cast<String, dynamic>();
        final ayahNumber =
            _parseInt(ayahMap['numberInSurah']) ?? _parseInt(ayahMap['number']);
        if (ayahNumber == null) continue;
        final text = _cleanText(ayahMap['text']?.toString());
        if (text.isEmpty) continue;
        verses['$surahNumber:$ayahNumber'] = text;
      }
    }
    return verses;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    if (data is List && data.isNotEmpty && data.first is Map) {
      return (data.first as Map).cast<String, dynamic>();
    }
    return const {};
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _cleanText(String? input) {
    if (input == null || input.isEmpty) return '';
    var value = input;
    value = value.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    value = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
    value = value
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'");
    value = value.replaceAll(RegExp(r'[ \t]+'), ' ');
    value = value.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return value.trim();
  }
}
