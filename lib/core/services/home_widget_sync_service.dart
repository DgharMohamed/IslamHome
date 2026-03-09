import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:islam_home/presentation/providers/daily_content_rotation_provider.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

const _widgetProviderName = 'DailyContentHomeWidgetProvider';

Future<void> syncDailyContentHomeWidget(WidgetRef ref) async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
    return;
  }

  final locale = ref.read(localeProvider);
  final isArabic = locale.languageCode == 'ar';
  final rotation = ref.read(dailyContentRotationProvider);
  final contentType = rotation % 3;

  var title = isArabic ? 'آية اليوم' : 'Verse of the Day';
  var content = '';
  var subtitle = '';
  var type = 'verse';

  if (contentType == 0) {
    final verse = ref.read(rotatingDailyVerseProvider);
    title = isArabic ? 'آية اليوم' : 'Verse of the Day';
    content = isArabic ? verse.text : verse.translation;
    subtitle = verse.surah;
    type = 'verse';
  } else if (contentType == 1) {
    final hadith = await ref.read(rotatingDailyHadithProvider.future);
    if (hadith != null) {
      title = isArabic ? 'حديث اليوم' : 'Hadith of the Day';
      content = isArabic
          ? (hadith.arab ?? hadith.english ?? '')
          : (hadith.english ?? hadith.arab ?? '');
      subtitle = '${hadith.book ?? ''} - ${hadith.number ?? ''}';
      type = 'hadith';
    }
  } else {
    final dhikr = await ref.read(rotatingDailyAdhkarProvider.future);
    if (dhikr != null) {
      title = isArabic ? 'ذكر اليوم' : 'Daily Adhkar';
      content = isArabic ? dhikr.textAr : dhikr.textEn;
      subtitle = dhikr.category;
      type = 'adhkar';
    }
  }

  if (content.trim().isEmpty) {
    final verse = ref.read(rotatingDailyVerseProvider);
    title = isArabic ? 'آية اليوم' : 'Verse of the Day';
    content = isArabic ? verse.text : verse.translation;
    subtitle = verse.surah;
    type = 'verse';
  }

  try {
    await HomeWidget.saveWidgetData<String>('daily_widget_title', title);
    await HomeWidget.saveWidgetData<String>('daily_widget_content', content);
    await HomeWidget.saveWidgetData<String>('daily_widget_subtitle', subtitle);
    await HomeWidget.saveWidgetData<String>('daily_widget_type', type);
    await HomeWidget.updateWidget(name: _widgetProviderName);
  } on MissingPluginException {
    // Plugin not available in this runtime (e.g. hot reload without full restart).
    debugPrint('HomeWidget plugin is not available on this run.');
  } catch (e) {
    debugPrint('HomeWidget sync failed: $e');
  }
}
