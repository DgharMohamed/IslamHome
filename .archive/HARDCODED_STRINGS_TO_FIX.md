# النصوص المكتوبة بشكل ثابت التي تحتاج إلى ترجمة

## 1. lib/presentation/widgets/home_header_widget.dart

### السطر 616:
```dart
'استخدام الموقع التلقائي (GPS)'
```
**الحل:** إضافة مفتاح في ملف الترجمة مثل `useAutoLocation` و `Use Auto Location (GPS)`

### السطر 686-688:
```dart
l10n.localeName == 'ar'
    ? 'المزيد من الإعدادات...'
    : 'More Settings...'
```
**الحل:** استخدام `l10n.moreSettings` بدلاً من الشرط

---

## 2. lib/presentation/screens/video_screen.dart

### السطر 45:
```dart
'خدمة الصوت لم تكتمل بعد، يرجى المحاولة مرة أخرى'
```
**الحل:** إضافة `audioServiceNotReady` في ملف الترجمة

### السطر 92:
```dart
'تم تشغيل المقطع كصوت في الخلفية'
```
**الحل:** إضافة `playingInBackground` في ملف الترجمة

### السطر 102:
```dart
'فشل تشغيل المقطع: $e'
```
**الحل:** إضافة `failedToPlay` في ملف الترجمة مع placeholder للخطأ

---

## 3. lib/presentation/screens/splash_screen.dart

### السطر 49:
```dart
'لاحقاً'
```
**الحل:** إضافة `later` في ملف الترجمة

### السطر 60:
```dart
'تفعيل الآن'
```
**الحل:** إضافة `activateNow` في ملف الترجمة

---

## 4. lib/presentation/screens/reciter_screen.dart

### السطر 534:
```dart
'تم بدء تحميل الكل إلى القائمة'
```
**الحل:** إضافة `downloadAllStarted` في ملف الترجمة

### السطر 539:
```dart
'تحميل الكل'
```
**الحل:** إضافة `downloadAll` في ملف الترجمة

### السطر 568:
```dart
'خطأ: لا يوجد رابط خادم للقارئ'
```
**الحل:** إضافة `noServerLinkError` في ملف الترجمة

### السطر 613:
```dart
'خطأ في تشغيل القائمة: $e'
```
**الحل:** إضافة `playlistPlayError` في ملف الترجمة

---

## 5. lib/presentation/screens/qibla_screen.dart

### السطر 91:
```dart
'Grant Permission'
```
**الحل:** إضافة `grantPermission` في ملف الترجمة

### السطر 121:
```dart
'Error: ${snapshot.error}'
```
**الحل:** إضافة `error` في ملف الترجمة

### السطر 134:
```dart
'Device does not have sensors'
```
**الحل:** إضافة `noSensors` في ملف الترجمة

---

## 6. lib/presentation/screens/prayer_times_screen.dart

### السطر 654:
```dart
'إلغاء'
```
**الحل:** إضافة `cancel` في ملف الترجمة

### السطر 666:
```dart
'حفظ'
```
**الحل:** إضافة `save` في ملف الترجمة

---

## 7. lib/presentation/screens/playlist_detail_screen.dart

### السطر 27:
```dart
'القائمة غير موجودة'
```
**الحل:** إضافة `playlistNotFound` في ملف الترجمة

---

## 8. lib/presentation/screens/playlists_screen.dart

### السطر 133:
```dart
'إنشاء قائمة جديدة'
```
**الحل:** إضافة `createNewPlaylist` في ملف الترجمة

---

## 9. lib/presentation/screens/hadith_screen.dart

### السطر 331 و 385:
```dart
'Error: $err'
```
**الحل:** استخدام `l10n.error` مع placeholder

---

## 10. lib/presentation/screens/favorites_screen.dart

### السطر 33:
```dart
'تم استيراد قائمة التشغيل بنجاح'
```
**الحل:** إضافة `playlistImportedSuccessfully` في ملف الترجمة

---

## 11. lib/presentation/screens/downloads_screen.dart

### السطر 353:
```dart
'حدث خطأ: $err'
```
**الحل:** استخدام `l10n.errorOccurred` مع placeholder

---

## 12. lib/presentation/screens/azkar_screen.dart

### السطر 312:
```dart
'Error: $err'
```
**الحل:** استخدام `l10n.error` مع placeholder

---

## الخطوات المطلوبة:

1. إضافة جميع المفاتيح المذكورة أعلاه إلى ملف `lib/l10n/app_en.arb`
2. إضافة الترجمات العربية المقابلة إلى ملف `lib/l10n/app_ar.arb`
3. تشغيل `flutter gen-l10n` لتوليد ملفات الترجمة
4. استبدال النصوص الثابتة في الكود باستخدام `l10n.keyName`
