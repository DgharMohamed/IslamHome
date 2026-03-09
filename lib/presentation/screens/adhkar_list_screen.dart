import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/widgets/adhkar_item_card.dart';

class AdhkarListScreen extends ConsumerWidget {
  final String category;

  const AdhkarListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final itemsAsync = ref.watch(adhkarByCategoryProvider(category));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isEnglish ? category : _localizedCategory(category, l10n),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.adhkarSearchTooltip,
            onPressed: () => context.push('/azkar/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: l10n.adhkarFavoritesTooltip,
            onPressed: () => context.push('/azkar/favorites'),
            icon: const Icon(Icons.favorite_rounded),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                l10n.noAdhkarInCategory,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final remainingAsync = ref.watch(
                adhkarRemainingProvider((id: item.id, repeat: item.repeat)),
              );
              final remaining = remainingAsync.maybeWhen(
                data: (value) => value,
                orElse: () => item.repeat,
              );

              return AdhkarItemCard(
                item: item,
                isEnglish: isEnglish,
                remainingCount: remaining,
                onTap: () {
                  final encodedCategory = Uri.encodeComponent(category);
                  context.push(
                    '/azkar/details/${item.id}?category=$encodedCategory',
                  );
                },
              );
            },
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

  String _localizedCategory(String value, AppLocalizations l10n) {
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
}
