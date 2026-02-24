import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/khatma_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/widgets/mushaf_text_page.dart';
import 'package:islam_home/data/services/quran_cdn_service.dart';

class MushafScreen extends ConsumerStatefulWidget {
  final int? initialPage;
  final int? initialAyah;
  final int? initialSurah;

  const MushafScreen({
    super.key,
    this.initialPage,
    this.initialAyah,
    this.initialSurah,
  });

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late PageController _pageController;
  int currentPage = 1;
  Axis _scrollDirection = Axis.horizontal;
  bool _isTextMode = false;
  int? _lastReadAyah;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage ?? 1;
    final box = Hive.box('settings');
    if (widget.initialPage == null) {
      currentPage = box.get('last_mushaf_page', defaultValue: 1);
    }
    _isTextMode = box.get('is_mushaf_text_mode', defaultValue: false);
    _scrollDirection =
        Axis.values[box.get(
          'mushaf_scroll_direction',
          defaultValue: Axis.horizontal.index,
        )];

    // Load last read ayah for highlighting
    final lastAyah = box.get('last_read_ayah_number');
    final lastPage = box.get('last_read_page_number');
    if (widget.initialAyah != null) {
      _lastReadAyah = widget.initialAyah;
    } else if (lastPage == currentPage) {
      _lastReadAyah = lastAyah;
    }

    _pageController = PageController(initialPage: currentPage - 1);

