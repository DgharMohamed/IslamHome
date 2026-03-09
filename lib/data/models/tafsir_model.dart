class TafsirItem {
  final int id;
  final String url;
  final String name;

  TafsirItem({required this.id, required this.url, required this.name});

  factory TafsirItem.fromJson(Map<String, dynamic> json) {
    return TafsirItem(id: json['id'], url: json['url'], name: json['name']);
  }
}

class TafsirSurah {
  final int id;
  final int tafsirId;
  final String name;
  final String url;
  final int surahId;

  TafsirSurah({
    required this.id,
    required this.tafsirId,
    required this.name,
    required this.url,
    required this.surahId,
  });

  factory TafsirSurah.fromJson(Map<String, dynamic> json) {
    return TafsirSurah(
      id: json['id'],
      tafsirId: json['tafsir_id'],
      name: json['name'],
      url: json['url'],
      surahId: json['sura_id'],
    );
  }
}
