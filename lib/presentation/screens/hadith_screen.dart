import 'package:flutter/material.dart';
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
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islam_home/presentation/providers/favorites_provider.dart';
import 'package:flutter/rendering.dart';

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
          setState(() {
            selectedBookKey = null;
            selectedBookName = null;
            currentPage = 1;
          });
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: selectedBookKey != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() {
                      selectedBookKey = null;
                      selectedBookName = null;
                      currentPage = 1;
                    }),
                  )
                : (context.canPop()
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.4),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _IslamicPatternPainter(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            displayBookName ?? l10n.hadithBooks,
                            style: GoogleFonts.cairo(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedBookKey != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_library_rounded,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.7,
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.hadith,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          booksAsync.when(
            data: (books) {
              if (selectedBookKey == null) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final book = books[index];
                      final bookName = isEnglish
                          ? (book.name ?? book.nameAr ?? '')
                          : (book.nameAr ?? book.name ?? '');

                      return InkWell(
                        onTap: () => setState(() {
                          selectedBookKey = book.id;
                          selectedBookName = bookName;
                          currentPage = 1;
                        }),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getBookIcon(book.id ?? ''),
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  bookName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${book.totalHadiths} ${l10n.hadith}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: books.length),
                  ),
                );
              }

              final hadithsAsync = ref.watch(hadithsProvider(selectedBookKey!));

              return hadithsAsync.when(
                data: (hadiths) {
                  final totalHadiths = hadiths.length;
                  final maxDisplayed = currentPage * pageSize;
                  final itemCount = maxDisplayed < totalHadiths
                      ? maxDisplayed
                      : totalHadiths;

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            // Trigger pagination when reaching the end of the currently displayed list
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

                            final hadith = hadiths[index];
                            return HadithCard(
                              key: ValueKey('hadith_${hadith.id ?? index}'),
                              hadith: hadith,
                            );
                          }, childCount: itemCount),
                        ),
                      ),
                      // Add a loading indicator at the bottom if more items are being loaded
                      if (itemCount < totalHadiths)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
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
        return Icons.menu_book_rounded;
    }
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
  bool _isExpanded = false;

  void _toggleTranslation() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _shareHadith() async {
    try {
      // Yield to the event loop to ensure any pending paints are flushed
      await Future.delayed(const Duration(milliseconds: 50));

      var boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // If it still needs paint, wait a bit longer
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 50));
        boundary =
            _repaintKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/hadith_${widget.hadith.id}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      final isEnglish = Localizations.localeOf(context).languageCode == 'en';
      final shareText = isEnglish
          ? 'Check out this Hadith from the Islamic Library App: ${widget.hadith.english}'
          : 'اقرأ هذا الحديث من تطبيق المكتبة الإسلامية: ${widget.hadith.arab}';

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: shareText),
      );
    } catch (e) {
      debugPrint('Error sharing hadith: $e');
    }
  }

  String _getBookName(BuildContext context, String slug) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    switch (slug.toLowerCase()) {
      case 'bukhari':
        return isEnglish ? 'Sahih al-Bukhari' : 'صحيح البخاري';
      case 'muslim':
        return isEnglish ? 'Sahih Muslim' : 'صحيح مسلم';
      case 'abudawud':
        return isEnglish ? 'Sunan Abu Dawud' : 'سنن أبي داود';
      case 'tirmidhi':
        return isEnglish ? 'Jami\' at-Tirmidhi' : 'جامع الترمذي';
      case 'nasai':
        return isEnglish ? 'Sunan an-Nasa\'i' : 'سنن النسائي';
      case 'ibnmajah':
        return isEnglish ? 'Sunan Ibn Majah' : 'سنن ابن ماجه';
      case 'malik':
        return isEnglish ? 'Muwatta Malik' : 'موطأ مالك';
      case 'nawawi':
        return isEnglish ? 'Forty Hadith Nawawi' : 'الأربعون النووية';
      case 'qudsi':
        return isEnglish ? 'Hadith Qudsi' : 'الأحاديث القدسية';
      default:
        // Capitalize slug if unknown
        if (slug.isEmpty) return '';
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }

  Color _getGradeColor(String grade) {
    final lowerGrade = grade.toLowerCase();
    if (lowerGrade.contains('sahih') || lowerGrade.contains('صحيح')) {
      return Colors.greenAccent;
    } else if (lowerGrade.contains('hasan') || lowerGrade.contains('حسن')) {
      return Colors.orangeAccent;
    } else if (lowerGrade.contains('da\'if') ||
        lowerGrade.contains('daif') ||
        lowerGrade.contains('ضعيف')) {
      return Colors.redAccent;
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
    final locale = ref.watch(localeProvider);
    final isEnglish = locale.languageCode == 'en';

    final hasEnglish =
        widget.hadith.english != null && widget.hadith.english!.isNotEmpty;
    final hasArabic =
        widget.hadith.arab != null && widget.hadith.arab!.isNotEmpty;

    // Determine primary and secondary texts to prevent overlap/redundancy
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

    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hadith Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getBookName(
                            context,
                            widget.hadith.bookSlug ?? widget.hadith.book ?? '',
                          ),
                          style: GoogleFonts.cairo(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 12,
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${widget.hadith.number ?? widget.hadith.id}',
                          style: GoogleFonts.cairo(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: isFav ? Colors.red : Colors.white38,
                      size: 20,
                    ),
                    onPressed: () => ref
                        .read(favoritesProvider.notifier)
                        .toggleFavoriteHadith(widget.hadith),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: _shareHadith,
                  ),
                  if (widget.hadith.grade != null &&
                      widget.hadith.grade!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(
                          widget.hadith.grade!,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getGradeColor(
                            widget.hadith.grade!,
                          ).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        widget.hadith.grade!,
                        style: GoogleFonts.cairo(
                          color: _getGradeColor(widget.hadith.grade!),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Hadith Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasTranslationToToggle ? _toggleTranslation : null,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Primary Language Text
                      if (primaryText != null)
                        Text(
                          primaryText,
                          textAlign: isPrimaryArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: isPrimaryArabic
                              ? GoogleFonts.amiri(
                                  fontSize: 22,
                                  height: 1.8,
                                  color: Colors.white,
                                )
                              : GoogleFonts.tajawal(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.white,
                                ),
                        ),

                      // Translation Text (Shown if expanded and available)
                      if (hasTranslationToToggle)
                        AnimatedCrossFade(
                          firstChild: const SizedBox(width: double.infinity),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Colors.white10),
                              ),
                              Text(
                                secondaryText,
                                textAlign: isSecondaryArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: isSecondaryArabic
                                    ? GoogleFonts.amiri(
                                        fontSize: 22,
                                        height: 1.8,
                                        color: Colors.white70,
                                      )
                                    : GoogleFonts.tajawal(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: Colors.white70,
                                      ),
                              ),
                            ],
                          ),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 20, paint);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 28, height: 28),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
