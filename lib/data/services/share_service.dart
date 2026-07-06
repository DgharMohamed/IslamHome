import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran/quran.dart' as quran;
import 'package:dio/dio.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/widgets/verse_share_card.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService(ref);
});

class ShareService {
  final Ref _ref;
  final Dio _dio = Dio();
  final ScreenshotController _screenshotController = ScreenshotController();

  ShareService(this._ref);

  Future<void> shareAsText({
    required int surah,
    required int ayah,
    required AppLocalizations l10n,
    required bool isEnglish,
  }) async {
    final surahName = isEnglish 
        ? QuranUtils.getSurahName(surah, isEnglish: true) 
        : quran.getSurahNameArabic(surah);
    final verseText = quran.getVerse(surah, ayah, verseEndSymbol: false);
    
    final shareText = '"$verseText"\n\n'
        '- [${isEnglish ? 'Surah' : 'سورة'} $surahName: ${isEnglish ? 'Ayah' : 'آية'} $ayah]\n'
        '${l10n.sharedFromApp}';

    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> shareAsImage({
    required int surah,
    required int ayah,
    required MushafTheme theme,
    required AppLocalizations l10n,
    required bool isEnglish,
  }) async {
    final widget = VerseShareCard(
      surah: surah,
      ayah: ayah,
      theme: theme,
      l10n: l10n,
      isEnglish: isEnglish,
    );

    // Capture the widget as an image using screenshot package
    final imageBytes = await _screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 50),
      pixelRatio: 3.0,
    );

    // Save image to temporary directory
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/shared_ayah_${surah}_$ayah.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageBytes);

    // Share the image file
    await SharePlus.instance.share(ShareParams(
      files: [XFile(imagePath)],
      text: l10n.sharedFromApp,
    ));
  }

  Future<void> shareAsAudio({
    required BuildContext context, // To show loading snackbar if needed
    required int surah,
    required int ayah,
    required int reciterId,
    required AppLocalizations l10n,
  }) async {
    final downloadService = _ref.read(audioDownloadServiceProvider);
    
    // Check if audio is already downloaded
    final isDownloaded = await downloadService.isAyahAudioDownloaded(
      reciterId,
      surah,
      ayah,
    );

    String? audioPath;

    if (isDownloaded) {
      final localFile = await downloadService.getAyahAudioFile(reciterId, surah, ayah);
      if (await localFile.exists() && await localFile.length() > 0) {
        audioPath = localFile.path;
      }
    }

    // If not cached, download temporarily
    if (audioPath == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.downloadingAudioForShare)),
        );
      }

      final apiService = _ref.read(apiServiceProvider);
      final audioFiles = await apiService.getQFAudioForChapter(reciterId, surah);
      
      String? url;
      for (final file in audioFiles) {
        final verseKey = file['verse_key'] as String;
        if (verseKey == '$surah:$ayah') {
          url = file['url'] as String;
          if (!url.startsWith('http')) {
            url = '${apiService.quranFoundationAudioBase}$url';
          }
          break;
        }
      }

      if (url != null && url.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final tempAudioPath = '${directory.path}/shared_audio_${surah}_$ayah.mp3';
        
        try {
          await _dio.download(url, tempAudioPath);
          audioPath = tempAudioPath;
        } catch (e) {
          debugPrint('Error downloading audio for sharing: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.audioNeedsInternetToShare)),
            );
          }
          return;
        }
      }
    }

    if (audioPath != null) {
      await SharePlus.instance.share(ShareParams(
        files: [XFile(audioPath)],
        text: l10n.sharedFromApp,
      ));
    }
  }
}
