# Changelog | سجل التغييرات

جميع التغييرات المهمة في هذا المشروع سيتم توثيقها في هذا الملف.

## [Unreleased] - قيد التطوير

### Added | إضافات جديدة

#### 🧪 نظام اختبار الإشعارات الشامل
- **سكريبت اختبار تلقائي** (`scripts/test_notifications.dart`)
  - 17 اختبار شامل لجميع أنظمة الإشعارات
  - اختبارات إشعارات أوقات الصلاة (4 اختبارات)
  - اختبارات إشعارات تشغيل القرآن (4 اختبارات)
  - اختبارات إشعارات التحميل (3 اختبارات)
  - اختبارات الأداء (2 اختبار)
  - اختبارات التكامل (2 اختبار)
  - اختبارات معالجة الأخطاء (2 اختبار)

- **تقارير متعددة**
  - تقرير نصي (افتراضي)
  - تقرير HTML تفاعلي (مع `--html`)
  - تقرير JSON للمعالجة البرمجية (مع `--json`)

- **سكريبتات تشغيل**
  - `scripts/run_tests.sh` لأنظمة Linux/macOS
  - `scripts/run_tests.bat` لنظام Windows

- **تكامل CI/CD**
  - GitHub Actions workflow (`.github/workflows/test_notifications.yml`)
  - مثال GitLab CI (`.gitlab-ci.example.yml`)
  - تكامل مع VS Code (`.vscode/tasks.json` و `.vscode/launch.json`)

- **توثيق شامل**
  - دليل البدء السريع (`QUICK_START_TESTING.md`)
  - توثيق كامل للسكريبتات (`SCRIPTS_DOCUMENTATION.md`)
  - README للسكريبت (`scripts/README_TEST_NOTIFICATIONS.md`)
  - تحديث README الرئيسي

- **أدوات مساعدة**
  - Makefile لتسهيل الأوامر
  - تحديث .gitignore لتجاهل ملفات التقارير

### Changed | تغييرات

- تحديث README الرئيسي لإضافة قسم الاختبارات
- تحديث .gitignore لتجاهل ملفات التقارير

### Technical Details | التفاصيل التقنية

- **اللغة:** Dart
- **الإطار:** Flutter
- **أدوات الاختبار:** Static Analysis
- **التقارير:** Text, HTML, JSON
- **CI/CD:** GitHub Actions, GitLab CI (مثال)
- **IDE:** VS Code Tasks & Launch Configurations

---

## [0.1.0] - النسخة الأولية

### Added | إضافات جديدة

- القرآن الكريم (قراءة واستماع)
- مواقيت الصلاة
- السيرة النبوية
- الأحاديث النبوية
- بوصلة القبلة
- المسبحة الإلكترونية
- البث المباشر للقنوات الإسلامية
- دعم اللغتين العربية والإنجليزية

### In Progress | قيد التطوير

- دعم اللغة الفرنسية
- الوضع الليلي (Dark Mode)
- نظام الإشعارات المتقدم

---

## الصيغة

هذا الملف يتبع صيغة [Keep a Changelog](https://keepachangelog.com/ar/1.0.0/)،
ويلتزم المشروع بـ [Semantic Versioning](https://semver.org/lang/ar/).

### أنواع التغييرات

- `Added` للميزات الجديدة
- `Changed` للتغييرات في الميزات الموجودة
- `Deprecated` للميزات التي ستُزال قريباً
- `Removed` للميزات المُزالة
- `Fixed` لإصلاح الأخطاء
- `Security` للتحديثات الأمنية
