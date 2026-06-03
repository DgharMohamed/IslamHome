import 'package:hive/hive.dart';

part 'tasbeeh_model.g.dart';

@HiveType(typeId: 15)
class TasbeehModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String arabicText;

  @HiveField(3)
  int count;

  @HiveField(4)
  int target;

  @HiveField(5)
  int totalCount;

  @HiveField(6)
  DateTime? lastUpdated;

  TasbeehModel({
    required this.id,
    required this.text,
    required this.arabicText,
    this.count = 0,
    this.target = 33,
    this.totalCount = 0,
    this.lastUpdated,
  });

  TasbeehModel copyWith({
    String? id,
    String? text,
    String? arabicText,
    int? count,
    int? target,
    int? totalCount,
    DateTime? lastUpdated,
  }) {
    return TasbeehModel(
      id: id ?? this.id,
      text: text ?? this.text,
      arabicText: arabicText ?? this.arabicText,
      count: count ?? this.count,
      target: target ?? this.target,
      totalCount: totalCount ?? this.totalCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'arabicText': arabicText,
        'count': count,
        'target': target,
        'totalCount': totalCount,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory TasbeehModel.fromJson(Map<String, dynamic> json) => TasbeehModel(
        id: json['id'],
        text: json['text'],
        arabicText: json['arabicText'],
        count: json['count'] ?? 0,
        target: json['target'] ?? 33,
        totalCount: json['totalCount'] ?? 0,
        lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      );
}

