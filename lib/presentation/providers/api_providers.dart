import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:islam_home/data/models/qf_recitation_model.dart';
import 'package:islam_home/data/services/api_service.dart';
import 'package:islam_home/data/models/surah_model.dart';
import 'package:islam_home/data/services/local_hadith_service.dart';
import 'package:islam_home/data/services/adhkar_service.dart';
import 'package:islam_home/data/services/offline_cache_service.dart';
import 'package:islam_home/data/services/last_read_service.dart';
import 'package:islam_home/data/services/local_sira_service.dart';
import 'package:islam_home/data/services/audio_download_service.dart';
import 'package:islam_home/data/services/audio_player_service.dart';
import 'package:islam_home/data/services/quran_api_service.dart';
import 'package:islam_home/data/repositories/quran_repository.dart';
import 'package:islam_home/data/models/quran_page_model.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:islam_home/data/models/radio_model.dart';
import 'package:islam_home/data/models/tv_model.dart';
import 'package:islam_home/data/models/video_model.dart';
import 'package:islam_home/data/models/riwaya_model.dart';
import 'package:islam_home/data/models/sira_model.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

// --- Core Service Providers ---

final apiServiceProvider = Provider((ref) => ApiService());
final hadithServiceProvider = Provider((ref) => LocalHadithService());
final azkarServiceProvider = Provider((ref) => AdhkarService());
final siraServiceProvider = Provider((ref) => LocalSiraService());
final cacheServiceProvider = Provider((ref) => OfflineCacheService());
final lastReadServiceProvider = Provider((ref) => LastReadService());
final audioDownloadServiceProvider = Provider((ref) => AudioDownloadService());
final quranApiServiceProvider = Provider((ref) => QuranApiService(Dio()));
final quranRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(quranApiServiceProvider);
  return QuranRepository(apiService);
});

final activeVerseKeyProvider =
    NotifierProvider<ActiveVerseKeyNotifier, String?>(
      ActiveVerseKeyNotifier.new,
    );

class ActiveVerseKeyNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setActive(String? key) => state = key;
}

final playingAyahProvider = StreamProvider<String?>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  if (audioService == null) return Stream.value(null);

  return audioService.mediaItemStream.map((item) {
    if (item == null) return null;
    final surah = item.extras?['surah']?.toString();
    final ayah = item.extras?['ayah']?.toString();
    debugPrint("🎵 playingAyahProvider: emitting $surah:$ayah");
    if (surah != null && ayah != null) {
      return '$surah:$ayah';
    }
    return null;
  });
});

final englishVerseTranslationProvider = FutureProvider.autoDispose
    .family<String, ({int surah, int ayah})>((ref, verse) async {
      final service = ref.watch(quranApiServiceProvider);
      return service.getVerseTranslation(
        verse.surah,
        verse.ayah,
        languageCode: 'en',
      );
    });

// --- Last Read Update Notifier ---
// يستخدم لإشعار واجهة المستخدم بتحديث آخر قراءة
final lastReadUpdateProvider = NotifierProvider<LastReadUpdateNotifier, int>(
  LastReadUpdateNotifier.new,
);

class LastReadUpdateNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final lastReadPositionProvider = FutureProvider<LastReadPosition?>((ref) async {
  ref.watch(lastReadUpdateProvider);
  final service = ref.watch(lastReadServiceProvider);
  return service.getLastRead();
});

// --- Reciters (Cache-then-Network with Local Fallback) ---

final recitersProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'reciters_${locale.languageCode}';

  try {
    final reciters = await apiService.getReciters(
      language: locale.languageCode,
    );
    if (reciters.isNotEmpty) {
      // Cache on success
      await cache.saveToCache(
        cacheKey,
        reciters.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return reciters;
    }
  } catch (e) {
    debugPrint('📴 Reciters API failed, trying cache: $e');
  }

  // Fallback to cache
  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    final cachedReciters = (cached as List)
        .map((e) => Reciter.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    if (cachedReciters.isNotEmpty) {
      return cachedReciters;
    }
  }

  // If all fails, return empty list
  debugPrint('📴 No reciters available from API or cache');
  return <Reciter>[];
});

final qfRecitersProvider = FutureProvider<List<QFRecitation>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getQFReciters();
});

final ayahAudioRecitersProvider = FutureProvider<List<QFRecitation>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);

  final qfReciters = await apiService.getQFReciters(
    language: locale.languageCode,
  );
  if (qfReciters.isEmpty) return const [];

  try {
    // The user requested to allow verse-by-verse audio for all Riwayats.
    // Since most (if not all) verse-by-verse audio on Quran.com is in Hafs,
    // we simply return all reciters capable of verse-by-verse.
    final verseByVerseCapable = await _filterVerseByVerseCapableReciters(
      apiService: apiService,
      reciters: qfReciters,
    );

    if (verseByVerseCapable.isNotEmpty) {
      return verseByVerseCapable;
    }
  } catch (e) {
    debugPrint('Error filtering verse-by-verse capable reciters: $e');
  }

  // Fallback to all QF reciters
  return qfReciters;
});

