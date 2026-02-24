import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:islam_home/data/services/api_service.dart';
import 'package:islam_home/data/services/local_quran_service.dart';
import 'package:islam_home/data/services/local_hadith_service.dart';
import 'package:islam_home/data/services/local_adhkar_service.dart';
import 'package:islam_home/data/services/quran_image_service.dart';
import 'package:islam_home/data/services/offline_cache_service.dart';
import 'package:islam_home/data/services/last_read_service.dart';
import 'package:islam_home/data/services/local_sira_service.dart';
import 'package:islam_home/data/services/quran_audio_sync_service.dart';
import 'package:islam_home/data/services/audio_player_service.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:islam_home/data/models/radio_model.dart';
import 'package:islam_home/data/models/tv_model.dart';
import 'package:islam_home/data/models/video_model.dart';
import 'package:islam_home/data/models/riwaya_model.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:islam_home/data/models/sira_model.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

// --- Core Service Providers ---

final apiServiceProvider = Provider((ref) => ApiService());
final quranServiceProvider = Provider((ref) => LocalQuranService());
final quranImageServiceProvider = Provider((ref) => QuranImageService());
final hadithServiceProvider = Provider((ref) => LocalHadithService());
final azkarServiceProvider = Provider((ref) => LocalAdhkarService());
final siraServiceProvider = Provider((ref) => LocalSiraService());
final cacheServiceProvider = Provider((ref) => OfflineCacheService());
final lastReadServiceProvider = Provider((ref) => LastReadService());
final quranAudioSyncServiceProvider = Provider(
  (ref) => QuranAudioSyncService(Dio()),
);

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

// --- Surahs (Local-first) ---

final surahsProvider = FutureProvider((ref) async {
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
  // Try local first
  final local = await azkarService.getLocalAzkar();
  if (local.isNotEmpty) return local;

  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAzkar();
});

// --- Duas (Local-first, already offline) ---

final duasProvider = FutureProvider<Map<String, List<AdhkarModel>>>((
  ref,
) async {
  final azkarService = ref.watch(azkarServiceProvider);
  // Try local first
  final local = await azkarService.getLocalDuas();
  if (local.isNotEmpty) return local;

  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDuas();
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

final quranPageProvider = FutureProvider.family<QuranContent?, int>((
  ref,
  pageNumber,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getQuranPage(pageNumber);
});
final quranSearchProvider = FutureProvider.family<List<Ayah>, String>((
  ref,
  query,
) async {
  if (query.length < 2) return [];
  final apiService = ref.watch(apiServiceProvider);
  return apiService.searchQuran(query);
});

// --- Sira (Prophetic Biography) ---

final siraProvider = FutureProvider<List<SiraStage>>((ref) async {
  final service = ref.watch(siraServiceProvider);
  return service.loadSira();
});

final audioPlayerServiceProvider = Provider<AudioPlayerService?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  if (handler == null) return null;
  return AudioPlayerService(handler);
});
