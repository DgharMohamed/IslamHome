# 🚀 دليل البدء السريع - اختبار الإشعارات

دليل سريع لتشغيل اختبارات الإشعارات في أقل من دقيقة.

## ⚡ البدء السريع

### 1️⃣ تشغيل الاختبارات

```bash
# الطريقة الأسهل
dart scripts/test_notifications.dart
```

### 2️⃣ مع تقارير HTML و JSON

```bash
dart scripts/test_notifications.dart --html --json
```

### 3️⃣ باستخدام السكريبتات المساعدة

**Linux/macOS:**
```bash
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

**Windows:**
```cmd
scripts\run_tests.bat
```

---

## 📊 ماذا يختبر؟

✅ **17 اختبار شامل:**

### إشعارات أوقات الصلاة (4 اختبارات)
- تهيئة الخدمة
- جدولة الإشعارات
- صلاحيات Exact Alarm
- إلغاء الإشعارات

### إشعارات تشغيل القرآن (4 اختبارات)
- تهيئة Audio Handler
- تحديث MediaItem
- سرعة التحديث
- التنقل بين الآيات

### إشعارات التحميل (3 اختبارات)
- تهيئة خدمة التحميل
- عرض التقدم
- إشعارات النجاح/الفشل

### اختبارات الأداء (2 اختبار)
- سرعة التهيئة
- استهلاك الذاكرة

### اختبارات التكامل (2 اختبار)
- تكامل الخدمات
- تكامل مع pubspec.yaml

### معالجة الأخطاء (2 اختبار)
- أخطاء الصلاحيات
- أخطاء التشغيل

---

## 📁 التقارير المُنتجة

### تقرير نصي (دائماً)
```
test_notifications_report_2024-01-15T10-30-00.txt
```

### تقرير HTML (مع --html)
```
test_notifications_report_2024-01-15T10-30-00.html
```
افتحه في المتصفح لرؤية تقرير تفاعلي جميل!

### تقرير JSON (مع --json)
```
test_notifications_report_2024-01-15T10-30-00.json
```
للمعالجة البرمجية أو التكامل مع أدوات أخرى.

---

## ✅ مثال على النتائج

```
🚀 بدء اختبار أنظمة الإشعارات

============================================================

📿 اختبار إشعارات أوقات الصلاة
------------------------------------------------------------
✅ تهيئة NotificationService (45ms)
✅ جدولة الإشعارات (32ms)
✅ صلاحية Exact Alarm (28ms)
✅ إلغاء الإشعارات (21ms)

🎵 اختبار إشعارات تشغيل القرآن
------------------------------------------------------------
✅ تهيئة QuranAudioHandler (38ms)
✅ تحديث MediaItem (42ms)
✅ سرعة تحديث الإشعار (106ms)
✅ التنقل بين الآيات (29ms)

📥 اختبار إشعارات التحميل
------------------------------------------------------------
✅ تهيئة DownloadService (35ms)
✅ عرض تقدم التحميل (31ms)
✅ إشعارات النجاح والفشل (27ms)

⚡ اختبار الأداء
------------------------------------------------------------
✅ سرعة تهيئة الخدمات (156ms)
✅ استهلاك الذاكرة (12ms)

🔗 اختبار التكامل
------------------------------------------------------------
✅ تكامل الخدمات مع بعضها (18ms)
✅ تكامل مع pubspec.yaml (15ms)

🛡️ اختبار معالجة الأخطاء
------------------------------------------------------------
✅ معالجة أخطاء الصلاحيات (22ms)
✅ معالجة أخطاء التشغيل (19ms)

============================================================

📊 ملخص النتائج:
------------------------------------------------------------
✅ اختبارات ناجحة: 17
❌ اختبارات فاشلة: 0
📝 إجمالي الاختبارات: 17
⏱️  الوقت الإجمالي: 635ms
📈 نسبة النجاح: 100.0%

💾 تم حفظ التقرير في: test_notifications_report_2024-01-15T10-30-00.txt
📄 تم إنشاء تقرير HTML: test_notifications_report_2024-01-15T10-30-00.html
📄 تم إنشاء تقرير JSON: test_notifications_report_2024-01-15T10-30-00.json
```

---

## 🔧 المتطلبات

### الأساسية
- ✅ Dart SDK مثبت
- ✅ مشروع Flutter

### التحقق من التثبيت
```bash
dart --version
```

إذا لم يكن مثبتاً:
```bash
# macOS
brew install dart

# Linux
sudo apt-get install dart

# Windows
choco install dart-sdk
```

---

## 🐛 حل المشاكل الشائعة

### ❌ "dart: command not found"
**الحل:** قم بتثبيت Dart SDK (انظر أعلاه)

### ❌ "ملف غير موجود"
**الحل:** تأكد من تشغيل الأمر من جذر المشروع

### ❌ "Permission denied" (Linux/macOS)
**الحل:**
```bash
chmod +x scripts/test_notifications.dart
chmod +x scripts/run_tests.sh
```

### ❌ بعض الاختبارات فشلت
**الحل:** راجع رسائل الخطأ في التقرير وتأكد من وجود الملفات المطلوبة:
- `lib/services/notification_service.dart`
- `lib/services/quran_audio_handler.dart`
- `lib/services/download_service.dart`

---

## 🔄 التكامل مع CI/CD

### GitHub Actions
الـ workflow جاهز في:
```
.github/workflows/test_notifications.yml
```

يتم تشغيله تلقائياً عند:
- Push إلى main أو develop
- إنشاء Pull Request
- يدوياً من تبويب Actions

### GitLab CI
أضف إلى `.gitlab-ci.yml`:
```yaml
test_notifications:
  stage: test
  script:
    - dart scripts/test_notifications.dart --html --json
  artifacts:
    paths:
      - test_notifications_report_*.txt
      - test_notifications_report_*.html
      - test_notifications_report_*.json
    expire_in: 30 days
```

### Jenkins
أضف إلى Jenkinsfile:
```groovy
stage('Test Notifications') {
    steps {
        sh 'dart scripts/test_notifications.dart --html --json'
    }
    post {
        always {
            archiveArtifacts artifacts: 'test_notifications_report_*.*'
        }
    }
}
```

---

## 📚 المزيد من المعلومات

- 📖 [التوثيق الكامل](SCRIPTS_DOCUMENTATION.md)
- 📖 [README السكريبت](scripts/README_TEST_NOTIFICATIONS.md)
- 📖 [خطة الاختبار](NOTIFICATION_TESTING_PLAN.md)

---

## 💡 نصائح

1. **شغّل الاختبارات قبل كل commit**
2. **استخدم --html لرؤية تقرير جميل**
3. **استخدم --json للتكامل مع أدوات أخرى**
4. **راجع التقارير بانتظام**
5. **أضف اختبارات جديدة عند إضافة ميزات**

---

## 🎯 الخطوات التالية

1. ✅ شغّل الاختبارات الآن
2. ✅ افتح تقرير HTML في المتصفح
3. ✅ أضف الـ workflow إلى CI/CD
4. ✅ شارك النتائج مع الفريق

---

**🚀 جاهز؟ ابدأ الآن:**
```bash
dart scripts/test_notifications.dart --html --json
```
