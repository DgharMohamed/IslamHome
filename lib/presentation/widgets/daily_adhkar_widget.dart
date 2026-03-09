import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/daily_content_rotation_provider.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class DailyAdhkarWidget extends ConsumerWidget {
  const DailyAdhkarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dailyAdhkar = ref.watch(rotatingDailyAdhkarProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return dailyAdhkar.when(
      data: (dhikr) {
        if (dhikr == null) return const SizedBox.shrink();

        return GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.adhkarOfTheDay,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                isArabic ? dhikr.textAr : dhikr.textEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: isArabic ? 'Cairo' : 'Montserrat',
                  fontSize: isArabic ? 22 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dhikr.category,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
