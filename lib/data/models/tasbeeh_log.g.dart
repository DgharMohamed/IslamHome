// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasbeeh_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TasbeehLogAdapter extends TypeAdapter<TasbeehLog> {
  @override
  final int typeId = 16;

  @override
  TasbeehLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TasbeehLog(
      dhikrId: fields[0] as String,
      date: fields[1] as DateTime,
      hour: fields[2] as int,
      count: fields[3] as int,
      timestamp: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TasbeehLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dhikrId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbeehLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
