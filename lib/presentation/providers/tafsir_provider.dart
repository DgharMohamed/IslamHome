import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/tafsir_model.dart';
import 'package:islam_home/data/repositories/tafsir_repository.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:flutter/foundation.dart';

final tafsirRepositoryProvider = Provider((ref) => TafsirRepository());

final availableTafasirProvider = FutureProvider<List<TafsirItem>>((ref) async {
  final repository = ref.watch(tafsirRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final cache = ref.watch(cacheServiceProvider);
  final cacheKey = 'available_tafasir_${locale.languageCode}';

  try {
    final tafasir = await repository.getAvailableTafasir(
      language: locale.languageCode,
    );
    if (tafasir.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        tafasir.map((e) => {'id': e.id, 'url': e.url, 'name': e.name}).toList(),
        ttl: const Duration(days: 7),
      );
      return tafasir;
    }
  } catch (e) {
    debugPrint('📴 Tafasir API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => TafsirItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return [];
});

class SelectedTafsirIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void setId(int? id) => state = id;
}

final selectedTafsirIdProvider =
    NotifierProvider<SelectedTafsirIdNotifier, int?>(
      SelectedTafsirIdNotifier.new,
    );

final tafsirSurahsProvider = FutureProvider<List<TafsirSurah>>((ref) async {
  final repository = ref.watch(tafsirRepositoryProvider);
  final selectedTafsirId = ref.watch(selectedTafsirIdProvider);
  final locale = ref.watch(localeProvider);
  final cache = ref.watch(cacheServiceProvider);

  // If no tafsir selected, default to the first one available
  int? tafsirIdToFetch = selectedTafsirId;

  if (tafsirIdToFetch == null) {
    final availableTafasir = await ref.watch(availableTafasirProvider.future);
    if (availableTafasir.isNotEmpty) {
      tafsirIdToFetch = availableTafasir.first.id;
      // We don't necessarily update the provider here, just use the first one
    } else {
      return [];
    }
  }

  final cacheKey = 'tafsir_surahs_${tafsirIdToFetch}_${locale.languageCode}';

  try {
    final surahs = await repository.getTafsirSurahs(
      tafsirIdToFetch,
      language: locale.languageCode,
    );
    if (surahs.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        surahs
            .map(
              (e) => {
                'id': e.id,
                'tafsir_id': e.tafsirId,
                'name': e.name,
                'url': e.url,
                'sura_id': e.surahId,
              },
            )
            .toList(),
        ttl: const Duration(days: 7),
      );
      return surahs;
    }
  } catch (e) {
    debugPrint('📴 Tafsir Surahs API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => TafsirSurah.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  return [];
});
