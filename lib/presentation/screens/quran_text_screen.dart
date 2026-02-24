import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/providers/khatma_provider.dart';
import 'package:islam_home/presentation/widgets/dua_khatm_dialog.dart';
import 'package:islam_home/presentation/widgets/sajdah_marker.dart';
import 'package:islam_home/presentation/widgets/mushaf_verse_marker.dart';
import 'package:flutter/gestures.dart';
import 'package:islam_home/presentation/providers/quran_flow_notifier.dart';
import 'package:islam_home/presentation/providers/quran_settings_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islam_home/presentation/widgets/ayah_details_sheet.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:islam_home/data/services/last_read_service.dart';
// Removed ReadingMode enum - only Flow mode is supported now

class QuranTextScreen extends ConsumerStatefulWidget {
  final int? initialSurahNumber;
  final int? initialAyahNumber;

  const QuranTextScreen({
    super.key,
    this.initialSurahNumber,
    this.initialAyahNumber,
  });

  @override
  ConsumerState<QuranTextScreen> createState() => _QuranTextScreenState();
}

class _QuranTextScreenState extends ConsumerState<QuranTextScreen> {
  late ScrollController _scrollController;
  int _currentVisibleSurah = 1;
  final Map<int, GlobalKey> _surahKeys = {};
  final Map<String, GlobalKey> _ayahKeys = {};

