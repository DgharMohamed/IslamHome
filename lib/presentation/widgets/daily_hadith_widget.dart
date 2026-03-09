import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/daily_content_rotation_provider.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

class DailyHadithWidget extends ConsumerWidget {
  const DailyHadithWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final dailyHadith = ref.watch(rotatingDailyHadithProvider);

    return dailyHadith.when(
      data: (hadith) {
        if (hadith == null) return const SizedBox.shrink();
        final content = isArabic
            ? (hadith.arab ?? hadith.english ?? '')
            : (hadith.english ?? hadith.arab ?? '');

        return GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.format_quote_rounded,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.hadithOfTheDay,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: isArabic
                    ? GoogleFonts.amiri(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.7,
                        color: Colors.white.withValues(alpha: 0.95),
                      )
                    : GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hadith.book ?? '',
                    style: GoogleFonts.cairo(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'No. ${hadith.number}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
