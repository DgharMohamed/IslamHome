class QuranUtils {
  static const List<String> arabicSurahNames = [
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس',
  ];

  static const List<String> englishSurahNames = [
    'Al-fatiha',
    'Al-baqara',
    'Aal-e-imran',
    'An-nisa',
    'Al-maida',
    "Al-an'am",
    "Al-a'raf",
    'Al-anfal',
    'At-tawba',
    'Yunus',
    'Hud',
    'Yusuf',
    "Ar-ra'd",
    'Ibrahim',
    'Al-hijr',
    'An-nahl',
    'Al-isra',
    'Al-kahf',
    'Maryam',
    'Taha',
    'Al-anbiya',
    'Al-hajj',
    "Al-mu'minun",
    'An-nur',
    'Al-furqan',
    'Ash-shu\'ara',
    'An-naml',
    'Al-qasas',
    'Al-ankabut',
    'Ar-rum',
    'Luqman',
    'As-sajda',
    'Al-ahzab',
    'Saba',
    'Fatir',
    'Ya-sin',
    'As-saffat',
    'Sad',
    'Az-zumar',
    'Ghafir',
    'Fussilat',
    'Ash-shura',
    'Az-zukhruf',
    'Ad-dukhan',
    'Al-jathiya',
    'Al-ahqaf',
    'Muhammad',
    'Al-fath',
    'Al-hujurat',
    'Qaf',
    'Adh-dhariyat',
    'At-tur',
    'An-najm',
    'Al-qamar',
    'Ar-rahman',
    "Al-waqi'a",
    'Al-hadid',
    'Al-mujadila',
    'Al-hashr',
    'Al-mumtahina',
    'As-saff',
    "Al-jumu'a",
    'Al-munafiqun',
    'At-taghabun',
    'At-talaq',
    'At-tahrim',
    'Al-mulk',
    'Al-qalam',
    'Al-haqqa',
    "Al-ma'arij",
    'Nuh',
    'Al-jinn',
    'Al-muzzammil',
    'Al-muddaththir',
    'Al-qiyama',
    'Al-insan',
    'Al-mursalat',
    'An-naba',
    "An-nazi'at",
    'Abasa',
    'At-takwir',
    'Al-infitar',
    'Al-mutaffifin',
    'Al-inshiqaq',
    'Al-buruj',
    'At-tariq',
    "Al-a'la",
    'Al-ghashiya',
    'Al-fajr',
    'Al-balad',
    'Ash-shams',
    'Al-layl',
    'Ad-duha',
    'Ash-sharh',
    'At-tin',
    'Al-alaq',
    'Al-qadr',
    'Al-bayyina',
    'Az-zalzala',
    'Al-adiyat',
    "Al-qari'a",
    'At-takathur',
    'Al-asr',
    'Al-humaza',
    'Al-fil',
    'Quraysh',
    "Al-ma'un",
    'Al-kawthar',
    'Al-kafirun',
    'An-nasr',
    'Al-masad',
    'Al-ikhlas',
    'Al-falaq',
    'An-nas',
  ];

  static String getSurahName(int surahNumber, {bool isEnglish = false}) {
    if (surahNumber < 1 || surahNumber > 114) {
      return 'Unknown';
    }
    final index = surahNumber - 1;
    return isEnglish ? englishSurahNames[index] : arabicSurahNames[index];
  }

  static bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Normalizes Arabic/English text for tolerant searching:
  /// - removes Arabic diacritics
  /// - normalizes Arabic letter variants (أ/إ/آ -> ا, ة -> ه, ى -> ي)
  /// - normalizes Arabic-Indic digits to Western digits
  /// - lowercases and trims spaces
  static String normalizeForSearch(String text) {
    if (text.isEmpty) return '';

    var value = text.toLowerCase().trim();

    // Remove Arabic diacritics and tatweel.
    value = value.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');

    // Normalize Arabic letters.
    value = value
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');

    // Normalize Arabic-Indic digits.
    const arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < arabicIndicDigits.length; i++) {
      value = value.replaceAll(arabicIndicDigits[i], '$i');
    }

    // Collapse repeated spaces.
    value = value.replaceAll(RegExp(r'\s+'), ' ');

    return value;
  }

  static bool matchesSearch(String source, String query) {
    final normalizedQuery = normalizeForSearch(query);
    if (normalizedQuery.isEmpty) return true;
    final normalizedSource = normalizeForSearch(source);
    return normalizedSource.contains(normalizedQuery);
  }

  static List<String> get surahNames => arabicSurahNames;
}
