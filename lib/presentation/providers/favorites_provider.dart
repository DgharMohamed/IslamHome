import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/playlist_model.dart';
import 'dart:convert';

class FavoritesNotifier extends Notifier<Map<String, List<dynamic>>> {
  @override
  Map<String, List<dynamic>> build() {
    _loadFavorites();
    return {
      'reciters': [],
      'surahs': [],
      'ayahs': [],
      'playlists': [],
      'hadiths': [],
      'tafsir': [],
      'seerah': [],
    };
  }

  final _box = Hive.box('favorites');

  void _loadFavorites() {
    final recitersJson = _box.get('reciters', defaultValue: '[]');
    final surahsJson = _box.get('surahs', defaultValue: '[]');
    final ayahsJson = _box.get('ayahs', defaultValue: '[]');
    final playlistsJson = _box.get('playlists', defaultValue: '[]');
    final hadithsJson = _box.get('hadiths', defaultValue: '[]');
    final tafsirJson = _box.get('tafsir', defaultValue: '[]');
    final seerahJson = _box.get('seerah', defaultValue: '[]');

    state = {
      'reciters': jsonDecode(recitersJson),
      'surahs': jsonDecode(surahsJson),
      'ayahs': jsonDecode(ayahsJson),
      'playlists': jsonDecode(playlistsJson),
      'hadiths': jsonDecode(hadithsJson),
      'tafsir': jsonDecode(tafsirJson),
      'seerah': jsonDecode(seerahJson),
    };
  }

  void toggleFavoriteReciter(dynamic reciter) {
    final list = List<dynamic>.from(state['reciters']!);
    final index = list.indexWhere((item) => item['id'] == reciter.id);

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(reciter.toJson());
    }

