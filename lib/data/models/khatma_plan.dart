import 'package:json_annotation/json_annotation.dart';

part 'khatma_plan.g.dart';

enum KhatmaType { reading, listening, tajweed }

@JsonSerializable()
class KhatmaPlan {
  final String id;
  final String title;
  final KhatmaType type;
  final int targetDays;
  final DateTime startDate;
  final int startPage;
  final bool isCompleted;

  KhatmaPlan({
    required this.id,
    required this.title,
    this.type = KhatmaType.reading,
    required this.targetDays,
    required this.startDate,
    required this.startPage,
    this.isCompleted = false,
  });

  factory KhatmaPlan.fromJson(Map<String, dynamic> json) =>
      _$KhatmaPlanFromJson(json);
  Map<String, dynamic> toJson() => _$KhatmaPlanToJson(this);

  // Constants
  static const int totalPages = 604;

  // Calculations
  int get remainingPages => totalPages - startPage;

  double get pagesPerDay => remainingPages / targetDays;

  double get pagesPerPrayer => pagesPerDay / 5;

  int daysPassed(DateTime now) {
    return now.difference(startDate).inDays;
  }

  /// Calculates how many pages should have been read by now based on the original plan
  int expectedPageByNow(DateTime now) {
    int days = daysPassed(now);
    return (startPage + (days * pagesPerDay)).toInt();
  }

  /// Smart Re-reallocation: Calculates how many pages are needed daily from CURRENT page
  /// to finish in the REMAINING target days.
  double smartPagesPerDay(int currentPage, DateTime now) {
    final daysUsed = daysPassed(now);
    final daysRemaining = targetDays - daysUsed;
    if (daysRemaining <= 0) return (totalPages - currentPage).toDouble();

    final pagesRemaining = totalPages - currentPage;
    return pagesRemaining / daysRemaining;
  }
}
