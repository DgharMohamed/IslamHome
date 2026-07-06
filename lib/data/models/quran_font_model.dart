/// Represents a Quran display font that can be bundled or downloaded.
class QuranFont {
  final String id;
  final String nameAr;
  final String nameEn;
  final String fontFamily;
  final bool isBundled;
  final String? downloadUrl;
  final String? fileName;
  final String preview; // A short Quranic verse for preview

  const QuranFont({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.fontFamily,
    required this.isBundled,
    this.downloadUrl,
    this.fileName,
    this.preview = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِيمِ',
  });

  // ─── Bundled fonts (already in assets) ───────────────────────────────────────

  static const uthmanicHafs = QuranFont(
    id: 'uthmanic_hafs',
    nameAr: 'خط عثمان طه',
    nameEn: 'Uthmanic Hafs',
    fontFamily: 'UthmanicHafs',
    isBundled: true,
  );

  static const amiri = QuranFont(
    id: 'amiri',
    nameAr: 'الأميري',
    nameEn: 'Amiri',
    fontFamily: 'Amiri',
    isBundled: true,
  );

  static const warsh = QuranFont(
    id: 'warsh_maghrebi',
    nameAr: 'الخط المغربي (ورش)',
    nameEn: 'Maghrebi Warsh',
    fontFamily: 'WarshUthmanic',
    isBundled: true,
  );

  static const qalon = QuranFont(
    id: 'qalon_maghrebi',
    nameAr: 'الخط المغربي (قالون)',
    nameEn: 'Maghrebi Qalon',
    fontFamily: 'QalonUthmanic',
    isBundled: true,
  );

  // ─── Downloadable fonts ──────────────────────────────────────────────────────

  static const scheherazade = QuranFont(
    id: 'scheherazade',
    nameAr: 'شهرزاد',
    nameEn: 'Scheherazade',
    fontFamily: 'ScheherazadeNew',
    isBundled: false,
    fileName: 'ScheherazadeNew-Regular.ttf',
    downloadUrl:
        'https://github.com/silnrsi/font-scheherazade/releases/download/v4.000/ScheherazadeNew-4.000.zip',
  );

  static const meQuran = QuranFont(
    id: 'me_quran',
    nameAr: 'مي قرآن',
    nameEn: 'Me Quran',
    fontFamily: 'MeQuran',
    isBundled: false,
    fileName: 'me_quran.ttf',
    downloadUrl:
        'https://cdn.jsdelivr.net/gh/AliEsmaeili/me-quran-font@master/me_quran.ttf',
  );

  static const alQalam = QuranFont(
    id: 'al_qalam',
    nameAr: 'القلم المجيدي',
    nameEn: 'Al Qalam Quran',
    fontFamily: 'AlQalamQuran',
    isBundled: false,
    fileName: 'AlQalamQuranMajeed.ttf',
    downloadUrl:
        'https://cdn.jsdelivr.net/gh/AliEsmaeili/quran-fonts@master/Al_Qalam_Quran_Majeed.ttf',
  );

  static const nooreHuda = QuranFont(
    id: 'noorehuda',
    nameAr: 'نور الهدى',
    nameEn: 'Noor e Huda',
    fontFamily: 'NooreHuda',
    isBundled: false,
    fileName: 'noorehuda.ttf',
    downloadUrl:
        'https://cdn.jsdelivr.net/gh/AliEsmaeili/quran-fonts@master/noorehuda.ttf',
  );

  static const kfgqpcHafs = QuranFont(
    id: 'kfgqpc_hafs',
    nameAr: 'مجمع الملك فهد',
    nameEn: 'KFGQPC Hafs',
    fontFamily: 'KFGQPCHafs',
    isBundled: false,
    fileName: 'UthmanicHafs1Ver18.otf',
    downloadUrl:
        'https://api.quranpedia.net/fonts/UthmanicHafs1Ver18.otf',
  );

  static const samirKhouaja = QuranFont(
    id: 'samir_khouaja',
    nameAr: 'خط سمير خوجة المغربي',
    nameEn: 'Samir Khouaja Maghribi',
    fontFamily: 'SamirKhouaja',
    isBundled: true,
  );

  // ─── All fonts list ──────────────────────────────────────────────────────────

  static const List<QuranFont> all = [
    uthmanicHafs,
    amiri,
    warsh,
    qalon,
    scheherazade,
    meQuran,
    alQalam,
    nooreHuda,
    kfgqpcHafs,
    samirKhouaja,
  ];

  static QuranFont fromId(String id) {
    return all.firstWhere((f) => f.id == id, orElse: () => uthmanicHafs);
  }
}

