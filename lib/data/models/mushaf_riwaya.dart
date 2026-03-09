/// Represents a Quran riwaya (recitation style/manuscript variant).
class MushafRiwaya {
  final int id; // Quranpedia mushaf ID
  final String key; // unique local key
  final String name; // Arabic display name
  final String rawiName; // name of the rawi
  final String qiraaName; // name of the qiraa
  final String fontFamily; // Flutter font family name declared in pubspec
  final bool isOffline; // bundled in the app (no download needed)
  final String? fontUrl; // URL to download font if not offline

  const MushafRiwaya({
    required this.id,
    required this.key,
    required this.name,
    required this.rawiName,
    required this.qiraaName,
    required this.fontFamily,
    required this.isOffline,
    this.fontUrl,
  });

  // ─── Offline (bundled) ──────────────────────────────────────────────────────

  static const hafs = MushafRiwaya(
    id: 1,
    key: 'hafs',
    name: 'مصحف حفص',
    rawiName: 'حفص',
    qiraaName: 'عاصم',
    fontFamily: 'UthmanicHafs',
    isOffline: true,
  );

  static const warsh = MushafRiwaya(
    id: 4,
    key: 'warsh',
    name: 'مصحف ورش',
    rawiName: 'ورش',
    qiraaName: 'نافع',
    fontFamily: 'WarshUthmanic',
    isOffline: true,
  );

  static const qalon = MushafRiwaya(
    id: 7,
    key: 'qalon',
    name: 'مصحف قالون',
    rawiName: 'قالون',
    qiraaName: 'نافع',
    fontFamily: 'QalonUthmanic',
    isOffline: true,
  );

  // ─── Downloadable ────────────────────────────────────────────────────────────

  static const doury = MushafRiwaya(
    id: 6,
    key: 'doury',
    name: 'مصحف الدوري',
    rawiName: 'الدوري',
    qiraaName: 'أبو عمرو',
    fontFamily: 'DouryUthmanic',
    isOffline: false,
    fontUrl: 'https://api.quranpedia.net/fonts/UthmanicDoori1Ver05.otf',
  );

  static const shouba = MushafRiwaya(
    id: 9,
    key: 'shouba',
    name: 'مصحف شعبة',
    rawiName: 'شعبة',
    qiraaName: 'عاصم',
    fontFamily: 'ShoubaUthmanic',
    isOffline: false,
    fontUrl: 'https://api.quranpedia.net/fonts/UthmanicShouba1Ver05.otf',
  );

  static const bazzi = MushafRiwaya(
    id: 5,
    key: 'bazzi',
    name: 'مصحف البزي',
    rawiName: 'البزي',
    qiraaName: 'ابن كثير',
    fontFamily: 'BazziUthmanic',
    isOffline: false,
    fontUrl: 'https://api.quranpedia.net/fonts/UthmanicBazzi1Ver06.otf',
  );

  static const qunbol = MushafRiwaya(
    id: 8,
    key: 'qunbol',
    name: 'مصحف قنبل',
    rawiName: 'قنبل',
    qiraaName: 'ابن كثير',
    fontFamily: 'QunbolUthmanic',
    isOffline: false,
    fontUrl: 'https://api.quranpedia.net/fonts/UthmanicQumbul1Ver05.otf',
  );

  static const sousi = MushafRiwaya(
    id: 10,
    key: 'sousi',
    name: 'مصحف السوسي',
    rawiName: 'السوسي',
    qiraaName: 'أبو عمرو',
    fontFamily: 'SousiUthmanic',
    isOffline: false,
    fontUrl: 'https://api.quranpedia.net/fonts/UthmanicSoosi1Ver05.otf',
  );

  static const hafsNastaleeq = MushafRiwaya(
    id: 3,
    key: 'hafs_nastaleeq',
    name: 'مصحف حفص نستعليق',
    rawiName: 'حفص',
    qiraaName: 'عاصم',
    fontFamily: 'HafsNastaleeq',
    isOffline: false,
    fontUrl: 'https://api.quranpedia.net/fonts/HafsNastaleeqVer10.otf',
  );

  // ─── All riwayat list ───────────────────────────────────────────────────────

  static const List<MushafRiwaya> all = [
    hafs,
    warsh,
    qalon,
    doury,
    shouba,
    bazzi,
    qunbol,
    sousi,
    hafsNastaleeq,
  ];

  static MushafRiwaya fromKey(String key) {
    return all.firstWhere((r) => r.key == key, orElse: () => hafs);
  }
}