    state = {...state, 'reciters': list};
    _box.put('reciters', jsonEncode(list));
  }

  void toggleFavoriteSurah(dynamic surah, dynamic reciter, {String? url}) {
    final list = List<dynamic>.from(state['surahs']!);
    final itemKey = '${surah.number}_${reciter.id}';
    final index = list.indexWhere(
      (item) => '${item['surah_number']}_${item['reciter_id']}' == itemKey,
    );

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'surah_number': surah.number,
        'surah_name': surah.name,
        'reciter_id': reciter.id,
        'reciter_name': reciter.name,
        'url': url, // Save the URL
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    state = {...state, 'surahs': list};
    _box.put('surahs', jsonEncode(list));
  }

  bool isFavoriteReciter(String id) {
    return state['reciters']!.any((item) => item['id'].toString() == id);
  }

  bool isFavoriteSurah(int surahNumber, String reciterId) {
    final itemKey = '${surahNumber}_$reciterId';
    return state['surahs']!.any(
      (item) => '${item['surah_number']}_${item['reciter_id']}' == itemKey,
    );
  }

  // --- Ayah Methods ---

  void toggleFavoriteAyah(int surah, int ayah) {
    final list = List<dynamic>.from(state['ayahs']!);
    final itemKey = '${surah}_$ayah';
    final index = list.indexWhere(
      (item) => '${item['surah']}_${item['ayah']}' == itemKey,
    );

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'surah': surah,
        'ayah': ayah,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    state = {...state, 'ayahs': list};
    _box.put('ayahs', jsonEncode(list));
  }

  bool isFavoriteAyah(int surah, int ayah) {
    final itemKey = '${surah}_$ayah';
    return state['ayahs']!.any(
      (item) => '${item['surah']}_${item['ayah']}' == itemKey,
    );
  }

  // --- Tafsir Methods ---

  void toggleFavoriteTafsir({
    required String tafsirName,
    required dynamic surahPart,
  }) {
    final list = List<dynamic>.from(state['tafsir']!);
    final itemKey = '${tafsirName}_${surahPart.id}';
    final index = list.indexWhere(
      (item) => '${item['tafsir_name']}_${item['part_id']}' == itemKey,
    );

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'part_id': surahPart.id,
        'part_name': surahPart.name,
        'tafsir_name': tafsirName,
        'url': surahPart.url,
        'surah_id': surahPart.surahId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    state = {...state, 'tafsir': list};
    _box.put('tafsir', jsonEncode(list));
  }

  bool isFavoriteTafsir(String tafsirName, int partId) {
    final itemKey = '${tafsirName}_$partId';
    return state['tafsir']!.any(
      (item) => '${item['tafsir_name']}_${item['part_id']}' == itemKey,
    );
  }

  // --- Seerah Methods ---

  void toggleFavoriteSeerah(dynamic episode, String scholarName) {
    final list = List<dynamic>.from(state['seerah']!);
    final itemKey = '${scholarName}_${episode.id}';
    final index = list.indexWhere(
      (item) => '${item['scholar_name']}_${item['episode_id']}' == itemKey,
    );

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'episode_id': episode.id,
        'episode_title': episode.title,
        'scholar_name': scholarName,
        'url': episode.url,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    state = {...state, 'seerah': list};
    _box.put('seerah', jsonEncode(list));
  }

  bool isFavoriteSeerah(String scholarName, String episodeId) {
    final itemKey = '${scholarName}_$episodeId';
    return state['seerah']!.any(
      (item) => '${item['scholar_name']}_${item['episode_id']}' == itemKey,
    );
  }

  // --- Hadith Methods ---

  void toggleFavoriteHadith(dynamic hadith) {
    // Check if hadith is HadithModel or Map, convert to map if needed
    final hadithMap = (hadith is Map) ? hadith : hadith.toJson();
    final list = List<dynamic>.from(state['hadiths'] ?? []);
    final hadithId = hadithMap['id'].toString();
    final index = list.indexWhere((item) => item['id'].toString() == hadithId);

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(hadithMap);
    }

    state = {...state, 'hadiths': list};
    _box.put('hadiths', jsonEncode(list));
  }

  bool isFavoriteHadith(String id) {
    return (state['hadiths'] ?? []).any((item) => item['id'].toString() == id);
  }

  // --- Playlist Methods ---

  void createPlaylist(String name, {String? icon}) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon ?? '⭐',
      items: [],
    );

    playlists.add(newPlaylist.toJson());
    state = {...state, 'playlists': playlists};
    _savePlaylists();
  }

  void deletePlaylist(String id) {
    final playlists = List<dynamic>.from(state['playlists']!);
    playlists.removeWhere((p) => p['id'] == id);
    state = {...state, 'playlists': playlists};
    _savePlaylists();
  }

  void updatePlaylist(Playlist updatedPlaylist) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final index = playlists.indexWhere((p) => p['id'] == updatedPlaylist.id);
    if (index >= 0) {
      playlists[index] = updatedPlaylist.toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void addToPlaylist(
    String playlistId,
    dynamic surah,
    dynamic reciter,
    String url,
  ) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final index = playlists.indexWhere((p) => p['id'] == playlistId);

    if (index >= 0) {
      final playlist = Playlist.fromJson(playlists[index]);
      final newItem = PlaylistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        surahNumber: surah.number,
        surahName: surah.name,
        reciterId: reciter.id,
        reciterName: reciter.name,
        url: url,
        order: playlist.items.length,
      );

      final updatedItems = [...playlist.items, newItem];
      playlists[index] = playlist.copyWith(items: updatedItems).toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void removeFromPlaylist(String playlistId, String itemId) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final pIndex = playlists.indexWhere((p) => p['id'] == playlistId);

    if (pIndex >= 0) {
      final playlist = Playlist.fromJson(playlists[pIndex]);
      final updatedItems = playlist.items.where((i) => i.id != itemId).toList();

      // Re-order remaining items
      for (int i = 0; i < updatedItems.length; i++) {
        updatedItems[i] = updatedItems[i].copyWith(order: i);
      }

      playlists[pIndex] = playlist.copyWith(items: updatedItems).toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void reorderPlaylistItems(String playlistId, int oldIndex, int newIndex) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final pIndex = playlists.indexWhere((p) => p['id'] == playlistId);

    if (pIndex >= 0) {
      final playlist = Playlist.fromJson(playlists[pIndex]);
      final items = List<PlaylistItem>.from(playlist.items);

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      // Update order property
      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(order: i);
      }

      playlists[pIndex] = playlist.copyWith(items: items).toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void _savePlaylists() {
    _box.put('playlists', jsonEncode(state['playlists']));
  }

  String exportPlaylist(String id) {
    final playlists = state['playlists']!;
    final playlist = playlists.firstWhere((p) => p['id'] == id);
    return base64Encode(utf8.encode(jsonEncode(playlist)));
  }

  void importPlaylist(String base64Data) {
    try {
      final decoded = utf8.decode(base64Decode(base64Data));
      final Map<String, dynamic> json = jsonDecode(decoded);

      // Reset ID to avoid conflicts
      json['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      json['name'] = '${json['name']} (Imported)';

      final playlists = List<dynamic>.from(state['playlists']!);
      playlists.add(json);

      state = {...state, 'playlists': playlists};
      _savePlaylists();
    } catch (e) {
      debugPrint('Error importing playlist: $e');
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<String, List<dynamic>>>(() {
      return FavoritesNotifier();
    });
