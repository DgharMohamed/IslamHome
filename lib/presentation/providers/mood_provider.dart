import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoodRecommendation {
  final String titleKey;
  final String descKey;
  final String route;
  final String actionKey;

  MoodRecommendation({
    required this.titleKey,
    required this.descKey,
    required this.route,
    required this.actionKey,
  });
}

final moodRecommendationProvider = Provider.family<MoodRecommendation, String>((
  ref,
  moodId,
) {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

  // We'll use dayOfYear to pick a recommendation
  // This is a simplified approach, in a real app these might come from a localized service
  // but for now we'll define them here with basic localization support via l10n if available.

  final recommendations = {
    'anxious': [
      MoodRecommendation(
        titleKey: 'surahSharh',
        descKey: 'descAnxious',
        route: '/quran-text?surah=94',
        actionKey: 'actionReadSurah',
      ),
      MoodRecommendation(
        titleKey: 'allahIsNear',
        descKey: 'descAnxiousDhikr',
        route: '/azkar',
        actionKey: 'actionGoToAzkar',
      ),
    ],
    'sad': [
      MoodRecommendation(
        titleKey: 'surahYusuf',
        descKey: 'descSad',
        route: '/quran-text?surah=12',
        actionKey: 'actionReadSurah',
      ),
      MoodRecommendation(
        titleKey: 'surahDuha',
        descKey: 'descDuha',
        route: '/quran-text?surah=93',
        actionKey: 'actionReadSurah',
      ),
    ],
    'happy': [
      MoodRecommendation(
        titleKey: 'surahRahman',
        descKey: 'descHappy',
        route: '/quran-text?surah=55',
        actionKey: 'actionReadSurah',
      ),
      MoodRecommendation(
        titleKey: 'rememberAllah',
        descKey: 'descHappyDhikr',
        route: '/tasbeeh',
        actionKey: 'startTasbeeh',
      ),
    ],
    'lost': [
      MoodRecommendation(
        titleKey: 'surahFatiha',
        descKey: 'descLost',
        route: '/quran-text?surah=1',
        actionKey: 'actionReadSurah',
      ),
      MoodRecommendation(
        titleKey: 'allahIsNear',
        descKey: 'descLostDhikr',
        route: '/azkar',
        actionKey: 'actionGoToDua',
      ),
    ],
    'tired': [
      MoodRecommendation(
        titleKey: 'sleepAzkar',
        descKey: 'descTired',
        route: '/azkar',
        actionKey: 'actionGoToAzkar',
      ),
      MoodRecommendation(
        titleKey: 'rewardForTired',
        descKey: 'descTiredDhikr',
        route: '/tasbeeh',
        actionKey: 'startTasbeeh',
      ),
    ],
  };

  final list = recommendations[moodId] ?? recommendations['lost']!;

  // Special handling for 'tired' mood to be time-sensitive
  if (moodId == 'tired') {
    final isNight = now.hour >= 20 || now.hour < 5;
    // Index 0 is Sleep Azkar (Night), Index 1 is Reward/Tasbeeh (Day)
    return isNight ? list[0] : list[1];
  }

  return list[dayOfYear % list.length];
});
