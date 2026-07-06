import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:islam_home/data/models/quran_font_model.dart';

/// Manages downloading, caching, and dynamically loading Quran fonts.
class QuranFontService {
  final Dio _dio;

  QuranFontService({Dio? dio}) : _dio = dio ?? Dio();

  /// Get the local directory where fonts are stored.
  Future<Directory> _fontDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/quran_fonts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Check if a downloadable font is already cached locally.
  Future<bool> isFontDownloaded(QuranFont font) async {
    if (font.isBundled) return true;
    final dir = await _fontDir();
    final file = File('${dir.path}/${font.fileName}');
    return file.exists();
  }

  /// Download a font file and save it locally.
  /// Returns the local file path on success, null on failure.
  /// [onProgress] callback provides download progress (0.0 - 1.0).
  Future<String?> downloadFont(
    QuranFont font, {
    void Function(double progress)? onProgress,
  }) async {
    if (font.isBundled || font.downloadUrl == null || font.fileName == null) {
      return null;
    }

    try {
      final dir = await _fontDir();
      final filePath = '${dir.path}/${font.fileName}';

      await _dio.download(
        font.downloadUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Load a downloaded font into Flutter's font engine so it can be used
  /// by its fontFamily name.
  Future<bool> loadFont(QuranFont font) async {
    if (font.isBundled) return true;

    try {
      final dir = await _fontDir();
      final file = File('${dir.path}/${font.fileName}');
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      final fontLoader = FontLoader(font.fontFamily);
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await fontLoader.load();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a downloaded font from local storage.
  Future<bool> deleteFont(QuranFont font) async {
    if (font.isBundled) return false;
    try {
      final dir = await _fontDir();
      final file = File('${dir.path}/${font.fileName}');
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the size of a downloaded font file in bytes.
  Future<int?> getFontFileSize(QuranFont font) async {
    if (font.isBundled) return null;
    try {
      final dir = await _fontDir();
      final file = File('${dir.path}/${font.fileName}');
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Provider for QuranFontService.
final quranFontServiceProvider = Provider<QuranFontService>((ref) {
  return QuranFontService();
});