Future<List<QFRecitation>> _filterVerseByVerseCapableReciters({
  required ApiService apiService,
  required List<QFRecitation> reciters,
}) async {
  if (reciters.isEmpty) return const [];

  // Keep this bounded to avoid excessive API calls.
  final probeList = reciters.take(35).toList();
  final checks = await Future.wait(
    probeList.map((reciter) async {
      try {
        final audioFiles = await apiService.getQFAudioForChapter(reciter.id, 1);
        return audioFiles.isNotEmpty ? reciter : null;
      } catch (_) {
        return null;
      }
    }),
  );

  final supported = checks.whereType<QFRecitation>().toList();
  if (supported.isEmpty) {
    return const [];
  }

  final supportedIds = supported.map((reciter) => reciter.id).toSet();
  return reciters
      .where((reciter) => supportedIds.contains(reciter.id))
      .toList();
}

final selectedReciterProvider =
    NotifierProvider<SelectedReciterNotifier, QFRecitation?>(
      SelectedReciterNotifier.new,
    );

class SelectedReciterNotifier extends Notifier<QFRecitation?> {
  @override
  QFRecitation? build() => null;
  void setReciter(QFRecitation? reciter) => state = reciter;
}

// --- Surahs (Local-first) ---

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // Surahs always return both names, UI handles selection
  return apiService.getSurahs();
});

// --- Radios (Cache-then-Network) ---

final radiosProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'radios_${locale.languageCode}';

  try {
    final radios = await apiService.getRadios(language: locale.languageCode);
    if (radios.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        radios.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return radios;
    }
  } catch (e) {
    debugPrint('📴 Radios API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => RadioModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <RadioModel>[];
});

// --- Live TV (Cache-then-Network) ---

final liveTVProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  const cacheKey = 'live_tv';

  try {
    final channels = await apiService.getLiveTV();
    if (channels.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        channels.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return channels;
    }
  } catch (e) {
    debugPrint('📴 LiveTV API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => TvModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <TvModel>[];
});

// --- Azkar (Local-first, already offline) ---

final azkarProvider = FutureProvider<Map<String, List<AdhkarModel>>>((
  ref,
) async {
  final azkarService = ref.watch(azkarServiceProvider);
  final categories = await azkarService.getCategories();
  final map = <String, List<AdhkarModel>>{};
  for (final category in categories) {
    map[category] = await azkarService.getByCategory(category);
  }
  return map;
});

// --- Duas (Local-first, already offline) ---

final duasProvider = FutureProvider<Map<String, List<AdhkarModel>>>((
  ref,
) async {
  final azkarService = ref.watch(azkarServiceProvider);
  final all = await azkarService.getByCategory('Quran Dua');
  return {'Quran Dua': all};
});

// --- Hadith Books (Local-first + API enrichment) ---

final hadithBooksProvider = FutureProvider((ref) async {
  final hadithService = ref.watch(hadithServiceProvider);

  // Return local books only (instant, always available offline)
  return await hadithService.getLocalBooks();
});

final localHadithBooksProvider = FutureProvider<List<HadithBook>>((ref) async {
  final hadithService = ref.watch(hadithServiceProvider);
  return hadithService.getLocalBooks();
});

// --- Hadiths (Local-first + API fallback) ---

/// Map from API edition names to local book keys
const _editionToLocalKey = {
  'ara-bukhari': 'bukhari',
  'ara-muslim': 'muslim',
  'ara-abudawud': 'abudawud',
  'ara-tirmidhi': 'tirmidhi',
  'ara-nasai': 'nasai',
  'ara-ibnmajah': 'ibnmajah',
  'ara-malik': 'malik',
  'ara-qudsi': 'qudsi',
  'qudsi': 'qudsi',
};

final hadithsProvider = FutureProvider.family<List<HadithModel>, String>((
  ref,
  edition,
) async {
  final hadithService = ref.watch(hadithServiceProvider);

  // Resolve the local key from the API edition name
  final localKey = _editionToLocalKey[edition] ?? edition;

  // 1. Try local first (instant, offline-safe)
  final localHadiths = await hadithService.getHadithsByBook(localKey);

  return localHadiths;
});

// --- Videos (Cache-then-Network) ---

final videosProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'videos_${locale.languageCode}';

  try {
    final videos = await apiService.getVideos(language: locale.languageCode);
    if (videos.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        videos.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 3),
      );
      return videos;
    }
  } catch (e) {
    debugPrint('📴 Videos API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <VideoModel>[];
});

final videoTypesProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'video_types_${locale.languageCode}';

  try {
    final types = await apiService.getVideoTypes(language: locale.languageCode);
    if (types.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        types.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return types;
    }
  } catch (e) {
    debugPrint('📴 VideoTypes API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => VideoType.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <VideoType>[];
});

// Note: prayerTimesProvider has been replaced by prayerNotifierProvider in presentation/providers/prayer_notifier.dart

// --- Rewayat (Cache-then-Network) ---

final rewayatProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'rewayat_${locale.languageCode}';

  try {
    final rewayat = await apiService.getRewayat(language: locale.languageCode);
    if (rewayat.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        rewayat.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return rewayat;
    }
  } catch (e) {
    debugPrint('📴 Rewayat API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => Riwaya.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <Riwaya>[];
});

final quranPageProvider = FutureProvider.family<QuranPage, int>((
  ref,
  pageNumber,
) async {
  final repository = ref.watch(quranRepositoryProvider);
  return repository.getPage(pageNumber);
});
final quranSearchProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  query,
) async {
  if (query.length < 2) return [];
  final apiService = ref.watch(apiServiceProvider);
  return apiService.searchQuran(query);
});

@immutable
class AyahLookup {
  final int surah;
  final int ayah;

  const AyahLookup(this.surah, this.ayah);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahLookup && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);
}

final quranSurahProfileProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, surah) async {
      final api = ref.watch(quranApiServiceProvider);
      return api.getUnifiedSurahProfile(surah, ayahForAsbab: 1);
    });

final quranAyahAdvancedProvider =
    FutureProvider.family<Map<String, dynamic>, AyahLookup>((
      ref,
      lookup,
    ) async {
      final api = ref.watch(quranApiServiceProvider);
      final reference = '${lookup.surah}:${lookup.ayah}';
      final result = <String, dynamic>{
        'reference': reference,
        'themes': const <Map<String, dynamic>>[],
        'similar': const <Map<String, dynamic>>[],
        'mutashabihat': const <Map<String, dynamic>>[],
        'morphology': const <String, dynamic>{},
        'tajweed': const <String, dynamic>{},
        'lineNumber': const <String, dynamic>{},
      };

      try {
        result['themes'] = await api.getAyahThemes(lookup.surah, lookup.ayah);
      } catch (_) {}
      try {
        result['similar'] = await api.getSimilarAyah(lookup.surah, lookup.ayah);
      } catch (_) {}
      try {
        result['mutashabihat'] = await api.getMutashabihat(
          lookup.surah,
          lookup.ayah,
        );
      } catch (_) {}
      try {
        result['morphology'] = await api.getMorphologyWord('$reference:1');
      } catch (_) {}
      try {
        result['tajweed'] = await api.getWordTajweed(
          surah: lookup.surah,
          ayah: lookup.ayah,
          word: 1,
        );
      } catch (_) {}
      try {
        result['lineNumber'] = await api.getWordLineNumber(
          surah: lookup.surah,
          ayah: lookup.ayah,
          word: 1,
        );
      } catch (_) {}

      return result;
    });

final quranExtendedSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      query,
    ) async {
      final trimmed = query.trim();
      if (trimmed.length < 2) return const [];

      final api = ref.watch(quranApiServiceProvider);
      final merged = <Map<String, dynamic>>[];
      try {
        final general = await api.searchGeneralQuran(trimmed, limit: 25);
        merged.addAll(
          general.map((item) => <String, dynamic>{'source': 'qurani', ...item}),
        );
      } catch (_) {}
      try {
        final pedia = await api.searchQuranpedia(trimmed, 'surahs');
        merged.addAll(
          pedia.map(
            (item) => <String, dynamic>{'source': 'quranpedia', ...item},
          ),
        );
      } catch (_) {}
      return merged;
    });

final quranAudioEditionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(quranApiServiceProvider);
  return api.getEditions(type: 'audio');
});

final quranNarrationDifferencesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final api = ref.watch(quranApiServiceProvider);
      return api.getNarrationsDifferences();
    });

// --- Sira (Prophetic Biography) ---

final siraProvider = FutureProvider<List<SiraStage>>((ref) async {
  final service = ref.watch(siraServiceProvider);
  return service.loadSira();
});

final audioPlayerServiceProvider = Provider<AudioPlayerService?>((ref) {
  final handlerAsync = ref.watch(audioHandlerProvider);
  return handlerAsync.when(
    data: (handler) => AudioPlayerService(handler),
    loading: () => null,
    error: (_, __) => null,
  );
});
