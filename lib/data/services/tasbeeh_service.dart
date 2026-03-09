import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/tasbeeh_log.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';

class TasbeehService {
  static const String _boxName = 'tasbeeh_box';
  static const String _totalCountKey = 'total_tasbeeh_count';
  static const String _orderVersionKey = 'dhikr_order_version';
  static const int _currentOrderVersion = 2;

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> init() async {
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
    final savedVersion = _asInt(
      _settingsBox.get(_orderVersionKey, defaultValue: 0),
    );

    if (_box.isEmpty) {
      _seedInitialData();
      _settingsBox.put(_orderVersionKey, _currentOrderVersion);
    } else if (savedVersion < _currentOrderVersion) {
      _ensureDefaultDhikrsExist();
      _settingsBox.put(_orderVersionKey, _currentOrderVersion);
    }

    final list = _box.values.toList();

    const traditionalOrder = [
      'subhanallah',
      'alhamdulillah',
      'allahuakbar',
      'la_ilaha_illa_allah',
      'astaghfirullah',
    ];

    list.sort((a, b) {
      final indexA = traditionalOrder.indexOf(a.id);
      final indexB = traditionalOrder.indexOf(b.id);

      if (indexA == -1 && indexB == -1) {
        return a.id.compareTo(b.id);
      }
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;

      return indexA.compareTo(indexB);
    });

    return list;
  }

  List<TasbeehModel> _defaultDhikrs() {
    return [
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
  }

  void _ensureDefaultDhikrsExist() {
    for (final dhikr in _defaultDhikrs()) {
      if (!_box.containsKey(dhikr.id)) {
        _box.put(dhikr.id, dhikr);
      }
    }
  }

  void _seedInitialData() {
    for (final dhikr in _defaultDhikrs()) {
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
      final log = TasbeehLog(
        dhikrId: dhikrId,
        date: date,
        hour: hour,
        count: count ?? 1,
        timestamp: now,
      );
      await _historyBox.add(log);
      return;
    }

    final logKey =
        '${dhikrId}_${now.year}${now.month.pad}${now.day.pad}_${hour.pad}';
    final existing = _historyBox.get(logKey);
    if (existing == null) {
      final log = TasbeehLog(
        dhikrId: dhikrId,
        date: date,
        hour: hour,
        count: count ?? 1,
        timestamp: now,
      );
      await _historyBox.put(logKey, log);
      return;
    }

    existing.count += count ?? 1;
    await existing.save();
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
    for (final log in logs) {
      stats[log.dhikrId] = (stats[log.dhikrId] ?? 0) + log.count;
    }
    return stats;
  }

  Map<int, int> getHourlyStatsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final logs = _historyBox.values.where((log) => log.date == startOfDay);

    final stats = <int, int>{};
    for (final log in logs) {
      stats[log.hour] = (stats[log.hour] ?? 0) + log.count;
    }
    return stats;
  }

  int getTotalCount() {
    return _asInt(_settingsBox.get(_totalCountKey, defaultValue: 0));
  }

  Future<void> incrementTotalCount() async {
    final current = getTotalCount();
    await _settingsBox.put(_totalCountKey, current + 1);
  }

  Future<void> resetTotalCount() async {
    await _settingsBox.put(_totalCountKey, 0);
  }

  Map<DateTime, int> getWeeklyTotals({int days = 7}) {
    final result = <DateTime, int>{};
    for (var i = 0; i < days; i++) {
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

  int getCurrentStreak() {
    var streak = 0;
    final today = DateTime.now();
    for (var i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final hasTasbeeh = _historyBox.values.any(
        (log) => log.date.isAtSameMomentAs(startOfDay),
      );
      if (!hasTasbeeh) break;
      streak++;
    }
    return streak;
  }
}

extension on int {
  String get pad => toString().padLeft(2, '0');
}
