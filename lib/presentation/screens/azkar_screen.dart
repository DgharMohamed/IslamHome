import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/providers/navigation_provider.dart';

class AzkarScreen extends ConsumerStatefulWidget {
  const AzkarScreen({super.key});

  @override
  ConsumerState<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends ConsumerState<AzkarScreen> {
  String? selectedCategory;
  Map<String, int> counts = {}; // Use String key (id or index)

  @override
  Widget build(BuildContext context) {
    final azkarAsync = ref.watch(azkarProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: selectedCategory == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedCategory != null) {
          ref.read(backButtonInterceptorProvider.notifier).set(true);
          setState(() {
            selectedCategory = null;
            counts.clear();
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              pinned: true,
              backgroundColor: AppTheme.backgroundColor,
              leading: selectedCategory != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() {
                        selectedCategory = null;
                        counts.clear();
                      }),
                    )
                  : (context.canPop()
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => context.pop(),
                          )
                        : Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu_rounded, size: 28),
                              onPressed: () =>
                                  GlobalScaffoldService.openDrawer(),
                            ),
                          )),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.3),
                        AppTheme.backgroundColor,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          selectedCategory != null
                              ? _getCategoryLabel(l10n, selectedCategory!)
                              : l10n.azkarDuas,
                          style: GoogleFonts.cairo(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (selectedCategory == null)
                          Text(
                            l10n.dailyMuslimAzkar,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Categories or List
            azkarAsync.when(
              data: (dataMap) {
                if (selectedCategory == null) {
                  final categories = dataMap.keys.toList();

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final categoryKey = categories[index];
                        final categoryLabel = _getCategoryLabel(
                          l10n,
                          categoryKey,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => setState(() {
                              selectedCategory = categoryKey;
                              counts.clear();
                            }),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(categoryKey),
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      categoryLabel,
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: categories.length),
                    ),
                  );
                } else {
                  final list = dataMap[selectedCategory!] ?? [];
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = list[index];
                        final itemId = item.id ?? '$selectedCategory-$index';
                        final targetCount = item.targetCount;
                        final currentCount = counts[itemId] ?? 0;
                        final isDone = currentCount >= targetCount;
                        final isEnglish =
                            Localizations.localeOf(context).languageCode !=
                            'ar';

                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isDone ? 0.5 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                if (!isDone) {
                                  setState(() {
                                    counts[itemId] = currentCount + 1;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDone
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Arabic Zekr (Always display)
                                    Text(
                                      item.zekr,
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.amiri(
                                        fontSize: 22,
                                        height: 1.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // English Translation (Display if not in Arabic mode and available)
                                    if (Localizations.localeOf(
                                              context,
                                            ).languageCode !=
                                            'ar' &&
                                        item.english != null &&
                                        item.english!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        item.english!,
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 16,
                                          height: 1.5,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    if (item.description != null &&
                                        item.description!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        _translateDescription(
                                          item.description!,
                                          isEnglish,
                                        ),
                                        textAlign: isEnglish
                                            ? TextAlign.left
                                            : TextAlign.right,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: Colors.white38,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? Colors.green.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : AppTheme.primaryColor
                                                      .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            isDone
                                                ? l10n.done
                                                : '$currentCount / $targetCount',
                                            style: GoogleFonts.cairo(
                                              color: isDone
                                                  ? Colors.green
                                                  : AppTheme.primaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (item.reference != null &&
                                            item.reference!.isNotEmpty)
                                          Expanded(
                                            child: Text(
                                              _translateReference(
                                                item.reference!,
                                                isEnglish,
                                              ),
                                              textAlign: isEnglish
                                                  ? TextAlign.left
                                                  : TextAlign.right,
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: list.length),
                    ),
                  );
                }
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text(l10n.error(err.toString()))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'morning_azkar':
        return l10n.morningAzkar;
      case 'evening_azkar':
        return l10n.eveningAzkar;
      case 'sleep_azkar':
        return l10n.sleepAzkar;
      case 'wake_up_azkar':
        return l10n.wakeUpAzkar;
      case 'mosque_azkar':
        return l10n.mosqueAzkar;
      case 'adhan_azkar':
        return l10n.adhanAzkar;
      case 'wudu_azkar':
        return l10n.wuduAzkar;
      case 'prophetic_duas':
        return l10n.propheticDuas;
      case 'quran_duas':
        return l10n.quranDuas;
      case 'prophets_duas':
        return l10n.prophetsDuas;
      case 'miscellaneous_azkar':
        return l10n.miscellaneousAzkar;
      default:
        return key;
    }
  }

  IconData _getCategoryIcon(String key) {
    switch (key) {
      case 'morning_azkar':
        return Icons.wb_sunny_rounded;
      case 'evening_azkar':
        return Icons.nights_stay_rounded;
      case 'sleep_azkar':
        return Icons.bedtime_rounded;
      case 'wake_up_azkar':
        return Icons.alarm_rounded;
      case 'mosque_azkar':
        return Icons.mosque_rounded;
      case 'adhan_azkar':
        return Icons.notifications_active_rounded;
      case 'wudu_azkar':
        return Icons.water_drop_rounded;
      case 'prophetic_duas':
        return Icons.favorite_rounded;
      case 'quran_duas':
        return Icons.menu_book_rounded;
      case 'prophets_duas':
        return Icons.star_rounded;
      case 'miscellaneous_azkar':
        return Icons.more_horiz_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  /// Translate Arabic description to English
  String _translateDescription(String arabic, bool isEnglish) {
    if (!isEnglish) return arabic;
    const map = {
      'دعاء الهم والحزن': 'Dua for Anxiety & Sorrow',
      'دعاء العافية': 'Dua for Well-Being',
      'دعاء الهدى والتقى': 'Dua for Guidance & Piety',
      'دعاء الهداية': 'Dua for Guidance',
      'دعاء العلم النافع': 'Dua for Beneficial Knowledge',
      'دعاء إصلاح الدين والدنيا': 'Dua for Rectifying Religion & Life',
      'الاستعاذة من زوال النعمة': 'Seeking refuge from loss of blessings',
      'دعاء جامع': 'Comprehensive Dua',
      'دعاء الدنيا والآخرة': 'Dua for This World & Hereafter',
      'دعاء الثبات': 'Dua for Steadfastness',
      'دعاء المغفرة والنصر': 'Dua for Forgiveness & Victory',
      'دعاء موسى عليه السلام': 'Dua of Prophet Musa (AS)',
      'دعاء العلم': 'Dua for Knowledge',
      'دعاء الذرية الصالحة': 'Dua for Righteous Offspring',
      'دعاء نوح عليه السلام': 'Dua of Prophet Nuh (AS)',
      'دعاء المغفرة للمؤمنين': 'Dua for Forgiveness of Believers',
      'دعاء يونس عليه السلام': 'Dua of Prophet Yunus (AS)',
      'دعاء زكريا عليه السلام': 'Dua of Prophet Zakariyya (AS)',
      'دعاء الصباح': 'Morning Supplication',
      'ذكر الصباح': 'Morning Remembrance',
      'الإقرار بالإسلام': 'Affirmation of Islam',
      'التسبيح': 'Glorification of Allah',
      'التهليل': 'Declaration of Tawhid',
      'الاستعاذة من الشيطان': 'Seeking refuge from Shaytan',
      'الحفظ من كل شيء': 'Protection from all harm',
      'الرضا بالله': 'Contentment with Allah',
      'الاستغاثة بالله': 'Seeking help from Allah',
      'دعاء المساء': 'Evening Supplication',
      'ذكر المساء': 'Evening Remembrance',
      'دعاء النوم': 'Dua before Sleep',
      'دعاء قبل النوم': 'Dua at Bedtime',
      'الاستعاذة من العذاب': 'Seeking refuge from punishment',
      'ذكر عند النوم': 'Remembrance at Sleep',
      'التسبيح قبل النوم': 'Tasbih before Sleep',
      'الحمد قبل النوم': 'Praise before Sleep',
      'التكبير قبل النوم': 'Takbir before Sleep',
      'دعاء الاستيقاظ': 'Dua upon Waking Up',
      'ذكر الاستيقاظ': 'Remembrance upon Waking',
      'الباقيات الصالحات': 'The Righteous Remainders',
      'الاستغفار': 'Seeking Forgiveness',
    };
    return map[arabic] ?? arabic;
  }

  /// Translate Arabic reference to English
  String _translateReference(String arabic, bool isEnglish) {
    if (!isEnglish) return arabic;
    const map = {
      'البخاري': 'Al-Bukhari',
      'مسلم': 'Muslim',
      'الترمذي': 'At-Tirmidhi',
      'أحمد': 'Ahmad',
      'أبو داود': 'Abu Dawud',
      'ابن ماجه': 'Ibn Majah',
      'النسائي': 'An-Nasa\'i',
      'البخاري ومسلم': 'Al-Bukhari & Muslim',
      'أبو داود وابن ماجه': 'Abu Dawud & Ibn Majah',
      'أبو داود والترمذي': 'Abu Dawud & At-Tirmidhi',
      'البقرة: 201': 'Al-Baqarah: 201',
      'آل عمران: 8': 'Aal \'Imran: 8',
      'آل عمران: 147': 'Aal \'Imran: 147',
      'طه: 25-28': 'Ta-Ha: 25-28',
      'طه: 114': 'Ta-Ha: 114',
      'الفرقان: 74': 'Al-Furqan: 74',
      'نوح: 28': 'Nuh: 28',
      'الحشر: 10': 'Al-Hashr: 10',
      'الأنبياء: 87': 'Al-Anbiya: 87',
      'القصص: 24': 'Al-Qasas: 24',
      'آل عمران: 38': 'Aal \'Imran: 38',
      'الأنبياء: 89': 'Al-Anbiya: 89',
      'المؤمنون: 26': 'Al-Mu\'minun: 26',
    };
    return map[arabic] ?? arabic;
  }
}
