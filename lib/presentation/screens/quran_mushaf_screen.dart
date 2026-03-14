import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/widgets/quran_mushaf_view.dart';
import 'package:islam_home/presentation/widgets/quran_english_view.dart';
import 'package:quran/quran.dart' as quran;
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/widgets/ayah_dedicated_player.dart';
import 'package:islam_home/presentation/widgets/surah_index_bottom_sheet.dart';
import 'package:islam_home/presentation/widgets/mushaf_settings_sheet.dart';
import 'package:islam_home/presentation/widgets/riwaya_settings_sheet.dart';
import 'package:islam_home/presentation/providers/mushaf_settings_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/presentation/providers/audio_ui_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:islam_home/data/models/qf_recitation_model.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/presentation/providers/mushaf_riwaya_provider.dart';
import 'package:islam_home/presentation/providers/khatma_v2_provider.dart';
import 'package:islam_home/data/services/tafsir_download_service.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class QuranMushafScreen extends ConsumerStatefulWidget {
  final int initialPage;
  final String? trackId;
  final bool restoreSavedPosition;

  const QuranMushafScreen({
    super.key,
    this.initialPage = 1,
    this.trackId,
    this.restoreSavedPosition = true,
  });

  @override
  ConsumerState<QuranMushafScreen> createState() => _QuranMushafScreenState();
}

class _QuranMushafScreenState extends ConsumerState<QuranMushafScreen> {
  static const String _settingsBoxName = 'settings_box';
  static const String _lastMushafPageKey = 'quran_last_mushaf_page';

  @override
  void initState() {
    super.initState();
    _currentPageNotifier = ValueNotifier<int>(widget.initialPage);
    _restoreAndOpenInitialPage();
  }

  late final ValueNotifier<int> _currentPageNotifier;

  final GlobalKey _surahIndexButtonKey = GlobalKey();

  @override
  void dispose() {
    _persistLastReadPage(_currentPageNotifier.value);
    _currentPageNotifier.dispose();
    super.dispose();
  }

  final GlobalKey<QuranMushafViewState> _mushafKey =
      GlobalKey<QuranMushafViewState>();
  final GlobalKey<QuranEnglishViewState> _englishViewKey =
      GlobalKey<QuranEnglishViewState>();

  bool get _isEnglishUi => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('en');

