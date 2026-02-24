import 'package:hive/hive.dart';

part 'tasbeeh_log.g.dart';

@HiveType(typeId: 16)
class TasbeehLog extends HiveObject {
  @HiveField(0)
  final String dhikrId;

  @HiveField(1)
  final DateTime date; // Keep for daily filtering

  @HiveField(2)
  final int hour; // Keep for hourly stats

  @HiveField(3)
  int count;

  @HiveField(4)
  final DateTime? timestamp;

  TasbeehLog({
    required this.dhikrId,
    required this.date,
    required this.hour,
    this.count = 0,
    this.timestamp,
  });

  @override
  String get key =>
      '${dhikrId}_${timestamp?.millisecondsSinceEpoch ?? (date.millisecondsSinceEpoch + hour)}';
}
