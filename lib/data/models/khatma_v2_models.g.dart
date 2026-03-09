// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatma_v2_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KhatmaTrackAdapter extends TypeAdapter<KhatmaTrack> {
  @override
  final int typeId = 23;

  @override
  KhatmaTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhatmaTrack(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as KhatmaType,
      schedulingMode: fields[3] as SchedulingMode,
      startDate: fields[4] as DateTime,
      targetDate: fields[5] as DateTime?,
      startPage: fields[6] as int,
      endPage: fields[7] as int,
      currentPage: fields[8] as int,
      progress: (fields[9] as Map).cast<String, int>(),
      remediationLog: (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, KhatmaTrack obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.schedulingMode)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.startPage)
      ..writeByte(7)
      ..write(obj.endPage)
      ..writeByte(8)
      ..write(obj.currentPage)
      ..writeByte(11)
      ..write(obj.unitOrNull)
      ..writeByte(9)
      ..write(obj.progress)
      ..writeByte(10)
      ..write(obj.remediationLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmaTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KhatmaTypeAdapter extends TypeAdapter<KhatmaType> {
  @override
  final int typeId = 20;

  @override
  KhatmaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return KhatmaType.reading;
      case 1:
        return KhatmaType.memorization;
      case 2:
        return KhatmaType.revision;
      case 3:
        return KhatmaType.listening;
      default:
        return KhatmaType.reading;
    }
  }

  @override
  void write(BinaryWriter writer, KhatmaType obj) {
    switch (obj) {
      case KhatmaType.reading:
        writer.writeByte(0);
        break;
      case KhatmaType.memorization:
        writer.writeByte(1);
        break;
      case KhatmaType.revision:
        writer.writeByte(2);
        break;
      case KhatmaType.listening:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KhatmaUnitAdapter extends TypeAdapter<KhatmaUnit> {
  @override
  final int typeId = 24;

  @override
  KhatmaUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return KhatmaUnit.page;
      case 1:
        return KhatmaUnit.juz;
      case 2:
        return KhatmaUnit.surah;
      default:
        return KhatmaUnit.page;
    }
  }

  @override
  void write(BinaryWriter writer, KhatmaUnit obj) {
    switch (obj) {
      case KhatmaUnit.page:
        writer.writeByte(0);
        break;
      case KhatmaUnit.juz:
        writer.writeByte(1);
        break;
      case KhatmaUnit.surah:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmaUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SchedulingModeAdapter extends TypeAdapter<SchedulingMode> {
  @override
  final int typeId = 21;

  @override
  SchedulingMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SchedulingMode.fixedDaily;
      case 1:
        return SchedulingMode.smartRemediation;
      default:
        return SchedulingMode.fixedDaily;
    }
  }

  @override
  void write(BinaryWriter writer, SchedulingMode obj) {
    switch (obj) {
      case SchedulingMode.fixedDaily:
        writer.writeByte(0);
        break;
      case SchedulingMode.smartRemediation:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchedulingModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemediationStrategyAdapter extends TypeAdapter<RemediationStrategy> {
  @override
  final int typeId = 22;

  @override
  RemediationStrategy read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RemediationStrategy.distribute;
      case 1:
        return RemediationStrategy.catchUp;
      case 2:
        return RemediationStrategy.extend;
      default:
        return RemediationStrategy.distribute;
    }
  }

  @override
  void write(BinaryWriter writer, RemediationStrategy obj) {
    switch (obj) {
      case RemediationStrategy.distribute:
        writer.writeByte(0);
        break;
      case RemediationStrategy.catchUp:
        writer.writeByte(1);
        break;
      case RemediationStrategy.extend:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemediationStrategyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KhatmaTrack _$KhatmaTrackFromJson(Map<String, dynamic> json) => KhatmaTrack(
  id: json['id'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$KhatmaTypeEnumMap, json['type']),
  schedulingMode: $enumDecode(_$SchedulingModeEnumMap, json['schedulingMode']),
  startDate: DateTime.parse(json['startDate'] as String),
  targetDate: json['targetDate'] == null
      ? null
      : DateTime.parse(json['targetDate'] as String),
  startPage: (json['startPage'] as num?)?.toInt() ?? 1,
  endPage: (json['endPage'] as num?)?.toInt() ?? 604,
  currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
  unit:
      $enumDecodeNullable(_$KhatmaUnitEnumMap, json['unit']) ?? KhatmaUnit.page,
  progress:
      (json['progress'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  remediationLog:
      (json['remediationLog'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$KhatmaTrackToJson(KhatmaTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$KhatmaTypeEnumMap[instance.type]!,
      'schedulingMode': _$SchedulingModeEnumMap[instance.schedulingMode]!,
      'startDate': instance.startDate.toIso8601String(),
      'targetDate': instance.targetDate?.toIso8601String(),
      'startPage': instance.startPage,
      'endPage': instance.endPage,
      'currentPage': instance.currentPage,
      'unit': _$KhatmaUnitEnumMap[instance.unit]!,
      'progress': instance.progress,
      'remediationLog': instance.remediationLog,
    };

const _$KhatmaTypeEnumMap = {
  KhatmaType.reading: 'reading',
  KhatmaType.memorization: 'memorization',
  KhatmaType.revision: 'revision',
  KhatmaType.listening: 'listening',
};

const _$SchedulingModeEnumMap = {
  SchedulingMode.fixedDaily: 'fixedDaily',
  SchedulingMode.smartRemediation: 'smartRemediation',
};

const _$KhatmaUnitEnumMap = {
  KhatmaUnit.page: 'page',
  KhatmaUnit.juz: 'juz',
  KhatmaUnit.surah: 'surah',
};
