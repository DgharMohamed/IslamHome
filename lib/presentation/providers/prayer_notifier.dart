import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:islam_home/data/models/prayer_time.dart';
import 'package:islam_home/data/models/prayer_times_model.dart';
import 'package:islam_home/data/services/api_service.dart';
import 'package:islam_home/data/services/offline_prayer_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/presentation/providers/location_provider.dart';
import 'package:islam_home/data/services/notification_service.dart';

class PrayerState {
  final AsyncValue<DailyPrayerTimes?> timings;
  final String city;
  final String country;
  final String? habousId;
  final bool useGPS;
  final int calculationMethodId;

  PrayerState({
    required this.timings,
    required this.city,
    required this.country,
    this.habousId,
    this.useGPS = false,
    this.calculationMethodId = 3,
  });

  PrayerState copyWith({
    AsyncValue<DailyPrayerTimes?>? timings,
    String? city,
    String? country,
    String? habousId,
    bool? useGPS,
    int? calculationMethodId,
  }) {
    return PrayerState(
      timings: timings ?? this.timings,
      city: city ?? this.city,
      country: country ?? this.country,
      habousId: habousId ?? this.habousId,
      useGPS: useGPS ?? this.useGPS,
      calculationMethodId: calculationMethodId ?? this.calculationMethodId,
    );
  }
}

class PrayerNotifier extends Notifier<PrayerState> {
  final ApiService _apiService = ApiService();
  final OfflinePrayerService _offlineService = OfflinePrayerService();

  @override
  PrayerState build() {
    final box = Hive.box('settings');
    final city = box.get('prayer_city', defaultValue: 'Rabat');
    final country = box.get('prayer_country', defaultValue: 'Morocco');
    final habousId = box.get('prayer_habous_id', defaultValue: '1');
    final useGPS = box.get('prayer_use_gps', defaultValue: false);
    final methodId = box.get('prayer_calculation_method', defaultValue: 3);

    // Load initial data
    Future.microtask(() => refresh());

    // Listen to location updates
    ref.listen(locationProvider, (previous, next) {
      if (next.gpsCoordinates != previous?.gpsCoordinates ||
          next.city != previous?.city ||
          next.country != previous?.country ||
          next.useGPS != previous?.useGPS) {
        debugPrint(
          '📍 PrayerNotifier: Location changed, refreshing prayer times...',
        );

        // Sync local state before refreshing
        state = state.copyWith(
          city: next.city,
          country: next.country,
          useGPS: next.useGPS,
        );

        refresh();
      }
    });

    return PrayerState(
      timings: const AsyncValue.loading(),
      city: city,
      country: country,
      habousId: habousId,
      useGPS: useGPS,
      calculationMethodId: methodId,
    );
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    state = state.copyWith(timings: const AsyncValue.loading());

    try {
      DailyPrayerTimes? times;

      // 1. Primary source: Aladhan API (via ApiService)
      try {
        PrayerTimesModel? result;
        final box = Hive.box('settings');
        final method = state.calculationMethodId;

        if (state.useGPS) {
          final coordsStr = box.get('prayer_coords'); // stored as "lat,long"
          if (coordsStr != null &&
              coordsStr is String &&
              coordsStr.contains(',')) {
            final parts = coordsStr.split(',');
            final lat = double.tryParse(parts[0]);
            final lng = double.tryParse(parts[1]);
            if (lat != null && lng != null) {
              result = await _apiService.getPrayerTimesByLocation(
                lat,
                lng,
                method: method,
              );
              debugPrint('📍 Fetching prayer times via GPS: $lat, $lng');
            }
          }
        }

        // If GPS failed or not enabled, fallback to City
        if (result == null) {
          debugPrint('🏙️ Fetching prayer times via City: ${state.city}');
          result = await _apiService.getPrayerTimesByCity(
            state.city,
            state.country,
            method: method,
          );
        }

        if (result != null && result.timings != null) {
          times = DailyPrayerTimes(
            timings: result.timings!,
            // Fix: accessing date directly from the flat Map structure we created
            date: result.date?.gregorian?.date ?? '',
            hijriDate: result.date?.hijri?.date ?? '',
            dayName: result.date?.gregorian?.day ?? '',
            cityName: state.useGPS ? 'GPS Location' : state.city,
          );
          // Cache the result in Hive for offline use
          await _cacheTimings(times);
          debugPrint('🕌 Prayer times loaded from API');
        }
      } catch (e) {
        debugPrint('🕌 API failed: $e');
      }

      // 2. Fallback: Last cached result from Hive
      if (times == null) {
        times = _getCachedTimings();
        if (times != null) {
          debugPrint('🕌 Prayer times loaded from cache');
        }
      }

      // 3. Final fallback: Offline calculation using adhan package
      if (times == null) {
        final box = Hive.box('settings');
        final lat = box.get('prayer_lat', defaultValue: 34.0209);
        final lng = box.get('prayer_lng', defaultValue: -6.8416);
        final offlineResult = _offlineService.calculatePrayerTimes(
          latitude: (lat as num).toDouble(),
          longitude: (lng as num).toDouble(),
        );
        if (offlineResult.timings != null) {
          times = DailyPrayerTimes(
            timings: offlineResult.timings!,
            date: offlineResult.date?.gregorian?.date ?? '',
            hijriDate: offlineResult.date?.hijri?.date ?? '',
            dayName: offlineResult.date?.gregorian?.day ?? '',
            cityName: state.city,
          );
          debugPrint('🕌 Prayer times calculated offline');
        }
      }

      // 4. Apply manual offset if exists
      if (times != null) {
        final box = Hive.box('settings');
        final offsetMinutes =
            box.get('prayer_adjustment_minutes', defaultValue: 0) as int;

        if (offsetMinutes != 0) {
          Map<String, String> adjustedTimings = Map.from(times.timings);
          adjustedTimings.forEach((key, value) {
            try {
              final parts = value.split(':');
              if (parts.length == 2) {
                int h = int.parse(parts[0]);
                int m = int.parse(parts[1]);

                final dateTime = DateTime(
                  2000,
                  1,
                  1,
                  h,
                  m,
                ).add(Duration(minutes: offsetMinutes));
                adjustedTimings[key] =
                    '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
              }
            } catch (e) {
              debugPrint('Error adjusting timing $key: $e');
            }
          });

          times = DailyPrayerTimes(
            timings: adjustedTimings,
            date: times.date,
            hijriDate: times.hijriDate,
            dayName: times.dayName,
            cityName: times.cityName,
          );
          debugPrint('🕒 Applied manual offset: $offsetMinutes minutes');
        }
      }

      state = state.copyWith(timings: AsyncValue.data(times));

      // Reschedule Adhan notifications if times are available
      if (times != null) {
        _updateAthanSchedules(times);
      }
    } catch (e, st) {
      state = state.copyWith(timings: AsyncValue.error(e, st));
    }
  }

