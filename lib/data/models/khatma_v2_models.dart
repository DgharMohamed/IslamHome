import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'khatma_v2_models.g.dart';

@HiveType(typeId: 20)
enum KhatmaType {
  @HiveField(0)
  reading,
  @HiveField(1)
  memorization,
  @HiveField(2)
  revision,
  @HiveField(3)
  listening,
}

@HiveType(typeId: 24)
enum KhatmaUnit {
  @HiveField(0)
  page,
  @HiveField(1)
  juz,
  @HiveField(2)
  surah,
}

@HiveType(typeId: 21)
enum SchedulingMode {
  @HiveField(0)
  fixedDaily,
  @HiveField(1)
  smartRemediation,
}

@HiveType(typeId: 22)
enum RemediationStrategy {
  @HiveField(0)
  distribute,
  @HiveField(1)
  catchUp,
  @HiveField(2)
  extend,
}

@HiveType(typeId: 23)
@JsonSerializable()
class KhatmaTrack extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final KhatmaType type;

  @HiveField(3)
  final SchedulingMode schedulingMode;

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime? targetDate;

  @HiveField(6)
  final int startPage;

  @HiveField(7)
  final int endPage;

  @HiveField(8)
  int currentPage;

  @HiveField(11)
  final KhatmaUnit? unitOrNull;

  /// Effective tracking unit — defaults to page for backward-compat with old data.
  KhatmaUnit get unit => unitOrNull ?? KhatmaUnit.page;

  @HiveField(9)
  final Map<String, int> progress; // Date (yyyy-MM-dd) -> Units read that day

  @HiveField(10)
  final List<String> remediationLog;

  KhatmaTrack({
    required this.id,
    required this.title,
    required this.type,
    required this.schedulingMode,
    required this.startDate,
    this.targetDate,
    this.startPage = 1,
    this.endPage = 604,
    this.currentPage = 1,
    KhatmaUnit unit = KhatmaUnit.page,
    this.progress = const {},
    this.remediationLog = const [],
  }) : unitOrNull = unit;

  factory KhatmaTrack.fromJson(Map<String, dynamic> json) =>
      _$KhatmaTrackFromJson(json);
  Map<String, dynamic> toJson() => _$KhatmaTrackToJson(this);

  KhatmaTrack copyWith({
    String? id,
    String? title,
    KhatmaType? type,
    SchedulingMode? schedulingMode,
    DateTime? startDate,
    DateTime? targetDate,
    int? startPage,
    int? endPage,
    int? currentPage,
    KhatmaUnit? unit,
    Map<String, int>? progress,
    List<String>? remediationLog,
  }) {
    return KhatmaTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      schedulingMode: schedulingMode ?? this.schedulingMode,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      currentPage: currentPage ?? this.currentPage,
      unit: unit ?? this.unit,
      progress: progress ?? this.progress,
      remediationLog: remediationLog ?? this.remediationLog,
    );
  }

  double get overallProgress =>
      totalUnits == 0 ? 0.0 : (completedUnits / totalUnits).clamp(0.0, 1.0);

  int get totalUnits => (endPage - startPage + 1).clamp(0, 1000000);

  /// Last completed unit (page/juz/surah based on [unit]).
  int get currentUnit => currentPage;

  int get completedUnits =>
      (currentUnit - startPage + 1).clamp(0, totalUnits);

  int get remainingUnits => (totalUnits - completedUnits).clamp(0, totalUnits);

  int get daysRemaining {
    if (targetDate == null) return 0;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }
}
