import 'package:json_annotation/json_annotation.dart';

part 'qf_recitation_model.g.dart';

@JsonSerializable()
class QFRecitation {
  final int id;
  @JsonKey(name: 'reciter_name')
  final String reciterName;
  final String? style;
  @JsonKey(name: 'translated_name')
  final QFTranslatedName? translatedName;

  QFRecitation({
    required this.id,
    required this.reciterName,
    this.style,
    this.translatedName,
  });

  String get displayName => translatedName?.name ?? reciterName;

  factory QFRecitation.fromJson(Map<String, dynamic> json) =>
      _$QFRecitationFromJson(json);
  Map<String, dynamic> toJson() => _$QFRecitationToJson(this);
}

@JsonSerializable()
class QFTranslatedName {
  final String name;
  @JsonKey(name: 'language_name')
  final String languageName;

  QFTranslatedName({required this.name, required this.languageName});

  factory QFTranslatedName.fromJson(Map<String, dynamic> json) =>
      _$QFTranslatedNameFromJson(json);
  Map<String, dynamic> toJson() => _$QFTranslatedNameToJson(this);
}
