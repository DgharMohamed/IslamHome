import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/mood_provider.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class SpiritualMoodsWidget extends ConsumerWidget {
  const SpiritualMoodsWidget({super.key});

  String _getLocalizedValue(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'surahSharh':
        return l10n.surahSharh;
      case 'descAnxious':
        return l10n.descAnxious;
      case 'actionReadSurah':
        return l10n.actionReadSurah;
      case 'allahIsNear':
        return l10n.allahIsNear;
      case 'actionGoToAzkar':
        return l10n.actionGoToAzkar;
      case 'surahYusuf':
        return l10n.surahYusuf;
      case 'descSad':
        return l10n.descSad;
      case 'surahDuha':
        return l10n.surahDuha;
      case 'descDuha':
        return l10n.descDuha;
      case 'surahRahman':
        return l10n.surahRahman;
      case 'descHappy':
        return l10n.descHappy;
      case 'startTasbeeh':
        return l10n.startTasbeeh;
      case 'rememberAllah':
        return l10n.rememberAllah;
      case 'descHappyDhikr':
        return l10n.descHappyDhikr;
      case 'surahFatiha':
        return l10n.surahFatiha;
      case 'descLost':
        return l10n.descLost;
      case 'actionGoToDua':
        return l10n.actionGoToDua;
      case 'descLostDhikr':
        return l10n.descLostDhikr;
      case 'descAnxiousDhikr':
        return l10n.descAnxiousDhikr;
      case 'sleepAzkar':
        return l10n.sleepAzkar;
      case 'descTired':
        return l10n.descTired;
      case 'rewardForTired':
        return l10n.rewardForTired;
      case 'descTiredDhikr':
        return l10n.descTiredDhikr;
      default:
        return key;
    }
  }

  String _buildAlternativeLabel(
    BuildContext context,
    MoodRecommendationSuggestion suggestion,
  ) {
    final action = _getLocalizedValue(context, suggestion.recommendation.actionKey);
    final title = _getLocalizedValue(context, suggestion.recommendation.titleKey);
    return '$action - $title';
  }

  void _showRecommendation(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> mood,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final moodId = mood['id'] as String;
    final suggestions = ref.read(moodRecommendationSuggestionsProvider(moodId));
    if (suggestions.isEmpty) return;

    final primary = suggestions.first;
    final alternative = suggestions.length > 1 ? suggestions[1] : null;
    final hasDistinctAlternative =
        alternative != null &&
        alternative.recommendation.route != primary.recommendation.route;
    final rec = primary.recommendation;
    final moodDisplay = mood['display'] as String;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: 32,
        blur: 40,
        opacity: 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              mood['icon'] as IconData,
              color: mood['color'] as Color,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.becauseYouFeel(moodDisplay),
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getLocalizedValue(context, rec.titleKey),
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                primary.reason,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getLocalizedValue(context, rec.descKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref
                      .read(moodEngineProvider.notifier)
                      .recordActionTap(rec.route);
                  if (!context.mounted) return;
                  context.push(rec.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _getLocalizedValue(context, rec.actionKey),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            if (hasDistinctAlternative) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(moodEngineProvider.notifier)
                        .recordActionTap(alternative.recommendation.route);
                    if (!context.mounted) return;
                    context.push(alternative.recommendation.route);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _buildAlternativeLabel(context, alternative),
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final moods = [
      {
        'id': 'anxious',
        'display': l10n.moodAnxious,
        'icon': Icons.air_rounded,
        'color': Colors.orangeAccent,
      },
      {
        'id': 'sad',
        'display': l10n.moodSad,
        'icon': Icons.cloud_outlined,
        'color': Colors.lightBlueAccent,
      },
      {
        'id': 'happy',
        'display': l10n.moodHappy,
        'icon': Icons.light_mode_outlined,
        'color': Colors.amberAccent,
      },
      {
        'id': 'lost',
        'display': l10n.moodLost,
        'icon': Icons.explore_outlined,
        'color': Colors.purpleAccent,
      },
      {
        'id': 'tired',
        'display': l10n.moodTired,
        'icon': Icons.nightlight_outlined,
        'color': Colors.redAccent,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.howDoYouFeel,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: moods.length,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemBuilder: (context, index) {
                final mood = moods[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () async {
                      await ref
                          .read(moodEngineProvider.notifier)
                          .selectMood(mood['id'] as String);
                      if (!context.mounted) return;
                      _showRecommendation(context, ref, mood);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: (mood['color'] as Color).withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mood['icon'] as IconData,
                            color: mood['color'] as Color,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood['display'] as String,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
