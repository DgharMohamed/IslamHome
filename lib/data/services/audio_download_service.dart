import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AudioDownloadService {
  static final AudioDownloadService _instance =
      AudioDownloadService._internal();

  factory AudioDownloadService() => _instance;

  AudioDownloadService._internal() {
    _dio.options = _dio.options.copyWith(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120), // Longer timeout for audio
      sendTimeout: const Duration(seconds: 15),
    );
  }

  final Dio _dio = Dio();
  final Map<int, ValueNotifier<double>> _downloadProgress = {};

  ValueNotifier<double> getDownloadProgress(int reciterId) {
    _downloadProgress.putIfAbsent(reciterId, () => ValueNotifier<double>(0.0));
    return _downloadProgress[reciterId]!;
  }

  Future<Directory> _getReciterDirectory(int reciterId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final reciterDir = Directory(
      p.join(appDir.path, 'audio', 'reciter_$reciterId'),
    );
    if (!await reciterDir.exists()) {
      await reciterDir.create(recursive: true);
    }
    return reciterDir;
  }

  Future<File> getAyahAudioFile(int reciterId, int surah, int ayah) async {
    final directory = await _getReciterDirectory(reciterId);
    return File(p.join(directory.path, '${surah}_$ayah.mp3'));
  }

  Future<bool> isAyahAudioDownloaded(int reciterId, int surah, int ayah) async {
    final file = await getAyahAudioFile(reciterId, surah, ayah);
    return await file.exists();
  }

  Future<List<int>> getDownloadedAyahsForSurah(
    int reciterId,
    int surah, {
    int fromAyah = 1,
  }) async {
    final directory = await _getReciterDirectory(reciterId);
    if (!await directory.exists()) return const [];

    final ayahs = <int>{};
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;

      final baseName = p.basenameWithoutExtension(entity.path);
      final parts = baseName.split('_');
      if (parts.length != 2) continue;

      final fileSurah = int.tryParse(parts[0]);
      final fileAyah = int.tryParse(parts[1]);
      if (fileSurah != surah || fileAyah == null || fileAyah < fromAyah) {
        continue;
      }

      try {
        if (await entity.length() > 0) {
          ayahs.add(fileAyah);
        }
      } catch (_) {
        continue;
      }
    }

    final sorted = ayahs.toList()..sort();
    return sorted;
  }

  Future<bool> isReciterDownloaded(int reciterId) async {
    final directory = await _getReciterDirectory(reciterId);
    if (!await directory.exists()) return false;

    // A rough heuristic: check if at least a significant number of files exist
    // (e.g., Fatiha and Baqarah starts)
    final ayah1 = File(p.join(directory.path, '1_1.mp3'));
    final ayah2 = File(p.join(directory.path, '114_6.mp3')); // Last ayah

    return await ayah1.exists() && await ayah2.exists();
  }

  Future<void> deleteReciterAudio(int reciterId) async {
    final directory = await _getReciterDirectory(reciterId);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    _downloadProgress[reciterId]?.value = 0.0;
  }

  Future<void> downloadReciterAudio(int reciterId) async {
    debugPrint('Starting audio download for reciter $reciterId');
    final progressNotifier = getDownloadProgress(reciterId);
    progressNotifier.value = 0.01;

    try {
      final reciterDir = await _getReciterDirectory(reciterId);

      // We need to fetch audio URLs chapter by chapter from the API
      // endpoint: https://api.quran.com/api/v4/quran/recitations/{reciter_id}?chapter_number={chapter_id}

      int totalAyahs = 6236;
      int downloadedAyahs = 0;

      for (int chapter = 1; chapter <= 114; chapter++) {
        var attempt = 0;
        bool success = false;
        List<dynamic> audioFiles = [];

        while (attempt < 3 && !success) {
          try {
            final response = await _dio.get(
              'https://api.quran.com/api/v4/quran/recitations/$reciterId',
              queryParameters: {'chapter_number': chapter},
            );

            if (response.statusCode == 200 && response.data != null) {
              audioFiles = response.data['audio_files'] ?? [];
              success = true;
            }
          } catch (e) {
            attempt++;
            if (attempt >= 3) {
              debugPrint('Failed to get audio info for chapter $chapter: $e');
              progressNotifier.value = 0.0; // Fail state
              return;
            }
            await Future.delayed(Duration(seconds: attempt));
          }
        }

        // Proceed to download each audio file
        for (final fileProp in audioFiles) {
          if (fileProp is! Map) continue;

          final urlSuffix = fileProp['url'] as String?;
          if (urlSuffix == null) continue;

          final verseKey = fileProp['verse_key'] as String?;
          if (verseKey == null) continue;

          final parts = verseKey.split(':');
          if (parts.length != 2) continue;

          final surah = int.tryParse(parts[0]);
          final ayah = int.tryParse(parts[1]);
          if (surah == null || ayah == null) continue;

          final localFile = File(p.join(reciterDir.path, '${surah}_$ayah.mp3'));

          if (!await localFile.exists()) {
            final url = urlSuffix.startsWith('http')
                ? urlSuffix
                : 'https://verses.quran.com/$urlSuffix';

            var dlAttempt = 0;
            bool dlSuccess = false;

            while (dlAttempt < 3 && !dlSuccess) {
              try {
                await _dio.download(url, localFile.path);
                dlSuccess = true;
              } catch (e) {
                dlAttempt++;
                if (dlAttempt >= 3) {
                  debugPrint('Failed to download $url: $e');
                  // Continue to next ayah instead of failing the whole process
                }
              }
            }
          }

          downloadedAyahs++;
          // Update progress smoothly
          progressNotifier.value = (downloadedAyahs / totalAyahs).clamp(
            0.01,
            1.0,
          );
        }
      }

      progressNotifier.value = 1.0; // Done
      debugPrint('Finished downloading reciter $reciterId');
    } catch (e) {
      debugPrint('Error downloading reciter $reciterId audio: $e');
      progressNotifier.value = 0.0; // Fail state
    }
  }
}
