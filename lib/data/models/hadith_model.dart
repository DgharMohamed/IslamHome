import 'package:json_annotation/json_annotation.dart';

part 'hadith_model.g.dart';

@JsonSerializable()
class HadithModel {
  final String? id;
  @JsonKey(name: 'hadithnumber')
  final int? number;
  @JsonKey(name: 'text')
  final String? arab;
  final String? english;
  final String? narrator;
  final String? book;
  final String? bookSlug;
  final String? chapter;
  final String? grade;

  HadithModel({
    this.id,
    this.number,
    this.arab,
    this.english,
    this.narrator,
    this.book,
    this.bookSlug,
    this.chapter,
    this.grade,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    // Safely handle id field which might be int or String
    final normalizedJson = Map<String, dynamic>.from(json);
    if (normalizedJson['id'] != null) {
      normalizedJson['id'] = normalizedJson['id'].toString();
    }
    return _$HadithModelFromJson(normalizedJson);
  }
  Map<String, dynamic> toJson() => _$HadithModelToJson(this);
}

@JsonSerializable()
class HadithBook {
  final String? id;
  final String? name;
  final String? nameAr;
  final int? available;
  final int? totalHadiths;
  final List<HadithChapter>? chapters;

  HadithBook({
    this.id,
    this.name,
    this.nameAr,
    this.available,
    this.totalHadiths,
    this.chapters,
  });

  factory HadithBook.fromJson(Map<String, dynamic> json) =>
      _$HadithBookFromJson(json);
  Map<String, dynamic> toJson() => _$HadithBookToJson(this);
}

@JsonSerializable()
class HadithChapter {
  final String? name;
  final String? nameAr;
  final List<HadithModel>? hadiths;

  HadithChapter({this.name, this.nameAr, this.hadiths});

  factory HadithChapter.fromJson(Map<String, dynamic> json) =>
      _$HadithChapterFromJson(json);
  Map<String, dynamic> toJson() => _$HadithChapterToJson(this);
}
