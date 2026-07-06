import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:islam_home/data/services/notification_service.dart';
import 'package:islam_home/data/services/offline_prayer_service.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';

/// The unique task name for the periodic Adhan reschedule job.
const String kAdhanRescheduleTaskName = 'adhan_reschedule_task';

const String kAdhanRescheduleOneshotName = 'adhan_reschedule_oneshot';

/// Applies a minute offset to all prayer time strings in a timings map.
Map<String, String> _applyOffset(
  Map<String, String> timings,
  int offsetMinutes,
) {
  final Map<String, String> adjusted = Map.from(timings);
  adjusted.forEach((key, value) {
    try {
      final parts = value.split(':');
      if (parts.length == 2) {
        final int h = int.parse(parts[0]);
        final int m = int.parse(parts[1]);
        final dateTime = DateTime(
          2000,
          1,
          1,
          h,
          m,
        ).add(Duration(minutes: offsetMinutes));
        adjusted[key] =
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      debugPrint('Error adjusting timing $key: $e');
    }
  });
  return adjusted;
}

/// Top-level callback required by workmanager.
/// This runs in an ISOLATED background isolate — no BuildContext, no providers.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('🔄 BackgroundWorker: task "$taskName" started');

    try {
      // Initialize Hive without Flutter binding (background isolate)
      await Hive.initFlutter();

      // Open the settings boxes we need to read prayer configuration
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }

      final box = Hive.box('settings');

      // Check if Adhan is globally enabled — if not, nothing to schedule
      final isAthanEnabled = box.get(
        'athan_global_enabled',
        defaultValue: true,
      );
      if (!isAthanEnabled) {
        debugPrint('🔄 BackgroundWorker: Adhan disabled, skipping reschedule');
        return true;
      }

      // Read location from saved settings
      final lat = (box.get('prayer_lat', defaultValue: 34.0209) as num)
          .toDouble();
      final lng = (box.get('prayer_lng', defaultValue: -6.8416) as num)
          .toDouble();

      // Read per-prayer enabled states
      final enabledPrayers = <String, bool>{
        'Fajr': box.get('athan_enabled_Fajr', defaultValue: true) as bool,
        'Dhuhr': box.get('athan_enabled_Dhuhr', defaultValue: true) as bool,
        'Asr': box.get('athan_enabled_Asr', defaultValue: true) as bool,
        'Maghrib': box.get('athan_enabled_Maghrib', defaultValue: true) as bool,
        'Isha': box.get('athan_enabled_Isha', defaultValue: true) as bool,
      };

      final methodId =
          box.get('prayer_calculation_method', defaultValue: 3) as int;
      final offsetMinutes =
          box.get('prayer_adjustment_minutes', defaultValue: 0) as int;

      final isPreReminderEnabled =
          box.get('athan_pre_reminders_enabled', defaultValue: false) as bool;
      final reminderMinutes =
          box.get('athan_reminder_minutes', defaultValue: 15) as int;

      // Calculate prayer times for the next 10 days offline
      final offlineService = OfflinePrayerService();
      final Map<DateTime, Map<String, String>> multiDayTimings = {};

      for (int i = 0; i < 10; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final result = offlineService.calculatePrayerTimes(
          latitude: lat,
          longitude: lng,
          date: date,
          methodId: methodId,
        );
        if (result.timings != null) {
          if (offsetMinutes != 0) {
            multiDayTimings[date] = _applyOffset(
              result.timings!,
              offsetMinutes,
            );
          } else {
            multiDayTimings[date] = result.timings!;
          }
        }
      }

      // Initialize notification service and reschedule
      final notifService = NotificationService();
      await notifService.init();
      await notifService.scheduleMultipleDays(
        multiDayTimings: multiDayTimings,
        enabledPrayers: enabledPrayers,
        preRemindersEnabled: isPreReminderEnabled,
        reminderMinutes: reminderMinutes,
      );

      debugPrint(
        '🔄 BackgroundWorker: Rescheduled Adhan for ${multiDayTimings.length} days',
      );

      // --- Khatma Daily Reminder Logic ---
      try {
        if (!Hive.isAdapterRegistered(20)) {
          Hive.registerAdapter(KhatmaTypeAdapter());
        }
        if (!Hive.isAdapterRegistered(21)) {
          Hive.registerAdapter(SchedulingModeAdapter());
        }
        if (!Hive.isAdapterRegistered(22)) {
          Hive.registerAdapter(RemediationStrategyAdapter());
        }
        if (!Hive.isAdapterRegistered(23)) {
          Hive.registerAdapter(KhatmaTrackAdapter());
        }
        if (!Hive.isAdapterRegistered(24)) {
          Hive.registerAdapter(KhatmaUnitAdapter());
        }

        if (!Hive.isBoxOpen('khatma_tracks_box')) {
          await Hive.openBox<KhatmaTrack>('khatma_tracks_box');
        }
        final khatmaBox = Hive.box<KhatmaTrack>('khatma_tracks_box');
        final activeTracks = khatmaBox.values
            .where((t) => t.overallProgress < 1.0)
            .toList();

        if (activeTracks.isNotEmpty) {
          // If the user has active tracks, send a daily reminder
          await notifService.showKhatmaReminderNotification(
            title: notifService.l10n.notificationKhatmaTitle,
            body: notifService.l10n.notificationKhatmaBody,
          );
          debugPrint('🔄 BackgroundWorker: Shown Khatma reminder');
        }
      } catch (khatmaError, st) {
        debugPrint('🔴 BackgroundWorker Khatma Error: $khatmaError\n$st');
      }

      return true;
    } catch (e, st) {
      debugPrint('🔴 BackgroundWorker error: $e\n$st');
      return false;
    }
  });
}

/// Helper to register the periodic Adhan reschedule background task.
/// Call this once from [main] after Workmanager is initialized.
Future<void> registerAdhanBackgroundTask() async {
  if (!Platform.isAndroid) return;
  try {
    // Register a periodic task that fires approximately every 24 hours.
    // workmanager uses a minimum interval of 15 minutes on Android,
    // but we request 24h which Android WorkManager will respect as a constraint.
    await Workmanager().registerPeriodicTask(
      kAdhanRescheduleTaskName,
      kAdhanRescheduleTaskName,
      frequency: const Duration(hours: 24),
      // Keep alive after reboot
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 30),
    );
    debugPrint('🔄 BackgroundWorker: Periodic task registered (24h interval)');
  } catch (e) {
    debugPrint('🔴 BackgroundWorker: Failed to register periodic task: $e');
  }
}
