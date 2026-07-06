// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qf_recitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QFRecitation _$QFRecitationFromJson(Map<String, dynamic> json) => QFRecitation(
  id: (json['id'] as num).toInt(),
  reciterName: json['reciter_name'] as String,
  style: json['style'] as String?,
  translatedName: json['translated_name'] == null
      ? null
      : QFTranslatedName.fromJson(
          json['translated_name'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$QFRecitationToJson(QFRecitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reciter_name': instance.reciterName,
      'style': instance.style,
      'translated_name': instance.translatedName,
    };

QFTranslatedName _$QFTranslatedNameFromJson(Map<String, dynamic> json) =>
    QFTranslatedName(
      name: json['name'] as String,
      languageName: json['language_name'] as String,
    );

Map<String, dynamic> _$QFTranslatedNameToJson(QFTranslatedName instance) =>
    <String, dynamic>{
      'name': instance.name,
      'language_name': instance.languageName,
    };
