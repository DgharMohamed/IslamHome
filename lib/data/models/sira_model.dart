class SiraStage {
  final int id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String icon;
  final String contentAr;
  final String contentEn;
  final String yearLabel;
  final String? lessonAr;
  final String? lessonEn;
  final List<String> eventsAr;
  final List<String> eventsEn;

  SiraStage({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.icon,
    required this.contentAr,
    required this.contentEn,
    required this.yearLabel,
    this.lessonAr,
    this.lessonEn,
    this.eventsAr = const [],
    this.eventsEn = const [],
  });

  factory SiraStage.fromJson(Map<String, dynamic> json) {
    return SiraStage(
      id: json['id'] as int,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String,
      descriptionAr: json['description_ar'] as String,
      descriptionEn: json['description_en'] as String,
      icon: json['icon'] as String,
      contentAr: json['content_ar'] as String,
      contentEn: json['content_en'] as String,
      yearLabel: json['year_label'] as String? ?? '',
      lessonAr: json['lesson_ar'] as String?,
      lessonEn: json['lesson_en'] as String?,
      eventsAr:
          (json['events_ar'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      eventsEn:
          (json['events_en'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'icon': icon,
      'content_ar': contentAr,
      'content_en': contentEn,
      'year_label': yearLabel,
      'lesson_ar': lessonAr,
      'lesson_en': lessonEn,
      'events_ar': eventsAr,
      'events_en': eventsEn,
    };
  }

  String getTitle(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;

  String getDescription(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  String getContent(String languageCode) =>
      languageCode == 'ar' ? contentAr : contentEn;

  String? getLesson(String languageCode) =>
      languageCode == 'ar' ? lessonAr : lessonEn;

  List<String> getEvents(String languageCode) =>
      languageCode == 'ar' ? eventsAr : eventsEn;
}
