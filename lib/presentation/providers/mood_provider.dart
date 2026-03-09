import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

class MoodRecommendation {
  final String titleKey;
  final String descKey;
  final String route;
  final String actionKey;

  const MoodRecommendation({
    required this.titleKey,
    required this.descKey,
    required this.route,
    required this.actionKey,
  });
}

class MoodRecommendationSuggestion {
  final MoodRecommendation recommendation;
  final String reason;
  final int score;

  const MoodRecommendationSuggestion({
    required this.recommendation,
    required this.reason,
    required this.score,
  });
}

class MoodEngineState {
  final String? lastMoodId;
  final Map<String, int> routeTapCounts;

  const MoodEngineState({this.lastMoodId, this.routeTapCounts = const {}});

  MoodEngineState copyWith({
    String? lastMoodId,
    Map<String, int>? routeTapCounts,
  }) {
    return MoodEngineState(
      lastMoodId: lastMoodId ?? this.lastMoodId,
      routeTapCounts: routeTapCounts ?? this.routeTapCounts,
    );
  }
}

class MoodEngineNotifier extends Notifier<MoodEngineState> {
  static const String _settingsBoxName = 'settings';
  static const String _lastMoodKey = 'mood_last_selected';
  static const String _routeTapCountsKey = 'mood_route_tap_counts';

  @override
  MoodEngineState build() {
    final box = Hive.box(_settingsBoxName);
    final lastMood = box.get(_lastMoodKey) as String?;
    final rawCounts = box.get(_routeTapCountsKey);
    final tapCounts = <String, int>{};
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is int) {
          tapCounts[key] = value;
        }
      }
    }
    return MoodEngineState(lastMoodId: lastMood, routeTapCounts: tapCounts);
  }

  Future<void> selectMood(String moodId) async {
    state = state.copyWith(lastMoodId: moodId);
    await Hive.box(_settingsBoxName).put(_lastMoodKey, moodId);
  }

  Future<void> recordActionTap(String route) async {
    final next = Map<String, int>.from(state.routeTapCounts);
    next[route] = (next[route] ?? 0) + 1;
    state = state.copyWith(routeTapCounts: next);
    await Hive.box(_settingsBoxName).put(_routeTapCountsKey, next);
  }
}

final moodEngineProvider = NotifierProvider<MoodEngineNotifier, MoodEngineState>(
  MoodEngineNotifier.new,
);

const Map<String, List<MoodRecommendation>> _recommendationsByMood = {
  'anxious': [
    MoodRecommendation(
      titleKey: 'surahSharh',
      descKey: 'descAnxious',
      route: '/quran?surah=94',
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
      route: '/quran?surah=12',
      actionKey: 'actionReadSurah',
    ),
    MoodRecommendation(
      titleKey: 'surahDuha',
      descKey: 'descDuha',
      route: '/quran?surah=93',
      actionKey: 'actionReadSurah',
    ),
  ],
  'happy': [
    MoodRecommendation(
      titleKey: 'surahRahman',
      descKey: 'descHappy',
      route: '/quran?surah=55',
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
      route: '/quran?surah=1',
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

final moodRecommendationSuggestionsProvider =
    Provider.family<List<MoodRecommendationSuggestion>, String>((ref, moodId) {
      final locale = ref.watch(localeProvider);
      final isArabic = locale.languageCode == 'ar';
      final moodState = ref.watch(moodEngineProvider);
      final now = DateTime.now();
      final items = _recommendationsByMood[moodId] ?? _recommendationsByMood['lost']!;
      final isNight = now.hour >= 20 || now.hour < 5;
      final isMorning = now.hour >= 5 && now.hour < 12;

      final ranked = items.map((rec) {
        var score = 50;
        final taps = moodState.routeTapCounts[rec.route] ?? 0;
        score -= (taps * 3).clamp(0, 15); // diversify suggestions

        if (isNight && rec.route == '/azkar') score += 22;
        if (isNight && rec.route == '/tasbeeh') score += 10;
        if (isMorning && rec.route.startsWith('/quran')) score += 12;
        if (!isNight && rec.route == '/tasbeeh') score += 8;

        if (moodState.lastMoodId == moodId) score += 6;
        if (moodId == 'tired' && isNight && rec.route == '/azkar') score += 25;
        if (moodId == 'anxious' && rec.route.startsWith('/quran')) score += 8;

        final reason = isArabic
            ? _reasonAr(
                rec: rec,
                isNight: isNight,
                isMorning: isMorning,
                repeatedMood: moodState.lastMoodId == moodId,
              )
            : _reasonEn(
                rec: rec,
                isNight: isNight,
                isMorning: isMorning,
                repeatedMood: moodState.lastMoodId == moodId,
              );

        return MoodRecommendationSuggestion(
          recommendation: rec,
          reason: reason,
          score: score,
        );
      }).toList();

      ranked.sort((a, b) => b.score.compareTo(a.score));
      return ranked;
    });

final moodRecommendationProvider = Provider.family<MoodRecommendation, String>((
  ref,
  moodId,
) {
  final suggestions = ref.watch(moodRecommendationSuggestionsProvider(moodId));
  return suggestions.first.recommendation;
});

String _reasonAr({
  required MoodRecommendation rec,
  required bool isNight,
  required bool isMorning,
  required bool repeatedMood,
}) {
  if (isNight && rec.route == '/azkar') {
    return 'اقتراح مناسب لوقت المساء والهدوء.';
  }
  if (isMorning && rec.route.startsWith('/quran')) {
    return 'وقت مناسب لبدء يومك بقراءة قصيرة.';
  }
  if (repeatedMood) {
    return 'اعتمادًا على حالتك الأخيرة، هذا المسار غالبًا أنسب الآن.';
  }
  return 'اقتراح متوازن بناءً على الوقت ونمط الاستخدام.';
}

String _reasonEn({
  required MoodRecommendation rec,
  required bool isNight,
  required bool isMorning,
  required bool repeatedMood,
}) {
  if (isNight && rec.route == '/azkar') {
    return 'A calm night-friendly recommendation.';
  }
  if (isMorning && rec.route.startsWith('/quran')) {
    return 'A good morning fit for a short Quran session.';
  }
  if (repeatedMood) {
    return 'Based on your recent mood pattern, this is likely the best fit now.';
  }
  return 'Balanced recommendation based on time and usage pattern.';
}
