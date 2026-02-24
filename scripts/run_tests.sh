#!/bin/bash

# سكريبت لتشغيل اختبارات الإشعارات في CI/CD
# الاستخدام: ./scripts/run_tests.sh

set -e

echo "🚀 بدء اختبارات الإشعارات..."
echo ""

# التحقق من وجود Dart
if ! command -v dart &> /dev/null; then
    echo "❌ خطأ: Dart غير مثبت"
    echo "يرجى تثبيت Dart SDK أولاً"
    exit 1
fi

# التحقق من وجود السكريبت
if [ ! -f "scripts/test_notifications.dart" ]; then
    echo "❌ خطأ: ملف test_notifications.dart غير موجود"
    exit 1
fi

# تشغيل الاختبارات
echo "📝 تشغيل الاختبارات..."
dart scripts/test_notifications.dart --html --json

# التحقق من النتيجة
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ جميع الاختبارات نجحت!"
    exit 0
else
    echo ""
    echo "❌ بعض الاختبارات فشلت"
    exit 1
fi
