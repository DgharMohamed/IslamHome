import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/widgets/adhkar_category_card.dart';

class AdhkarCategoriesScreen extends ConsumerWidget {
  const AdhkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(adhkarCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.adhkarTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w700,
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
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Text(
                l10n.noAdhkarDataFound,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final countAsync = ref.watch(
                adhkarCategoryCountProvider(category),
              );
              final count = countAsync.maybeWhen(
                data: (c) => c,
                orElse: () => 0,
              );

              return AdhkarCategoryCard(
                title: _localizedCategory(category, l10n),
                count: count,
                icon: _categoryIcon(category),
                onTap: () {
                  context.push('/azkar/list/${Uri.encodeComponent(category)}');
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Evening':
        return Icons.nights_stay_rounded;
      case 'Sleep':
        return Icons.bedtime_rounded;
      case 'Prayer':
      case 'After Prayer':
        return Icons.mosque_rounded;
      case 'Mosque':
        return Icons.location_city_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.flight_takeoff_rounded;
      case 'Home':
        return Icons.home_rounded;
      case 'Tasbeeh':
        return Icons.touch_app_rounded;
      case 'Quran Dua':
        return Icons.menu_book_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
