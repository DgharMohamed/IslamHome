import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AdhkarSettingsState {
  final bool morningEnabled;
  final int morningMinutesAfterFajr;
  final bool eveningEnabled;
  final int eveningMinutesAfterAsr;
  final bool sleepEnabled;
  final int sleepMinutesAfterIsha;
  final bool tasbeehReminderEnabled;
  final int tasbeehReminderHour;
  final int tasbeehReminderMinute;

  AdhkarSettingsState({
    required this.morningEnabled,
    required this.morningMinutesAfterFajr,
    required this.eveningEnabled,
    required this.eveningMinutesAfterAsr,
    required this.sleepEnabled,
    required this.sleepMinutesAfterIsha,
    required this.tasbeehReminderEnabled,
    required this.tasbeehReminderHour,
    required this.tasbeehReminderMinute,
  });

  AdhkarSettingsState copyWith({
    bool? morningEnabled,
    int? morningMinutesAfterFajr,
    bool? eveningEnabled,
    int? eveningMinutesAfterAsr,
    bool? sleepEnabled,
    int? sleepMinutesAfterIsha,
    bool? tasbeehReminderEnabled,
    int? tasbeehReminderHour,
    int? tasbeehReminderMinute,
  }) {
    return AdhkarSettingsState(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      morningMinutesAfterFajr: morningMinutesAfterFajr ?? this.morningMinutesAfterFajr,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      eveningMinutesAfterAsr: eveningMinutesAfterAsr ?? this.eveningMinutesAfterAsr,
      sleepEnabled: sleepEnabled ?? this.sleepEnabled,
      sleepMinutesAfterIsha: sleepMinutesAfterIsha ?? this.sleepMinutesAfterIsha,
      tasbeehReminderEnabled: tasbeehReminderEnabled ?? this.tasbeehReminderEnabled,
      tasbeehReminderHour: tasbeehReminderHour ?? this.tasbeehReminderHour,
      tasbeehReminderMinute: tasbeehReminderMinute ?? this.tasbeehReminderMinute,
    );
  }
}

class AdhkarSettingsNotifier extends Notifier<AdhkarSettingsState> {
  static const String _boxName = 'settings_box';

  Box get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError('Box $_boxName is not open');
    }
    return Hive.box(_boxName);
  }

  @override
  AdhkarSettingsState build() {
    return AdhkarSettingsState(
      morningEnabled: _box.get('adhkar_morning_enabled', defaultValue: true),
      morningMinutesAfterFajr: _box.get('adhkar_morning_offset', defaultValue: 30),
      eveningEnabled: _box.get('adhkar_evening_enabled', defaultValue: true),
      eveningMinutesAfterAsr: _box.get('adhkar_evening_offset', defaultValue: 30),
      sleepEnabled: _box.get('adhkar_sleep_enabled', defaultValue: true),
      sleepMinutesAfterIsha: _box.get('adhkar_sleep_offset', defaultValue: 120),
      tasbeehReminderEnabled: _box.get('tasbeeh_reminder_enabled', defaultValue: true),
      tasbeehReminderHour: _box.get('tasbeeh_reminder_hour', defaultValue: 20),
      tasbeehReminderMinute: _box.get('tasbeeh_reminder_minute', defaultValue: 0),
    );
  }

  Future<void> updateSettings({
    bool? morningEnabled,
    int? morningMinutesAfterFajr,
    bool? eveningEnabled,
    int? eveningMinutesAfterAsr,
    bool? sleepEnabled,
    int? sleepMinutesAfterIsha,
    bool? tasbeehReminderEnabled,
    int? tasbeehReminderHour,
    int? tasbeehReminderMinute,
  }) async {
    if (morningEnabled != null) await _box.put('adhkar_morning_enabled', morningEnabled);
    if (morningMinutesAfterFajr != null) await _box.put('adhkar_morning_offset', morningMinutesAfterFajr);
    
    if (eveningEnabled != null) await _box.put('adhkar_evening_enabled', eveningEnabled);
    if (eveningMinutesAfterAsr != null) await _box.put('adhkar_evening_offset', eveningMinutesAfterAsr);
    
    if (sleepEnabled != null) await _box.put('adhkar_sleep_enabled', sleepEnabled);
    if (sleepMinutesAfterIsha != null) await _box.put('adhkar_sleep_offset', sleepMinutesAfterIsha);
    
    if (tasbeehReminderEnabled != null) await _box.put('tasbeeh_reminder_enabled', tasbeehReminderEnabled);
    if (tasbeehReminderHour != null) await _box.put('tasbeeh_reminder_hour', tasbeehReminderHour);
    if (tasbeehReminderMinute != null) await _box.put('tasbeeh_reminder_minute', tasbeehReminderMinute);

    state = state.copyWith(
      morningEnabled: morningEnabled,
      morningMinutesAfterFajr: morningMinutesAfterFajr,
      eveningEnabled: eveningEnabled,
      eveningMinutesAfterAsr: eveningMinutesAfterAsr,
      sleepEnabled: sleepEnabled,
      sleepMinutesAfterIsha: sleepMinutesAfterIsha,
      tasbeehReminderEnabled: tasbeehReminderEnabled,
      tasbeehReminderHour: tasbeehReminderHour,
      tasbeehReminderMinute: tasbeehReminderMinute,
    );
  }
}

final adhkarSettingsProvider =
    NotifierProvider<AdhkarSettingsNotifier, AdhkarSettingsState>(
  AdhkarSettingsNotifier.new,
);
