import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/tasbeeh_provider.dart';
import 'package:islam_home/data/models/tasbeeh_log.dart';

final tasbeehHistoryStatsProvider = Provider.family<Map<String, int>, DateTime>(
  (ref, date) {
    final service = ref.watch(tasbeehServiceProvider);
    return service.getDailyStats(date);
  },
);

final tasbeehHourlyStatsProvider = Provider.family<Map<int, int>, DateTime>((
  ref,
  date,
) {
  final service = ref.watch(tasbeehServiceProvider);
  return service.getHourlyStatsForDay(date);
});

class SelectedHistoryDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

final selectedHistoryDateProvider =
    NotifierProvider<SelectedHistoryDateNotifier, DateTime>(
      SelectedHistoryDateNotifier.new,
    );

final tasbeehDetailedLogsProvider = Provider.family<List<TasbeehLog>, DateTime>(
  (ref, date) {
    final service = ref.watch(tasbeehServiceProvider);
    return service.getAllLogsForDay(date);
  },
);

final tasbeehWeeklyStatsProvider = Provider<Map<DateTime, int>>((ref) {
  final service = ref.watch(tasbeehServiceProvider);
  return service.getWeeklyTotals();
});

final tasbeehStreakProvider = Provider<int>((ref) {
  final service = ref.watch(tasbeehServiceProvider);
  return service.getCurrentStreak();
});
