import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/core/utils/last_read_messages.dart';
import 'package:islam_home/presentation/providers/quran_settings_provider.dart';

class AyahDetailsSheet extends ConsumerStatefulWidget {
  final Ayah ayah;
  final Ayah? translation;
  final int surahNumber;
  final Map<String, String> translationOptions;
  final String selectedTranslation;
  final Map<String, String> tafsirOptions;
  final dynamic apiService;

  const AyahDetailsSheet({
    super.key,
    required this.ayah,
    required this.translation,
    required this.surahNumber,
    required this.translationOptions,
    required this.selectedTranslation,
    required this.tafsirOptions,
    required this.apiService,
  });

  @override
  ConsumerState<AyahDetailsSheet> createState() => _AyahDetailsSheetState();
}

class _AyahDetailsSheetState extends ConsumerState<AyahDetailsSheet> {
  bool showTranslation = false; // false = tafsir (default), true = translation

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final currentLocale = ref.watch(localeProvider);
                              final isEnglish =
                                  currentLocale.languageCode == 'en';
                              final surahName =
                                  widget.ayah.surah?.name
                                      ?.replaceAll('سورة', '')
                                      .trim() ??
                                  QuranUtils.getSurahName(
                                    widget.surahNumber,
                                    isEnglish: isEnglish,
                                  );
                              final displayName = isEnglish
                                  ? 'Surah $surahName'
                                  : 'سورة $surahName';

                              return Text(
                                displayName,
                                style: GoogleFonts.amiri(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.verseN(widget.ayah.numberInSurah!),
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.bookmark_add_rounded,
                            size: 22,
                          ),
                          color: AppTheme.primaryColor,
                          onPressed: () async {
                            final lastReadService = ref.read(
                              lastReadServiceProvider,
                            );

                            try {
                              // استخدام الدالة الجديدة
                              final result = await lastReadService
                                  .saveLastReadWithPrevious(
                                    surahNumber: widget.surahNumber,
                                    ayahNumber: widget.ayah.numberInSurah!,
                                  );

                              if (context.mounted) {
                                Navigator.pop(context);

                                // تحديث واجهة المستخدم
                                ref
                                    .read(lastReadUpdateProvider.notifier)
                                    .increment();

                                // تحديد الرسالة المناسبة
                                final message =
                                    LastReadMessages.getSuccessMessage(
                                      result,
                                      ref,
                                      context,
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      message,
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: AppTheme.primaryColor,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              // التعامل مع الأخطاء
                              if (context.mounted) {
                                final errorMessage =
                                    LastReadMessages.getErrorMessage(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      errorMessage,
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          tooltip: 'حفظ كآخر قراءة',
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => showTranslation = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: showTranslation
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: 18,
                                  color: showTranslation
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الترجمة',
                                  style: GoogleFonts.cairo(
                                    color: showTranslation
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => showTranslation = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !showTranslation
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 18,
                                  color: !showTranslation
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'التفسير',
                                  style: GoogleFonts.cairo(
                                    color: !showTranslation
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Content
                if (showTranslation)
                  _buildTranslationSection()
                else
                  _buildAllTafsirsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslationSection() {
    if (widget.translation == null) {
      return Text(
        'لا توجد ترجمة متاحة',
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontSize: 14, color: Colors.white54),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.language_rounded,
              color: AppTheme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.translationOptions[widget.selectedTranslation]}:',
              style: GoogleFonts.cairo(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.translation!.text ?? '',
          style: GoogleFonts.archivoBlack(
            fontSize:
                ref.watch(translationFontSizeProvider) +
                1, // Slightly larger in sheet
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAllTafsirsSection() {
    // Filter tafsirs based on current language
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    final filteredTafsirs = widget.tafsirOptions.entries.where((entry) {
      if (isArabic) {
        // Show only Arabic tafsirs (keys starting with 'ar.')
        return entry.key.startsWith('ar.');
      } else {
        // Show only English tafsirs (keys starting with 'en.')
        return entry.key.startsWith('en.');
      }
    }).toList();

    return Column(
      children: filteredTafsirs.map((entry) {
        return _buildSingleTafsir(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildSingleTafsir(String edition, String name) {
    return FutureBuilder<String?>(
      future: widget.apiService.getAyahTafsir(
        widget.surahNumber,
        widget.ayah.numberInSurah!,
        edition: edition,
      ),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.cairo(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (snapshot.hasError)
                Text(
                  'حدث خطأ في تحميل التفسير',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.red.withValues(alpha: 0.8),
                  ),
                )
              else
                Text(
                  snapshot.data?.isNotEmpty == true
                      ? snapshot.data!
                      : l10n.noTafsirAvailable,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize:
                        ref.watch(quranFontSizeProvider) *
                        0.55, // Responsive tafsir size
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
