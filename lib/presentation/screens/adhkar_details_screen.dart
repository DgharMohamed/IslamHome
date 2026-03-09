import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';

class AdhkarDetailsScreen extends ConsumerWidget {
  final int id;
  final String? category;

  const AdhkarDetailsScreen({super.key, required this.id, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final itemAsync = ref.watch(adhkarByIdProvider(id));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.dhikrDetailsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          itemAsync.maybeWhen(
            data: (item) {
              if (item == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: l10n.toggleFavorite,
                icon: Icon(
                  item.favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: item.favorite ? AppTheme.primaryColor : Colors.white,
                ),
                onPressed: () async {
                  await ref.read(adhkarActionsProvider).toggleFavorite(item.id);
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return Center(
              child: Text(
                l10n.dhikrNotFound,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            );
          }

          return _DetailsBody(
            item: item,
            category: category,
            isEnglish: isEnglish,
            l10n: l10n,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error.toString(),
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  final AdhkarModel item;
  final String? category;
  final bool isEnglish;
  final AppLocalizations l10n;

  const _DetailsBody({
    required this.item,
    required this.category,
    required this.isEnglish,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingAsync = ref.watch(
      adhkarRemainingProvider((id: item.id, repeat: item.repeat)),
    );
    final remaining = remainingAsync.maybeWhen(
      data: (value) => value,
      orElse: () => item.repeat,
    );

    final categoryValue = category ?? item.category;
    final categoryItemsAsync = ref.watch(
      adhkarByCategoryProvider(categoryValue),
    );
    final arText = item.textAr.trim();
    final enText = item.textEn.trim();
    final rawTitle = item.title.trim();
    final primaryText = isEnglish
        ? (enText.isNotEmpty ? enText : arText)
        : (arText.isNotEmpty ? arText : enText);
    final isArabicText = !isEnglish || enText.isEmpty;
    final title = _displayTitle(rawTitle, categoryValue);
    final displayReference = _displayReference(item.reference);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  primaryText,
                  textAlign: isArabicText ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontFamily: isArabicText ? 'Cairo' : 'Montserrat',
                    fontSize: isArabicText ? 26 : 18,
                    height: isArabicText ? 1.7 : 1.55,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (displayReference != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    '${l10n.referenceLabel}: $displayReference',
                    style: TextStyle(
                      fontFamily: isEnglish ? 'Montserrat' : 'Cairo',
                      fontSize: 13,
                      color: AppTheme.primaryColor.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.repeatCounter,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          '$remaining / ${item.repeat}',
                          key: ValueKey<String>('$remaining-${item.repeat}'),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final next = await ref
                        .read(adhkarActionsProvider)
                        .decrementRepeat(item.id, fallbackRepeat: item.repeat);
                    if (!context.mounted) return;
                    if (next == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.completedThisDhikr,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.exposure_minus_1_rounded),
                  label: Text(
                    l10n.countLabel,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await ref
                        .read(adhkarActionsProvider)
                        .resetRepeat(item.id, fallbackRepeat: item.repeat);
                  },
                  child: Text(
                    l10n.reset,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          categoryItemsAsync.when(
            data: (items) {
              final index = items.indexWhere((entry) => entry.id == item.id);
              final previousId = index > 0 ? items[index - 1].id : null;
              final nextId = index >= 0 && index < items.length - 1
                  ? items[index + 1].id
                  : null;

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: previousId == null
                          ? null
                          : () {
                              final encoded = Uri.encodeComponent(
                                categoryValue,
                              );
                              context.go(
                                '/azkar/details/$previousId?category=$encoded',
                              );
                            },
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(
                        l10n.previous,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: nextId == null
                          ? null
                          : () {
                              final encoded = Uri.encodeComponent(
                                categoryValue,
                              );
                              context.go(
                                '/azkar/details/$nextId?category=$encoded',
                              );
                            },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        l10n.next,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _displayTitle(String rawTitle, String categoryValue) {
    final hasArabic = _hasArabic(rawTitle);
    final hasLatin = _hasLatin(rawTitle);
    if (rawTitle.isNotEmpty) {
      if (isEnglish && !hasArabic) return rawTitle;
      if (!isEnglish && !hasLatin) return rawTitle;
    }
    return '${_localizedCategory(categoryValue)} #${item.id}';
  }

  String _localizedCategory(String value) {
    switch (value) {
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
        return value;
    }
  }

  String? _displayReference(String rawReference) {
    final reference = rawReference.trim();
    if (reference.isEmpty) return null;
    final hasArabic = _hasArabic(reference);
    final hasLatin = _hasLatin(reference);
    if (isEnglish) {
      return hasLatin || !hasArabic ? reference : null;
    }
    return hasArabic || !hasLatin ? reference : null;
  }

  bool _hasArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  bool _hasLatin(String text) => RegExp(r'[A-Za-z]').hasMatch(text);
}
