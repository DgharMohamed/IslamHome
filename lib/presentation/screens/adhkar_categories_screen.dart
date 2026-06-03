import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/widgets/adhkar_category_card.dart';
import 'package:islam_home/core/utils/responsive_utils.dart';

import 'package:islam_home/presentation/widgets/app_search_field.dart';
import 'package:google_fonts/google_fonts.dart';

class AdhkarCategoriesScreen extends ConsumerStatefulWidget {
  const AdhkarCategoriesScreen({super.key});

  @override
  ConsumerState<AdhkarCategoriesScreen> createState() => _AdhkarCategoriesScreenState();
}

class _AdhkarCategoriesScreenState extends ConsumerState<AdhkarCategoriesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(adhkarCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 180,
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.15),
                      AppTheme.backgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            l10n.adhkarTitle,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: l10n.adhkarFavoritesTooltip,
                            onPressed: () => context.push('/azkar/favorites'),
                            icon: const Icon(Icons.favorite_rounded, color: Colors.white),
                          ),
                          IconButton(
                            tooltip: l10n.adhkarSearchTooltip,
                            onPressed: () => context.push('/azkar/search'),
                            icon: const Icon(Icons.manage_search_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AppSearchField(
                        hintText: l10n.searchForCategory,
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                        onClear: () => setState(() => _searchQuery = ''),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          categoriesAsync.when(
            data: (categories) {
              final filteredCategories = categories.where((cat) {
                final localized = _localizedCategory(cat, l10n).toLowerCase();
                return localized.contains(_searchQuery) || cat.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredCategories.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noResultsFound,
                          style: GoogleFonts.cairo(fontSize: 16, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.getCrossAxisCount(
                      context,
                      mobile: 2,
                      tablet: 3,
                      desktop: 4,
                    ),
                    childAspectRatio: 0.88,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = filteredCategories[index];
                      final countAsync = ref.watch(adhkarCategoryCountProvider(category));
                      final count = countAsync.maybeWhen(data: (c) => c, orElse: () => 0);
                      final style = _categoryStyle(category);

                      return AdhkarCategoryCard(
                        title: _localizedCategory(category, l10n),
                        count: count,
                        icon: style.icon,
                        accentColor: style.color,
                        onTap: () {
                          context.push('/azkar/list/${Uri.encodeComponent(category)}');
                        },
                      );
                    },
                    childCount: filteredCategories.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(error.toString(), style: GoogleFonts.montserrat(color: Colors.white70)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedCategory(String category, AppLocalizations l10n) {
    final lower = category.toLowerCase();
    
    // Check for both Arabic and English variants
    if (lower.contains('صباح') || lower == 'morning') return l10n.adhkarCategoryMorning;
    if (lower.contains('مساء') || lower == 'evening') return l10n.adhkarCategoryEvening;
    if (lower.contains('نوم') || lower.contains('فراش') || lower == 'sleep') return l10n.adhkarCategorySleep;
    if (lower.contains('استيقاظ') || lower == 'waking up') return l10n.adhkarCategoryWakingUp;
    if (lower.contains('بعد الصلاة') || lower == 'after prayer') return l10n.adhkarCategoryAfterPrayer;
    if (lower.contains('صلاة') || lower == 'prayer') return l10n.adhkarCategoryPrayer;
    if (lower.contains('مسجد') || lower == 'mosque') return l10n.adhkarCategoryMosque;
    if (lower.contains('وضوء') || lower == 'wudu') return l10n.adhkarCategoryWudu;
    if (lower.contains('أذان') || lower.contains('آذان') || lower == 'adhan') return l10n.adhkarCategoryAdhan;
    if (lower.contains('طعام') || lower.contains('شراب') || lower.contains('أكل') || lower == 'food') return l10n.adhkarCategoryFood;
    if (lower.contains('سفر') || lower == 'travel') return l10n.adhkarCategoryTravel;
    if (lower.contains('منزل') || lower.contains('بيت') || lower == 'home') return l10n.adhkarCategoryHome;
    if (lower.contains('كرب') || lower.contains('هم') || lower.contains('حزن') || lower == 'distress') return l10n.adhkarCategoryDistress;
    if (lower.contains('استغفار') || lower.contains('توبة') || lower == 'istighfar') return l10n.adhkarCategoryIstighfar;
    if (lower.contains('رقية') || lower == 'ruqyah') return l10n.adhkarCategoryRuqyah;
    if (lower.contains('حج') || lower.contains('عمرة') || lower == 'hajj') return l10n.adhkarCategoryHajj;
    if (lower.contains('مرض') || lower.contains('مريض') || lower == 'illness') return l10n.adhkarCategoryIllness;
    if (lower.contains('عام') || lower == 'general') return l10n.adhkarCategoryGeneral;
    if (lower.contains('تسبيح') || lower == 'tasbeeh') return l10n.adhkarCategoryTasbeeh;
    if (lower.contains('قرآن') || lower.contains('سورة') || lower == 'quran dua') return l10n.adhkarCategoryQuranDua;

    return category;
  }

  _CategoryStyle _categoryStyle(String category) {
    final lower = category.toLowerCase();

    // ── Morning / Sabah ──
    if (lower.contains('صباح')) {
      return const _CategoryStyle(Icons.wb_sunny_rounded, Color(0xFFF9A825));
    }
    // ── Evening / Masaa ──
    if (lower.contains('مساء')) {
      return const _CategoryStyle(Icons.nights_stay_rounded, Color(0xFF7E57C2));
    }
    // ── Sleep / Naum ──
    if (lower.contains('نوم') || lower.contains('فراش')) {
      return const _CategoryStyle(Icons.bedtime_rounded, Color(0xFF5C6BC0));
    }
    // ── Waking up ──
    if (lower.contains('استيقاظ')) {
      return const _CategoryStyle(Icons.alarm_rounded, Color(0xFFFF8A65));
    }
    // ── Adhan ──
    if (lower.contains('أذان') || lower.contains('آذان')) {
      return const _CategoryStyle(Icons.volume_up_rounded, Color(0xFF4DB6AC));
    }
    // ── Salah related ──
    if (lower.contains('صلاة') || lower.contains('سلام من الصلاة')) {
      return const _CategoryStyle(Icons.mosque_rounded, Color(0xFF26A69A));
    }
    // ── Rukoo / Sujood ──
    if (lower.contains('ركوع') || lower.contains('سجود') || lower.contains('تلاوة')) {
      return const _CategoryStyle(Icons.self_improvement_rounded, Color(0xFF66BB6A));
    }
    // ── Tashahhud / Istiftah ──
    if (lower.contains('تشهد') || lower.contains('استفتاح')) {
      return const _CategoryStyle(Icons.menu_book_rounded, Color(0xFF42A5F5));
    }
    // ── Qunut / Witr ──
    if (lower.contains('قنوت') || lower.contains('وتر')) {
      return const _CategoryStyle(Icons.dark_mode_rounded, Color(0xFF8D6E63));
    }
    // ── Jalsah ──
    if (lower.contains('جلسة')) {
      return const _CategoryStyle(Icons.weekend_rounded, Color(0xFFAB47BC));
    }
    // ── Mosque ──
    if (lower.contains('مسجد')) {
      return const _CategoryStyle(Icons.mosque_rounded, Color(0xFF29B6F6));
    }
    // ── Wudu ──
    if (lower.contains('وضوء')) {
      return const _CategoryStyle(Icons.water_drop_rounded, Color(0xFF4FC3F7));
    }
    // ── Bathroom ──
    if (lower.contains('خلاء')) {
      return const _CategoryStyle(Icons.door_front_door_rounded, Color(0xFF78909C));
    }
    // ── Clothing ──
    if (lower.contains('ثوب') || lower.contains('لبس')) {
      return const _CategoryStyle(Icons.checkroom_rounded, Color(0xFFEF5350));
    }
    // ── Istikhara ──
    if (lower.contains('استخارة')) {
      return const _CategoryStyle(Icons.lightbulb_rounded, Color(0xFFFFCA28));
    }
    // ── Distress / Karb ──
    if (lower.contains('كرب') || lower.contains('هم') || lower.contains('حزن')) {
      return const _CategoryStyle(Icons.healing_rounded, Color(0xFFEF9A9A));
    }
    // ── Enemy / Sultaan ──
    if (lower.contains('عدو') || lower.contains('سلطان')) {
      return const _CategoryStyle(Icons.shield_rounded, Color(0xFFFF7043));
    }
    // ── Dreams ──
    if (lower.contains('رؤيا') || lower.contains('حلم')) {
      return const _CategoryStyle(Icons.cloud_rounded, Color(0xFF90CAF9));
    }
    // ── Night restlessness ──
    if (lower.contains('تقلب') || lower.contains('فزع') || lower.contains('وحشة')) {
      return const _CategoryStyle(Icons.nightlight_round, Color(0xFFCE93D8));
    }
    // ── Istighfar / Tawba ──
    if (lower.contains('استغفار') || lower.contains('توبة')) {
      return const _CategoryStyle(Icons.favorite_rounded, Color(0xFFE91E63));
    }
    // ── Ifsha Salam ──
    if (lower.contains('إفشاء') || lower.contains('سلام') && !lower.contains('صلاة')) {
      return const _CategoryStyle(Icons.waving_hand_rounded, Color(0xFF81C784));
    }
    // ── Ruqyah ──
    if (lower.contains('رقية') || lower.contains('رُّقية')) {
      return const _CategoryStyle(Icons.health_and_safety_rounded, Color(0xFF4CAF50));
    }
    // ── Salawat ──
    if (lower.contains('صلاة على النبي')) {
      return const _CategoryStyle(Icons.star_rounded, Color(0xFFFFD54F));
    }
    // ── Food ──
    if (lower.contains('طعام') || lower.contains('شراب') || lower.contains('أكل')) {
      return const _CategoryStyle(Icons.restaurant_rounded, Color(0xFFFF8A65));
    }
    // ── Travel ──
    if (lower.contains('سفر')) {
      return const _CategoryStyle(Icons.flight_takeoff_rounded, Color(0xFF4DD0E1));
    }
    // ── Home ──
    if (lower.contains('منزل') || lower.contains('بيت')) {
      return const _CategoryStyle(Icons.home_rounded, Color(0xFFA1887F));
    }
    // ── Quran Dua ──
    if (lower.contains('قرآن') || lower.contains('سورة')) {
      return const _CategoryStyle(Icons.auto_stories_rounded, Color(0xFF26C6DA));
    }
    // ── Hajj / Umrah ──
    if (lower.contains('حج') || lower.contains('عمرة')) {
      return const _CategoryStyle(Icons.explore_rounded, Color(0xFFFFB74D));
    }
    // ── Illness / Sickness ──
    if (lower.contains('مرض') || lower.contains('مريض') || lower.contains('وجع')) {
      return const _CategoryStyle(Icons.local_hospital_rounded, Color(0xFFE57373));
    }
    // ── Tasbeeh ──
    if (lower.contains('تسبيح')) {
      return const _CategoryStyle(Icons.all_inclusive_rounded, Color(0xFF80DEEA));
    }

    // ── English fallback ──
    switch (category) {
      case 'Morning':
        return const _CategoryStyle(Icons.wb_sunny_rounded, Color(0xFFF9A825));
      case 'Evening':
        return const _CategoryStyle(Icons.nights_stay_rounded, Color(0xFF7E57C2));
      case 'Sleep':
        return const _CategoryStyle(Icons.bedtime_rounded, Color(0xFF5C6BC0));
      case 'Prayer':
      case 'After Prayer':
        return const _CategoryStyle(Icons.mosque_rounded, Color(0xFF26A69A));
      case 'Mosque':
        return const _CategoryStyle(Icons.mosque_rounded, Color(0xFF29B6F6));
      case 'Food':
        return const _CategoryStyle(Icons.restaurant_rounded, Color(0xFFFF8A65));
      case 'Travel':
        return const _CategoryStyle(Icons.flight_takeoff_rounded, Color(0xFF4DD0E1));
      case 'Home':
        return const _CategoryStyle(Icons.home_rounded, Color(0xFFA1887F));
      case 'Tasbeeh':
        return const _CategoryStyle(Icons.all_inclusive_rounded, Color(0xFF80DEEA));
      case 'Quran Dua':
        return const _CategoryStyle(Icons.auto_stories_rounded, Color(0xFF26C6DA));
      case 'General':
        return const _CategoryStyle(Icons.auto_awesome_rounded, AppTheme.primaryColor);
      default:
        return const _CategoryStyle(Icons.auto_awesome_rounded, AppTheme.primaryColor);
    }
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color color;

  const _CategoryStyle(this.icon, this.color);
}
