import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islam_home/data/models/save_last_read_result.dart';

class LastReadService {
  static const String _lastReadSurahKey = 'last_read_surah';
  static const String _lastReadAyahKey = 'last_read_ayah';
  static const String _lastReadTimestampKey = 'last_read_timestamp';

  /// حفظ آخر موضع قراءة
  Future<void> saveLastRead({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadSurahKey, surahNumber);
    await prefs.setInt(_lastReadAyahKey, ayahNumber);
    await prefs.setInt(
      _lastReadTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// استرجاع آخر موضع قراءة
  Future<LastReadPosition?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surahNumber = prefs.getInt(_lastReadSurahKey);
    final ayahNumber = prefs.getInt(_lastReadAyahKey);
    final timestamp = prefs.getInt(_lastReadTimestampKey);

    if (surahNumber == null || ayahNumber == null) {
      return null;
    }

    return LastReadPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      timestamp: timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null,
    );
  }

  /// مسح آخر موضع قراءة
  Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReadSurahKey);
    await prefs.remove(_lastReadAyahKey);
    await prefs.remove(_lastReadTimestampKey);
  }

  /// حفظ آخر موضع قراءة مع إرجاع معلومات عن الحفظ السابق
  Future<SaveLastReadResult> saveLastReadWithPrevious({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      debugPrint('💾 Saving last read: Surah $surahNumber, Ayah $ayahNumber');

      // الحصول على الحفظ السابق
      final previous = await getLastRead();
      debugPrint(
        '💾 Previous last read: ${previous?.surahNumber}:${previous?.ayahNumber}',
      );

      // حفظ الجديد
      await saveLastRead(surahNumber: surahNumber, ayahNumber: ayahNumber);
      debugPrint('💾 Successfully saved new last read');

      // إرجاع النتيجة
      return SaveLastReadResult(
        previousPosition: previous,
        newPosition: LastReadPosition(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      // تسجيل الخطأ
      debugPrint('❌ Error saving last read: $e');
      debugPrint('Stack trace: $stackTrace');

      // إعادة رمي الخطأ ليتم التعامل معه في واجهة المستخدم
      rethrow;
    }
  }
}

class LastReadPosition {
  final int surahNumber;
  final int ayahNumber;
  final DateTime? timestamp;

  LastReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
    this.timestamp,
  });
}
