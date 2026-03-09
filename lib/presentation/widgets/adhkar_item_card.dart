import 'package:flutter/material.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

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
    final subtitle = isEnglish ? enText : arText;
    final maxLine = isEnglish ? 2 : 3;
    final title = _displayTitle(l10n);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.66),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.favorite
                ? AppTheme.primaryColor.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (item.favorite)
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    remainingCount == null
                        ? '${item.repeat}x'
                        : '${remainingCount!}/${item.repeat}',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle.isEmpty ? arText : subtitle,
              textAlign: isEnglish ? TextAlign.left : TextAlign.right,
              maxLines: maxLine,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: isEnglish ? 'Montserrat' : 'Cairo',
                fontSize: isEnglish ? 15 : 20,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showCategory) ...[
              const SizedBox(height: 10),
              Text(
                item.category,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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