  /// Scroll alignment determines where the target ayah appears on screen.
  /// 0.0 = top, 0.5 = center, 1.0 = bottom. Set to 0.1 to keep ayah near top.
  static const double _kScrollAlignment = 0.1;
  static const Color _darkBrownColor = Color(0xFF2C1810);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.initialSurahNumber != null) {
      selectedSurahNumber = widget.initialSurahNumber!;
      _currentVisibleSurah = widget.initialSurahNumber!;
    }

    _scrollController.addListener(_onScroll);

    // Initial jump after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Check for initial ayah deep-link first
      if (widget.initialSurahNumber != null &&
          widget.initialAyahNumber != null) {
        final position = LastReadPosition(
          surahNumber: widget.initialSurahNumber!,
          ayahNumber: widget.initialAyahNumber!,
        );

        // Load the surah
        await ref
            .read(quranFlowProvider.notifier)
            .loadInitialSurah(
              widget.initialSurahNumber!,
              translation: selectedTranslation,
            );

        // Navigate to the ayah instantly
        _goToLastReadInstant(position);
        return;
      }

      // If no initial position specified, try to load last read position
      if (widget.initialSurahNumber == null) {
        final lastRead = await ref.read(lastReadServiceProvider).getLastRead();
        if (lastRead != null && mounted) {
          selectedSurahNumber = lastRead.surahNumber;
          _currentVisibleSurah = lastRead.surahNumber;

          // Load the surah and navigate to last read position
          await ref
              .read(quranFlowProvider.notifier)
              .loadInitialSurah(
                selectedSurahNumber,
                translation: selectedTranslation,
              );

          // Navigate to the last read ayah instantly (no animation)
          _goToLastReadInstant(lastRead);
          return;
        }
      }

      // Default behavior: load initial surah
      ref
          .read(quranFlowProvider.notifier)
          .loadInitialSurah(
            selectedSurahNumber,
            translation: selectedTranslation,
          );
      _jumpToInitialSurah(selectedSurahNumber);
    });
  }

  void _jumpToInitialSurah(int number) {
    // We wait for data to load and then try to jump
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _jumpToSurah(number);
    });
  }

  DateTime _lastScrollTime = DateTime.now();

  void _onScroll() {
    final now = DateTime.now();
    if (now.difference(_lastScrollTime).inMilliseconds < 100) return;
    _lastScrollTime = now;

    // Optimize: only check surahs around the current one to save CPU
    final start = (_currentVisibleSurah - 2).clamp(1, 114);
    final end = (_currentVisibleSurah + 2).clamp(1, 114);

    int? mostVisible;
    double minDelta = double.infinity;

    for (int i = start; i <= end; i++) {
      final key = _surahKeys[i];
      if (key == null) continue;
      final context = key.currentContext;
      if (context != null) {
        final renderObject = context.findRenderObject();
        if (renderObject != null && renderObject is RenderBox) {
          final position = renderObject.localToGlobal(Offset.zero).dy;
          final delta = (position - 150).abs(); // 150 is approx appbar height
          if (delta < minDelta) {
            minDelta = delta;
            mostVisible = i;
          }
        }
      }
    }

    // Fallback: if none of the range is visible, scan all (should rarely happen)
    if (mostVisible == null) {
      for (var entry in _surahKeys.entries) {
        final context = entry.value.currentContext;
        if (context != null) {
          final renderObject = context.findRenderObject();
          if (renderObject != null && renderObject is RenderBox) {
            final position = renderObject.localToGlobal(Offset.zero).dy;
            final delta = (position - 150).abs();
            if (delta < minDelta) {
              minDelta = delta;
              mostVisible = entry.key;
            }
          }
        }
      }
    }

    if (mostVisible != null && mostVisible != _currentVisibleSurah) {
      if (mounted) {
        setState(() {
          _currentVisibleSurah = mostVisible!;
        });
      }
      // Pre-load neighbors
      ref
          .read(quranFlowProvider.notifier)
          .ensureSurahVisible(mostVisible, translation: selectedTranslation);

      // Sync audio if playing (Follow-Scroll)
      _syncAudioToCurrentSurah();
    }
  }

  void _syncAudioToCurrentSurah() async {
    final audioService = ref.read(audioPlayerServiceProvider);
    final selectedReciter = ref.read(selectedReciterProvider);
    if (audioService == null || selectedReciter == null) return;

    // Only switch if currently playing to avoid annoying auto-starts
    if (audioService.player.playing) {
      final currentItem =
          audioService.player.sequenceState?.currentSource?.tag as MediaItem?;
      final playingSurah = currentItem?.extras?['surahNumber'];

      if (playingSurah != null && playingSurah != _currentVisibleSurah) {
        final moshaf = selectedReciter.moshaf?.isNotEmpty == true
            ? selectedReciter.moshaf!.first
            : null;
        if (moshaf?.server == null) {
          debugPrint(
            '⚠️ No moshaf server available for reciter: ${selectedReciter.name}',
          );
          return;
        }

        final paddedId = _currentVisibleSurah.toString().padLeft(3, '0');
        final url = '${moshaf!.server}$paddedId.mp3';
        debugPrint('🎵 Attempting to play: $url');

        // Get current locale for title
        final currentLocale = ref.read(localeProvider);
        final isEnglish = currentLocale.languageCode == 'en';
        final surahName = QuranUtils.getSurahName(
          _currentVisibleSurah,
          isEnglish: isEnglish,
        );
        final surahTitle = isEnglish ? 'Surah $surahName' : 'سورة $surahName';

        try {
          final source = AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(
              id: url,
              title: surahTitle,
              artist: selectedReciter.name,
              artUri: Uri.parse(
                'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
              ),
              extras: {'surahNumber': _currentVisibleSurah},
            ),
          );

          await audioService.setPlaylist(sources: [source]);
        } catch (e) {
          debugPrint('❌ Error playing audio: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في تشغيل الصوت: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _jumpToSurah(int number) {
    final key = _surahKeys[number];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If key not found, try again after a short delay
      debugPrint('⚠️ Key for surah $number not found, retrying...');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final retryKey = _surahKeys[number];
          if (retryKey != null && retryKey.currentContext != null) {
            Scrollable.ensureVisible(
              retryKey.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            debugPrint('❌ Failed to find key for surah $number after retry');
          }
        }
      });
    }
  }

  int selectedSurahNumber = 1;
  String selectedTranslation = 'en.sahih'; // Default English translation
  String arabicEdition = 'quran-uthmani'; // Clear Uthmani text
  String selectedTafsir = 'ar.jalalayn';
  bool isTafsirLoading = false;

  bool _isNightMode = false; // Night mode state
  int? _highlightedAyahNumber;
  int? _highlightedSurahNumber;

  // Get colors based on night mode
  Color get _backgroundColor =>
      _isNightMode ? const Color(0xFF0D1117) : const Color(0xFFFDFBF7);
  Color get _textColor =>
      _isNightMode ? const Color(0xFFE8D4B0) : const Color(0xFF2C1810);
  Color get _secondaryTextColor =>
      _isNightMode ? const Color(0xFFC4A57B) : const Color(0xFF8B7355);
  Color get _appBarColor =>
      _isNightMode ? const Color(0xFF161B22) : const Color(0xFFFDFBF7);
  Color get _goldColor =>
      _isNightMode ? const Color(0xFFFFD700) : const Color(0xFFD4AF37);

  /// Determines the position of the floating action button based on language direction
  /// and whether we're at Surah 114 (where the dua button appears).
  ///
  /// Returns:
  /// - For RTL (Arabic): endFloat normally, startFloat when at Surah 114
  /// - For LTR (English): startFloat normally, endFloat when at Surah 114
  ///
  /// This ensures the surah selector FAB doesn't overlap with the dua button.
  FloatingActionButtonLocation _getFABLocation() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // Note: Dua button moved to a card at end of Surah 114 to prevent overlap with audio player
    return isRTL
        ? FloatingActionButtonLocation.endFloat
        : FloatingActionButtonLocation.startFloat;
  }

  /// Builds the floating action button(s) based on the current surah.
  ///
  /// Returns:
  /// - At Surah 114: A Row containing two FABs (surah selector + dua khatm)
  /// - Other surahs: A single FAB for surah selection
  ///
  /// Each button uses a unique heroTag to avoid conflicts.
  Widget? _buildFloatingActionButtons() {
    final l10n = AppLocalizations.of(context)!;

    // Moving Dua button into a card at the end of Surah 114 (An-Naas)
    // to avoid layout congestion and overlap with the playback bar.
    return FloatingActionButton.extended(
      heroTag: 'surah_selector',
      onPressed: _showSurahPicker,
      backgroundColor: _goldColor,
      elevation: 4,
      tooltip: l10n.index,
      icon: Icon(Icons.menu_book, color: _darkBrownColor),
      label: Text(
        l10n.index,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: _darkBrownColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  final Map<String, String> translationOptions = {
    'en.sahih': 'English (Sahih)',
  };

  final Map<String, String> tafsirOptions = {
    'ar.jalalayn': 'تفسير الجلالين',
    'ar.muyassar': 'التفسير الميسر',
    'ar.tanweer': 'تفسير التنوير',
    'ar.waseet': 'الوسيط لطنطاوي',
    'en.ahmedali': 'Ahmed Ali (English)',
    'en.asad': 'Muhammad Asad (English)',
    'en.hilali': 'Hilali & Khan (English)',
    'en.pickthall': 'Pickthall (English)',
    'en.yusufali': 'Yusuf Ali (English)',
  };

  // Helper method to get surah name based on current language
  String _getSurahName(
    int surahNumber, {
    String? arabicName,
    String? englishName,
  }) {
    final currentLocale = ref.read(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';

    if (isEnglish) {
      return englishName ??
          QuranUtils.getSurahName(surahNumber, isEnglish: true);
    } else {
      return arabicName?.replaceAll('سورة', '').trim() ??
          QuranUtils.getSurahName(surahNumber, isEnglish: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: _getFABLocation(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Row(
          children: [
            // أيقونة الانتقال لآخر قراءة على اليسار
            Consumer(
              builder: (context, ref, child) {
                // مراقبة التغييرات في lastReadUpdateProvider
                final updateTrigger = ref.watch(lastReadUpdateProvider);

                return FutureBuilder<LastReadPosition?>(
                  key: ValueKey(
                    updateTrigger,
                  ), // إجبار إعادة البناء عند التغيير
                  future: ref.read(lastReadServiceProvider).getLastRead(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isNightMode
                              ? const Color(0xFF1C2128).withValues(alpha: 0.95)
                              : const Color(0xFFFDFBF7).withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _goldColor.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.bookmark,
                            color: _goldColor,
                            size: 28,
                          ),
                          onPressed: () {
                            debugPrint('🔖 Bookmark icon pressed!');
                            debugPrint(
                              '🔖 Last read data: Surah ${snapshot.data!.surahNumber}, Ayah ${snapshot.data!.ayahNumber}',
                            );
                            _goToLastRead(snapshot.data!);
                          },
                          tooltip: AppLocalizations.of(context)!.lastRead,
                        ),
                      );
                    }
                    return const SizedBox(width: 56);
                  },
                );
              },
            ),
            const SizedBox(width: 12),
            // مشغل القرآن على اليمين
            Expanded(child: _buildFloatingPlayer()),
          ],
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 130.0, // Increased to provide more space
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: _appBarColor,
            centerTitle: false,
            leading: context.canPop()
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF5D4037),
                    ), // Brown
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  )
                : Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu_rounded,
                        size: 28,
                        color: Color(0xFF5D4037),
                      ),
                      onPressed: () => GlobalScaffoldService.openDrawer(),
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _isNightMode
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF5D4037),
                ),
                onPressed: () => context.push('/quran-search?from=text'),
                tooltip: AppLocalizations.of(context)!.search,
              ),
              IconButton(
                icon: Icon(
                  Icons.format_size,
                  color: _isNightMode
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF5D4037),
                ),
                onPressed: _showFontSizeDialog,
                tooltip: AppLocalizations.of(context)!.fontSize,
              ),
              IconButton(
                icon: Icon(
                  _isNightMode ? Icons.light_mode : Icons.dark_mode,
                  color: _isNightMode
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF5D4037),
                ),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _isNightMode = !_isNightMode;
                    });
                  }
                },
                tooltip: _isNightMode
                    ? AppLocalizations.of(context)!.dayMode
                    : AppLocalizations.of(context)!.nightMode,
              ),
              IconButton(
                icon: Icon(
                  Icons.record_voice_over_outlined,
                  color: _isNightMode
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF5D4037),
                ),
                onPressed: _showReciterPicker,
                tooltip: AppLocalizations.of(context)!.chooseReciter,
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final settings = context
                    .dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings
                    >();
                final deltaExtent = settings!.maxExtent - settings.minExtent;
                final t =
                    (1.0 -
                            (settings.currentExtent - settings.minExtent) /
                                deltaExtent)
                        .clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(
                    bottom: 12 + (4 * (1 - t)),
                    left: 20 + (40 * t),
                    right: 20 + (40 * t),
                  ),
                  title: Opacity(
                    opacity: t > 0.7 ? 1.0 : 0.0,
                    child: surahsAsync.when(
                      data: (surahs) {
                        final currentSurah = surahs.firstWhere(
                          (s) => s.number == _currentVisibleSurah,
                        );
                        final surahName = _getSurahName(
                          _currentVisibleSurah,
                          arabicName: currentSurah.name,
                          englishName: currentSurah.englishName,
                        );
                        return GestureDetector(
                          onTap: _showSurahPicker,
                          child: Text(
                            surahName,
                            style: GoogleFonts.amiri(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ),
                  background: Container(
                    color: _appBarColor,
                    child: surahsAsync.when(
                      data: (surahs) {
                        final currentSurah = surahs.firstWhere(
                          (s) => s.number == _currentVisibleSurah,
                        );
                        final currentLocale = ref.watch(localeProvider);
                        return Opacity(
                          opacity: (1.0 - t).clamp(0.0, 1.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 45),
                                Text(
                                  currentLocale.languageCode == 'ar'
                                      ? currentSurah.name ?? ''
                                      : currentSurah.englishName ?? '',
                                  style: GoogleFonts.amiri(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                                FutureBuilder<QuranSurahContent?>(
                                  future: ref
                                      .read(quranServiceProvider)
                                      .getQuranSurah(_currentVisibleSurah),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }
                                    final ayah = snapshot.data!.ayahs!.first;
                                    return Text(
                                      currentLocale.languageCode == 'ar'
                                          ? 'صفحة ${ayah.page ?? 1} | الجزء ${ayah.juz ?? 1} | الحزب ${((ayah.hizbQuarter ?? 1) / 4).ceil()}'
                                          : 'Page ${ayah.page ?? 1} | Juz ${ayah.juz ?? 1} | Hizb ${((ayah.hizbQuarter ?? 1) / 4).ceil()}',
                                      style: GoogleFonts.amiri(
                                        fontSize: 11,
                                        color: _secondaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
            title: null,
          ),

          // Settings Bar
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Ayah List
          Consumer(
            builder: (context, ref, child) {
              final flowState = ref.watch(quranFlowProvider);

              if (flowState.isLoading && flowState.items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = flowState.items[index];
                  if (item.type == FlowItemType.surahHeader) {
                    // Only create key if it doesn't exist
                    _surahKeys.putIfAbsent(item.surahNumber, () => GlobalKey());
                    return Container(
                      key: _surahKeys[item.surahNumber],
                      child: _buildSurahHeaderFromItem(item),
                    );
                  } else {
                    return _buildAyahBlock(item);
                  }
                }, childCount: flowState.items.length),
              );
            },
          ),

          // Dua Card (Only at the end of the Quran Surah 114)
          if (selectedSurahNumber == 114)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: _buildDuaKhatmCard(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSurahHeaderFromItem(FlowItem item) {
    // Sync Khatma progress (only forward)
    if (item.surahNumber == _currentVisibleSurah) {
      // We can estimate page from surahStartPages
      final firstPage = QuranUtils.surahStartPages[item.surahNumber];
      if (firstPage != null &&
          firstPage > ref.read(khatmaProvider).currentPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(khatmaProvider.notifier).updateProgress(firstPage);
        });
      }
    }

    final surahsAsync = ref.watch(surahsProvider);

    return Container(
      // Ensure Surah headers have fixed, ample spacing to prevent overlap
      margin: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            surahsAsync.when(
              data: (surahs) {
                final surah = surahs.firstWhere(
                  (s) => s.number == item.surahNumber,
                  orElse: () => surahs.first,
                );
                final surahName = _getSurahName(
                  item.surahNumber,
                  arabicName: surah.name,
                  englishName: surah.englishName,
                );
                return Text(
                  surahName,
                  style: GoogleFonts.amiri(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    height: 1.1,
                  ),
                );
              },
              loading: () => Text(
                item.surahName?.replaceAll('سورة', '').trim() ?? '',
                style: GoogleFonts.amiri(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  height: 1.1,
                ),
              ),
              error: (_, __) => Text(
                item.surahName?.replaceAll('سورة', '').trim() ?? '',
                style: GoogleFonts.amiri(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (item.surahNumber != 1 && item.surahNumber != 9)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  style: GoogleFonts.amiri(fontSize: 26, color: _textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahBlock(FlowItem item) {
    final ayahs = item.ayahs ?? [];
    final transAyahs = item.translationAyahs ?? [];
    final List<Widget> children = [];
    final currentLocale = ref.watch(localeProvider);
    final showTranslation = currentLocale.languageCode == 'en';

    // If English, show each ayah with translation below
    if (showTranslation) {
      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        final trans = transAyahs.length > i ? transAyahs[i] : null;
        final dynamic rawSajda = ayah.sajda;
        final isSajdah =
            rawSajda != null &&
            (rawSajda == true ||
                rawSajda == 1 ||
                rawSajda == 'true' ||
                rawSajda == '1' ||
                (rawSajda is Map && rawSajda.isNotEmpty));

        final isHighlighted =
            _highlightedSurahNumber == item.surahNumber &&
            _highlightedAyahNumber == ayah.numberInSurah;

        bool isJuzStart = false;
        for (var entry in QuranUtils.juzMapping.entries) {
          if (entry.value['surah'] == item.surahNumber &&
              entry.value['ayah'] == ayah.numberInSurah) {
            isJuzStart = true;
            break;
          }
        }

        bool isHizbStart = false;
        if (!isJuzStart) {
          for (var entry in QuranUtils.hizbMapping.entries) {
            if (entry.value['surah'] == item.surahNumber &&
                entry.value['ayah'] == ayah.numberInSurah) {
              isHizbStart = true;
              break;
            }
          }
        }

        final Color? blockColor;
        final BoxBorder? blockBorder;

        if (isHighlighted) {
          blockColor = _goldColor.withValues(alpha: _isNightMode ? 0.3 : 0.25);
          blockBorder = Border.all(
            color: _goldColor.withValues(alpha: 0.6),
            width: 2,
          );
        } else if (isJuzStart) {
          blockColor = const Color(
            0xFFE91E63, // Pink/Rose Red
          ).withValues(alpha: _isNightMode ? 0.2 : 0.15);
          blockBorder = Border.all(
            color: const Color(0xFFE91E63).withValues(alpha: 0.4),
            width: 1,
          );
        } else if (isHizbStart) {
          blockColor = const Color(
            0xFFD81B60, // Deep Rose Red / Crimson
          ).withValues(alpha: _isNightMode ? 0.2 : 0.15);
          blockBorder = Border.all(
            color: const Color(0xFFD81B60).withValues(alpha: 0.4),
            width: 1,
          );
        } else {
          blockColor = Colors.transparent;
          blockBorder = null;
        }

        children.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(12),
              border: blockBorder,
            ),
            child: GestureDetector(
              onTap: () => _showAyahDetails(ayah, translation: trans),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic text with verse marker
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          // Invisible anchor at the START of the ayah
                          WidgetSpan(
                            child: SizedBox.shrink(
                              key: _ayahKeys.putIfAbsent(
                                '${item.surahNumber}_${ayah.numberInSurah}',
                                () => GlobalKey(),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '${ayah.text} ',
                            style: GoogleFonts.amiri(
                              fontSize: ref.watch(quranFontSizeProvider),
                              height: 2.2,
                              color: _textColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: MushafVerseMarker(
                                verseNumber: ayah.numberInSurah ?? 0,
                                size: ref.watch(quranFontSizeProvider) * 1.1,
                                color: _goldColor,
                              ),
                            ),
                          ),
                          if (isSajdah)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: SajdahMarker(
                                  color: _goldColor,
                                  size: 20, // Increased slightly for visibility
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // English translation
                  if (trans != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        trans.text ?? '',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.archivoBlack(
                          fontSize: ref.watch(translationFontSizeProvider),
                          height: 1.5,
                          color: _secondaryTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      // Arabic only - original flow view
      final List<InlineSpan> spans = [];

      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        final trans = transAyahs.length > i ? transAyahs[i] : null;

        final isHighlighted =
            _highlightedSurahNumber == item.surahNumber &&
            _highlightedAyahNumber == ayah.numberInSurah;

        // Anchor at beginning of Arabic text
        spans.add(
          WidgetSpan(
            child: SizedBox.shrink(
              key: _ayahKeys.putIfAbsent(
                '${item.surahNumber}_${ayah.numberInSurah}',
                () => GlobalKey(),
              ),
            ),
          ),
        );

        // Arabic Text
        spans.add(
          TextSpan(
            text: '${ayah.text} ',
            recognizer: TapGestureRecognizer()
              ..onTap = () => _showAyahDetails(ayah, translation: trans),
            style: GoogleFonts.amiri(
              fontSize: ref.watch(quranFontSizeProvider),
              height: 2.2,
              color: _textColor,
              backgroundColor: isHighlighted
                  ? _goldColor.withValues(alpha: _isNightMode ? 0.35 : 0.3)
                  : null,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );

        // Ayah Marker (Number)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: MushafVerseMarker(
                verseNumber: ayah.numberInSurah ?? 0,
                size: ref.watch(quranFontSizeProvider) * 1.1,
                color: _goldColor,
              ),
            ),
          ),
        );

        // Robust checking for Sajdah
        final dynamic rawSajda = ayah.sajda;
        final isSajdah =
            rawSajda != null &&
            (rawSajda == true ||
                rawSajda == 1 ||
                rawSajda == 'true' ||
                rawSajda == '1' ||
                (rawSajda is Map && rawSajda.isNotEmpty));

        if (isSajdah) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SajdahMarker(
                  color: _goldColor,
                  size: 20, // Consistent with split view
                ),
              ),
            ),
          );
        }
      }

      if (spans.isNotEmpty) {
        children.add(
          Directionality(
            textDirection: TextDirection.rtl,
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(children: spans),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      child: Column(children: children),
    );
  }

  // Removed unused _toArabicNumbers logic

  void _showAyahDetails(Ayah ayah, {Ayah? translation}) {
    final surahNumForTafsir = ayah.surah?.number ?? _currentVisibleSurah;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AyahDetailsSheet(
          ayah: ayah,
          translation: translation,
          surahNumber: surahNumForTafsir,
          translationOptions: translationOptions,
          selectedTranslation: selectedTranslation,
          tafsirOptions: tafsirOptions,
          apiService: ref.read(apiServiceProvider),
        );
      },
    );
  }

  void _showDua(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DuaKhatmDialog(isNightMode: _isNightMode),
    );
  }

  Widget _buildDuaKhatmCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: InkWell(
        onTap: () => _showDua(context),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _goldColor.withValues(alpha: 0.15),
                _goldColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _goldColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _goldColor.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _goldColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: _goldColor, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.duaKhatmQuran,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                Directionality.of(context) == TextDirection.rtl
                    ? 'تقبل الله منا ومنكم صالح الأعمال'
                    : 'May Allah accept from us and you',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToLastRead(LastReadPosition lastRead) async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '🔖 Going to last read: Surah ${lastRead.surahNumber}, Ayah ${lastRead.ayahNumber}',
    );

    // الانتقال للسورة
    if (mounted) {
      setState(() {
        selectedSurahNumber = lastRead.surahNumber;
        _currentVisibleSurah = lastRead.surahNumber;
        _highlightedSurahNumber = lastRead.surahNumber;
        _highlightedAyahNumber = lastRead.ayahNumber;
        _ayahKeys.clear(); // Clear old keys
        _surahKeys.clear();
      });
    }

    // تحميل السورة
    await ref
        .read(quranFlowProvider.notifier)
        .loadInitialSurah(
          lastRead.surahNumber,
          translation: selectedTranslation,
        );

    // الانتظار للتأكد من بناء الواجهة باستخدام postFrameCallback
    if (mounted) {
      // Force rebuild to create keys
      setState(() {});

      // Wait for the frame to complete and widgets to be built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        debugPrint('🔖 Attempting to jump to ayah instantly...');

        // Use the instant jump method for a direct transition
        _attemptJumpToAyahInstant(lastRead, 0);
      });
    }

    // إظهار رسالة للمستخدم
    final currentLocale = ref.read(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';
    final surahName = QuranUtils.getSurahName(
      lastRead.surahNumber,
      isEnglish: isEnglish,
    );
    final message = l10n.navigatedToAyah(surahName, lastRead.ayahNumber);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo()),
          backgroundColor: _goldColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Clear highlight after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _highlightedAyahNumber = null;
          _highlightedSurahNumber = null;
        });
      }
    });
  }

  // Instant navigation without animation (for initial load)
  void _goToLastReadInstant(LastReadPosition lastRead) async {
    debugPrint(
      '🔖 Going to last read instantly: Surah ${lastRead.surahNumber}, Ayah ${lastRead.ayahNumber}',
    );

    if (mounted) {
      setState(() {
        selectedSurahNumber = lastRead.surahNumber;
        _currentVisibleSurah = lastRead.surahNumber;
        _highlightedSurahNumber = lastRead.surahNumber;
        _highlightedAyahNumber = lastRead.ayahNumber;
        _ayahKeys.clear();
        _surahKeys.clear();
      });
    }

    if (mounted) {
      setState(() {});

      // Reduced wait time for a more immediate feel
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _attemptJumpToAyahInstant(lastRead, 0);
        });
      }
    }

    // Clear highlight after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _highlightedAyahNumber = null;
          _highlightedSurahNumber = null;
        });
      }
    });
  }

  // Instant jump without animation
  void _attemptJumpToAyahInstant(LastReadPosition lastRead, int attempt) {
    if (!mounted || attempt >= 40) {
      if (attempt >= 40) {
        debugPrint(
          '❌ Failed to navigate to ayah after 40 attempts. '
          'Target: Surah ${lastRead.surahNumber}, Ayah ${lastRead.ayahNumber}. '
          'Available Ayah Keys: ${_ayahKeys.length}',
        );
      }
      return;
    }

    final targetKey = '${lastRead.surahNumber}_${lastRead.ayahNumber}';
    final key = _ayahKeys[targetKey];

    if (key != null && key.currentContext != null) {
      // Found it! Jump instantly without animation
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Duration.zero,
        alignment: _kScrollAlignment,
      );
      debugPrint(
        '✅ Successfully jumped to ayah ${lastRead.ayahNumber} instantly on attempt ${attempt + 1}',
      );

      // Clear highlight after some time
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          setState(() {
            _highlightedAyahNumber = null;
            _highlightedSurahNumber = null;
          });
        }
      });
    } else {
      // Key not found - Smart Seek Logic (Instant version)
      if (attempt % 5 == 0) {
        debugPrint(
          '🔖 Attempt ${attempt + 1}: Key $targetKey not found. Keys available: ${_ayahKeys.length}. Context ready: ${key?.currentContext != null}',
        );
      }

      double scrollDelta = 0;
      bool isTargetBefore = false;

      // 1. Check for visible ayahs in ANY surah to determine direction
      for (final entry in _ayahKeys.entries) {
        if (entry.value.currentContext == null) continue;
        final parts = entry.key.split('_');
        if (parts.length != 2) continue;
        final sNum = int.tryParse(parts[0]);
        final aNum = int.tryParse(parts[1]);
        if (sNum == null || aNum == null) continue;

        if (sNum > lastRead.surahNumber) {
          isTargetBefore = true;
          break;
        } else if (sNum < lastRead.surahNumber) {
          isTargetBefore = false;
          break;
        } else {
          // Same surah
          if (aNum > lastRead.ayahNumber) {
            isTargetBefore = true;
            break;
          } else if (aNum < lastRead.ayahNumber) {
            isTargetBefore = false;
            break;
          }
        }
      }

      // 2. Check for visible surah headers (more reliable for far jumps)
      if (!isTargetBefore) {
        // Only if not determined yet
        for (final entry in _surahKeys.entries) {
          if (entry.value.currentContext == null) continue;
          if (entry.key > lastRead.surahNumber) {
            isTargetBefore = true;
            break;
          }
        }
      }

      // 3. Calculate Delta
      int minVisible = 999999;
      int maxVisible = -1;
      bool foundAnyInSurah = false;

      for (final entry in _ayahKeys.entries) {
        final parts = entry.key.split('_');
        if (parts.length != 2) continue;
        final sNum = int.tryParse(parts[0]);
        final aNum = int.tryParse(parts[1]);
        if (sNum == lastRead.surahNumber &&
            entry.value.currentContext != null) {
          if (aNum != null) {
            if (aNum < minVisible) minVisible = aNum;
            if (aNum > maxVisible) maxVisible = aNum;
            foundAnyInSurah = true;
          }
        }
      }

      if (foundAnyInSurah) {
        int diff = 0;
        double estimatedHeight = 300.0;
        if (lastRead.ayahNumber < minVisible) {
          diff = lastRead.ayahNumber - minVisible;
        } else {
          diff = lastRead.ayahNumber - maxVisible;
        }
        scrollDelta = diff * estimatedHeight;
      } else {
        // More aggressive jump for faster navigation
        final surahDiff = (lastRead.surahNumber - _currentVisibleSurah).abs();
        if (surahDiff > 5) {
          scrollDelta = isTargetBefore ? -8000.0 : 8000.0;
        } else if (surahDiff > 0) {
          scrollDelta = isTargetBefore ? -4000.0 : 4000.0;
        } else {
          scrollDelta = isTargetBefore ? -1500.0 : 1500.0;
        }
        if (attempt % 5 == 0) {
          debugPrint(
            '🔖 Smart Direction: ${isTargetBefore ? "UP" : "DOWN"}, Delta: $scrollDelta',
          );
        }
      }

      if (scrollDelta != 0 && _scrollController.hasClients) {
        final currentPos = _scrollController.offset;
        final targetPos = (currentPos + scrollDelta).clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );

        if ((targetPos - currentPos).abs() > 10) {
          _scrollController.jumpTo(targetPos);

          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              setState(() {});
              _attemptJumpToAyahInstant(lastRead, attempt + 1);
            }
          });
          return;
        }
      }

      // Fallback Retry
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {});
          _attemptJumpToAyahInstant(lastRead, attempt + 1);
        }
      });
    }
  }

  void _showSurahPicker() {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    final surahsAsync = ref.read(surahsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: _isNightMode
          ? const Color(0xFF1C2128)
          : const Color(0xFFFDFBF7),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _ModernPickerSheet(
          title: l10n.index,
          backgroundColor: _backgroundColor,
          textColor: _textColor,
          secondaryTextColor: _secondaryTextColor,
          goldColor: _goldColor,
          onJuzHizbSelected: (position) {
            Navigator.pop(context); // Close sheet
            _goToLastRead(position);
          },
          items: surahsAsync.when(
            data: (surahs) => surahs.map((surah) {
              // Use the name directly from API without modification
              final displayName = currentLocale.languageCode == 'ar'
                  ? (surah.name ??
                        QuranUtils.getSurahName(
                          surah.number!,
                          isEnglish: false,
                        ))
                  : (surah.englishName ??
                        QuranUtils.getSurahName(
                          surah.number!,
                          isEnglish: true,
                        ));
              final subtitle = currentLocale.languageCode == 'ar'
                  ? 'رقم السورة: ${surah.number}'
                  : 'Surah No. ${surah.number}';

              return _PickerItem(
                id: surah.number!,
                title: displayName,
                subtitle: subtitle,
              );
            }).toList(),
            loading: () => List.generate(114, (index) {
              final surahNumber = index + 1;
              final isEnglish = currentLocale.languageCode == 'en';
              final surahName = QuranUtils.getSurahName(
                surahNumber,
                isEnglish: isEnglish,
              );
              // Don't add prefix, use name as is
              final displayName = surahName;
              final subtitle = isEnglish
                  ? 'Surah No. $surahNumber'
                  : 'رقم السورة: $surahNumber';

              return _PickerItem(
                id: surahNumber,
                title: displayName,
                subtitle: subtitle,
              );
            }),
            error: (_, __) => List.generate(114, (index) {
              final surahNumber = index + 1;
              final isEnglish = currentLocale.languageCode == 'en';
              final surahName = QuranUtils.getSurahName(
                surahNumber,
                isEnglish: isEnglish,
              );
              // Don't add prefix, use name as is
              final displayName = surahName;
              final subtitle = isEnglish
                  ? 'Surah No. $surahNumber'
                  : 'رقم السورة: $surahNumber';

              return _PickerItem(
                id: surahNumber,
                title: displayName,
                subtitle: subtitle,
              );
            }),
          ),
          onSelected: (id) async {
            Navigator.pop(context); // Close sheet first

            if (mounted) {
              setState(() {
                selectedSurahNumber = id;
                _currentVisibleSurah = id;
                // Clear keys to ensure absolute precision for the new list
                _surahKeys.clear();
              });
            }

            // Load data - this now resets the state and loads only ID and ID+1
            await ref
                .read(quranFlowProvider.notifier)
                .loadInitialSurah(id, translation: selectedTranslation);

            // Force rebuild and reset scroll
            if (mounted) {
              setState(() {});
              // Important: jump to 0 immediately as the target surah is now at index 0
              _scrollController.jumpTo(0);

              // Small delay to let layout settle, then sync title/audio
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                setState(() => _currentVisibleSurah = id);
                _syncAudioToCurrentSurah();
              }
            }
          },
        );
      },
    );
  }

  Widget _buildFloatingPlayer() {
    final currentLocale = ref.watch(localeProvider);
    final surahsAsync = ref.watch(surahsProvider);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _isNightMode
            ? const Color(0xFF1C2128).withValues(alpha: 0.95)
            : const Color(0xFFFDFBF7).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _goldColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final audioService = ref.watch(audioPlayerServiceProvider);
          final selectedReciter = ref.watch(selectedReciterProvider);

          return StreamBuilder<PlayerState>(
            stream: audioService?.player.playerStateStream,
            builder: (context, playerSnapshot) {
              final playerState = playerSnapshot.data;
              final playing = playerState?.playing ?? false;
              final processingState = playerState?.processingState;

              return StreamBuilder<MediaItem?>(
                stream: audioService?.mediaItemStream,
                builder: (context, mediaSnapshot) {
                  final activeMedia = mediaSnapshot.data;
                  final isThisSurahPlaying =
                      activeMedia?.extras?['surahNumber'] ==
                          _currentVisibleSurah &&
                      activeMedia?.artist == selectedReciter?.name;

                  return Row(
                    children: [
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (audioService == null || selectedReciter == null) {
                            return;
                          }

                          if (isThisSurahPlaying && playing) {
                            await audioService.pause();
                          } else if (isThisSurahPlaying && !playing) {
                            await audioService.resume();
                          } else {
                            // Start new playback
                            final moshaf =
                                selectedReciter.moshaf?.isNotEmpty == true
                                ? selectedReciter.moshaf!.first
                                : null;
                            if (moshaf?.server == null) {
                              debugPrint('⚠️ No moshaf server available');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'لا يوجد خادم صوت متاح لهذا القارئ',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            final paddedId = _currentVisibleSurah
                                .toString()
                                .padLeft(3, '0');
                            final url = '${moshaf!.server}$paddedId.mp3';
                            debugPrint('🎵 Playing: $url');

                            // Get surah name based on language
                            final isEnglish =
                                currentLocale.languageCode == 'en';
                            final surahName = QuranUtils.getSurahName(
                              _currentVisibleSurah,
                              isEnglish: isEnglish,
                            );
                            final surahTitle = isEnglish
                                ? 'Surah $surahName'
                                : 'سورة $surahName';

                            try {
                              final source = AudioSource.uri(
                                Uri.parse(url),
                                tag: MediaItem(
                                  id: url,
                                  title: surahTitle,
                                  artist: selectedReciter.name,
                                  artUri: Uri.parse(
                                    'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
                                  ),
                                  extras: {'surahNumber': _currentVisibleSurah},
                                ),
                              );

                              await audioService.setPlaylist(sources: [source]);
                            } catch (e) {
                              debugPrint('❌ Error playing audio: $e');
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.errorPlayingAudio(e.toString()),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isNightMode
                                ? _goldColor.withValues(alpha: 0.3)
                                : const Color(0xFFF3E5AB),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child:
                                (isThisSurahPlaying &&
                                    processingState == ProcessingState.loading)
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _goldColor,
                                    ),
                                  )
                                : Icon(
                                    (isThisSurahPlaying && playing)
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: _goldColor,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: surahsAsync.when(
                          data: (surahs) {
                            final surah = surahs.firstWhere(
                              (s) => s.number == _currentVisibleSurah,
                              orElse: () => surahs.first,
                            );
                            final surahName = _getSurahName(
                              _currentVisibleSurah,
                              arabicName: surah.name,
                              englishName: surah.englishName,
                            );
                            final displayName =
                                currentLocale.languageCode == 'ar'
                                ? 'سورة $surahName'
                                : 'Surah $surahName';

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.amiri(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                                Text(
                                  isThisSurahPlaying
                                      ? (currentLocale.languageCode == 'ar'
                                            ? 'جاري الاستماع لـ ${selectedReciter?.name ?? ""}'
                                            : 'Listening to ${selectedReciter?.name ?? ""}')
                                      : (currentLocale.languageCode == 'ar'
                                            ? 'اضغط للبدء بالاستماع'
                                            : 'Tap to start listening'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: _secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                          loading: () {
                            final isEnglish =
                                currentLocale.languageCode == 'en';
                            final surahName = QuranUtils.getSurahName(
                              _currentVisibleSurah,
                              isEnglish: isEnglish,
                            );
                            final displayName = isEnglish
                                ? 'Surah $surahName'
                                : 'سورة $surahName';

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.amiri(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                                Text(
                                  isThisSurahPlaying
                                      ? (currentLocale.languageCode == 'ar'
                                            ? 'جاري الاستماع لـ ${selectedReciter?.name ?? ""}'
                                            : 'Listening to ${selectedReciter?.name ?? ""}')
                                      : (currentLocale.languageCode == 'ar'
                                            ? 'اضغط للبدء بالاستماع'
                                            : 'Tap to start listening'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: _secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                          error: (_, __) {
                            final isEnglish =
                                currentLocale.languageCode == 'en';
                            final surahName = QuranUtils.getSurahName(
                              _currentVisibleSurah,
                              isEnglish: isEnglish,
                            );
                            final displayName = isEnglish
                                ? 'Surah $surahName'
                                : 'سورة $surahName';

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.amiri(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                                Text(
                                  isThisSurahPlaying
                                      ? (currentLocale.languageCode == 'ar'
                                            ? 'جاري الاستماع لـ ${selectedReciter?.name ?? ""}'
                                            : 'Listening to ${selectedReciter?.name ?? ""}')
                                      : (currentLocale.languageCode == 'ar'
                                            ? 'اضغط للبدء بالاستماع'
                                            : 'Tap to start listening'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: _secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (isThisSurahPlaying)
                        IconButton(
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            size: 24,
                            color: _secondaryTextColor,
                          ),
                          onPressed: () => audioService?.stop(),
                        ),
                      const SizedBox(width: 8),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showReciterPicker() {
    final recitersAsync = ref.read(recitersProvider);

    recitersAsync.when(
      data: (reciters) {
        showModalBottomSheet(
          context: context,
          backgroundColor: _isNightMode
              ? const Color(0xFF1C2128)
              : const Color(0xFFFDFBF7),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (context) {
            return _ModernPickerSheet(
              title: 'اختر المقرئ',
              backgroundColor: _backgroundColor,
              textColor: _textColor,
              secondaryTextColor: _secondaryTextColor,
              goldColor: _goldColor,
              items: reciters
                  .asMap()
                  .entries
                  .map(
                    (e) => _PickerItem(
                      id: e.key,
                      title: e.value.name ?? '',
                      subtitle:
                          e.value.moshaf != null && e.value.moshaf!.isNotEmpty
                          ? e.value.moshaf!.first.name ?? ''
                          : '',
                    ),
                  )
                  .toList(),
              onSelected: (index) {
                final reciter = reciters[index];
                ref.read(selectedReciterProvider.notifier).setReciter(reciter);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم اختيار: ${reciter.name}',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'جاري تحميل قائمة المقرئين...',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في تحميل المقرئين',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      },
    );
  }

  void _showFontSizeDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final quranSize = ref.watch(quranFontSizeProvider);
            final transSize = ref.watch(translationFontSizeProvider);

            return Container(
              decoration: BoxDecoration(
                color: _appBarColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.fontSettings,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSizeSlider(
                    label: l10n.mushafFontSize,
                    value: quranSize,
                    min: 20.0,
                    max: 50.0,
                    onChanged: (val) => ref
                        .read(quranFontSizeProvider.notifier)
                        .updateSize(val),
                  ),
                  if (Localizations.localeOf(context).languageCode != 'ar') ...[
                    const SizedBox(height: 16),
                    _buildSizeSlider(
                      label: l10n.translationFontSize,
                      value: transSize,
                      min: 12.0,
                      max: 24.0,
                      onChanged: (val) => ref
                          .read(translationFontSizeProvider.notifier)
                          .updateSize(val),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSizeSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(color: _textColor, fontSize: 14),
            ),
            Text(
              value.toInt().toString(),
              style: GoogleFonts.cairo(
                color: _goldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: _goldColor,
          inactiveColor: _textColor.withValues(alpha: 0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PickerItem {
  final int id;
  final String title;
  final String subtitle;

  _PickerItem({required this.id, required this.title, required this.subtitle});
}

class _ModernPickerSheet extends StatefulWidget {
  final String title;
  final List<_PickerItem> items;
  final Function(int) onSelected;
  final Function(LastReadPosition)? onJuzHizbSelected;
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color goldColor;

  const _ModernPickerSheet({
    required this.title,
    required this.items,
    required this.onSelected,
    this.onJuzHizbSelected,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.goldColor,
  });

  @override
  State<_ModernPickerSheet> createState() => _ModernPickerSheetState();
}

class _ModernPickerSheetState extends State<_ModernPickerSheet> {
  late List<_PickerItem> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void filterSearchResults(String query) {
    if (mounted) {
      setState(() {
        // إزالة الحركات من نص البحث لتسريع البحث
        final normalizedQuery = QuranUtils.removeDiacritics(
          query.toLowerCase(),
        );

        filteredItems = widget.items.where((item) {
          // إزالة الحركات من العنوان والعنوان الفرعي للمقارنة
          final normalizedTitle = QuranUtils.removeDiacritics(
            item.title.toLowerCase(),
          );
          final normalizedSubtitle = QuranUtils.removeDiacritics(
            item.subtitle.toLowerCase(),
          );

          return normalizedTitle.contains(normalizedQuery) ||
              normalizedSubtitle.contains(normalizedQuery) ||
              item.id.toString().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _toArabicDigits(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String res = number.toString();
    for (int i = 0; i < english.length; i++) {
      res = res.replaceAll(english[i], arabic[i]);
    }
    return res;
  }

  Widget _buildJuzHizbList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final hizb1 = juzNumber * 2 - 1;
        final hizb2 = juzNumber * 2;

        final juzStart = QuranUtils.juzMapping[juzNumber]!;
        final hizb2Start = QuranUtils.hizbMapping[hizb2]!;

        final surah1Name = QuranUtils.getSurahName(
          juzStart['surah']!,
          isEnglish: false,
        );
        final surah2Name = QuranUtils.getSurahName(
          hizb2Start['surah']!,
          isEnglish: false,
        );

        return ExpansionTile(
          iconColor: widget.goldColor,
          collapsedIconColor: widget.secondaryTextColor,
          title: Text(
            'الجزء ${_toArabicDigits(juzNumber)}',
            style: GoogleFonts.amiriQuran(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
          subtitle: Text(
            'سورة $surah1Name - آية ${_toArabicDigits(juzStart['ayah']!)}',
            style: GoogleFonts.cairo(
              color: widget.secondaryTextColor,
              fontSize: 13,
            ),
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.goldColor,
            ),
            child: Center(
              child: Text(
                _toArabicDigits(juzNumber),
                style: GoogleFonts.cairo(
                  color: const Color(0xFF2C1810),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(
                'بداية الجزء (الحزب ${_toArabicDigits(hizb1)})',
                style: GoogleFonts.amiriQuran(
                  fontSize: 18,
                  color: widget.textColor,
                ),
              ),
              subtitle: Text(
                'سورة $surah1Name - آية ${_toArabicDigits(juzStart['ayah']!)}',
                style: GoogleFonts.cairo(
                  color: widget.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                if (widget.onJuzHizbSelected != null) {
                  widget.onJuzHizbSelected!(
                    LastReadPosition(
                      surahNumber: juzStart['surah']!,
                      ayahNumber: juzStart['ayah']!,
                    ),
                  );
                }
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(
                'الحزب ${_toArabicDigits(hizb2)}',
                style: GoogleFonts.amiriQuran(
                  fontSize: 18,
                  color: widget.textColor,
                ),
              ),
              subtitle: Text(
                'سورة $surah2Name - آية ${_toArabicDigits(hizb2Start['ayah']!)}',
                style: GoogleFonts.cairo(
                  color: widget.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                if (widget.onJuzHizbSelected != null) {
                  widget.onJuzHizbSelected!(
                    LastReadPosition(
                      surahNumber: hizb2Start['surah']!,
                      ayahNumber: hizb2Start['ayah']!,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasJuzHizb = widget.onJuzHizbSelected != null;

    return DefaultTabController(
      length: hasJuzHizb ? 2 : 1,
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.secondaryTextColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: filterSearchResults,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: widget.textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.title.contains('مقرئ')
                            ? 'بحث سريع عن مقرئ...'
                            : 'بحث سريع عن سورة...',
                        prefixIcon: Icon(Icons.search, color: widget.goldColor),
                        filled: true,
                        fillColor: widget.backgroundColor.withValues(
                          alpha: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.goldColor,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.goldColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.goldColor,
                            width: 2,
                          ),
                        ),
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 14,
                          color: widget.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasJuzHizb)
                TabBar(
                  labelColor: widget.goldColor,
                  unselectedLabelColor: widget.secondaryTextColor,
                  indicatorColor: widget.goldColor,
                  labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'السور'),
                    Tab(text: 'الأجزاء والأحزاب'),
                  ],
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => Divider(
                        color: widget.secondaryTextColor.withValues(alpha: 0.3),
                        indent: 60,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          onTap: () => widget.onSelected(item.id),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.goldColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${item.id}',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF2C1810),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          subtitle: item.subtitle.isNotEmpty
                              ? Text(
                                  item.subtitle,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: widget.secondaryTextColor,
                                  ),
                                  textAlign: TextAlign.right,
                                )
                              : null,
                        );
                      },
                    ),
                    if (hasJuzHizb) _buildJuzHizbList(scrollController),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