  Future<void> updateAdjustment(int minutes) async {
    final box = Hive.box('settings');
    await box.put('prayer_adjustment_minutes', minutes);
    debugPrint('🔄 Manual adjustment updated to $minutes minutes');
    await refresh();
  }

  /// Cache prayer times in Hive for offline access.
  Future<void> _cacheTimings(DailyPrayerTimes times) async {
    try {
      final box = Hive.box('prayer_times_cache');
      await box.put('last_timings', times.timings);
      await box.put('last_date', times.date);
      await box.put('last_hijri_date', times.hijriDate);
      await box.put('last_day_name', times.dayName);
      await box.put('last_city_name', times.cityName);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('❌ Failed to cache prayer times: $e');
    }
  }

  /// Retrieve cached prayer times from Hive.
  DailyPrayerTimes? _getCachedTimings() {
    try {
      final box = Hive.box('prayer_times_cache');
      final timings = box.get('last_timings');
      if (timings == null) return null;

      return DailyPrayerTimes(
        timings: Map<String, String>.from(timings),
        date: box.get('last_date', defaultValue: ''),
        hijriDate: box.get('last_hijri_date', defaultValue: ''),
        dayName: box.get('last_day_name', defaultValue: ''),
        cityName: box.get('last_city_name', defaultValue: ''),
      );
    } catch (e) {
      debugPrint('❌ Failed to read cached prayer times: $e');
      return null;
    }
  }

