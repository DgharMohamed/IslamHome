import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:islam_home/data/models/mushaf_riwaya.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/mushaf_riwaya_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/presentation/providers/audio_ui_provider.dart';
import 'package:islam_home/presentation/widgets/quran_mushaf_view_headers.dart';

class _VirtualMushafPage {
  final int mushafPageNumber;
  final List<Map<String, dynamic>> segments;

  const _VirtualMushafPage({
    required this.mushafPageNumber,
    required this.segments,
  });
}

class QuranMushafView extends ConsumerStatefulWidget {
  final Function(int) onPageChanged;
  final Function(int, int, int, Offset) onShowAyahOptions;
  final void Function(int surah, int ayah) onShowSurahInfo;
  final double bottomInset;

  const QuranMushafView({
    super.key,
    required this.onPageChanged,
    required this.onShowAyahOptions,
    required this.onShowSurahInfo,
    this.bottomInset = 140,
  });

  @override
  ConsumerState<QuranMushafView> createState() => QuranMushafViewState();
}

class QuranMushafViewState extends ConsumerState<QuranMushafView> {
  static const double _playingAyahTopAlignment = 0.15;
  static const double _playingAyahFollowMinTopFactor = 0.10;
  static const double _playingAyahFollowMaxBottomFactor = 0.75;
  static const Duration _playingAyahPageJumpDuration = Duration(
    milliseconds: 110,
  );

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late final ProviderSubscription<AsyncValue<String?>> _playingAyahSub;
  late final ValueNotifier<String?> selectedAyahNotifier;
  final Map<int, List<Map<String, dynamic>>> _pageDataCache = {};
  final Map<int, Map<String, String>> _pageAyahTextCache = {};
  final Map<int, GlobalKey> _surahHeaderKeys = {};
  final Map<String, GlobalKey> _ayahStartMarkerKeys = {};
  final Map<String, GlobalKey> _ayahMarkerKeys = {};
  final Map<String, int> _ayahToVirtualIndex = {};
  final List<_VirtualMushafPage> _virtualPages = [];
  final Map<int, int> _mushafToVirtualIndex = {};
  final Map<int, int> _surahToVirtualIndex = {};
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
  }

  @override
  void dispose() {
    _playingAyahSub.close();
    _itemPositionsListener.itemPositions.removeListener(_onVisibleItemsChanged);
    selectedAyahNotifier.dispose();
    super.dispose();
  }

  void _onVisibleItemsChanged() {
    if (_virtualPages.isEmpty) return;

    final visible = _itemPositionsListener.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0 && p.itemLeadingEdge < 1)
        .toList();
    if (visible.isEmpty) return;

    visible.sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    final idx = visible.first.index.clamp(0, _virtualPages.length - 1);
    final mushafPage = _virtualPages[idx].mushafPageNumber;

    if (mushafPage != _lastReportedPage) {
      _lastReportedPage = mushafPage;
      widget.onPageChanged(mushafPage);
    }
  }

  void _onPlayingAyahChanged(String? ayahKey) {
    final normalized = ayahKey?.trim();
    if (normalized == null || normalized.isEmpty) {
      _lastCenteredAyahKey = null;
      return;
    }
    if (normalized == _lastCenteredAyahKey) return;
    _lastCenteredAyahKey = normalized;

    _ensureVirtualPagesBuilt();

    final parts = normalized.split(':');
    if (parts.length != 2) return;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null || ayah == null) return;

    final mushafPage = quran.getPageNumber(surah, ayah);
    final targetVirtualIndex = _findVirtualIndexForAyah(surah, ayah);
    final needsVirtualJump = !_isVirtualIndexVisible(targetVirtualIndex);

    if (needsVirtualJump) {
      _jumpToVirtualIndex(
        targetVirtualIndex: targetVirtualIndex,
        mushafPageNumber: mushafPage,
        alignment: _playingAyahTopAlignment,
      );
    }

    _scheduleCenterPlayingAyah(normalized, animate: needsVirtualJump);
  }

  int _findVirtualIndexForAyah(int surah, int ayah) {
    final ayahId = '$surah:$ayah';
    final cached = _ayahToVirtualIndex[ayahId];
    if (cached != null) return cached;

    final page = quran.getPageNumber(surah, ayah);
    for (var i = 0; i < _virtualPages.length; i++) {
      final virtual = _virtualPages[i];
      if (virtual.mushafPageNumber != page) continue;

      for (final seg in virtual.segments) {
        final segSurah = seg['surah'] as int;
        final segStart = seg['start'] as int;
        final segEnd = seg['end'] as int;
        if (segSurah == surah && ayah >= segStart && ayah <= segEnd) {
          _ayahToVirtualIndex[ayahId] = i;
          return i;
        }
      }
    }

    final fallback = _mushafToVirtualIndex[page] ?? 0;
    _ayahToVirtualIndex[ayahId] = fallback;
    return fallback;
  }

  bool _isVirtualIndexVisible(int index) {
    for (final item in _itemPositionsListener.itemPositions.value) {
      if (item.index == index &&
          item.itemTrailingEdge > 0 &&
          item.itemLeadingEdge < 1) {
        return true;
      }
    }
    return false;
  }

  bool _isAyahWithinFollowBand(BuildContext ayahContext) {
    final ayahRenderObject = ayahContext.findRenderObject();
    if (ayahRenderObject is! RenderBox) return false;

    final scrollableState = Scrollable.maybeOf(ayahContext);
    final viewportRenderObject = scrollableState?.context.findRenderObject();
    if (viewportRenderObject is! RenderBox) return false;

    final ayahOffset = ayahRenderObject.localToGlobal(
      Offset.zero,
      ancestor: viewportRenderObject,
    );
    final ayahTop = ayahOffset.dy;
    final ayahBottom = ayahTop + ayahRenderObject.size.height;
    final viewportHeight = viewportRenderObject.size.height;
    final minTop = viewportHeight * _playingAyahFollowMinTopFactor;
    final maxBottom = viewportHeight * _playingAyahFollowMaxBottomFactor;

    return ayahTop >= minTop && ayahBottom <= maxBottom;
  }

  void _scheduleCenterPlayingAyah(
    String ayahId, {
    int retries = 10,
    bool animate = false,
  }) {
    if (!mounted || retries <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final key = _ayahStartMarkerKeys[ayahId];
      final context = key?.currentContext;
      if (context != null && context.mounted) {
        if (!animate && _isAyahWithinFollowBand(context)) {
          return;
        }

        Scrollable.ensureVisible(
          context,
          duration: animate ? _playingAyahPageJumpDuration : Duration.zero,
          alignment: _playingAyahTopAlignment,
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

  List<Map<String, dynamic>> _getCachedPageData(int page) {
    return _pageDataCache.putIfAbsent(
      page,
      () => quran.getPageData(page).cast<Map<String, dynamic>>(),
    );
  }

  String _getCachedAyahText(int pageNumber, int surah, int ayah) {
    final pageTexts = _pageAyahTextCache.putIfAbsent(pageNumber, () {
      final map = <String, String>{};
      final data = _getCachedPageData(pageNumber);
      for (final element in data) {
        final s = element['surah'] as int;
        final start = element['start'] as int;
        final end = element['end'] as int;
        for (var a = start; a <= end; a++) {
          map['$s:$a'] = quran.getVerse(s, a, verseEndSymbol: false);
        }
      }
      return map;
    });

    return pageTexts['$surah:$ayah'] ??
        quran.getVerse(surah, ayah, verseEndSymbol: false);
  }

  GlobalKey _getSurahHeaderKey(int surahId) {
    return _surahHeaderKeys.putIfAbsent(surahId, () => GlobalKey());
  }

  GlobalKey _getAyahStartMarkerKey(int surah, int ayah) {
    final id = '$surah:$ayah';
    return _ayahStartMarkerKeys.putIfAbsent(id, () => GlobalKey());
  }

  GlobalKey _getAyahMarkerKey(int surah, int ayah) {
    final id = '$surah:$ayah';
    return _ayahMarkerKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _ensureVirtualPagesBuilt() {
    if (_virtualPages.isNotEmpty) return;

    for (var page = 1; page <= quran.totalPagesCount; page++) {
      final rawSegments = quran.getPageData(page).cast<Map<String, dynamic>>();
      if (rawSegments.isEmpty) continue;

      _mushafToVirtualIndex.putIfAbsent(page, () => _virtualPages.length);

      var start = 0;
      for (var i = 1; i < rawSegments.length; i++) {
        final segStart = rawSegments[i]['start'] as int;
        if (segStart == 1) {
          _appendVirtualPage(page, rawSegments.sublist(start, i));
          start = i;
        }
      }
      _appendVirtualPage(page, rawSegments.sublist(start));
    }
  }

  void _appendVirtualPage(int mushafPage, List<Map<String, dynamic>> segments) {
    if (segments.isEmpty) return;

    final virtualIndex = _virtualPages.length;
    _virtualPages.add(
      _VirtualMushafPage(
        mushafPageNumber: mushafPage,
        segments: List.unmodifiable(segments),
      ),
    );

    final first = segments.first;
    final surah = first['surah'] as int;
    final start = first['start'] as int;
    if (start == 1) {
      _surahToVirtualIndex.putIfAbsent(surah, () => virtualIndex);
    }
  }

  Future<void> navigateToSurah(int surahId) async {
    _ensureVirtualPagesBuilt();
    selectedAyahNotifier.value = null;

    final fallbackPage = quran.getPageNumber(surahId, 1);
    final targetVirtualIndex =
        _surahToVirtualIndex[surahId] ?? _mushafToVirtualIndex[fallbackPage];
    if (targetVirtualIndex == null) return;

    _jumpToVirtualIndex(
      targetVirtualIndex: targetVirtualIndex,
      mushafPageNumber: fallbackPage,
    );
  }

  Future<void> navigateToPage(int pageNumber) async {
    _ensureVirtualPagesBuilt();

    final targetPage = pageNumber.clamp(1, quran.totalPagesCount);
    final targetVirtualIndex = _mushafToVirtualIndex[targetPage];
    if (targetVirtualIndex == null) return;

    _jumpToVirtualIndex(
      targetVirtualIndex: targetVirtualIndex,
      mushafPageNumber: targetPage,
    );
  }

  void _jumpToVirtualIndex({
    required int targetVirtualIndex,
    required int mushafPageNumber,
    double alignment = 0.0,
  }) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(
        index: targetVirtualIndex,
        alignment: alignment,
      );
      _lastReportedPage = mushafPageNumber;
      widget.onPageChanged(mushafPageNumber);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpToVirtualIndex(
        targetVirtualIndex: targetVirtualIndex,
        mushafPageNumber: mushafPageNumber,
        alignment: alignment,
      );
    });
  }

  void clearSelection() {
    selectedAyahNotifier.value = null;
  }

  @override
  Widget build(BuildContext context) {
    _ensureVirtualPagesBuilt();

    final mushafTheme = ref.watch(mushafThemeProvider);
    final playingAyah = ref.watch(playingAyahProvider).value;
    final selectedRiwaya = ref.watch(selectedRiwayaProvider);

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          // Minimize player on any scroll activity
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
        physics: const BouncingScrollPhysics(),
        itemCount: _virtualPages.length + 1,
        itemBuilder: (context, index) {
          if (index >= _virtualPages.length) {
            return SizedBox(height: widget.bottomInset);
          }
          final virtualPage = _virtualPages[index];
          final quranPageNumber = virtualPage.mushafPageNumber;

          return Container(
            key: ValueKey('virtual_page_$index'),
            decoration: BoxDecoration(
              color: mushafTheme.backgroundColor,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageHeader(
                      quranPageNumber,
                      virtualPage.segments,
                      mushafTheme,
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: ValueListenableBuilder<String?>(
                        valueListenable: selectedAyahNotifier,
                        builder: (context, selection, _) {
                          final mushafTextStyle = _buildMushafTextStyle(
                            selectedRiwaya,
                            mushafTheme,
                            quranPageNumber,
                          );

                          return RichText(
                            textAlign:
                                (quranPageNumber == 1 ||
                                    quranPageNumber == 2 ||
                                    quranPageNumber > 570)
                                ? TextAlign.center
                                : TextAlign.justify,
                            softWrap: true,
                            strutStyle: StrutStyle(
                              fontFamily: mushafTextStyle.fontFamily,
                              fontFamilyFallback:
                                  mushafTextStyle.fontFamilyFallback,
                              fontSize: mushafTextStyle.fontSize,
                              height: mushafTextStyle.height,
                              forceStrutHeight: true,
                            ),
                            text: TextSpan(
                              style: mushafTextStyle,
                              children: _buildPageSpans(
                                quranPageNumber,
                                virtualPage.segments,
                                mushafTheme.highlightColor,
                                playingAyah,
                                selection,
                                mushafTheme,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageHeader(
    int pageNumber,
    List<Map<String, dynamic>> pageData,
    MushafTheme theme,
  ) {
    final surahNumber = pageData.isNotEmpty ? pageData[0]['surah'] as int : 1;
    final startAyah = pageData.isNotEmpty ? pageData[0]['start'] as int : 1;
    final juzNumber = quran.getJuzNumber(surahNumber, startAyah);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "الجزء $juzNumber",
              style: TextStyle(
                fontFamily: 'Amiri',
                color: theme.secondaryColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$pageNumber",
              style: TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
                color: theme.secondaryColor,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onShowSurahInfo(surahNumber, startAyah),
              child: Text(
                quran.getSurahNameArabic(surahNumber),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: theme.secondaryColor,
                  fontSize: 13,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildPageSpans(
    int pageNumber,
    List<Map<String, dynamic>> pageData,
    Color highlightColor,
    String? playingAyah,
    String? currentSelection,
    MushafTheme theme,
  ) {
    final spans = <InlineSpan>[];

    for (final element in pageData) {
      final surah = element['surah'] as int;
      final startAyah = element['start'] as int;
      final endAyah = element['end'] as int;

      for (var ayah = startAyah; ayah <= endAyah; ayah++) {
        if (ayah == 1) {
          spans.add(
            WidgetSpan(
              child: SurahHeaderWidget(
                key: _getSurahHeaderKey(surah),
                element: element,
                theme: theme,
                onTapSurahName: () => widget.onShowSurahInfo(surah, 1),
              ),
            ),
          );

          if (surah != 1 && surah != 9) {
            spans.add(WidgetSpan(child: BismillahWidget(theme: theme)));
          }
          if (surah == 9) {
            spans.add(const WidgetSpan(child: SizedBox(height: 20)));
          }
        }

        // Add a start marker for scrolling precision
        spans.add(
          WidgetSpan(
            child: SizedBox.shrink(key: _getAyahStartMarkerKey(surah, ayah)),
          ),
        );

        final ayahText = _getCachedAyahText(pageNumber, surah, ayah);
        final ayahIdentifier = " $surah:$ayah";
        final isHighlighted =
            playingAyah == "${surah.toString()}:${ayah.toString()}" ||
            currentSelection == ayahIdentifier;

        Offset? tapPos;
        final recognizer = TapGestureRecognizer();
        recognizer.onTapDown = (d) => tapPos = d.globalPosition;
        recognizer.onTap = () {
          selectedAyahNotifier.value = ayahIdentifier;
          widget.onShowAyahOptions(
            pageNumber,
            surah,
            ayah,
            tapPos ?? Offset.zero,
          );
        };

        spans.add(
          TextSpan(
            text: '$ayahText ',
            style: TextStyle(
              backgroundColor: isHighlighted
                  ? highlightColor
                  : Colors.transparent,
            ),
            recognizer: recognizer,
          ),
        );

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: KeyedSubtree(
              key: _getAyahMarkerKey(surah, ayah),
              child: GestureDetector(
                onTapDown: (d) => tapPos = d.globalPosition,
                onTap: () {
                  selectedAyahNotifier.value = ayahIdentifier;
                  widget.onShowAyahOptions(
                    pageNumber,
                    surah,
                    ayah,
                    tapPos ?? Offset.zero,
                  );
                },
                child: Text(
                  '\u06DD${_toArabicNum(ayah)}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: isHighlighted
                        ? Colors.amber.shade800
                        : theme.secondaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return spans;
  }

  String _toArabicNum(int n) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => arabic[int.parse(d)]).join();
  }

  TextStyle _buildMushafTextStyle(
    MushafRiwaya riwaya,
    MushafTheme theme,
    int pageNumber,
  ) {
    final isWarsh = riwaya.key == MushafRiwaya.warsh.key;
    final fallback = isWarsh
        ? const ['UthmanicHafs', 'QalonUthmanic', 'Amiri']
        : const ['UthmanicHafs', 'Amiri'];

    return TextStyle(
      color: theme.textColor,
      fontSize: _getFontSizeForPage(pageNumber),
      fontFamily: riwaya.fontFamily,
      fontFamilyFallback: fallback,
      height: isWarsh ? 1.9 : 1.95,
    );
  }

  double _getFontSizeForPage(int pageNumber) {
    if (pageNumber == 1 || pageNumber == 2) return 26.0;
    if (pageNumber == 145 || pageNumber == 201) return 22.0;
    if (pageNumber == 532 || pageNumber == 533) return 22.0;
    return 25.0;
  }
}
