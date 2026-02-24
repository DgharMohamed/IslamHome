# Makefile لتسهيل تشغيل الأوامر الشائعة

.PHONY: help test test-html test-json test-all clean install

# الأمر الافتراضي
help:
	@echo "🕋 Islam Home - أوامر متاحة:"
	@echo ""
	@echo "  make test          - تشغيل اختبارات الإشعارات"
	@echo "  make test-html     - تشغيل الاختبارات مع تقرير HTML"
	@echo "  make test-json     - تشغيل الاختبارات مع تقرير JSON"
	@echo "  make test-all      - تشغيل الاختبارات مع جميع التقارير"
	@echo "  make clean         - حذف ملفات التقارير"
	@echo "  make install       - تثبيت المتطلبات"
	@echo ""

# تشغيل الاختبارات
test:
	@echo "🧪 تشغيل اختبارات الإشعارات..."
	@dart scripts/test_notifications.dart

# تشغيل مع تقرير HTML
test-html:
	@echo "🧪 تشغيل اختبارات الإشعارات مع تقرير HTML..."
	@dart scripts/test_notifications.dart --html
	@echo ""
	@echo "📄 افتح التقرير في المتصفح:"
	@ls -t test_notifications_report_*.html | head -1

# تشغيل مع تقرير JSON
test-json:
	@echo "🧪 تشغيل اختبارات الإشعارات مع تقرير JSON..."
	@dart scripts/test_notifications.dart --json

# تشغيل مع جميع التقارير
test-all:
	@echo "🧪 تشغيل اختبارات الإشعارات مع جميع التقارير..."
	@dart scripts/test_notifications.dart --html --json
	@echo ""
	@echo "📊 التقارير المُنشأة:"
	@ls -lh test_notifications_report_*

# حذف ملفات التقارير
clean:
	@echo "🧹 حذف ملفات التقارير..."
	@rm -f test_notifications_report_*.txt
	@rm -f test_notifications_report_*.html
	@rm -f test_notifications_report_*.json
	@echo "✅ تم الحذف"

# تثبيت المتطلبات
install:
	@echo "📦 تثبيت المتطلبات..."
	@flutter pub get
	@echo "✅ تم التثبيت"

# تشغيل التطبيق
run:
	@echo "🚀 تشغيل التطبيق..."
	@flutter run

# بناء التطبيق
build:
	@echo "🔨 بناء التطبيق..."
	@flutter build apk --release

# فحص الكود
lint:
	@echo "🔍 فحص الكود..."
	@flutter analyze

# تنسيق الكود
format:
	@echo "✨ تنسيق الكود..."
	@dart format .

# اختبارات Flutter
flutter-test:
	@echo "🧪 تشغيل اختبارات Flutter..."
	@flutter test