  Future<void> updateLocation({
    required String city,
    required String country,
    String? habousId,
    double? latitude,
    double? longitude,
  }) async {
    final box = Hive.box('settings');
    await box.put('prayer_city', city);
    await box.put('prayer_country', country);
    if (habousId != null) await box.put('prayer_habous_id', habousId);
    if (latitude != null) await box.put('prayer_lat', latitude);
    if (longitude != null) await box.put('prayer_lng', longitude);

    state = state.copyWith(
      city: city,
      country: country,
      habousId: habousId,
      useGPS: false,
    );

    await refresh();
  }

  Future<void> _updateAthanSchedules(DailyPrayerTimes times) async {
    final box = Hive.box('settings');
    final isAthanEnabled = box.get('athan_global_enabled', defaultValue: true);

    if (!isAthanEnabled) {
      // If globally disabled, cancel prayer notifications
      // Fajr: 100, Dhuhr: 101, Asr: 102, Maghrib: 103, Isha: 104
      for (int id in [100, 101, 102, 103, 104]) {
        await NotificationService().cancelNotification(id);
      }
      return;
    }

    // Check for exact alarm permission on Android
    final hasPermission = await NotificationService()
        .holdsExactAlarmPermission();
    if (!hasPermission) {
      debugPrint('⚠️ Exact alarm permission missing, cannot schedule Adhan');
      // We don't request here to avoid multiple popups, but logs will show why it failed
      return;
    }

    // Load per-prayer enabled state
    final enabledPrayers = {
      'Fajr': box.get('athan_enabled_Fajr', defaultValue: true),
      'Dhuhr': box.get('athan_enabled_Dhuhr', defaultValue: true),
      'Asr': box.get('athan_enabled_Asr', defaultValue: true),
      'Maghrib': box.get('athan_enabled_Maghrib', defaultValue: true),
      'Isha': box.get('athan_enabled_Isha', defaultValue: true),
    };

    await NotificationService().scheduleDailyPrayers(
      timings: times.timings,
      enabledPrayers: Map<String, bool>.from(enabledPrayers),
    );

    // Schedule pre-prayer reminders if enabled
    final isPreReminderEnabled = box.get(
      'athan_pre_reminders_enabled',
      defaultValue: false,
    );
    if (isPreReminderEnabled) {
      final reminderMinutes =
          box.get('athan_reminder_minutes', defaultValue: 15) as int;
      await NotificationService().scheduleDailyPrePrayerReminders(
        timings: times.timings,
        enabledPrayers: Map<String, bool>.from(enabledPrayers),
        reminderMinutes: reminderMinutes,
      );
      debugPrint(
        '🔔 PrayerNotifier: Pre-prayer reminders scheduled ($reminderMinutes min)',
      );
    } else {
      // Cancel reminder notifications if disabled
      for (int id in [200, 201, 202, 203, 204]) {
        await NotificationService().cancelNotification(id);
      }
    }

    debugPrint('🔔 PrayerNotifier: Adhan schedules updated');
  }

  Future<void> updateCalculationMethod(int methodId) async {
    final box = Hive.box('settings');
    await box.put('prayer_calculation_method', methodId);
    state = state.copyWith(calculationMethodId: methodId);
    debugPrint('🔄 Calculation method updated to $methodId');
    await refresh();
  }

  Future<void> toggleAthan(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService().requestExactAlarmPermission();
      if (!granted) {
        debugPrint('🚫 Exact alarm permission not granted');
        // We still save the preference, but it might not work until permission is granted
      }
    }
    await Hive.box('settings').put('athan_global_enabled', enabled);
    refresh();
  }

  Future<void> togglePrayerAthan(String prayerName, bool enabled) async {
    await Hive.box('settings').put('athan_enabled_$prayerName', enabled);
    refresh();
  }

  Future<void> togglePreAthanReminders(bool enabled) async {
    await Hive.box('settings').put('athan_pre_reminders_enabled', enabled);
    refresh();
  }

  Future<void> setReminderMinutes(int minutes) async {
    await Hive.box('settings').put('athan_reminder_minutes', minutes);
    // Re-schedule with the new timing if reminders are active
    final isEnabled =
        Hive.box(
              'settings',
            ).get('athan_pre_reminders_enabled', defaultValue: false)
            as bool;
    if (isEnabled) refresh();
  }
}

final prayerNotifierProvider = NotifierProvider<PrayerNotifier, PrayerState>(
  () {
    return PrayerNotifier();
  },
);
