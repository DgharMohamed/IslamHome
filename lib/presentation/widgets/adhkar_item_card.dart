import 'package:flutter/material.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class AdhkarItemCard extends StatelessWidget {
  final AdhkarModel item;
  final bool isEnglish;
  final bool showCategory;
  final int? remainingCount;
  final VoidCallback onTap;

  const AdhkarItemCard({
    super.key,
    required this.item,
    required this.isEnglish,
    required this.onTap,
    this.showCategory = false,
    this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final arText = item.textAr.trim();
    final enText = item.textEn.trim();
    final title = _displayTitle(l10n);

    // Calculate progress for the background highlight (if repeat > 0)
    final double progress = remainingCount != null && item.repeat > 0
        ? 1.0 - (remainingCount! / item.repeat)
        : 0.0;
        
    // Fix flex issue if progress is exactly 0 or 1
    final int progressFlex = (progress * 1000).toInt();
    final int remainingFlex = ((1 - progress) * 1000).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Background Progress
          if (remainingCount != null && item.repeat > 0)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    if (progressFlex > 0)
                      Expanded(
                        flex: progressFlex,
                        child: Container(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    if (remainingFlex > 0)
                      Expanded(
                        flex: remainingFlex,
                        child: const SizedBox(),
                      ),
                  ],
                ),
              ),
            ),
            
          GlassContainer(
            borderRadius: 20,
            opacity: 0.04,
            blur: 15,
            borderColor: item.favorite
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            borderWidth: item.favorite ? 1.5 : 1.0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                highlightColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                splashColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row: Title & Action/Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (item.favorite) ...[
                                  const Icon(
                                    Icons.favorite_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: isEnglish ? 'Montserrat' : 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Counter Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.repeat_rounded,
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  remainingCount == null
                                      ? '${item.repeat}'
                                      : '${remainingCount!}/${item.repeat}',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Text Content
                      if (isEnglish && enText.isNotEmpty) ...[
                        // English Primary
                        Text(
                          enText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17,
                            height: 1.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Arabic Secondary
                        Text(
                          arText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            height: 1.7,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        // Arabic Primary
                        Text(
                          arText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            height: 1.8,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      
                      // Category Tag (if enabled)
                      if (showCategory) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _localizedCategory(item.category, l10n),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayTitle(AppLocalizations l10n) {
    final raw = item.title.trim();
    final hasArabic = _hasArabic(raw);
    final hasLatin = _hasLatin(raw);

    if (raw.isNotEmpty) {
      if (isEnglish && !hasArabic) return raw;
      if (!isEnglish && !hasLatin) return raw;
    }

    final localizedCategory = _localizedCategory(item.category, l10n);
    return '$localizedCategory #${item.id}';
  }

  String _localizedCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Morning':
        return l10n.adhkarCategoryMorning;
      case 'Evening':
        return l10n.adhkarCategoryEvening;
      case 'Sleep':
        return l10n.adhkarCategorySleep;
      case 'Prayer':
        return l10n.adhkarCategoryPrayer;
      case 'After Prayer':
        return l10n.adhkarCategoryAfterPrayer;
      case 'Mosque':
        return l10n.adhkarCategoryMosque;
      case 'Food':
        return l10n.adhkarCategoryFood;
      case 'Travel':
        return l10n.adhkarCategoryTravel;
      case 'Home':
        return l10n.adhkarCategoryHome;
      case 'General':
        return l10n.adhkarCategoryGeneral;
      case 'Tasbeeh':
        return l10n.adhkarCategoryTasbeeh;
      case 'Quran Dua':
        return l10n.adhkarCategoryQuranDua;
      default:
        return category;
    }
  }

  bool _hasArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  bool _hasLatin(String text) => RegExp(r'[A-Za-z]').hasMatch(text);
}
