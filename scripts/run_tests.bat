@echo off
REM سكريبت لتشغيل اختبارات الإشعارات في Windows
REM الاستخدام: scripts\run_tests.bat

echo 🚀 بدء اختبارات الإشعارات...
echo.

REM التحقق من وجود Dart
where dart >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ خطأ: Dart غير مثبت
    echo يرجى تثبيت Dart SDK أولاً
    exit /b 1
)

REM التحقق من وجود السكريبت
if not exist "scripts\test_notifications.dart" (
    echo ❌ خطأ: ملف test_notifications.dart غير موجود
    exit /b 1
)

REM تشغيل الاختبارات
echo 📝 تشغيل الاختبارات...
dart scripts\test_notifications.dart --html --json

REM التحقق من النتيجة
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ جميع الاختبارات نجحت!
    exit /b 0
) else (
    echo.
    echo ❌ بعض الاختبارات فشلت
    exit /b 1
)
