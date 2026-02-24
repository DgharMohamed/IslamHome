// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasbeeh_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TasbeehModelAdapter extends TypeAdapter<TasbeehModel> {
  @override
  final int typeId = 15;

  @override
  TasbeehModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TasbeehModel(
      id: fields[0] as String,
      text: fields[1] as String,
      arabicText: fields[2] as String,
      count: fields[3] as int,
      target: fields[4] as int,
      totalCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TasbeehModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.arabicText)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.target)
      ..writeByte(5)
      ..write(obj.totalCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbeehModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