    // Initial preload
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAdjacentPages(currentPage);
    });
  }

  void _preloadAdjacentPages(int page) {
    // Note: QuranCdnService doesn't have a preload local cache method yet,
    // but CachedNetworkImage handles it via the URL.
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  onPressed: () => GlobalScaffoldService.openDrawer(),
                ),
              ),
        title: Text(
          l10n.mushaf,
          style: GoogleFonts.amiriQuran(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor, // Emerald Green
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryColor),
            onPressed: () => context.push('/quran-search?from=mushaf'),
          ),
          IconButton(
            icon: Icon(
              currentPage == Hive.box('settings').get('last_mushaf_page')
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              final box = Hive.box('settings');
              box.put('last_mushaf_page', currentPage);
              setState(() {}); // Refresh icon state

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.pageSavedAsBookmark(currentPage),
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _scrollDirection == Axis.horizontal
                  ? Icons.swap_horiz_rounded
                  : Icons.swap_vert_rounded,
              color: AppTheme.primaryColor,
            ),
            tooltip: _scrollDirection == Axis.horizontal
                ? 'Switch to Vertical Scroll'
                : 'Switch to Horizontal Paging',
            onPressed: () {
              setState(() {
                _scrollDirection = _scrollDirection == Axis.horizontal
                    ? Axis.vertical
                    : Axis.horizontal;
                Hive.box(
                  'settings',
                ).put('mushaf_scroll_direction', _scrollDirection.index);
              });
            },
          ),
          IconButton(
            icon: Tooltip(
              message: _isTextMode ? l10n.mushaf : l10n.readingModeText,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isTextMode
                      ? Icons.auto_stories_rounded
                      : Icons.text_fields_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),
            onPressed: () {
              setState(() {
                _isTextMode = !_isTextMode;
                Hive.box('settings').put('is_mushaf_text_mode', _isTextMode);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Page indicator
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              l10n.pageXOf604(currentPage),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          // Page View Area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: _scrollDirection,
              itemCount: 604,
              onPageChanged: (index) {
                final newPage = index + 1;
                final box = Hive.box('settings');
                setState(() {
                  currentPage = newPage;
                  // Only show highlighting if we just loaded this page from a bookmark,
                  // but for simplicity, we treat it as "highlights sticky to page"
                  final lastPage = box.get('last_read_page_number');
                  if (lastPage == newPage) {
                    _lastReadAyah = box.get('last_read_ayah_number');
                  } else {
                    _lastReadAyah = null;
                  }
                });
                box.put('last_mushaf_page', newPage);
                ref.read(khatmaProvider.notifier).updateProgress(newPage);
                _preloadAdjacentPages(newPage);
              },
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                if (_isTextMode) {
                  return MushafTextPage(
                    pageNumber: pageNum,
                    highlightedAyah: _lastReadAyah,
                  );
                }
                return _buildMushafPage(pageNum);
              },
            ),
          ),
          // Navigation controls
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: l10n.previous,
                  onPressed: currentPage > 1
                      ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                ),
                _buildNavButton(
                  icon: Icons.grid_view_rounded,
                  label: l10n.index,
                  onPressed: () => _showPagePicker(),
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  label: l10n.next,
                  onPressed: currentPage < 604
                      ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafPage(int pageNumber) {
    final cdnService = ref.watch(quranCdnServiceProvider);
    final imageUrl = cdnService.getPageImageUrl(pageNumber);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3E0),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          panEnabled: true,
          scaleEnabled: true,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            errorWidget: (context, url, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.errorLoadingPage,
                    style: GoogleFonts.cairo(color: Colors.black54),
                  ),
                ],
              ),
            ),
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  // ... _buildSurahHeader and _buildAyahsText remain mostly the same but maybe less Gold ...

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final bool isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFFD4AF37)
              : const Color(0xFF1A1F2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: isEnabled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isEnabled ? const Color(0xFF2C1810) : Colors.white24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled ? const Color(0xFF2C1810) : Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Unused _switchToTextMode removed

  // Surah start pages moved to QuranUtils

  void _showPagePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  TabBar(
                    indicatorColor: AppTheme.primaryColor,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'السور'),
                      Tab(text: 'الأجزاء'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Surahs Tab
                        FutureBuilder<List<dynamic>>(
                          future: ref.read(apiServiceProvider).getSurahs(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Center(
                                child: Text(l10n.errorLoadingSurahs),
                              );
                            }

                            final surahs = snapshot.data!;
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: surahs.length,
                              itemBuilder: (context, index) {
                                final surah = surahs[index];
                                return ListTile(
                                  onTap: () {
                                    final page =
                                        QuranUtils.surahStartPages[surah
                                            .number] ??
                                        1;
                                    _pageController.jumpToPage(page - 1);
                                    Navigator.pop(context);
                                  },
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        surah.number.toString(),
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    surah.name ?? '',
                                    style: GoogleFonts.amiriQuran(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${surah.revelationType == 'Meccan' ? l10n.meccan : l10n.medinan} • ${l10n.ayahsCount(surah.numberOfAyahs ?? 0)}',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Text(
                                    l10n.pageN(
                                      QuranUtils.surahStartPages[surah
                                              .number] ??
                                          0,
                                    ),
                                    style: GoogleFonts.cairo(
                                      color: Colors.white30,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // Juz Tab
                        _buildJuzHizbList(scrollController, l10n),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildJuzHizbList(
    ScrollController scrollController,
    AppLocalizations l10n,
  ) {
    String toArabicDigits(int number) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String res = number.toString();
      for (int i = 0; i < english.length; i++) {
        res = res.replaceAll(english[i], arabic[i]);
      }
      return res;
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final hizb1 = juzNumber * 2 - 1;
        final hizb2 = juzNumber * 2;
        final hizb1Page = QuranUtils.hizbStartPages[hizb1] ?? 1;
        final hizb2Page = QuranUtils.hizbStartPages[hizb2] ?? 1;

        return ExpansionTile(
          iconColor: AppTheme.primaryColor,
          collapsedIconColor: Colors.white54,
          title: Text(
            'الجزء ${toArabicDigits(juzNumber)}',
            style: GoogleFonts.amiriQuran(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            l10n.pageN(hizb1Page),
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: Center(
              child: Text(
                juzNumber.toString(),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(
                'بداية الجزء (الحزب ${toArabicDigits(hizb1)})',
                style: GoogleFonts.amiriQuran(fontSize: 18),
              ),
              trailing: Text(
                l10n.pageN(hizb1Page),
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
              ),
              onTap: () {
                _pageController.jumpToPage(hizb1Page - 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(
                'الحزب ${toArabicDigits(hizb2)}',
                style: GoogleFonts.amiriQuran(fontSize: 18),
              ),
              trailing: Text(
                l10n.pageN(hizb2Page),
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
              ),
              onTap: () {
                _pageController.jumpToPage(hizb2Page - 1);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
