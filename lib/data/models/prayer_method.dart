class PrayerMethod {
  final int id;
  final String nameEn;
  final String nameAr;

  const PrayerMethod({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  /// All calculation methods extracted from http://api.aladhan.com/v1/methods
  static const List<PrayerMethod> methods = [
    PrayerMethod(
      id: 0,
      nameEn: 'Shia Ithna-Ashari, Leva Institute, Qum',
      nameAr: 'الشيعة الاثنا عشرية، معهد ليفا، قم',
    ),
    PrayerMethod(
      id: 1,
      nameEn: 'University of Islamic Sciences, Karachi',
      nameAr: 'جامعة العلوم الإسلامية، كراتشي',
    ),
    PrayerMethod(
      id: 2,
      nameEn: 'Islamic Society of North America (ISNA)',
      nameAr: 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
    ),
    PrayerMethod(
      id: 3,
      nameEn: 'Muslim World League',
      nameAr: 'رابطة العالم الإسلامي',
    ),
    PrayerMethod(
      id: 4,
      nameEn: 'Umm Al-Qura University, Makkah',
      nameAr: 'جامعة أم القرى، مكة المكرمة',
    ),
    PrayerMethod(
      id: 5,
      nameEn: 'Egyptian General Authority of Survey',
      nameAr: 'الهيئة العامة المصرية للمساحة',
    ),
    PrayerMethod(
      id: 7,
      nameEn: 'Institute of Geophysics, University of Tehran',
      nameAr: 'معهد الجيوفيزياء، جامعة طهران',
    ),
    PrayerMethod(id: 8, nameEn: 'Gulf Region', nameAr: 'منطقة الخليج'),
    PrayerMethod(id: 9, nameEn: 'Kuwait', nameAr: 'الكويت'),
    PrayerMethod(id: 10, nameEn: 'Qatar', nameAr: 'قطر'),
    PrayerMethod(
      id: 11,
      nameEn: 'Majlis Ugama Islam Singapura, Singapore',
      nameAr: 'المجلس الديني الإسلامي في سنغافورة',
    ),
    PrayerMethod(
      id: 12,
      nameEn: 'Union Organization Islamic de France',
      nameAr: 'اتحاد المنظمات الإسلامية في فرنسا',
    ),
    PrayerMethod(
      id: 13,
      nameEn: 'Diyanet İşleri Başkanlığı, Turkey',
      nameAr: 'رئاسة الشؤون الدينية، تركيا',
    ),
    PrayerMethod(
      id: 14,
      nameEn: 'Spiritual Administration of Muslims of Russia',
      nameAr: 'الإدارة الروحية لمسلمي روسيا',
    ),
    PrayerMethod(
      id: 15,
      nameEn: 'Moonsighting Committee Worldwide',
      nameAr: 'لجنة مشاهدة القمر حول العالم',
    ),
    PrayerMethod(id: 16, nameEn: 'Dubai', nameAr: 'دبي'),
    PrayerMethod(
      id: 17,
      nameEn: 'Jabatan Kemajuan Islam Malaysia (JAKIM)',
      nameAr: 'إدارة التنمية الإسلامية الماليزية (JAKIM)',
    ),
    PrayerMethod(id: 18, nameEn: 'Tunisia', nameAr: 'تونس'),
    PrayerMethod(id: 19, nameEn: 'Algeria', nameAr: 'الجزائر'),
    PrayerMethod(
      id: 20,
      nameEn: 'Kementerian Agama Republik Indonesia',
      nameAr: 'وزارة الشؤون الدينية بجمهورية إندونيسيا',
    ),
    PrayerMethod(id: 21, nameEn: 'Morocco', nameAr: 'المغرب'),
    PrayerMethod(
      id: 22,
      nameEn: 'Comunidade Islamica de Lisboa',
      nameAr: 'الجالية الإسلامية في لشبونة',
    ),
    PrayerMethod(
      id: 23,
      nameEn: 'Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan',
      nameAr: 'وزارة الأوقاف والشؤون والمقدسات الإسلامية، الأردن',
    ),
  ];
}
