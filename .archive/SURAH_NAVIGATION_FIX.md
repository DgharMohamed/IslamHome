# إصلاح مشكلة الانتقال بين السور

## المشكلة
عند محاولة الانتقال إلى سورة معينة من قائمة السور في صفحة القراءة، كان التطبيق يعيد المستخدم تلقائياً إلى سورة الفاتحة بدلاً من الانتقال إلى السورة المطلوبة.

## السبب
المشكلة كانت في توقيت إنشاء المفاتيح (`GlobalKey`) للسور. عندما يتم تحميل سورة جديدة:
1. يتم استدعاء `loadInitialSurah()` لتحميل بيانات السورة
2. يتم إضافة السورة إلى قائمة العناصر
3. لكن المفاتيح (`_surahKeys`) لا يتم إنشاؤها إلا عند بناء عنصر واجهة المستخدم
4. عند محاولة الانتقال، المفتاح لا يكون جاهزاً بعد

## الحل المطبق

### 1. استخدام `WidgetsBinding.instance.addPostFrameCallback`
بدلاً من الانتظار لفترة زمنية ثابتة، نستخدم `addPostFrameCallback` للتأكد من أن إطار الواجهة قد تم بناؤه بالكامل قبل محاولة الانتقال.

### 2. آلية إعادة المحاولة
إذا لم يتم العثور على المفتاح في المحاولة الأولى، يتم إعادة المحاولة بعد 500ms.

### 3. رسائل التصحيح
إضافة رسائل `debugPrint` لتتبع عملية الانتقال ومعرفة ما إذا كانت تنجح أم لا.

## الكود المحدث

```dart
onSelected: (id) async {
  Navigator.pop(context); // Close sheet first

  setState(() {
    selectedSurahNumber = id;
    _currentVisibleSurah = id;
  });

  // Load data
  await ref
      .read(quranFlowProvider.notifier)
      .loadInitialSurah(id, translation: selectedTranslation);

  // Use post frame callback to ensure widget tree is built
  if (context.mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Try to scroll immediately after frame is rendered
      final key = _surahKeys[id];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        debugPrint('✅ Scrolled to surah $id');
      } else {
        debugPrint('❌ Key for surah $id not found');
        // Try again after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final retryKey = _surahKeys[id];
          if (retryKey != null && retryKey.currentContext != null) {
            Scrollable.ensureVisible(
              retryKey.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            debugPrint('✅ Scrolled to surah $id on retry');
          } else {
            debugPrint('❌ Failed to scroll to surah $id after retry');
          }
        });
      }
    });
  }
},
```

## ملفات معدلة
- `lib/presentation/screens/quran_text_screen.dart`

## اختبار الحل
1. افتح صفحة القراءة
2. اضغط على اسم السورة في الأعلى لفتح قائمة السور
3. اختر أي سورة من القائمة
4. يجب أن ينتقل التطبيق إلى السورة المختارة مباشرة

## ملاحظات
- إذا استمرت المشكلة، تحقق من رسائل التصحيح في console لمعرفة ما إذا كانت المفاتيح يتم إنشاؤها أم لا
- قد تحتاج إلى زيادة وقت الانتظار في إعادة المحاولة إذا كان الجهاز بطيئاً
