import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/save_last_read_result.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

/// دوال مساعدة لتوليد رسائل حفظ آخر قراءة
class LastReadMessages {
  /// الحصول على رسالة النجاح المناسبة بناءً على نتيجة الحفظ
  static String getSuccessMessage(
    SaveLastReadResult result,
    WidgetRef ref,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';

    // إذا كانت نفس الآية، فقط تحديث الوقت
    if (result.isSameAyah) {
      return l10n.lastReadUpdated;
    }

    // إذا كان هناك استبدال لآية مختلفة
    if (result.isReplacement) {
      final prevSurah = QuranUtils.getSurahName(
        result.previousPosition!.surahNumber,
        isEnglish: isEnglish,
      );
      final newSurah = QuranUtils.getSurahName(
        result.newPosition.surahNumber,
        isEnglish: isEnglish,
      );

      return l10n.lastReadReplaced(
        prevSurah,
        result.previousPosition!.ayahNumber,
        newSurah,
        result.newPosition.ayahNumber,
      );
    }

    // حفظ جديد بدون حفظ سابق
    return l10n.lastReadSaved;
  }

  /// الحصول على رسالة الخطأ
  static String getErrorMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.lastReadSaveFailed;
  }
}
