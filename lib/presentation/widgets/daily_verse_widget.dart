import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/daily_content_rotation_provider.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

class DailyVerseWidget extends ConsumerWidget {
  const DailyVerseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    final dailyVerse = ref.watch(rotatingDailyVerseProvider);
    final verse = isArabic ? dailyVerse.text : dailyVerse.translation;
    final surah = dailyVerse.surah;

    return GlassContainer(
      borderRadius: 24,
      blur: 20,
      opacity: 0.1,
      padding: const EdgeInsets.all(24),
      child: Column(
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
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.verseOfTheDay,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            verse,
            textAlign: TextAlign.center,
            style: isArabic
                ? GoogleFonts.amiri(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.6,
                  )
                : GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.5,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            surah,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
