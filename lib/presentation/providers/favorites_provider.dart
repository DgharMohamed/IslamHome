import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/playlist_model.dart';
import 'package:islam_home/data/services/auth_service.dart';
import 'package:islam_home/data/services/firestore_sync_service.dart';
import 'dart:convert';

class FavoritesNotifier extends Notifier<Map<String, List<dynamic>>> {
  late final _auth = ref.read(authServiceProvider);
  late final _syncService = ref.read(firestoreSyncServiceProvider);
  final _box = Hive.box('favorites');
  StreamSubscription? _cloudSubscription;
  String? _listeningUid;

  @override
  Map<String, List<dynamic>> build() {
    ref.onDispose(() => _cloudSubscription?.cancel());
    ref.listen(authStateProvider, (previous, next) {
      _listenToCloudChanges(next.asData?.value?.uid);
    });

    // We can't use state = _loadFavorites() directly here because build must return the initial state.
    // However, Notifier build() should return the state.
    return _getInitialFavorites();
  }

  Map<String, List<dynamic>> _getInitialFavorites() {
    final categories = ['reciters', 'surahs', 'ayahs', 'playlists', 'hadiths', 'tafsir', 'seerah'];
    final Map<String, List<dynamic>> loadedState = {};
    
    for (final category in categories) {
      final json = _box.get(category, defaultValue: '[]');
      loadedState[category] = jsonDecode(json);
    }
    
    // Set up listener after state is initialized
    Future.microtask(() => _listenToCloudChanges(_auth.currentUser?.uid));
    
    return loadedState;
  }

  void _listenToCloudChanges(String? uid) {
    if (_listeningUid == uid) return;

    _cloudSubscription?.cancel();
    _cloudSubscription = null;
    _listeningUid = uid;
    if (uid == null) return;

    _cloudSubscription = _syncService
        .getUserCollectionStream('favorites', uid: uid)
        .listen((snapshot) {
      bool localUpdated = false;
      final newState = Map<String, List<dynamic>>.from(state);

      for (var doc in snapshot.docs) {
        final category = doc.id;
        final cloudData = doc.data();
        final List<dynamic> cloudList = cloudData['items'] ?? [];
        
        // Handle both ISO string and Firestore Timestamp
        final cloudTimestampVal = cloudData['lastUpdated'];
        final DateTime cloudTimestamp;
        if (cloudTimestampVal is Timestamp) {
          cloudTimestamp = cloudTimestampVal.toDate();
        } else if (cloudTimestampVal is String) {
          cloudTimestamp = DateTime.parse(cloudTimestampVal);
        } else {
          cloudTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
        }
        
        final localTimestampStr = _box.get('${category}_timestamp');
        final localTimestamp = localTimestampStr != null 
            ? DateTime.parse(localTimestampStr) 
            : DateTime.fromMillisecondsSinceEpoch(0);

        if (cloudTimestamp.isAfter(localTimestamp)) {
          newState[category] = cloudList;
          _box.put(category, jsonEncode(cloudList));
          _box.put('${category}_timestamp', cloudTimestamp.toIso8601String());
          localUpdated = true;
        }
      }

      if (localUpdated) {
        state = newState;
      }
    }, onError: (Object error) {
      debugPrint('FavoritesNotifier: cloud listener error: $error');
    });
  }

  Future<void> _syncToCloud(String category, List<dynamic> list) async {
    final now = DateTime.now();
    _box.put(category, jsonEncode(list));
    _box.put('${category}_timestamp', now.toIso8601String());
    
    state = {...state, category: list};

    if (_auth.currentUser != null) {
      await _syncService.saveUserData(
        collection: 'favorites',
        docId: category,
        data: {
          'items': list,
          'lastUpdated': now.toIso8601String(),
        },
      );
    }
  }

  void toggleFavoriteReciter(dynamic reciter) {
    final list = List<dynamic>.from(state['reciters']!);
    final index = list.indexWhere((item) => item['id'] == reciter.id);

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(reciter.toJson());
    }

    _syncToCloud('reciters', list);
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
        'url': url,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    _syncToCloud('surahs', list);
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

    _syncToCloud('ayahs', list);
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

    _syncToCloud('tafsir', list);
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

    _syncToCloud('seerah', list);
  }

  bool isFavoriteSeerah(String scholarName, String episodeId) {
    final itemKey = '${scholarName}_$episodeId';
    return state['seerah']!.any(
      (item) => '${item['scholar_name']}_${item['episode_id']}' == itemKey,
    );
  }

  // --- Hadith Methods ---

  void toggleFavoriteHadith(dynamic hadith) {
    final hadithMap = (hadith is Map) ? hadith : hadith.toJson();
    final list = List<dynamic>.from(state['hadiths'] ?? []);
    final hadithId = hadithMap['id'].toString();
    final index = list.indexWhere((item) => item['id'].toString() == hadithId);

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(hadithMap);
    }

    _syncToCloud('hadiths', list);
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
    _syncToCloud('playlists', playlists);
  }

  void deletePlaylist(String id) {
    final playlists = List<dynamic>.from(state['playlists']!);
    playlists.removeWhere((p) => p['id'] == id);
    _syncToCloud('playlists', playlists);
  }

  void updatePlaylist(Playlist updatedPlaylist) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final index = playlists.indexWhere((p) => p['id'] == updatedPlaylist.id);
    if (index >= 0) {
      playlists[index] = updatedPlaylist.toJson();
      _syncToCloud('playlists', playlists);
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
      _syncToCloud('playlists', playlists);
    }
  }

  void removeFromPlaylist(String playlistId, String itemId) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final pIndex = playlists.indexWhere((p) => p['id'] == playlistId);

    if (pIndex >= 0) {
      final playlist = Playlist.fromJson(playlists[pIndex]);
      final updatedItems = playlist.items.where((i) => i.id != itemId).toList();

      for (int i = 0; i < updatedItems.length; i++) {
        updatedItems[i] = updatedItems[i].copyWith(order: i);
      }

      playlists[pIndex] = playlist.copyWith(items: updatedItems).toJson();
      _syncToCloud('playlists', playlists);
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

      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(order: i);
      }

      playlists[pIndex] = playlist.copyWith(items: items).toJson();
      _syncToCloud('playlists', playlists);
    }
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

      json['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      json['name'] = '${json['name']} (Imported)';

      final playlists = List<dynamic>.from(state['playlists']!);
      playlists.add(json);

      _syncToCloud('playlists', playlists);
    } catch (e) {
      debugPrint('Error importing playlist: $e');
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<String, List<dynamic>>>(() {
  return FavoritesNotifier();
});
