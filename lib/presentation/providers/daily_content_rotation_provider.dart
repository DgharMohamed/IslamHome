import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/data/services/notification_service.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/daily_verse_provider.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

final dailyContentRotationProvider =
    NotifierProvider<DailyContentRotationNotifier, int>(
      DailyContentRotationNotifier.new,
    );

class DailyContentRotationNotifier extends Notifier<int> {
  static const String _settingsBoxName = 'settings';
  static const String _rotationKey = 'daily_content_rotation';
  static const String _lastVerseNotifSignatureKey =
      'last_daily_verse_notif_signature';
  static const String _lastDhikrNotifSignatureKey =
      'last_daily_dhikr_notif_signature';

  @override
  int build() {
    final box = Hive.box(_settingsBoxName);
    return (box.get(_rotationKey, defaultValue: 0) as int?) ?? 0;
  }

  Future<void> rotateOnHomeEnter() async {
    final next = state + 1;
    state = next;

    final box = Hive.box(_settingsBoxName);
    await box.put(_rotationKey, next);
    await _notifyOnVerseChange(next, box);
    await _notifyOnDhikrChange(next, box);
  }

  Future<void> _notifyOnVerseChange(int rotation, Box box) async {
    final verse = _dailyVersesPool[rotation % _dailyVersesPool.length];
    final signature = '${verse.surah}|${verse.text}';
    final lastSignature = box.get(_lastVerseNotifSignatureKey) as String?;
    if (lastSignature == signature) return;

    final locale = ref.read(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    final sent = await NotificationService().showDailyVerseNotification(
      title: isArabic ? 'آية اليوم' : 'Verse of the Day',
      body: isArabic ? verse.text : verse.translation,
      subtitle: verse.surah,
    );
    if (sent) {
      await box.put(_lastVerseNotifSignatureKey, signature);
    }
  }

  Future<void> _notifyOnDhikrChange(int rotation, Box box) async {
    final service = ref.read(adhkarServiceProvider);
    final categories = await service.getCategories();
    if (categories.isEmpty) return;

    final categoryIndex = ((rotation * 5) + 1) % categories.length;
    AdhkarModel? dhikr;

    for (var i = 0; i < categories.length; i++) {
      final category = categories[(categoryIndex + i) % categories.length];
      final items = await service.getByCategory(category);
      if (items.isEmpty) continue;
      final itemIndex = ((rotation * 13) + 7) % items.length;
      dhikr = items[itemIndex];
      break;
    }
    if (dhikr == null) return;

    final signature = '${dhikr.category}|${dhikr.textAr}';
    final lastSignature = box.get(_lastDhikrNotifSignatureKey) as String?;
    if (lastSignature == signature) return;

    final locale = ref.read(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final body = isArabic
        ? dhikr.textAr
        : (dhikr.textEn.trim().isNotEmpty ? dhikr.textEn : dhikr.textAr);

    final sent = await NotificationService().showDailyDhikrNotification(
      title: isArabic ? 'ذكر اليوم' : 'Daily Adhkar',
      body: body,
      subtitle: dhikr.category,
    );
    if (sent) {
      await box.put(_lastDhikrNotifSignatureKey, signature);
    }
  }
}

const List<DailyVerse> _dailyVersesPool = <DailyVerse>[
  DailyVerse(
    text: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    surah: 'سورة الرعد - آية ٢٨',
    translation:
        'Unquestionably, by the remembrance of Allah hearts are assured.',
  ),
  DailyVerse(
    text: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    surah: 'سورة البقرة - آية ٢٨٦',
    translation:
        'Allah does not charge a soul except [with that within] its capacity.',
  ),
  DailyVerse(
    text: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    surah: 'سورة الشرح - آية ٦',
    translation: 'Indeed, with hardship comes ease.',
  ),
  DailyVerse(
    text: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    surah: 'سورة الطلاق - آية ٢',
    translation: 'Whoever fears Allah, He makes for him a way out.',
  ),
  DailyVerse(
    text: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
    surah: 'سورة طه - آية ١١٤',
    translation: 'And say, "My Lord, increase me in knowledge."',
  ),
  DailyVerse(
    text: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
    surah: 'سورة البقرة - آية ١٥٢',
    translation: 'So remember Me; I will remember you.',
  ),
  DailyVerse(
    text: 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    surah: 'سورة البقرة - آية ١٥٣',
    translation: 'Indeed, Allah is with the patient.',
  ),
];

final rotatingDailyVerseProvider = Provider<DailyVerse>((ref) {
  final rotation = ref.watch(dailyContentRotationProvider);
  final index = rotation % _dailyVersesPool.length;
  return _dailyVersesPool[index];
});

final rotatingDailyHadithProvider = FutureProvider<HadithModel?>((ref) async {
  final rotation = ref.watch(dailyContentRotationProvider);
  final locale = ref.watch(localeProvider);
  final hadithService = ref.watch(hadithServiceProvider);
  final allBooks = await hadithService.loadAllHadiths();
  final allHadiths = allBooks.values.expand((list) => list).toList();
  if (allHadiths.isEmpty) return null;

  final requireEnglish = locale.languageCode == 'en';
  var source = allHadiths;
  if (requireEnglish) {
    final englishOnly = allHadiths
        .where((h) => (h.english ?? '').trim().isNotEmpty)
        .toList();
    if (englishOnly.isNotEmpty) {
      source = englishOnly;
    }
  }

  source.sort((a, b) {
    final idA = a.id ?? '';
    final idB = b.id ?? '';
    final idCmp = idA.compareTo(idB);
    if (idCmp != 0) return idCmp;
    final nA = a.number ?? 0;
    final nB = b.number ?? 0;
    return nA.compareTo(nB);
  });

  final index = ((rotation * 11) + 5) % source.length;
  return source[index];
});

final rotatingDailyAdhkarProvider = FutureProvider<AdhkarModel?>((ref) async {
  final rotation = ref.watch(dailyContentRotationProvider);
  final service = ref.watch(adhkarServiceProvider);
  final categories = await service.getCategories();
  if (categories.isEmpty) return null;

  final categoryIndex = ((rotation * 5) + 1) % categories.length;

  for (var i = 0; i < categories.length; i++) {
    final category = categories[(categoryIndex + i) % categories.length];
    final items = await service.getByCategory(category);
    if (items.isEmpty) continue;
    final itemIndex = ((rotation * 13) + 7) % items.length;
    return items[itemIndex];
  }

  return null;
});
