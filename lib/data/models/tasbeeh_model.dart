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

  TasbeehModel({
    required this.id,
    required this.text,
    required this.arabicText,
    this.count = 0,
    this.target = 33,
    this.totalCount = 0,
  });

  TasbeehModel copyWith({
    String? id,
    String? text,
    String? arabicText,
    int? count,
    int? target,
    int? totalCount,
  }) {
    return TasbeehModel(
      id: id ?? this.id,
      text: text ?? this.text,
      arabicText: arabicText ?? this.arabicText,
      count: count ?? this.count,
      target: target ?? this.target,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
