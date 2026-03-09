import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service responsible for scheduling and managing Islamic prayer (Adhan)
/// notifications with audio playback.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Notification IDs
  // 100–104 = Fajr, Dhuhr, Asr, Maghrib, Isha (adhan)
  // 200–204 = pre-prayer reminders
  static const Map<String, int> _prayerIds = {
    'Fajr': 100,
    'Dhuhr': 101,
    'Asr': 102,
    'Maghrib': 103,
    'Isha': 104,
  };

  static const Map<String, int> _reminderIds = {
    'Fajr': 200,
    'Dhuhr': 201,
    'Asr': 202,
    'Maghrib': 203,
    'Isha': 204,
  };

  /// Maps prayer name → Arabic display name
  static const Map<String, String> _prayerNamesAr = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };
  static const int _dailyVerseNotificationId = 710;
  static const int _dailyDhikrNotificationId = 711;

  // ──────────────────────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    await ensureNotificationPermission();

    // Create notification channels
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Adhan channel (with custom sound)
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'adhan_channel_v3',
          'أوقات الصلاة',
          description: 'إشعارات الأذان عند دخول وقت الصلاة',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      // Reminder channel (silent)
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_reminder_channel',
          'تذكير قبل الصلاة',
          description: 'تذكير قبل موعد الصلاة',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      // Daily content channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_content_channel',
          'المحتوى اليومي',
          description: 'إشعارات آية اليوم والمحتوى الإيماني',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    }

    _initialized = true;
    debugPrint('🔔 NotificationService: initialized');
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      if (tz.timeZoneDatabase.locations.containsKey(timezoneName)) {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        debugPrint('🔔 Timezone set to $timezoneName');
      } else {
        debugPrint('🔔 Timezone "$timezoneName" not found in TZ database');
      }
    } catch (e) {
      debugPrint('🔔 Failed to configure timezone: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Permission helpers
  // ──────────────────────────────────────────────────────────────────────────

  Future<bool> holdsExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final result = await plugin?.canScheduleExactNotifications();
      debugPrint('🔔 Exact alarm permission: $result');
      return result ?? true;
    } catch (e) {
      debugPrint('🔔 holdsExactAlarmPermission error: $e');
      // On older Android, this method doesn't exist — assume granted
      return true;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await plugin?.requestExactAlarmsPermission();
      return await holdsExactAlarmPermission();
    } catch (e) {
      debugPrint('🔔 requestExactAlarmPermission error: $e');
      return true;
    }
  }

  Future<bool> holdsNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final plugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final enabled = await plugin?.areNotificationsEnabled();
        return enabled ?? true;
      }

      if (Platform.isIOS) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('🔔 holdsNotificationPermission error: $e');
    }

    return true;
  }

  Future<bool> ensureNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final plugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        final enabled = await plugin?.areNotificationsEnabled();
        if (enabled ?? true) return true;

        await plugin?.requestNotificationsPermission();
        final afterRequest = await plugin?.areNotificationsEnabled();
        return afterRequest ?? false;
      }

      if (Platform.isIOS) {
        final plugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await plugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      }
    } catch (e) {
      debugPrint('🔔 ensureNotificationPermission error: $e');
    }

    return true;
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('🔔 isIgnoringBatteryOptimizations error: $e');
      return true;
    }
  }

  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await Permission.ignoreBatteryOptimizations.request();
      if (result.isGranted) return true;

      // Some OEM ROMs ignore direct requests; opening settings is the fallback.
      await openAppSettings();
      return await isIgnoringBatteryOptimizations();
    } catch (e) {
      debugPrint('🔔 requestIgnoreBatteryOptimizations error: $e');
      return true;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Adhan audio — copy bundled asset to file system so the plugin can use it
  // ──────────────────────────────────────────────────────────────────────────

  Future<String?> _getAdhanSoundPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/athan.mp3');

      if (!file.existsSync()) {
        final data = await rootBundle.load('assets/audio/athan.mp3');
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes);
        debugPrint('🔔 Adhan audio copied to: ${file.path}');
      }
      return file.path;
    } catch (e) {
      debugPrint('🔔 _getAdhanSoundPath error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Schedule daily prayers
  // ──────────────────────────────────────────────────────────────────────────

  /// Schedules one exact alarm for each enabled prayer today (or tomorrow if
  /// the prayer time has already passed).
  Future<void> scheduleDailyPrayers({
    required Map<String, String> timings,
    required Map<String, bool> enabledPrayers,
  }) async {
    if (!_initialized) await init();

    final soundPath = await _getAdhanSoundPath();

    for (final entry in _prayerIds.entries) {
      final prayerName = entry.key;
      final notifId = entry.value;

      // Cancel existing alarm for this prayer
      await _plugin.cancel(notifId);

      final isEnabled = enabledPrayers[prayerName] ?? true;
      if (!isEnabled) {
        debugPrint('🔕 $prayerName adhan disabled, skipped');
        continue;
      }

      final timeStr = timings[prayerName];
      if (timeStr == null) continue;

      final scheduledTime = _nextOccurrence(timeStr);
      if (scheduledTime == null) continue;

      final androidDetails = AndroidNotificationDetails(
        'adhan_channel_v3',
        'أوقات الصلاة',
        channelDescription: 'إشعارات الأذان',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'حان وقت ${_prayerNamesAr[prayerName] ?? prayerName}',
        fullScreenIntent: true,
        sound: soundPath != null
            ? UriAndroidNotificationSound('file://$soundPath')
            : null,
      );

      final details = NotificationDetails(android: androidDetails);

      try {
        await _plugin.zonedSchedule(
          notifId,
          'حان وقت ${_prayerNamesAr[prayerName] ?? prayerName}',
          'اللهم صلِّ على محمد',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint(
          '🔔 Scheduled $prayerName adhan at ${scheduledTime.toLocal()}',
        );
      } catch (e) {
        debugPrint('🔔 Failed to schedule $prayerName: $e');
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Pre-prayer reminders
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> scheduleDailyPrePrayerReminders({
    required Map<String, String> timings,
    required Map<String, bool> enabledPrayers,
    int reminderMinutes = 15,
  }) async {
    if (!_initialized) await init();

    for (final entry in _reminderIds.entries) {
      final prayerName = entry.key;
      final notifId = entry.value;

      await _plugin.cancel(notifId);

      final isEnabled = enabledPrayers[prayerName] ?? true;
      if (!isEnabled) continue;

      final timeStr = timings[prayerName];
      if (timeStr == null) continue;

      final prayerTime = _nextOccurrence(timeStr);
      if (prayerTime == null) continue;

      final reminderTime = prayerTime.subtract(
        Duration(minutes: reminderMinutes),
      );

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

      const androidDetails = AndroidNotificationDetails(
        'prayer_reminder_channel',
        'تذكير قبل الصلاة',
        importance: Importance.high,
        priority: Priority.high,
      );

      try {
        await _plugin.zonedSchedule(
          notifId,
          '${_prayerNamesAr[prayerName] ?? prayerName} بعد $reminderMinutes دقيقة',
          'استعد لصلاة ${_prayerNamesAr[prayerName] ?? prayerName}',
          reminderTime,
          const NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint(
          '🔔 Scheduled $prayerName pre-reminder at ${reminderTime.toLocal()}',
        );
      } catch (e) {
        debugPrint('🔔 Failed to schedule $prayerName reminder: $e');
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Custom methods needed across the app
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> testAthan() async {
    if (!_initialized) await init();
    try {
      final soundPath = await _getAdhanSoundPath();
      final androidDetails = AndroidNotificationDetails(
        'adhan_channel_v3',
        'أوقات الصلاة',
        channelDescription: 'إشعارات الأذان',
        importance: Importance.max,
        priority: Priority.max,
        sound: soundPath != null
            ? UriAndroidNotificationSound('file://$soundPath')
            : null,
      );
      await _plugin.show(
        999,
        'تجربة الأذان',
        'الصوت يعمل بنجاح',
        NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('🔔 testAthan error: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_initialized) await init();
    try {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'إشعارات التجربة',
        importance: Importance.high,
        priority: Priority.high,
      );
      await _plugin.show(
        998,
        'إشعار تجريبي',
        'الإشعارات تعمل بكفاءة على جهازك',
        const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('🔔 showTestNotification error: $e');
    }
  }

  Future<bool> showDailyVerseNotification({
    required String title,
    required String body,
    String? subtitle,
  }) async {
    if (!_initialized) await init();
    final hasPermission = await holdsNotificationPermission();
    if (!hasPermission) return false;

    try {
      final safeBody = body.trim().isEmpty ? subtitle ?? '' : body.trim();
      final trimmed = safeBody.length > 220
          ? '${safeBody.substring(0, 220)}...'
          : safeBody;

      const androidDetails = AndroidNotificationDetails(
        'daily_content_channel',
        'المحتوى اليومي',
        channelDescription: 'إشعارات آية اليوم والمحتوى الإيماني',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _plugin.show(
        _dailyVerseNotificationId,
        title,
        trimmed,
        const NotificationDetails(android: androidDetails),
      );
      return true;
    } catch (e) {
      debugPrint('🔔 showDailyVerseNotification error: $e');
      return false;
    }
  }

  Future<bool> showDailyDhikrNotification({
    required String title,
    required String body,
    String? subtitle,
  }) async {
    if (!_initialized) await init();
    final hasPermission = await holdsNotificationPermission();
    if (!hasPermission) return false;

    try {
      final base = body.trim().isEmpty ? (subtitle ?? '') : body.trim();
      final trimmed = base.length > 220 ? '${base.substring(0, 220)}...' : base;

      const androidDetails = AndroidNotificationDetails(
        'daily_content_channel',
        'المحتوى اليومي',
        channelDescription: 'إشعارات آية اليوم والمحتوى الإيماني',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _plugin.show(
        _dailyDhikrNotificationId,
        title,
        trimmed,
        const NotificationDetails(android: androidDetails),
      );
      return true;
    } catch (e) {
      debugPrint('🔔 showDailyDhikrNotification error: $e');
      return false;
    }
  }

  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    if (!_initialized) await init();
    try {
      final androidDetails = AndroidNotificationDetails(
        'download_channel',
        'التحميلات',
        channelDescription: 'إشعارات تقدم التحميل',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        onlyAlertOnce: true,
        playSound: false,
      );
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('🔔 showProgressNotification error: $e');
    }
  }

  Future<void> showDownloadCompleteNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    try {
      const androidDetails = AndroidNotificationDetails(
        'download_channel',
        'التحميلات',
        channelDescription: 'إشعارات تقدم التحميل',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('🔔 showDownloadCompleteNotification error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cancel
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('🔕 Cancelled notification id=$id');
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('🔕 All notifications cancelled');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Parses a "HH:MM" string and returns the next occurrence as a
  /// [tz.TZDateTime] (today if the time is still in the future, otherwise
  /// tomorrow).
  tz.TZDateTime? _nextOccurrence(String timeStr) {
    try {
      // Strip timezone suffix if present (e.g. "05:12 (WET)")
      final clean = timeStr.split(' ').first.trim();
      final parts = clean.split(':');
      if (parts.length < 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      return scheduled;
    } catch (e) {
      debugPrint('🔔 _nextOccurrence parse error for "$timeStr": $e');
      return null;
    }
  }
}