  Future<void> _restoreAndOpenInitialPage() async {
    final explicitInitial = widget.initialPage != 1;
    var targetPage = widget.initialPage.clamp(1, quran.totalPagesCount);

    if (!explicitInitial && widget.restoreSavedPosition) {
      final savedPage = _readSavedPage();
      if (savedPage != null) {
        targetPage = savedPage;
      } else {
        // Fallback to LastReadService for page derivation
        final lastRead = await ref.read(lastReadServiceProvider).getLastRead();
        if (lastRead != null) {
          targetPage = quran.getPageNumber(
            lastRead.surahNumber,
            lastRead.ayahNumber,
          );
        }
      }
    }

    if (!mounted) return;
    _currentPageNotifier.value = targetPage;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _englishViewKey.currentState?.navigateToPage(targetPage);
      _mushafKey.currentState?.navigateToPage(targetPage);

      // Restore last played ayah in player (cued/paused) if nothing is playing
      final audioService = ref.read(audioPlayerServiceProvider);
      final isPlaying = audioService?.player.playing ?? false;
      final hasMedia = audioService?.handler.mediaItem.value != null;

      if (!isPlaying && !hasMedia) {
        final lastRead = await ref.read(lastReadServiceProvider).getLastRead();
        if (lastRead != null) {
          _playAyahAudio(
            lastRead.surahNumber,
            lastRead.ayahNumber,
            autoPlay: false,
          );
        }
      }
    });
  }

  int? _readSavedPage() {
    try {
      if (!Hive.isBoxOpen(_settingsBoxName)) return null;
      final box = Hive.box(_settingsBoxName);
      final value = box.get(_lastMushafPageKey);
      if (value is int) {
        return value.clamp(1, quran.totalPagesCount);
      }
    } catch (e) {
      debugPrint('QuranMushafScreen: load saved page failed: $e');
    }
    return null;
  }

  void _persistLastReadPage(int pageNumber) {
    final safePage = pageNumber.clamp(1, quran.totalPagesCount);
    try {
      if (!Hive.isBoxOpen(_settingsBoxName)) return;
      Hive.box(_settingsBoxName).put(_lastMushafPageKey, safePage);
    } catch (e) {
      debugPrint('QuranMushafScreen: save page failed: $e');
    }
  }

  void _onPageChanged(int pageNumber) {
    final safePage = pageNumber.clamp(1, quran.totalPagesCount);
    _currentPageNotifier.value = safePage;
    _persistLastReadPage(safePage);
  }

  void _navigateToSurah(int surahId) {
    if (_isEnglishUi) {
      _englishViewKey.currentState?.navigateToSurah(surahId);
      return;
    }
    _mushafKey.currentState?.navigateToSurah(surahId);
  }

  void _clearAyahSelection() {
    _englishViewKey.currentState?.clearSelection();
    _mushafKey.currentState?.clearSelection();
  }

  void _onShowAyahOptions(int page, int surah, int ayah, Offset tapPosition) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final dx = tapPosition.dx.clamp(60.0, screenSize.width - 60.0);
    final dy = (tapPosition.dy - 8).clamp(100.0, screenSize.height - 220.0);
    final rect = RelativeRect.fromLTRB(
      dx - 60,
      dy - 10,
      screenSize.width - dx - 60,
      screenSize.height - dy,
    );

    final mushafTheme = ref.read(mushafThemeProvider);

    showMenu<String>(
      context: context,
      position: rect,
      elevation: 16,
      color: mushafTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEnglishUi
                    ? quran.getSurahName(surah)
                    : quran.getSurahNameArabic(surah),
                style: TextStyle(
                  color: mushafTheme.secondaryColor,
                  fontSize: 13,
                  fontFamily: 'Amiri',
                ),
              ),
              Text(
                l10n.verseN(ayah),
                style: TextStyle(
                  color: mushafTheme.textColor.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontFamily: 'Amiri',
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        _bubbleItem(
          'tafsir',
          Icons.menu_book_rounded,
          l10n.tafsirLabel,
          mushafTheme,
        ),
        _bubbleItem(
          'play',
          Icons.play_circle_filled_rounded,
          l10n.playVerseAudio,
          mushafTheme,
        ),
      ],
    ).then((value) {
      _clearAyahSelection();
      if (!mounted) return;
      switch (value) {
        case 'tafsir':
          _showTafsirDialog(surah, ayah);
          break;
        case 'play':
          _playAyahAudio(surah, ayah);
          break;
      }
    });
  }

  PopupMenuItem<String> _bubbleItem(
    String value,
    IconData icon,
    String label,
    MushafTheme theme,
  ) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.secondaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: theme.secondaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.tajawal(
                color: theme.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncSelectedReciterWithRiwaya() async {
    try {
      final availableReciters = await ref.read(
        ayahAudioRecitersProvider.future,
      );
      if (availableReciters.isEmpty) return;

      final selectedReciter = ref.read(selectedReciterProvider);
      final hasValidSelection =
          selectedReciter != null &&
          availableReciters.any((reciter) => reciter.id == selectedReciter.id);

      if (!hasValidSelection) {
        ref
            .read(selectedReciterProvider.notifier)
            .setReciter(availableReciters.first);
      }
    } catch (e) {
      debugPrint('QuranMushafScreen: sync reciter with riwaya failed: $e');
    }
  }

  void _restartPlaybackFromCurrentAyahIfActive() {
    final audioService = ref.read(audioPlayerServiceProvider);
    if (audioService == null || !audioService.player.playing) return;

    final sequence = audioService.player.audioSource?.sequence;
    final currentIndex = audioService.player.currentIndex;
    if (sequence == null || sequence.isEmpty || currentIndex == null) return;
    if (currentIndex < 0 || currentIndex >= sequence.length) return;

    final metadata = sequence[currentIndex].tag as MediaItem?;
    if (metadata == null) return;

    final surah = metadata.extras?['surah'] as int?;
    final ayah = metadata.extras?['ayah'] as int?;
    if (surah != null && ayah != null) {
      _playAyahAudio(surah, ayah);
    }
  }

  Future<void> _playAyahAudio(int surah, int ayah, {bool autoPlay = true}) async {
    final audioService = ref.read(audioPlayerServiceProvider);
    if (audioService == null) return;
    final l10n = AppLocalizations.of(context)!;

    await _syncSelectedReciterWithRiwaya();
    final QFRecitation? reciter = ref.read(selectedReciterProvider);
    final reciterName = reciter?.displayName ?? 'Mishary Alafasy';
    final reciterId = reciter?.id ?? 7; // Default to Alafasy if not selected

    List<AudioSource> playlist = [];

    // Fetch verse audio list from QF
    final audioFiles = await ref
        .read(apiServiceProvider)
        .getQFAudioForChapter(reciterId, surah);

    if (audioFiles.isEmpty) {
      final localAyahs = await ref
          .read(audioDownloadServiceProvider)
          .getDownloadedAyahsForSurah(reciterId, surah, fromAyah: ayah);

      if (localAyahs.isNotEmpty) {
        final localPlaylist = <AudioSource>[];
        for (final localAyah in localAyahs) {
          try {
            final localFile = await ref
                .read(audioDownloadServiceProvider)
                .getAyahAudioFile(reciterId, surah, localAyah);
            if (!await localFile.exists() || await localFile.length() == 0) {
              continue;
            }
            final mediaItem = MediaItem(
              id: 'quran_${surah}_$localAyah',
              album: _isEnglishUi
                  ? quran.getSurahName(surah)
                  : quran.getSurahNameArabic(surah),
              title: l10n.verseN(localAyah),
              artist: reciterName,
              extras: {'surah': surah, 'ayah': localAyah},
            );
            localPlaylist.add(AudioSource.file(localFile.path, tag: mediaItem));
          } catch (e) {
            debugPrint('[QuranMushaf] local fallback ayah failed: $e');
          }
        }

        if (localPlaylist.isNotEmpty) {
          try {
            await audioService.setPlaylist(sources: localPlaylist);
            return;
          } catch (e) {
            debugPrint('[QuranMushaf] local fallback setPlaylist failed: $e');
          }
        }
      }

      if (mounted) {
        final message = l10n.reciterUnavailableNow;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    // Map each verse audio to an AudioSource
    final apiService = ref.read(apiServiceProvider);
    final downloadService = ref.read(audioDownloadServiceProvider);

    for (var i = 0; i < audioFiles.length; i++) {
      final file = audioFiles[i];
      var url = file['url'] as String;

      // Prepend base URL if it's a relative path
      if (!url.startsWith('http')) {
        url = '${apiService.quranFoundationAudioBase}$url';
      }

      final verseKey = file['verse_key']; // e.g., "1:1"
      final ayahNumber = int.parse(verseKey.split(':')[1]);

      // We only add ayahs starting from the requested one
      if (ayahNumber < ayah) continue;

      final isDownloaded = await downloadService.isAyahAudioDownloaded(
        reciterId,
        surah,
        ayahNumber,
      );

      if (url.isEmpty) {
        debugPrint(
          '[QuranMushaf] _playAyahAudio: skipping empty URL for ayah $ayahNumber',
        );
        continue;
      }

      final mediaItem = MediaItem(
        id: 'quran_${surah}_$ayahNumber',
        album: _isEnglishUi
            ? quran.getSurahName(surah)
            : quran.getSurahNameArabic(surah),
        title: l10n.verseN(ayahNumber),
        artist: reciterName,
        extras: {'surah': surah, 'ayah': ayahNumber},
      );

      try {
        if (isDownloaded) {
          final localFile = await downloadService.getAyahAudioFile(
            reciterId,
            surah,
            ayahNumber,
          );
          if (await localFile.exists() && await localFile.length() > 0) {
            playlist.add(AudioSource.file(localFile.path, tag: mediaItem));
          } else {
            debugPrint(
              '[QuranMushaf] _playAyahAudio: local file missing or empty for ayah $ayahNumber, falling back to URL',
            );
            playlist.add(AudioSource.uri(Uri.parse(url), tag: mediaItem));
          }
        } else {
          playlist.add(AudioSource.uri(Uri.parse(url), tag: mediaItem));
        }
      } catch (e) {
        debugPrint(
          '[QuranMushaf] _playAyahAudio: Error creating AudioSource for $url: $e',
        );
      }
    }

    if (playlist.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unableToLoadPlayableAyahAudio)),
        );
      }
      return;
    }

    try {
      await audioService.setPlaylist(sources: playlist, autoPlay: autoPlay);
    } catch (e) {
      debugPrint('[QuranMushaf] _playAyahAudio setPlaylist failed: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unableToStartAudioTryAgain)),
        );
      }
    }
  }

  Future<void> _showSimpleTextDialog({
    required BuildContext context,
    required String title,
    required Future<String> futureText,
    VoidCallback? onBack,
  }) async {
    final mushafTheme = ref.read(mushafThemeProvider);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: mushafTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: FutureBuilder<String>(
                future: futureText,
                builder: (context, snapshot) {
                  final text = snapshot.data?.trim() ?? '';
                  final isRtl = Directionality.of(context) == TextDirection.rtl;
                  final mushafSettings = ref.read(mushafSettingsProvider);
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: mushafTheme.backgroundColor,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        toolbarHeight: 90,
                        flexibleSpace: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: mushafTheme.textColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                              child: Row(
                                children: [
                                  if (onBack != null)
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        onBack();
                                      },
                                      icon: Icon(
                                        isRtl
                                            ? Icons.arrow_forward_rounded
                                            : Icons.arrow_back_rounded,
                                        color: mushafTheme.textColor.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      title,
                                      textAlign: isRtl
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                        color: mushafTheme.secondaryColor,
                                        fontSize: 18 * mushafSettings.fontSizeScale,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.close,
                                      color: mushafTheme.textColor.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: mushafTheme.textColor.withValues(
                                alpha: 0.1,
                              ),
                              height: 1,
                            ),
                          ],
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: mushafTheme.secondaryColor,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(22),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              text.isNotEmpty
                                  ? text
                                  : AppLocalizations.of(
                                      context,
                                    )!.noDataAvailable,
                              style: TextStyle(
                                color: mushafTheme.textColor,
                                fontSize: 18 * mushafSettings.fontSizeScale,
                                height: 1.7,
                                fontFamily: 'Amiri',
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTafsirDialog(int surah, int ayah) async {
    final selectedSource = await _showTafsirSourcesDialog(context);
    if (!mounted || selectedSource == null) return;
    final l10n = AppLocalizations.of(context)!;

    final sourceId = selectedSource['id'] ?? '';
    final sourceName = selectedSource['name'] ?? l10n.tafsirLabel;
    if (sourceId.isEmpty) return;

    await _showSimpleTextDialog(
      context: context,
      title: '$sourceName - ${l10n.verseN(ayah)}',
      futureText: ref
          .read(quranApiServiceProvider)
          .getVerseTafsirBySource(surah, ayah, sourceId: sourceId),
      onBack: () => _showTafsirDialog(surah, ayah),
    );
  }

  Future<Map<String, String>?> _showTafsirSourcesDialog(
    BuildContext context,
  ) async {
    final mushafTheme = ref.read(mushafThemeProvider);
    final service = ref.read(quranApiServiceProvider);

    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isArabicUi = Localizations.localeOf(
          context,
        ).languageCode.toLowerCase().startsWith('ar');
        final isEnglishUi = Localizations.localeOf(
          context,
        ).languageCode.toLowerCase().startsWith('en');
        final sourcePickerTitle = AppLocalizations.of(
          context,
        )!.chooseTafsirSource;
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: mushafTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: FutureBuilder<List<Map<String, String>>>(
                future: service.getTafsirSources(
                  arabicOnly: isArabicUi,
                  englishOnly: isEnglishUi,
                  arabicTitles: isArabicUi,
                ),
                builder: (context, snapshot) {
                  final sources = snapshot.data ?? const [];
                  final isRtl = Directionality.of(context) == TextDirection.rtl;
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: mushafTheme.backgroundColor,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        toolbarHeight: 90,
                        flexibleSpace: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: mushafTheme.textColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (isRtl)
                                    Expanded(
                                      child: Text(
                                        sourcePickerTitle,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: mushafTheme.secondaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Amiri',
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.close,
                                      color: mushafTheme.textColor.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  if (!isRtl)
                                    Expanded(
                                      child: Text(
                                        sourcePickerTitle,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: mushafTheme.secondaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Amiri',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Divider(
                              color: mushafTheme.textColor.withValues(
                                alpha: 0.1,
                              ),
                              height: 1,
                            ),
                          ],
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: mushafTheme.secondaryColor,
                            ),
                          ),
                        )
                      else if (sources.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.noTafsirSourcesAvailable,
                              style: TextStyle(
                                color: mushafTheme.textColor.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 15,
                                fontFamily: 'Amiri',
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index.isOdd) {
                                return Divider(
                                  color: mushafTheme.textColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  height: 1,
                                );
                              }
                              final itemIndex = index ~/ 2;
                              final source = sources[itemIndex];
                              final id = source['id'] ?? '';
                              final name = source['name'] ?? id;
                              final author = source['author'] ?? '';
                              final language = source['language'] ?? '';
                              final subtitleParts = <String>[
                                if (author.isNotEmpty) author,
                                if (language.isNotEmpty && !isArabicUi)
                                  language,
                              ];
                              final subtitleText = subtitleParts.join(' - ');
                              final hasSubtitle = subtitleText.isNotEmpty;
                              final canDownload = TafsirDownloadService()
                                  .isDownloadableSource(id);
                              return ValueListenableBuilder<double>(
                                valueListenable: TafsirDownloadService()
                                    .getDownloadProgress(id),
                                builder: (context, progress, child) {
                                  return FutureBuilder<bool>(
                                    future: TafsirDownloadService()
                                        .isTafsirDownloaded(id),
                                    builder: (context, snapshot) {
                                      final isDownloaded =
                                          snapshot.data ?? false;

                                      Widget trailingWidget;
                                      if (progress > 0 && progress < 1.0) {
                                        trailingWidget = SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 2,
                                            color: mushafTheme.secondaryColor,
                                          ),
                                        );
                                      } else if (isDownloaded) {
                                        trailingWidget = Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: mushafTheme.textColor
                                                    .withValues(alpha: 0.6),
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                TafsirDownloadService()
                                                    .deleteTafsir(id);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        );
                                      } else if (canDownload) {
                                        trailingWidget = IconButton(
                                          icon: Icon(
                                            Icons.download_rounded,
                                            color: mushafTheme.secondaryColor,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            TafsirDownloadService()
                                                .downloadTafsir(id);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        );
                                      } else {
                                        trailingWidget = Icon(
                                          Icons.cloud_outlined,
                                          color: mushafTheme.textColor
                                              .withValues(alpha: 0.4),
                                          size: 20,
                                        );
                                      }

                                      return ListTile(
                                        onTap: id.isEmpty
                                            ? null
                                            : () => Navigator.pop(
                                                context,
                                                source,
                                              ),
                                        isThreeLine: hasSubtitle && !isArabicUi,
                                        title: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: mushafTheme.textColor,
                                            fontSize: 18,
                                            fontFamily: 'Amiri',
                                          ),
                                        ),
                                        subtitle: hasSubtitle && !isArabicUi
                                            ? Text(
                                                subtitleText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: mushafTheme.textColor
                                                      .withValues(alpha: 0.62),
                                                  fontSize: 13,
                                                ),
                                              )
                                            : null,
                                        trailing: trailingWidget,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            childCount: sources.isEmpty
                                ? 0
                                : sources.length * 2 - 1,
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showSurahIndex() async {
    await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: AnimationStyle.noAnimation,
      builder: (context) => SurahIndexBottomSheet(
        onSurahSelected: (id) {
          _navigateToSurah(id);
        },
      ),
    );
  }

  Future<void> _showSurahQuickMenu() async {
    final buttonContext = _surahIndexButtonKey.currentContext;
    final mushafTheme = ref.read(mushafThemeProvider);

    if (buttonContext == null) {
      _showSurahIndex();
      return;
    }

    final buttonBox = buttonContext.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (buttonBox == null || overlayBox == null) {
      _showSurahIndex();
      return;
    }

    final topLeft = buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final bottomRight = buttonBox.localToGlobal(
      buttonBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );
    final position = RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight),
      Offset.zero & overlayBox.size,
    );

    const fullIndexValue = -1;
    final selected = await showMenu<int>(
      context: context,
      position: position,
      color: mushafTheme.backgroundColor,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(minWidth: 230, maxWidth: 260),
      items: [
        PopupMenuItem<int>(
          value: fullIndexValue,
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 18,
                color: mushafTheme.secondaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.fullIndex,
                style: GoogleFonts.tajawal(
                  color: mushafTheme.secondaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        ...List<PopupMenuEntry<int>>.generate(quran.totalSurahCount, (index) {
          final surahId = index + 1;
          return PopupMenuItem<int>(
            value: surahId,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$surahId',
                    style: TextStyle(
                      color: mushafTheme.textColor.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _isEnglishUi
                        ? quran.getSurahName(surahId)
                        : quran.getSurahNameArabic(surahId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                      color: mushafTheme.textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );

    if (!mounted || selected == null) return;
    if (selected == fullIndexValue) {
      _showSurahIndex();
      return;
    }
    _navigateToSurah(selected);
  }

  void _showThemeSettings() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MushafSettingsSheet(),
    );
  }

  void _showRiwayaSettings() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RiwayaSettingsSheet(),
    );
  }

  int _surahForPage(int page) {
    final data = quran.getPageData(page).cast<Map<String, dynamic>>();
    if (data.isEmpty) return 1;
    return data.first['surah'] as int;
  }

  int _juzForPage(int page) {
    final data = quran.getPageData(page).cast<Map<String, dynamic>>();
    if (data.isEmpty) return 1;
    final surah = data.first['surah'] as int;
    final ayah = data.first['start'] as int;
    return quran.getJuzNumber(surah, ayah);
  }

  Future<void> _recordKhatmaProgress(
    KhatmaTrack track, {
    KhatmaUnit? displayUnit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final currentPage = _currentPageNotifier.value.clamp(1, quran.totalPagesCount);
    final selectedUnit = displayUnit ?? track.unit;

    int targetUnit;
    String recordLabel;
    switch (selectedUnit) {
      case KhatmaUnit.page:
        final pageValue = currentPage;
        recordLabel = l10n.khatmaV2RecordPage(pageValue);
        break;
      case KhatmaUnit.juz:
        final juzValue = _juzForPage(currentPage);
        recordLabel = l10n.khatmaV2RecordJuz(juzValue);
        break;
      case KhatmaUnit.surah:
        final surahValue = _surahForPage(currentPage);
        recordLabel = l10n.khatmaV2RecordSurah(
          _isEnglishUi
              ? quran.getSurahName(surahValue)
              : quran.getSurahNameArabic(surahValue),
        );
        break;
    }

    switch (track.unit) {
      case KhatmaUnit.page:
        targetUnit = currentPage;
        break;
      case KhatmaUnit.juz:
        targetUnit = _juzForPage(currentPage);
        break;
      case KhatmaUnit.surah:
        targetUnit = _surahForPage(currentPage);
        break;
    }

    await ref.read(khatmaV2Provider.notifier).updateProgress(track.id, targetUnit);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$recordLabel - ${l10n.khatmaV2ProgressSaved(track.title)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTrackQuickAction(
    KhatmaTrack track,
    KhatmaUnit unit,
    IconData icon,
    String label,
    MushafTheme mushafTheme,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _recordKhatmaProgress(track, displayUnit: unit),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: mushafTheme.secondaryColor,
        side: BorderSide(color: mushafTheme.secondaryColor.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mushafTheme = ref.watch(mushafThemeProvider);
    final isEnglishUi = _isEnglishUi;
    final audioService = ref.watch(audioPlayerServiceProvider);
    final isPlayerMinimized = ref.watch(audioPlayerMinimizedProvider);
    final hasActiveAyahPlayer =
        audioService != null &&
        audioService.player.playerState.processingState != ProcessingState.idle;
    final khatmaState = ref.watch(khatmaV2Provider);
    final linkedTrack = widget.trackId == null
        ? null
        : khatmaState.getTrack(widget.trackId!);
    final contentBottomInset =
        16.0 +
        (hasActiveAyahPlayer ? (isPlayerMinimized ? 76.0 : 246.0) : 0.0);

    // Listen for reciter changes to restart playback if active
    ref.listen(selectedReciterProvider, (previous, next) {
      if (next != null && previous != next) {
        _restartPlaybackFromCurrentAyahIfActive();
      }
    });

    // Keep selected reciter aligned with the selected riwaya
    ref.listen(selectedRiwayaProvider, (previous, next) async {
      if (previous?.key != next.key) {
        await _syncSelectedReciterWithRiwaya();
      }
    });

    // Listen to playing ayah to persist last read position
    ref.listen(playingAyahProvider, (previous, next) {
      final playingAyah = next.value;
      if (playingAyah != null) {
        final parts = playingAyah.split(':');
        if (parts.length == 2) {
          final surah = int.tryParse(parts[0]);
          final ayah = int.tryParse(parts[1]);
          if (surah != null && ayah != null) {
            ref.read(lastReadServiceProvider).saveLastRead(
              surahNumber: surah,
              ayahNumber: ayah,
            );
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: mushafTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Navigation Bar (Persistent Header)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: mushafTheme.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: mushafTheme.textColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  // Surah Quick Index (small pop-up menu)
                  IconButton(
                    key: _surahIndexButtonKey,
                    onPressed: _showSurahQuickMenu,
                    icon: Icon(
                      Icons.format_list_bulleted_rounded,
                      color: mushafTheme.secondaryColor,
                    ),
                    tooltip: AppLocalizations.of(context)!.index,
                  ),
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPageNotifier,
                      builder: (context, page, _) {
                        return Text(
                          AppLocalizations.of(context)!.page(page),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            color: mushafTheme.textColor.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  if (linkedTrack != null)
                    IconButton(
                      onPressed: () => _recordKhatmaProgress(linkedTrack),
                      icon: Icon(
                        Icons.playlist_add_check_circle_rounded,
                        color: mushafTheme.secondaryColor,
                      ),
                      tooltip: AppLocalizations.of(context)!.khatmaV2ProgressSaved(
                        linkedTrack.title,
                      ),
                    ),
                  // Theme Button
                  IconButton(
                    onPressed: _showThemeSettings,
                    icon: Icon(
                      Icons.palette_outlined,
                      color: mushafTheme.textColor.withValues(alpha: 0.7),
                    ),
                    tooltip: AppLocalizations.of(context)!.theme,
                  ),
                  // Riwaya Button
                  IconButton(
                    onPressed: _showRiwayaSettings,
                    icon: Icon(
                      Icons.menu_book_rounded,
                      color: mushafTheme.textColor.withValues(alpha: 0.7),
                    ),
                    tooltip: AppLocalizations.of(context)!.riwaya,
                  ),
                ],
              ),
            ),
            if (linkedTrack != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTrackQuickAction(
                        linkedTrack,
                        KhatmaUnit.page,
                        Icons.menu_book_rounded,
                        AppLocalizations.of(context)!.khatmaV2RecordPage(
                          _currentPageNotifier.value,
                        ),
                        mushafTheme,
                      ),
                      const SizedBox(width: 8),
                      _buildTrackQuickAction(
                        linkedTrack,
                        KhatmaUnit.juz,
                        Icons.bookmark_outline_rounded,
                        AppLocalizations.of(context)!.khatmaV2RecordJuz(
                          _juzForPage(_currentPageNotifier.value),
                        ),
                        mushafTheme,
                      ),
                      const SizedBox(width: 8),
                      _buildTrackQuickAction(
                        linkedTrack,
                        KhatmaUnit.surah,
                        Icons.auto_stories_outlined,
                        AppLocalizations.of(context)!.khatmaV2RecordSurah(
                          _isEnglishUi
                              ? quran.getSurahName(
                                  _surahForPage(_currentPageNotifier.value),
                                )
                              : quran.getSurahNameArabic(
                                  _surahForPage(_currentPageNotifier.value),
                                ),
                        ),
                        mushafTheme,
                      ),
                    ],
                  ),
                ),
              ),
            // Main Content Area
            Expanded(
              child: Stack(
                children: [
                  isEnglishUi
                      ? QuranEnglishView(
                          key: _englishViewKey,
                          bottomInset: contentBottomInset,
                          initialPage: _currentPageNotifier.value,
                          onPageChanged: _onPageChanged,
                          onPlayAyah: _playAyahAudio,
                          onShowTafsir: _showTafsirDialog,
                        )
                      : QuranMushafView(
                          key: _mushafKey,
                          bottomInset: contentBottomInset,
                          initialPage: _currentPageNotifier.value,
                          onPageChanged: _onPageChanged,
                          onShowAyahOptions: _onShowAyahOptions,
                          onShowSurahInfo: (_, __) {},
                        ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AyahDedicatedPlayer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
