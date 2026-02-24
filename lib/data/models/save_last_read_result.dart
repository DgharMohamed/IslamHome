import 'package:islam_home/data/services/last_read_service.dart';

/// نتيجة عملية حفظ آخر قراءة
///
/// يحتوي على معلومات عن الموضع السابق (إن وجد) والموضع الجديد
class SaveLastReadResult {
  /// الموضع السابق (null إذا لم يكن هناك حفظ سابق)
  final LastReadPosition? previousPosition;

  /// الموضع الجديد المحفوظ
  final LastReadPosition newPosition;

  SaveLastReadResult({
    required this.previousPosition,
    required this.newPosition,
  });

  /// هل هذا استبدال لحفظ سابق؟
  bool get isReplacement => previousPosition != null;

  /// هل الآية الجديدة هي نفس الآية السابقة؟
  bool get isSameAyah =>
      previousPosition?.surahNumber == newPosition.surahNumber &&
      previousPosition?.ayahNumber == newPosition.ayahNumber;
}
