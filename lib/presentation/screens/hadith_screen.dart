import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:islam_home/presentation/providers/navigation_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islam_home/presentation/providers/favorites_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:islam_home/presentation/widgets/hadith_share_card.dart';
import 'package:islam_home/core/utils/responsive_utils.dart';
import 'package:islam_home/core/utils/quran_utils.dart';

import 'package:islam_home/presentation/widgets/app_search_field.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  String? selectedBookKey;
  String? selectedBookName;
  int currentPage = 1;
  static const int pageSize = 50;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBookSelected(String bookId, String bookName) {
    setState(() {
      selectedBookKey = bookId;
      selectedBookName = bookName;
      currentPage = 1;
      searchQuery = '';
      _searchController.clear();
    });
  }

  void _onBackToBooks() {
    setState(() {
      selectedBookKey = null;
      selectedBookName = null;
      currentPage = 1;
      searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(hadithBooksProvider);
    final locale = ref.watch(localeProvider);
    final isEnglish = locale.languageCode == 'en';
    final l10n = AppLocalizations.of(context)!;

    String? displayBookName = selectedBookName;
    if (selectedBookKey != null) {
      final books = booksAsync.value ?? [];
      final book = books.where((b) => b.id == selectedBookKey).firstOrNull;
      if (book != null) {
        displayBookName = isEnglish
            ? (book.name ?? book.nameAr ?? '')
            : (book.nameAr ?? book.name ?? '');
      }
    }

    return PopScope(
      canPop: selectedBookKey == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedBookKey != null) {
          ref.read(backButtonInterceptorProvider.notifier).set(true);
          _onBackToBooks();
        }
      },
      child: CustomScrollView(
        slivers: [
          // Sleek Glassmorphic Hero App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: selectedBookKey != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: _onBackToBooks,
                  )
                : (context.canPop()
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        )
                      : Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded, size: 28),
                            onPressed: () => GlobalScaffoldService.openDrawer(),
                          ),
                        )),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Dynamic Islamic Pattern Background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _IslamicPatternPainter(
                          color: AppTheme.primaryColor.withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                    // Centered Title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 40.0,
                          left: 16,
                          right: 16,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.2),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: Text(
                            displayBookName ?? l10n.hadithBooks,
                            key: ValueKey<String>(
                              displayBookName ?? 'hadithBooks',
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: displayBookName == null ? 36 : 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: AppSearchField(
                hintText: selectedBookKey == null
                    ? l10n.searchHadithBooksHint
                    : l10n.searchInHadithHint,
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    currentPage = 1;
                  });
                },
              ),
            ),
          ),

          if (selectedBookKey != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.hadith,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          booksAsync.when(
            data: (books) {
              if (selectedBookKey == null) {
                // Books Grid View
                final filteredBooks = books.where((book) {
                  final name =
                      (isEnglish
                              ? (book.name ?? book.nameAr ?? '')
                              : (book.nameAr ?? book.name ?? ''))
                          .toLowerCase();
                  return name.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredBooks.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noResultsFound,
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getCrossAxisCount(
                        context,
                        mobile: 2,
                        tablet: 3,
                        desktop: 4,
                      ),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final book = filteredBooks[index];
                      final bookName = isEnglish
                          ? (book.name ?? book.nameAr ?? '')
                          : (book.nameAr ?? book.name ?? '');

                      return HadithBookCard(
                        book: book,
                        bookName: bookName,
                        icon: _getBookIcon(book.id ?? ''),
                        hadithLabel: l10n.hadith,
                        onTap: () => _onBookSelected(book.id!, bookName),
                      );
                    }, childCount: filteredBooks.length),
                  ),
                );
              }

              // Hadith List View
              final hadithsAsync = ref.watch(hadithsProvider(selectedBookKey!));

              return hadithsAsync.when(
                data: (hadiths) {
                  final filteredHadiths = hadiths.where((h) {
                    final query = searchQuery.trim();
                    if (query.isEmpty) return true;

                    final numberStr = (h.number ?? '').toString();
                    if (numberStr.contains(query)) return true;

                    final matchAr = QuranUtils.matchesSearch(
                      h.arab ?? '',
                      query,
                    );
                    final matchEn = QuranUtils.matchesSearch(
                      h.english ?? '',
                      query,
                    );

                    return matchAr || matchEn;
                  }).toList();

                  if (filteredHadiths.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noResultsFound,
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final totalHadiths = filteredHadiths.length;
                  final maxDisplayed = currentPage * pageSize;
                  final itemCount = maxDisplayed < totalHadiths
                      ? maxDisplayed
                      : totalHadiths;

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            // Trigger pagination
                            if (index == itemCount - 1 &&
                                itemCount < totalHadiths) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              });
                            }

                            final hadith = filteredHadiths[index];
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 800,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: HadithCard(
                                    key: ValueKey(
                                      'hadith_${hadith.id ?? index}',
                                    ),
                                    hadith: hadith,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: itemCount),
                        ),
                      ),
                      // Add a loading indicator at the bottom if more items are being loaded
                      if (itemCount < totalHadiths)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => SliverFillRemaining(
                  child: Center(child: Text(e.toString())),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) =>
                SliverToBoxAdapter(child: Center(child: Text(e.toString()))),
          ),
        ],
      ),
    );
  }

  IconData _getBookIcon(String bookKey) {
    switch (bookKey) {
      case 'bukhari':
        return Icons.menu_book_rounded;
      case 'muslim':
        return Icons.auto_stories_rounded;
      case 'abudawud':
        return Icons.import_contacts_rounded;
      case 'tirmidhi':
        return Icons.book_rounded;
      case 'nasai':
        return Icons.library_books_rounded;
      case 'ibnmajah':
        return Icons.chrome_reader_mode_rounded;
      case 'malik':
        return Icons.menu_book_outlined;
      case 'nawawi':
        return Icons.star_rounded;
      default:
        return Icons.library_books_rounded;
    }
  }
}

