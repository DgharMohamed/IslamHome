import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/widgets/adhkar_item_card.dart';

class AdhkarFavoriteScreen extends ConsumerWidget {
  const AdhkarFavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final favoritesAsync = ref.watch(adhkarFavoritesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.favoriteAdhkarTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: favoritesAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                l10n.noFavoriteAdhkar,
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
                showCategory: true,
                remainingCount: remaining,
                onTap: () {
                  final category = Uri.encodeComponent(item.category);
                  context.push('/azkar/details/${item.id}?category=$category');
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
      ),
    );
  }
}
