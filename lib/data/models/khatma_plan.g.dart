// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatma_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KhatmaPlan _$KhatmaPlanFromJson(Map<String, dynamic> json) => KhatmaPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      type: $enumDecodeNullable(_$KhatmaTypeEnumMap, json['type']) ??
          KhatmaType.reading,
      targetDays: (json['targetDays'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      startPage: (json['startPage'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$KhatmaPlanToJson(KhatmaPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$KhatmaTypeEnumMap[instance.type]!,
      'targetDays': instance.targetDays,
      'startDate': instance.startDate.toIso8601String(),
      'startPage': instance.startPage,
      'isCompleted': instance.isCompleted,
    };

const _$KhatmaTypeEnumMap = {
  KhatmaType.reading: 'reading',
  KhatmaType.listening: 'listening',
  KhatmaType.tajweed: 'tajweed',
};