class HadithBookCard extends StatefulWidget {
  final HadithBook book;
  final String bookName;
  final IconData icon;
  final String hadithLabel;
  final VoidCallback onTap;

  const HadithBookCard({
    super.key,
    required this.book,
    required this.bookName,
    required this.icon,
    required this.hadithLabel,
    required this.onTap,
  });

  @override
  State<HadithBookCard> createState() => _HadithBookCardState();
}

class _HadithBookCardState extends State<HadithBookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCirc,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.primaryColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 10 : 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Gradient Accent
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(
                            alpha: _isHovered ? 0.2 : 0.05,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.icon,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bookName,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.format_list_bulleted_rounded,
                                size: 14,
                                color: Colors.white38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.book.totalHadiths} ${widget.hadithLabel}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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

class HadithCard extends ConsumerStatefulWidget {
  final HadithModel hadith;

  const HadithCard({super.key, required this.hadith});

  @override
  ConsumerState<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends ConsumerState<HadithCard> {
  final GlobalKey _repaintKey = GlobalKey();
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExpanded = false;

  void _toggleTranslation() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _copyToClipboard(String text, bool isEnglish) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnglish ? 'Copied to clipboard' : 'تم النسخ إلى الحافظة',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _shareHadith() async {
    try {
      if (!mounted) return;

      final locale = Localizations.localeOf(context).languageCode;
      final isEnglish = locale == 'en';

      // Promotional text
      final shareText = isEnglish
          ? 'Read this hadith and hundreds of other hadiths through Islam Home app?'
          : 'اقرأ هذا الحديث ومئات الأحاديث الأخرى عبر تطبيق بيت الإسلام ؟';

      // Capture the already mounted Offstage widget
      final pngBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (pngBytes == null) {
        debugPrint('Failed to capture screenshot');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/hadith_${widget.hadith.id}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: shareText),
      );
    } catch (e) {
      debugPrint('Error sharing hadith: $e');
    }
  }

