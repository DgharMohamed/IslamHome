import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Service responsible for scheduling and managing Islamic prayer (Adhan)
/// notifications with audio playback.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String _adhanChannelId = 'adhan_channel_v7';
  static const List<String> _legacyAdhanChannelIds = [
    'adhan_channel_v4',
    'adhan_channel_v5',
    'adhan_channel_v6',
  ];
  static const String _reminderChannelId = 'prayer_reminder_channel';
  static const String _dailyContentChannelId = 'daily_content_channel';
  static const RawResourceAndroidNotificationSound _adhanSound =
      RawResourceAndroidNotificationSound('athan');

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

  static const int _dailyVerseNotificationId = 710;
  static const int _dailyDhikrNotificationId = 711;
  static const int _khatmaReminderNotificationId = 712;

  // Smart Adhkar & Tasbeeh IDs
  static const int _adhkarMorningBaseId = 300;
  static const int _adhkarEveningBaseId = 301;
  static const int _adhkarSleepBaseId = 302;
  static const int _tasbeehStreakBaseId = 400;

  static AppLocalizations? _localizations;
  static String _currentLocale = 'ar';

  /// Returns the current localizations.
  /// Loads them synchronously if not already loaded.
  AppLocalizations get l10n {
    _localizations ??= lookupAppLocalizations(Locale(_currentLocale));
    return _localizations!;
  }

  /// Updates the current locale used for notifications.
  void updateLocale(String locale) {
    _currentLocale = locale;
    _localizations = lookupAppLocalizations(Locale(locale));
    debugPrint('🔔 NotificationService: locale updated to $locale');
  }

  /// Reloads the locale from Hive settings (called when user switches language).
  void reloadLocale() {
    try {
      if (Hive.isBoxOpen('settings')) {
        final saved = Hive.box('settings').get('language', defaultValue: 'ar');
        updateLocale(saved);
        debugPrint('🔔 NotificationService: locale reloaded to $saved');
      }
    } catch (e) {
      debugPrint('🔔 NotificationService: reloadLocale error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _configureLocalTimezone();

    // Load current locale from Hive
    try {
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }
      _currentLocale = Hive.box('settings').get('language', defaultValue: 'ar');
      _localizations = lookupAppLocalizations(Locale(_currentLocale));
    } catch (e) {
      debugPrint('🔔 NotificationService: failed to load locale from Hive: $e');
    }

    if (Platform.isWindows || kIsWeb) {
      _initialized = true;
      debugPrint(
        '🔔 NotificationService: initialization skipped for this platform',
      );
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
    } catch (e) {
      debugPrint('🔔 NotificationService initialize error: $e');
    }
    await ensureNotificationPermission();

    // Create notification channels
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      for (final channelId in _legacyAdhanChannelIds) {
        await androidPlugin?.deleteNotificationChannel(channelId);
      }

      // Adhan channel (with custom sound)
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _adhanChannelId,
          l10n.prayerTimes,
          description: l10n.notificationAdhanDesc,
          importance: Importance.max,
          playSound: true,
          sound: _adhanSound,
          enableVibration: true,
          showBadge: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );

      // Reminder channel
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _reminderChannelId,
          l10n.notificationReminders,
          description: l10n.notificationRemindersDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      // Daily content channel
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _dailyContentChannelId,
          l10n.notificationDailyContent,
          description: l10n.notificationDailyDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    }

    _initialized = true;
    debugPrint('🔔 NotificationService: initialized (locale: $_currentLocale)');
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
  // Schedule daily prayers
  // ──────────────────────────────────────────────────────────────────────────

  /// Schedules multiple days of prayers to ensure accuracy as times shift.
  Future<void> scheduleMultipleDays({
    required Map<DateTime, Map<String, String>> multiDayTimings,
    required Map<String, bool> enabledPrayers,
    required bool preRemindersEnabled,
    int reminderMinutes = 15,
  }) async {
    if (!_initialized) await init();
    if (Platform.isWindows || kIsWeb) return;

    final scheduleMode = await _scheduleModeForPrayerAlerts();

    // 1. Cancel existing future notifications (to avoid overlaps)
    // Cancel IDs for up to 12 days to cover the full scheduling window
    for (int dayOffset = 0; dayOffset <= 12; dayOffset++) {
      for (final baseId in _prayerIds.values) {
        await _plugin.cancel(_calculateId(baseId, dayOffset));
      }
      for (final baseId in _reminderIds.values) {
        await _plugin.cancel(_calculateId(baseId, dayOffset));
      }
    }

    // 2. Schedule for each day provided
    int dayIndex = 0;
    for (final dateEntry in multiDayTimings.entries) {
      final date = dateEntry.key;
      final timings = dateEntry.value;

      for (final entry in _prayerIds.entries) {
        final prayerName = entry.key;
        final baseId = entry.value;

        if (!(enabledPrayers[prayerName] ?? true)) continue;

        final timeStr = timings[prayerName];
        if (timeStr == null) continue;

        final scheduledTime = _getSpecificTime(date, timeStr);
        if (scheduledTime == null) continue;

        // Skip if in the past
        if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

        final notifId = _calculateId(baseId, dayIndex);

        final prayerDisplayName = prayerName == 'Fajr'
            ? l10n.fajr
            : prayerName == 'Dhuhr'
            ? l10n.dhuhr
            : prayerName == 'Asr'
            ? l10n.asr
            : prayerName == 'Maghrib'
            ? l10n.maghrib
            : l10n.isha;
        final title = l10n.notificationAthanTimeFor(prayerDisplayName);

        final androidDetails = AndroidNotificationDetails(
          _adhanChannelId,
          l10n.prayerTimes,
          channelDescription: l10n.notificationAdhanDesc,
          importance: Importance.max,
          priority: Priority.max,
          ticker: title,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          sound: _adhanSound,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );

        await _zonedScheduleWithFallback(
          notifId,
          title,
          l10n.notificationAllahBlessing,
          scheduledTime,
          NotificationDetails(android: androidDetails),
          scheduleMode,
        );

        // Schedule reminder if enabled
        if (preRemindersEnabled) {
          final reminderBaseId = _reminderIds[prayerName];
          if (reminderBaseId != null) {
            final reminderTime = scheduledTime.subtract(
              Duration(minutes: reminderMinutes),
            );

            if (reminderTime.isAfter(tz.TZDateTime.now(tz.local))) {
              final reminderId = _calculateId(reminderBaseId, dayIndex);
              final reminderTitle = l10n.notificationReminderBefore(
                prayerDisplayName,
                reminderMinutes.toString(),
              );
              final reminderBody = l10n.notificationPrepareFor(
                prayerDisplayName,
              );

              final reminderAndroid = AndroidNotificationDetails(
                _reminderChannelId,
                l10n.notificationReminders,
                importance: Importance.high,
                priority: Priority.high,
              );

              await _zonedScheduleWithFallback(
                reminderId,
                reminderTitle,
                reminderBody,
                reminderTime,
                NotificationDetails(android: reminderAndroid),
                scheduleMode,
              );
            }
          }
        }
      }
      dayIndex++;
    }

    debugPrint('🔔 Scheduled prayers for $dayIndex days');
  }

  /// Calculates a unique ID based on a base ID and a day offset.
  int _calculateId(int baseId, int dayOffset) {
    // baseId is 100-104 (prayer) or 200-204 (reminder).
    // We use dayOffset * 1000 to guarantee no collision between
    // prayer IDs and reminder IDs across different days.
    // E.g. day 0 prayer Fajr = 100, day 0 reminder Fajr = 200,
    //      day 1 prayer Fajr = 1100, day 1 reminder Fajr = 1200.
    return baseId + (dayOffset * 1000);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Smart Adhkar & Tasbeeh Scheduling
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> scheduleAdhkarReminders({
    required Map<DateTime, Map<String, String>> multiDayTimings,
    required bool morningEnabled,
    required int morningMinutesAfterFajr,
    required bool eveningEnabled,
    required int eveningMinutesAfterAsr,
    required bool sleepEnabled,
    required int sleepMinutesAfterIsha,
  }) async {
    if (!_initialized) await init();
    if (Platform.isWindows || kIsWeb) return;

    final scheduleMode = await _scheduleModeForPrayerAlerts();

    // Cancel existing Adhkar notifications
    for (int dayOffset = 0; dayOffset <= 12; dayOffset++) {
      await _plugin.cancel(_calculateId(_adhkarMorningBaseId, dayOffset));
      await _plugin.cancel(_calculateId(_adhkarEveningBaseId, dayOffset));
      await _plugin.cancel(_calculateId(_adhkarSleepBaseId, dayOffset));
    }

    int dayIndex = 0;
    for (final dateEntry in multiDayTimings.entries) {
      final date = dateEntry.key;
      final timings = dateEntry.value;
      final now = tz.TZDateTime.now(tz.local);

      final androidDetails = AndroidNotificationDetails(
        _reminderChannelId,
        l10n.notificationReminders,
        importance: Importance.high,
        priority: Priority.high,
      );
      final details = NotificationDetails(android: androidDetails);

      // Morning
      if (morningEnabled) {
        final fajrTimeStr = timings['Fajr'];
        if (fajrTimeStr != null) {
          final fajrTime = _getSpecificTime(date, fajrTimeStr);
          if (fajrTime != null) {
            final morningTime = fajrTime.add(Duration(minutes: morningMinutesAfterFajr));
            if (morningTime.isAfter(now)) {
              await _zonedScheduleWithFallback(
                _calculateId(_adhkarMorningBaseId, dayIndex),
                l10n.adhkarMorningNotificationTitle,
                l10n.adhkarMorningNotificationBody,
                morningTime,
                details,
                scheduleMode,
              );
            }
          }
        }
      }

      // Evening
      if (eveningEnabled) {
        final asrTimeStr = timings['Asr'];
        if (asrTimeStr != null) {
          final asrTime = _getSpecificTime(date, asrTimeStr);
          if (asrTime != null) {
            final eveningTime = asrTime.add(Duration(minutes: eveningMinutesAfterAsr));
            if (eveningTime.isAfter(now)) {
              await _zonedScheduleWithFallback(
                _calculateId(_adhkarEveningBaseId, dayIndex),
                l10n.adhkarEveningNotificationTitle,
                l10n.adhkarEveningNotificationBody,
                eveningTime,
                details,
                scheduleMode,
              );
            }
          }
        }
      }

      // Sleep
      if (sleepEnabled) {
        final ishaTimeStr = timings['Isha'];
        if (ishaTimeStr != null) {
          final ishaTime = _getSpecificTime(date, ishaTimeStr);
          if (ishaTime != null) {
            final sleepTime = ishaTime.add(Duration(minutes: sleepMinutesAfterIsha));
            if (sleepTime.isAfter(now)) {
              await _zonedScheduleWithFallback(
                _calculateId(_adhkarSleepBaseId, dayIndex),
                l10n.adhkarSleepNotificationTitle,
                l10n.adhkarSleepNotificationBody,
                sleepTime,
                details,
                scheduleMode,
              );
            }
          }
        }
      }

      dayIndex++;
    }
  }

  Future<void> scheduleTasbeehStreakReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();
    if (Platform.isWindows || kIsWeb) return;

    final scheduleMode = await _scheduleModeForPrayerAlerts();
    await _plugin.cancel(_tasbeehStreakBaseId);

    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      l10n.notificationReminders,
      importance: Importance.high,
      priority: Priority.high,
    );

    // We can use matchDateTimeComponents to make it daily
    try {
      await _plugin.zonedSchedule(
        _tasbeehStreakBaseId,
        l10n.tasbeehStreakNotificationTitle,
        l10n.tasbeehStreakNotificationBody,
        scheduledTime,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('🔔 Tasbeeh schedule error: $e');
    }
  }

  /// Deprecated in favor of [scheduleMultipleDays]
  @Deprecated('Use scheduleMultipleDays instead')
  Future<void> scheduleDailyPrayers({
    required Map<String, String> timings,
    required Map<String, bool> enabledPrayers,
  }) async {
    final now = DateTime.now();
    await scheduleMultipleDays(
      multiDayTimings: {now: timings},
      enabledPrayers: enabledPrayers,
      preRemindersEnabled: false,
    );
  }

  /// Deprecated in favor of [scheduleMultipleDays]
  @Deprecated('Use scheduleMultipleDays instead')
  Future<void> scheduleDailyPrePrayerReminders({
    required Map<String, String> timings,
    required Map<String, bool> enabledPrayers,
    int reminderMinutes = 15,
  }) async {
    final now = DateTime.now();
    await scheduleMultipleDays(
      multiDayTimings: {now: timings},
      enabledPrayers: enabledPrayers,
      preRemindersEnabled: true,
      reminderMinutes: reminderMinutes,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Custom methods needed across the app
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> testAthan() async {
    if (!_initialized) await init();
    if (Platform.isWindows || kIsWeb) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        _adhanChannelId,
        l10n.prayerTimes,
        channelDescription: l10n.notificationAdhanDesc,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        sound: _adhanSound,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      await _plugin.show(
        999,
        l10n.notificationTestAthanTitle,
        l10n.notificationTestAthanBody,
        NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('🔔 testAthan error: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_initialized) await init();
    if (Platform.isWindows || kIsWeb) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        'test_channel',
        l10n.notificationTestNotifTitle,
        importance: Importance.high,
        priority: Priority.high,
      );
      await _plugin.show(
        998,
        l10n.notificationTestNotifTitle,
        l10n.notificationTestNotifBody,
        NotificationDetails(android: androidDetails),
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
    if (Platform.isWindows || kIsWeb) return false;
    final hasPermission = await holdsNotificationPermission();
    if (!hasPermission) return false;

    try {
      final safeBody = body.trim().isEmpty ? subtitle ?? '' : body.trim();

      final androidDetails = AndroidNotificationDetails(
        _dailyContentChannelId,
        l10n.notificationDailyContent,
        channelDescription: l10n.notificationDailyDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          safeBody,
          contentTitle: title,
          summaryText: l10n.notificationDailyVerse,
        ),
      );

      await _plugin.show(
        _dailyVerseNotificationId,
        title,
        safeBody,
        NotificationDetails(android: androidDetails),
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
    if (Platform.isWindows || kIsWeb) return false;
    final hasPermission = await holdsNotificationPermission();
    if (!hasPermission) return false;

    try {
      final safeBody = body.trim().isEmpty ? (subtitle ?? '') : body.trim();

      final androidDetails = AndroidNotificationDetails(
        _dailyContentChannelId,
        l10n.notificationDailyContent,
        channelDescription: l10n.notificationDailyDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          safeBody,
          contentTitle: title,
          summaryText: l10n.notificationDailyDhikr,
        ),
      );

      await _plugin.show(
        _dailyDhikrNotificationId,
        title,
        safeBody,
        NotificationDetails(android: androidDetails),
      );
      return true;
    } catch (e) {
      debugPrint('🔔 showDailyDhikrNotification error: $e');
      return false;
    }
  }

  Future<bool> showKhatmaReminderNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    if (Platform.isWindows || kIsWeb) return false;
    final hasPermission = await holdsNotificationPermission();
    if (!hasPermission) return false;

    try {
      final androidDetails = AndroidNotificationDetails(
        _dailyContentChannelId,
        l10n.notificationDailyContent,
        channelDescription: l10n.notificationDailyDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
      );

      await _plugin.show(
        _khatmaReminderNotificationId,
        title,
        body,
        NotificationDetails(android: androidDetails),
      );
      return true;
    } catch (e) {
      debugPrint('🔔 showKhatmaReminderNotification error: $e');
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
    if (Platform.isWindows || kIsWeb) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        'download_channel',
        l10n.notificationDownloads,
        channelDescription: l10n.notificationDownloadProgress,
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
    if (Platform.isWindows || kIsWeb) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        'download_channel',
        l10n.notificationDownloads,
        channelDescription: l10n.notificationDownloadProgress,
        importance: Importance.high,
        priority: Priority.high,
        showProgress: false, // Explicitly disable progress bar
        playSound: true,
        enableVibration: true,
      );
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('🔔 showDownloadCompleteNotification error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cancel
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    if (Platform.isWindows || kIsWeb) return;
    await _plugin.cancel(id);
    debugPrint('🔕 Cancelled notification id=$id');
  }

  Future<void> cancelAll() async {
    if (Platform.isWindows || kIsWeb) return;
    await _plugin.cancelAll();
    debugPrint('🔕 All notifications cancelled');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Parses a "HH:MM" string and returns the specific [tz.TZDateTime] for a [baseDate].
  tz.TZDateTime? _getSpecificTime(DateTime baseDate, String timeStr) {
    try {
      // Strip timezone suffix if present (e.g. "05:12 (WET)")
      final clean = timeStr.split(' ').first.trim();
      final parts = clean.split(':');
      if (parts.length < 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;

      return tz.TZDateTime(
        tz.local,
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (e) {
      debugPrint('🔔 _getSpecificTime error for "$timeStr": $e');
      return null;
    }
  }

  Future<AndroidScheduleMode> _scheduleModeForPrayerAlerts() async {
    final canUseExactAlarms = await holdsExactAlarmPermission();
    if (canUseExactAlarms) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    debugPrint(
      'Exact alarm permission missing; using inexact prayer alert schedule',
    );
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> _zonedScheduleWithFallback(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails,
    AndroidScheduleMode androidScheduleMode,
  ) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (androidScheduleMode != AndroidScheduleMode.exactAllowWhileIdle) {
        rethrow;
      }

      debugPrint(
        'Exact schedule failed for notification $id; retrying inexact: $e',
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
