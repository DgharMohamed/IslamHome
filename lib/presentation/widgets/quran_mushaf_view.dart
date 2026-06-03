import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:islam_home/core/utils/responsive_utils.dart';
import 'package:islam_home/data/models/mushaf_riwaya.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/mushaf_riwaya_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/presentation/providers/audio_ui_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_settings_provider.dart';
import 'package:islam_home/presentation/widgets/quran_mushaf_view_headers.dart';
import 'package:islam_home/data/services/last_read_service.dart';

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
  final int initialPage;

  const QuranMushafView({
    super.key,
    required this.onPageChanged,
    required this.onShowAyahOptions,
    required this.onShowSurahInfo,
    this.bottomInset = 140,
    this.initialPage = 1,
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
  final Map<int, List<_VirtualMushafPage>> _mushafPageToVirtualPages = {};
  final List<List<int>> _spreads = [];
  final Map<int, int> _mushafToSpreadIndex = {};
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
      _ensureVirtualPagesBuilt(); // Need this for correct index calculation
      final playingAyah = ref.read(playingAyahProvider).value;
      if (playingAyah != null) {
        _onPlayingAyahChanged(playingAyah);
      }
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
    if (_virtualPages.isEmpty) return;

    final visible = _itemPositionsListener.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0 && p.itemLeadingEdge < 1)
        .toList();
    if (visible.isEmpty) return;

    visible.sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final idx = visible.first.index;
    
    int mushafPage;
    if (isDesktop && idx < _spreads.length) {
      mushafPage = _spreads[idx].first;
    } else if (!isDesktop && idx < _virtualPages.length) {
      mushafPage = _virtualPages[idx].mushafPageNumber;
    } else {
      return;
    }

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
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    final targetIndex = isDesktop 
        ? (_mushafToSpreadIndex[mushafPage] ?? 0)
        : (_findVirtualIndexForAyah(surah, ayah));
        
    final needsJump = !_isIndexVisible(targetIndex);

    if (needsJump) {
      _jumpToIndex(
        targetIndex: targetIndex,
        mushafPageNumber: mushafPage,
        alignment: _playingAyahTopAlignment,
      );
    }

    _scheduleCenterPlayingAyah(normalized, animate: needsJump);
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

  bool _isIndexVisible(int index) {
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

    // Group virtual pages by their physical Mushaf page number
    _mushafPageToVirtualPages.clear();
    for (final vp in _virtualPages) {
      _mushafPageToVirtualPages.putIfAbsent(vp.mushafPageNumber, () => []).add(vp);
    }

    // Build spreads (Page 1 centered, then 2-3, 4-5, etc.)
    _spreads.clear();
    _mushafToSpreadIndex.clear();
    
    // Spread 0: Page 1
    _spreads.add([1]);
    _mushafToSpreadIndex[1] = 0;
    
    for (var page = 2; page <= quran.totalPagesCount; page += 2) {
      final spread = [page];
      if (page + 1 <= quran.totalPagesCount) {
        spread.add(page + 1);
      }
      _spreads.add(spread);
      final spreadIdx = _spreads.length - 1;
      _mushafToSpreadIndex[page] = spreadIdx;
      if (page + 1 <= quran.totalPagesCount) {
        _mushafToSpreadIndex[page + 1] = spreadIdx;
      }
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
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    if (isDesktop) {
      final spreadIdx = _mushafToSpreadIndex[fallbackPage];
      if (spreadIdx == null) return;
      _jumpToIndex(targetIndex: spreadIdx, mushafPageNumber: fallbackPage);
    } else {
      final targetVirtualIndex =
          _surahToVirtualIndex[surahId] ?? _mushafToVirtualIndex[fallbackPage];
      if (targetVirtualIndex == null) return;
      _jumpToIndex(targetIndex: targetVirtualIndex, mushafPageNumber: fallbackPage);
    }
  }

  Future<void> navigateToPage(int pageNumber) async {
    _ensureVirtualPagesBuilt();

    final targetPage = pageNumber.clamp(1, quran.totalPagesCount);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    if (isDesktop) {
      final spreadIdx = _mushafToSpreadIndex[targetPage];
      if (spreadIdx == null) return;
      _jumpToIndex(targetIndex: spreadIdx, mushafPageNumber: targetPage);
    } else {
      final targetVirtualIndex = _mushafToVirtualIndex[targetPage];
      if (targetVirtualIndex == null) return;
      _jumpToIndex(targetIndex: targetVirtualIndex, mushafPageNumber: targetPage);
    }
  }

  void _jumpToIndex({
    required int targetIndex,
    required int mushafPageNumber,
    double alignment = 0.0,
  }) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(
        index: targetIndex,
        alignment: alignment,
      );
      _lastReportedPage = mushafPageNumber;
      widget.onPageChanged(mushafPageNumber);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpToIndex(
        targetIndex: targetIndex,
        mushafPageNumber: mushafPageNumber,
        alignment: alignment,
      );
    });
  }

  void clearSelection() {
    selectedAyahNotifier.value = null;
  }

  int _getInitialScrollIndex() {
    _ensureVirtualPagesBuilt();
    final isDesktop = ResponsiveUtils.isDesktop(context);
    if (isDesktop) {
      return _mushafToSpreadIndex[widget.initialPage] ?? 0;
    }
    return _mushafToVirtualIndex[widget.initialPage] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    _ensureVirtualPagesBuilt();

    final mushafTheme = ref.watch(mushafThemeProvider);
    final playingAyah = ref.watch(playingAyahProvider).value;
    final selectedRiwaya = ref.watch(selectedRiwayaProvider);
    final mushafSettings = ref.watch(mushafSettingsProvider);
    final lastReadPos = ref.watch(lastReadPositionProvider).value;


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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = ResponsiveUtils.isDesktop(context);
          final bool useSpread = isDesktop && constraints.maxWidth > 900;
          
          return ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            initialScrollIndex: _getInitialScrollIndex(),
            physics: const BouncingScrollPhysics(),
            itemCount: useSpread ? (_spreads.length + 1) : (_virtualPages.length + 1),
            itemBuilder: (context, index) {
              if (useSpread) {
                if (index >= _spreads.length) {
                  return SizedBox(height: widget.bottomInset);
                }
                final pageNumbers = _spreads[index];
                return Container(
                  key: ValueKey('spread_$index'),
                  color: mushafTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pageNumbers.map((p) {
                        final vps = _mushafPageToVirtualPages[p] ?? [];
                        return Container(
                          width: math.min(500, (constraints.maxWidth - 100) / 2), // Dynamic width for each page
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: mushafTheme.backgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: vps.map((vp) => _buildVirtualPage(
                              vp,
                              mushafTheme,
                              playingAyah,
                              selectedRiwaya,
                              mushafSettings,
                              lastReadPos,
                            )).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }

              if (index >= _virtualPages.length) {
                return SizedBox(height: widget.bottomInset);
              }
              final virtualPage = _virtualPages[index];
              return _buildVirtualPage(
                virtualPage,
                mushafTheme,
                playingAyah,
                selectedRiwaya,
                mushafSettings,
                lastReadPos,
                showPageDecoration: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVirtualPage(
    _VirtualMushafPage virtualPage,
    MushafTheme mushafTheme,
    String? playingAyah,
    MushafRiwaya selectedRiwaya,
    MushafSettings mushafSettings,
    LastReadPosition? lastReadPos, {
    bool showPageDecoration = false,
  }) {
    final quranPageNumber = virtualPage.mushafPageNumber;
    
    final Widget content = Column(
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
                mushafSettings.fontSizeScale,
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
                    mushafSettings.fontSizeScale,
                    lastReadPos,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (showPageDecoration) {
      return Container(
        key: ValueKey('virtual_page_${virtualPage.mushafPageNumber}_${virtualPage.segments.first['start']}'),
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
            child: content,
          ),
        ),
      );
    }
    
    return content;
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
              'الجزء $juzNumber',
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
              '$pageNumber',
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
    double fontSizeScale,
    LastReadPosition? lastReadPos,
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
                fontSizeScale: fontSizeScale,
                onTapSurahName: () => widget.onShowSurahInfo(surah, 1),
              ),
            ),
          );

          if (surah != 1 && surah != 9) {
            spans.add(WidgetSpan(child: BismillahWidget(theme: theme, fontSizeScale: fontSizeScale)));
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
        final ayahIdentifier = ' $surah:$ayah';
        final isHighlighted =
            playingAyah == '${surah.toString()}:${ayah.toString()}' ||
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

        final isBookmarked = lastReadPos?.surahNumber == surah && lastReadPos?.ayahNumber == ayah;

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
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      '\u06DD${_toArabicNum(ayah)}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22 * fontSizeScale,
                        color: isHighlighted
                            ? Colors.amber.shade800
                            : theme.secondaryColor,
                      ),
                    ),
                    if (isBookmarked)
                      Positioned(
                        top: -8,
                        child: Icon(
                          Icons.bookmark,
                          size: 14 * fontSizeScale,
                          color: Colors.redAccent.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
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
    double fontSizeScale,
  ) {
    final isWarsh = riwaya.key == MushafRiwaya.warsh.key;
    final fallback = isWarsh
        ? const ['UthmanicHafs', 'QalonUthmanic', 'Amiri']
        : const ['UthmanicHafs', 'Amiri'];

    return TextStyle(
      color: theme.textColor,
      fontSize: _getFontSizeForPage(pageNumber) * fontSizeScale,
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