  String _getBookName(BuildContext context, String slug) {
    final l10n = AppLocalizations.of(context)!;
    switch (slug.toLowerCase()) {
      case 'bukhari':
        return l10n.hadithBookBukhari;
      case 'muslim':
        return l10n.hadithBookMuslim;
      case 'abudawud':
        return l10n.hadithBookAbuDawud;
      case 'tirmidhi':
        return l10n.hadithBookTirmidhi;
      case 'nasai':
        return l10n.hadithBookNasai;
      case 'ibnmajah':
        return l10n.hadithBookIbnMajah;
      case 'malik':
        return l10n.hadithBookMalik;
      case 'nawawi':
        return l10n.hadithBookNawawi;
      case 'qudsi':
        return l10n.hadithBookQudsi;
      default:
        if (slug.isEmpty) return '';
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }

  Color _getGradeColor(String grade) {
    final lowerGrade = grade.toLowerCase();
    if (lowerGrade.contains('sahih') || lowerGrade.contains('صحيح')) {
      return const Color(0xFF00E676); // Beautiful Green
    } else if (lowerGrade.contains('hasan') || lowerGrade.contains('حسن')) {
      return const Color(0xFFFFAB00); // Amber
    } else if (lowerGrade.contains('da\'if') ||
        lowerGrade.contains('daif') ||
        lowerGrade.contains('ضعيف')) {
      return const Color(0xFFFF5252); // Red Accent
    }
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final hadithId = widget.hadith.id ?? '';
    final isFav = ref.watch(
      favoritesProvider.select(
        (s) => (s['hadiths'] ?? []).any(
          (item) => item['id'].toString() == hadithId,
        ),
      ),
    );
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final bookNameStr = _getBookName(
      context,
      widget.hadith.bookSlug ?? widget.hadith.book ?? '',
    );

    final hasEnglish =
        widget.hadith.english != null && widget.hadith.english!.isNotEmpty;
    final hasArabic =
        widget.hadith.arab != null && widget.hadith.arab!.isNotEmpty;

    String? primaryText;
    bool isPrimaryArabic = false;

    if (!isEnglish) {
      primaryText = hasArabic ? widget.hadith.arab : widget.hadith.english;
      isPrimaryArabic = hasArabic;
    } else {
      primaryText = hasEnglish ? widget.hadith.english : widget.hadith.arab;
      isPrimaryArabic = !hasEnglish && hasArabic;
    }

    String? secondaryText;
    bool isSecondaryArabic = false;

    if (!isEnglish) {
      if (hasEnglish && primaryText != widget.hadith.english) {
        secondaryText = widget.hadith.english;
        isSecondaryArabic = false;
      }
    } else {
      if (hasArabic && primaryText != widget.hadith.arab) {
        secondaryText = widget.hadith.arab;
        isSecondaryArabic = true;
      }
    }

    final hasTranslationToToggle =
        secondaryText != null && secondaryText.isNotEmpty;

    final textToCopy = isPrimaryArabic
        ? (hasTranslationToToggle
              ? '$primaryText\n\n$secondaryText'
              : primaryText ?? '')
        : (hasTranslationToToggle
              ? '$secondaryText\n\n$primaryText'
              : primaryText ?? '');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -10000,
          top: -10000,
          child: Screenshot(
            controller: _screenshotController,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width:
                    600, // Fixed logical width for consistent high-quality layout
                child: Directionality(
                  textDirection: isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: HadithShareCard(
                    hadith: widget.hadith,
                    bookName: bookNameStr,
                    gradeLabel: widget.hadith.grade ?? '',
                  ),
                ),
              ),
            ),
          ),
        ),
        RepaintBoundary(
          key: _repaintKey,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(28),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stylish Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getBookName(
                              context,
                              widget.hadith.bookSlug ??
                                  widget.hadith.book ??
                                  '',
                            ),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${widget.hadith.number ?? widget.hadith.id}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hadith Content Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Grade Badge (if available)
                        if (widget.hadith.grade != null &&
                            widget.hadith.grade!.isNotEmpty) ...[
                          Align(
                            alignment: isEnglish
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getGradeColor(
                                  widget.hadith.grade!,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getGradeColor(
                                    widget.hadith.grade!,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: _getGradeColor(widget.hadith.grade!),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.hadith.grade!,
                                    style: GoogleFonts.cairo(
                                      color: _getGradeColor(
                                        widget.hadith.grade!,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Primary Text
                        if (primaryText != null)
                          Text(
                            primaryText,
                            textAlign: isPrimaryArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: isPrimaryArabic
                                ? GoogleFonts.amiri(
                                    fontSize: 24,
                                    height: 2.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  )
                                : GoogleFonts.tajawal(
                                    fontSize: 18,
                                    height: 1.8,
                                    color: Colors.white,
                                  ),
                          ),

                        // Secondary (Translated) Text
                        if (hasTranslationToToggle)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isExpanded
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Divider(color: Colors.white10),
                                      ),
                                      Text(
                                        secondaryText,
                                        textAlign: isSecondaryArabic
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        style: isSecondaryArabic
                                            ? GoogleFonts.amiri(
                                                fontSize: 24,
                                                height: 2.0,
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.9),
                                              )
                                            : GoogleFonts.tajawal(
                                                fontSize: 18,
                                                height: 1.8,
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.9),
                                              ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                      ],
                    ),
                  ),

                  // Action Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Actions (Translate & Copy)
                        Row(
                          children: [
                            if (hasTranslationToToggle)
                              TextButton.icon(
                                onPressed: _toggleTranslation,
                                icon: Icon(
                                  Icons.translate_rounded,
                                  color: _isExpanded
                                      ? AppTheme.primaryColor
                                      : Colors.white54,
                                  size: 20,
                                ),
                                label: Text(
                                  _isExpanded
                                      ? (isEnglish ? 'Hide' : 'إخفاء')
                                      : (isEnglish ? 'Translate' : 'ترجمة'),
                                  style: GoogleFonts.cairo(
                                    color: _isExpanded
                                        ? AppTheme.primaryColor
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: _isExpanded
                                      ? AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        )
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  _copyToClipboard(textToCopy, isEnglish),
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              tooltip: isEnglish ? 'Copy' : 'نسخ',
                            ),
                          ],
                        ),
                        // Right Actions (Share & Fav)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.share_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: _shareHadith,
                              tooltip: 'Share as Image',
                            ),
                            IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                color: isFav
                                    ? Colors.redAccent
                                    : Colors.white54,
                                size: 24,
                              ),
                              onPressed: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavoriteHadith(widget.hadith),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 60.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 25, paint);
        // Draw an intricate star pattern
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: 35,
          height: 35,
        );
        canvas.drawRect(rect, paint);
        canvas.drawLine(Offset(x - 25, y), Offset(x + 25, y), paint);
        canvas.drawLine(Offset(x, y - 25), Offset(x, y + 25), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
