import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/mushaf_riwaya.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/audio_ui_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_riwaya_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_settings_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuranEnglishView extends ConsumerStatefulWidget {
  final ValueChanged<int> onPageChanged;
  final void Function(int surah, int ayah) onPlayAyah;
  final void Function(int surah, int ayah) onShowTafsir;
  final double bottomInset;
  final int initialPage;

  const QuranEnglishView({
    super.key,
    required this.onPageChanged,
    required this.onPlayAyah,
    required this.onShowTafsir,
    this.bottomInset = 140,
    this.initialPage = 1,
  });

  @override
  ConsumerState<QuranEnglishView> createState() => QuranEnglishViewState();
}

class QuranEnglishViewState extends ConsumerState<QuranEnglishView> {
  static const double _playingAyahCenterAlignment = 0.5;
  static const Duration _playingAyahScrollDuration = Duration(
    milliseconds: 260,
  );

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  late final ProviderSubscription<AsyncValue<String?>> _playingAyahSub;
  late final ValueNotifier<String?> selectedAyahNotifier;
  final Map<String, GlobalKey> _ayahCardKeys = {};
  int _lastReportedPage = -1;
  String? _lastCenteredAyahKey;

  @override
  void initState() {
    super.initState();
    selectedAyahNotifier = ValueNotifier<String?>(null);
    _playingAyahSub = ref.listenManual<AsyncValue<String?>>(
      playingAyahProvider,
      (previous, next) => _onPlayingAyahChanged(next.value),
    );
    _itemPositionsListener.itemPositions.addListener(_onVisibleItemsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onPlayingAyahChanged(ref.read(playingAyahProvider).value);
    });
  }

  @override
  void dispose() {
    _playingAyahSub.close();
    _itemPositionsListener.itemPositions.removeListener(_onVisibleItemsChanged);
    selectedAyahNotifier.dispose();
    super.dispose();
  }

  void _onVisibleItemsChanged() {
    final visible = _itemPositionsListener.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0 && p.itemLeadingEdge < 1)
        .toList();
    if (visible.isEmpty) return;

    visible.sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    final pageIndex = visible.first.index;
    if (pageIndex >= quran.totalPagesCount) return;

    final page = pageIndex + 1;
    if (_lastReportedPage != page) {
      _lastReportedPage = page;
      widget.onPageChanged(page);
    }
  }

  Future<void> navigateToSurah(int surahId) async {
    final page = quran.getPageNumber(surahId, 1);
    await navigateToPage(page);
  }

  Future<void> navigateToPage(int pageNumber) async {
    final targetPage = pageNumber.clamp(1, quran.totalPagesCount);
    final targetIndex = targetPage - 1;

    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(index: targetIndex, alignment: 0);
      _lastReportedPage = targetPage;
      widget.onPageChanged(targetPage);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      navigateToPage(targetPage);
    });
  }

  void clearSelection() {
    selectedAyahNotifier.value = null;
  }

  bool _isPageVisible(int pageIndex) {
    for (final item in _itemPositionsListener.itemPositions.value) {
      if (item.index == pageIndex &&
          item.itemTrailingEdge > 0 &&
          item.itemLeadingEdge < 1) {
        return true;
      }
    }
    return false;
  }

  GlobalKey _getAyahCardKey(int surah, int ayah) {
    final id = '$surah:$ayah';
    return _ayahCardKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _onPlayingAyahChanged(String? ayahId) {
    final normalized = ayahId?.trim();
    if (normalized == null || normalized.isEmpty) {
      _lastCenteredAyahKey = null;
      return;
    }
    if (normalized == _lastCenteredAyahKey) return;
    _lastCenteredAyahKey = normalized;

    final parts = normalized.split(':');
    if (parts.length != 2) return;

    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null || ayah == null) return;

    final targetPageIndex = quran.getPageNumber(surah, ayah) - 1;
    final needsPageJump = !_isPageVisible(targetPageIndex);

    if (needsPageJump) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: targetPageIndex, alignment: 0.15);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _onPlayingAyahChanged(normalized);
        });
        return;
      }
    }

    _scheduleCenterPlayingAyah(normalized, animate: needsPageJump);
  }

  void _scheduleCenterPlayingAyah(
    String ayahId, {
    int retries = 12,
    bool animate = false,
  }) {
    if (!mounted || retries <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final key = _ayahCardKeys[ayahId];
      final context = key?.currentContext;
      if (context != null && context.mounted) {
        Scrollable.ensureVisible(
          context,
          alignment: _playingAyahCenterAlignment,
          duration: animate ? _playingAyahScrollDuration : Duration.zero,
          curve: animate ? Curves.easeOutCubic : Curves.linear,
        );
        return;
      }

      _scheduleCenterPlayingAyah(
        ayahId,
        retries: retries - 1,
        animate: animate,
      );
    });
  }

  List<(int surah, int ayah)> _collectPageAyahs(
    List<Map<String, dynamic>> pageData,
  ) {
    final verses = <(int surah, int ayah)>[];
    for (final element in pageData) {
      final surah = element['surah'] as int;
      final startAyah = element['start'] as int;
      final endAyah = element['end'] as int;
      for (var ayah = startAyah; ayah <= endAyah; ayah++) {
        verses.add((surah, ayah));
      }
    }
    return verses;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(mushafThemeProvider);
    final selectedRiwaya = ref.watch(selectedRiwayaProvider);
    final playingAyah = ref.watch(playingAyahProvider).value;
    final mushafSettings = ref.watch(mushafSettingsProvider);

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          final isMinimized = ref.read(audioPlayerMinimizedProvider);
          if (!isMinimized) {
            ref.read(audioPlayerMinimizedProvider.notifier).setMinimized(true);
          }
        }
        return false;
      },
      child: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        initialScrollIndex: widget.initialPage - 1,
        physics: const BouncingScrollPhysics(),
        itemCount: quran.totalPagesCount + 1,
        itemBuilder: (context, index) {
          if (index >= quran.totalPagesCount) {
            return SizedBox(height: widget.bottomInset);
          }

          final pageNumber = index + 1;
          final pageData = quran
              .getPageData(pageNumber)
              .cast<Map<String, dynamic>>();
          final ayahs = _collectPageAyahs(pageData);

          return Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: ValueListenableBuilder<String?>(
                  valueListenable: selectedAyahNotifier,
                  builder: (context, selection, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPageHeader(pageData: pageData, theme: theme),
                        const SizedBox(height: 10),
                        for (var i = 0; i < ayahs.length; i++) ...[
                          if (i == 0 || ayahs[i - 1].$1 != ayahs[i].$1) ...[
                            _buildSurahSectionHeader(
                              theme: theme,
                              surah: ayahs[i].$1,
                            ),
                            const SizedBox(height: 8),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildAyahCard(
                              ayahCardKey: _getAyahCardKey(
                                ayahs[i].$1,
                                ayahs[i].$2,
                              ),
                              theme: theme,
                              selectedRiwaya: selectedRiwaya,
                              surah: ayahs[i].$1,
                              ayah: ayahs[i].$2,
                              playingAyah: playingAyah,
                              currentSelection: selection,
                              l10n: l10n,
                              fontSizeScale: mushafSettings.fontSizeScale,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageHeader({
    required List<Map<String, dynamic>> pageData,
    required MushafTheme theme,
  }) {
    final surahNumber = pageData.isNotEmpty
        ? pageData.first['surah'] as int
        : 1;
    final startAyah = pageData.isNotEmpty ? pageData.first['start'] as int : 1;
    final juzNumber = quran.getJuzNumber(surahNumber, startAyah);
    final surahName = quran.getSurahName(surahNumber);

    return Row(
      children: [
        Text(
          'Juz $juzNumber',
          style: TextStyle(
            color: theme.secondaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          'Surah $surahName',
          style: TextStyle(
            color: theme.textColor.withValues(alpha: 0.9),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSurahSectionHeader({
    required MushafTheme theme,
    required int surah,
  }) {
    final surahName = quran.getSurahName(surah);
    final versesCount = quran.getVerseCount(surah);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Surah $surahName',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$versesCount verses',
            style: TextStyle(
              color: theme.secondaryColor.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCard({
    required GlobalKey ayahCardKey,
    required MushafTheme theme,
    required MushafRiwaya selectedRiwaya,
    required int surah,
    required int ayah,
    required String? playingAyah,
    required String? currentSelection,
    required AppLocalizations l10n,
    required double fontSizeScale,
  }) {
    final ayahKey = '$surah:$ayah';
    final isHighlighted = playingAyah == ayahKey || currentSelection == ayahKey;
    final translation = ref.watch(
      englishVerseTranslationProvider((surah: surah, ayah: ayah)),
    );

    return InkWell(
      key: ayahCardKey,
      onTap: () => selectedAyahNotifier.value = ayahKey,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.highlightColor.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? theme.secondaryColor.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Surah ${quran.getSurahName(surah)} • Ayah $ayah',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.92),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    selectedAyahNotifier.value = ayahKey;
                    widget.onShowTafsir(surah, ayah);
                  },
                  icon: Icon(
                    Icons.menu_book_rounded,
                    color: theme.textColor.withValues(alpha: 0.84),
                  ),
                  tooltip: l10n.tafsirLabel,
                ),
                IconButton(
                  onPressed: () {
                    selectedAyahNotifier.value = ayahKey;
                    widget.onPlayAyah(surah, ayah);
                  },
                  icon: Icon(
                    Icons.play_circle_fill_rounded,
                    color: theme.secondaryColor,
                  ),
                  tooltip: l10n.playVerseAudio,
                ),
              ],
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                quran.getVerse(surah, ayah, verseEndSymbol: false),
                style: TextStyle(
                  color: theme.textColor.withValues(alpha:0.97),
                  fontSize: 26 * fontSizeScale,
                  height: 1.8,
                  fontFamily: selectedRiwaya.fontFamily,
                  fontFamilyFallback: const ['UthmanicHafs', 'Amiri'],
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: theme.textColor.withValues(alpha: 0.45)),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: translation.when(
                data: (text) => Text(
                  text.isNotEmpty ? text : l10n.noTranslationAvailable,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.94),
                    fontSize: 14 * fontSizeScale,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
                loading: () => Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.secondaryColor,
                    ),
                  ),
                ),
                error: (_, __) => Text(
                  l10n.failedToLoadTranslation,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.78),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
