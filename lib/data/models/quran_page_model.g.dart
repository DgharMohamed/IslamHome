// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_page_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuranWordAdapter extends TypeAdapter<QuranWord> {
  @override
  final int typeId = 30;

  @override
  QuranWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranWord(
      id: fields[0] as int,
      position: fields[1] as int,
      textUthmani: fields[2] as String,
      charTypeName: fields[3] as String,
      lineNumber: fields[4] as int?,
      verseKey: fields[5] as String,
      pageNumber: fields[6] as int,
      audioUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuranWord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.textUthmani)
      ..writeByte(3)
      ..write(obj.charTypeName)
      ..writeByte(4)
      ..write(obj.lineNumber)
      ..writeByte(5)
      ..write(obj.verseKey)
      ..writeByte(6)
      ..write(obj.pageNumber)
      ..writeByte(7)
      ..write(obj.audioUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuranLineAdapter extends TypeAdapter<QuranLine> {
  @override
  final int typeId = 31;

  @override
  QuranLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranLine(
      lineNumber: fields[0] as int,
      words: (fields[1] as List).cast<QuranWord>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuranLine obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lineNumber)
      ..writeByte(1)
      ..write(obj.words);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuranPageAdapter extends TypeAdapter<QuranPage> {
  @override
  final int typeId = 32;

  @override
  QuranPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranPage(
      pageNumber: fields[0] as int,
      surahName: fields[1] as String,
      juzNumber: fields[2] as int,
      hizbNumber: fields[3] as int,
      lines: (fields[4] as List).cast<QuranLine>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuranPage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.pageNumber)
      ..writeByte(1)
      ..write(obj.surahName)
      ..writeByte(2)
      ..write(obj.juzNumber)
      ..writeByte(3)
      ..write(obj.hizbNumber)
      ..writeByte(4)
      ..write(obj.lines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
