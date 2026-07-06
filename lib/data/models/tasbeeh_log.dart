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

  Map<String, dynamic> toJson() => {
    'dhikrId': dhikrId,
    'date': date.toIso8601String(),
    'hour': hour,
    'count': count,
    'timestamp': timestamp?.toIso8601String(),
  };

  factory TasbeehLog.fromJson(Map<String, dynamic> json) => TasbeehLog(
    dhikrId: json['dhikrId'],
    date: DateTime.parse(json['date']),
    hour: json['hour'],
    count: json['count'] ?? 0,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : null,
  );
}
