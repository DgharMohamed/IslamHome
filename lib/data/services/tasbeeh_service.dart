import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/data/models/tasbeeh_log.dart';

class TasbeehService {
  static const String _boxName = 'tasbeeh_box';
  static const String _totalCountKey = 'total_tasbeeh_count';

  Future<void> init() async {
    // Adapter registration moved to main.dart for earlier initialization,
    // but kept here as a safeguard during service instantiation.
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(TasbeehModelAdapter());
    }
  }

  Box<TasbeehModel> get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw HiveError(
        'Box not found: $_boxName. Ensure it is opened in main.dart',
      );
    }
    return Hive.box<TasbeehModel>(_boxName);
  }

  Box get _settingsBox {
    if (!Hive.isBoxOpen('settings_box')) {
      throw HiveError(
        'Box not found: settings_box. Ensure it is opened in main.dart',
      );
    }
    return Hive.box('settings_box');
  }

  Box<TasbeehLog> get _historyBox {
    if (!Hive.isBoxOpen('tasbeeh_history_box')) {
      throw HiveError(
        'Box not found: tasbeeh_history_box. Ensure it is opened in main.dart',
      );
    }
    return Hive.box<TasbeehLog>('tasbeeh_history_box');
  }

  List<TasbeehModel> getDhikrList() {
    // Migration: Check if we need to re-seed data to the traditional order
    const String orderVersionKey = 'dhikr_order_version';
    const int currentOrderVersion = 2; // Incremented for traditional order
    final savedVersion = _settingsBox.get(orderVersionKey, defaultValue: 0);

    if (_box.isEmpty || savedVersion < currentOrderVersion) {
      _seedInitialData();
      _settingsBox.put(orderVersionKey, currentOrderVersion);
    }

    final list = _box.values.toList();

    // Define the desired traditional order
    final traditionalOrder = [
      'subhanallah',
      'alhamdulillah',
      'allahuakbar',
      'la_ilaha_illa_allah',
      'astaghfirullah',
    ];

    // Sort the list based on the traditionalOrder
    list.sort((a, b) {
      final indexA = traditionalOrder.indexOf(a.id);
      final indexB = traditionalOrder.indexOf(b.id);

      // If an ID is not in the list (user added custom), put it at the end
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;

      return indexA.compareTo(indexB);
    });

    return list;
  }

  void _seedInitialData() {
    final initialDhikrs = [
      TasbeehModel(
        id: 'subhanallah',
        text: 'Subhan Allah',
        arabicText: 'سبحان الله',
      ),
      TasbeehModel(
        id: 'alhamdulillah',
        text: 'Alhamdulillah',
        arabicText: 'الحمد لله',
      ),
      TasbeehModel(
        id: 'allahuakbar',
        text: 'Allahu Akbar',
        arabicText: 'الله أكبر',
      ),
      TasbeehModel(
        id: 'la_ilaha_illa_allah',
        text: 'La ilaha illa Allah',
        arabicText: 'لا إله إلا الله',
      ),
      TasbeehModel(
        id: 'astaghfirullah',
        text: 'Astaghfirullah',
        arabicText: 'أستغفر الله',
      ),
    ];

    // Clear the box before re-seeding to ensure the new order is respected
    _box.clear();

    for (var dhikr in initialDhikrs) {
      _box.put(dhikr.id, dhikr);
    }
  }

  Future<void> updateDhikr(TasbeehModel dhikr) async {
    await _box.put(dhikr.id, dhikr);
  }

  Future<void> logIncrement(
    String dhikrId, {
    int? count,
    bool isSetComplete = false,
  }) async {
    final now = DateTime.now();
    final hour = now.hour;
    final date = DateTime(now.year, now.month, now.day);

    if (isSetComplete) {
      // For completed sets, always create a new entry
      final log = TasbeehLog(
        dhikrId: dhikrId,
        date: date,
        hour: hour,
        count: count ?? 1,
        timestamp: now,
      );
      await _historyBox.add(log);
    } else {
      // For individual increments, we could still aggregate or just log them.
      // To fulfill "every tasbeeha", let's aggregate for hourly stats but
      // maybe log as unique if needed.
      // Let's stick to aggregating by hour for stats, but we'll add a way to
      // log specific "completed sets" or "milestones".

      final logKey =
          '${dhikrId}_${now.year}${now.month.pad}${now.day.pad}_${hour.pad}';
      var log = _historyBox.get(logKey);
      if (log == null) {
        log = TasbeehLog(
          dhikrId: dhikrId,
          date: date,
          hour: hour,
          count: 1,
          timestamp: now,
        );
        await _historyBox.put(logKey, log);
      } else {
        log.count += 1;
        await log.save();
      }
    }
  }

  List<TasbeehLog> getAllLogsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    return _historyBox.values
        .where((log) => log.date.isAtSameMomentAs(startOfDay))
        .toList()
      ..sort(
        (a, b) => (b.timestamp ?? b.date).compareTo(a.timestamp ?? a.date),
      );
  }

  List<TasbeehLog> getHistoryForDhikr(String dhikrId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return _historyBox.values
        .where((log) => log.dhikrId == dhikrId && log.date == startOfDay)
        .toList();
  }

  Map<String, int> getDailyStats(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final logs = _historyBox.values.where((log) => log.date == startOfDay);

    final stats = <String, int>{};
    for (var log in logs) {
      stats[log.dhikrId] = (stats[log.dhikrId] ?? 0) + log.count;
    }
    return stats;
  }

  Map<int, int> getHourlyStatsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final logs = _historyBox.values.where((log) => log.date == startOfDay);

    final stats = <int, int>{};
    for (var log in logs) {
      stats[log.hour] = (stats[log.hour] ?? 0) + log.count;
    }
    return stats;
  }

  int getTotalCount() {
    return _settingsBox.get(_totalCountKey, defaultValue: 0);
  }

  Future<void> incrementTotalCount() async {
    final current = getTotalCount();
    await _settingsBox.put(_totalCountKey, current + 1);
  }

  Future<void> resetTotalCount() async {
    await _settingsBox.put(_totalCountKey, 0);
  }

  /// Returns total taps per day for the past [days] days (including today).
  Map<DateTime, int> getWeeklyTotals({int days = 7}) {
    final result = <DateTime, int>{};
    for (int i = 0; i < days; i++) {
      final day = DateTime.now().subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final logs = _historyBox.values.where(
        (log) => log.date.isAtSameMomentAs(startOfDay),
      );
      final total = logs.fold<int>(0, (sum, log) => sum + log.count);
      result[startOfDay] = total;
    }
    return result;
  }

  /// Returns consecutive days (up to today) with at least 1 tasbeeha.
  int getCurrentStreak() {
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final hasTasbeeh = _historyBox.values.any(
        (log) => log.date.isAtSameMomentAs(startOfDay),
      );
      if (hasTasbeeh) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

extension on int {
  String get pad => toString().padLeft(2, '0');
}
