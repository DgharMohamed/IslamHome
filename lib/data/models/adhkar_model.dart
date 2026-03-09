import 'package:hive/hive.dart';

@HiveType(typeId: 60)
class AdhkarModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String textAr;

  @HiveField(4)
  final String textEn;

  @HiveField(5)
  final String reference;

  @HiveField(6)
  final int repeat;

  @HiveField(7)
  final bool favorite;

  AdhkarModel({
    required this.id,
    required this.category,
    required this.title,
    required this.textAr,
    required this.textEn,
    required this.reference,
    required this.repeat,
    this.favorite = false,
  });

  factory AdhkarModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final intId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final rawRepeat = json['repeat'] ?? json['count'];
    final repeat = rawRepeat is int
        ? rawRepeat
        : int.tryParse(rawRepeat?.toString() ?? '') ?? 1;

    final category = _pickFirstNonEmptyString([
      json['category'],
      json['type'],
      json['group'],
    ]);

    final title = _pickFirstNonEmptyString([
      json['title'],
      json['name'],
      json['description'],
      category,
    ]);

    final textAr = _pickFirstNonEmptyString([
      json['textAr'],
      json['arabic'],
      json['zikr'],
      json['text'],
      json['zekr'],
    ]);

    final textEn = _pickFirstNonEmptyString([
      json['textEn'],
      json['english'],
      json['translation'],
      json['transliteration'],
    ]);

    final reference = _pickFirstNonEmptyString([
      json['reference'],
      json['source'],
      json['book'],
    ]);

    return AdhkarModel(
      id: intId,
      category: category,
      title: title,
      textAr: textAr,
      textEn: textEn,
      reference: reference,
      repeat: repeat < 1 ? 1 : repeat,
      favorite: json['favorite'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'textAr': textAr,
      'textEn': textEn,
      'reference': reference,
      'repeat': repeat,
      'favorite': favorite,
    };
  }

  AdhkarModel copyWith({
    int? id,
    String? category,
    String? title,
    String? textAr,
    String? textEn,
    String? reference,
    int? repeat,
    bool? favorite,
  }) {
    return AdhkarModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      textAr: textAr ?? this.textAr,
      textEn: textEn ?? this.textEn,
      reference: reference ?? this.reference,
      repeat: repeat ?? this.repeat,
      favorite: favorite ?? this.favorite,
    );
  }

  static String _pickFirstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

class AdhkarModelAdapter extends TypeAdapter<AdhkarModel> {
  @override
  final int typeId = 60;

  @override
  AdhkarModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdhkarModel(
      id: fields[0] as int,
      category: fields[1] as String,
      title: fields[2] as String,
      textAr: fields[3] as String,
      textEn: fields[4] as String,
      reference: fields[5] as String,
      repeat: fields[6] as int,
      favorite: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AdhkarModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.textAr)
      ..writeByte(4)
      ..write(obj.textEn)
      ..writeByte(5)
      ..write(obj.reference)
      ..writeByte(6)
      ..write(obj.repeat)
      ..writeByte(7)
      ..write(obj.favorite);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdhkarModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
