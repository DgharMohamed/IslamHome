import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/services/adhkar_service.dart';

final adhkarServiceProvider = Provider<AdhkarService>((ref) {
  return AdhkarService();
});

final adhkarVersionProvider = NotifierProvider<AdhkarVersionNotifier, int>(
  AdhkarVersionNotifier.new,
);

class AdhkarVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final adhkarActionsProvider = Provider<AdhkarActions>((ref) {
  return AdhkarActions(ref);
});

class AdhkarActions {
  final Ref _ref;
  AdhkarActions(this._ref);

  Future<void> toggleFavorite(int id) async {
    final service = _ref.read(adhkarServiceProvider);
    await service.toggleFavorite(id);
    _ref.read(adhkarVersionProvider.notifier).bump();
  }

  Future<int> decrementRepeat(int id, {required int fallbackRepeat}) async {
    final service = _ref.read(adhkarServiceProvider);
    final next = await service.decrementRepeat(
      id,
      fallbackRepeat: fallbackRepeat,
    );
    _ref.read(adhkarVersionProvider.notifier).bump();
    return next;
  }

  Future<void> resetRepeat(int id, {required int fallbackRepeat}) async {
    final service = _ref.read(adhkarServiceProvider);
    await service.resetRepeat(id, fallbackRepeat: fallbackRepeat);
    _ref.read(adhkarVersionProvider.notifier).bump();
  }
}

final adhkarInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(adhkarServiceProvider);
  await service.bootstrap();
});

final adhkarCategoriesProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(adhkarVersionProvider);
  await ref.watch(adhkarInitProvider.future);
  final service = ref.watch(adhkarServiceProvider);
  return service.getCategories();
});

final adhkarCategoryCountProvider = FutureProvider.family<int, String>((
  ref,
  category,
) async {
  ref.watch(adhkarVersionProvider);
  await ref.watch(adhkarInitProvider.future);
  final service = ref.watch(adhkarServiceProvider);
  final list = await service.getByCategory(category);
  return list.length;
});

final adhkarByCategoryProvider =
    FutureProvider.family<List<AdhkarModel>, String>((ref, category) async {
      ref.watch(adhkarVersionProvider);
      await ref.watch(adhkarInitProvider.future);
      final service = ref.watch(adhkarServiceProvider);
      return service.getByCategory(category);
    });

final adhkarByIdProvider = FutureProvider.family<AdhkarModel?, int>((
  ref,
  id,
) async {
  ref.watch(adhkarVersionProvider);
  await ref.watch(adhkarInitProvider.future);
  final service = ref.watch(adhkarServiceProvider);
  return service.getById(id);
});

final adhkarFavoritesProvider = FutureProvider<List<AdhkarModel>>((ref) async {
  ref.watch(adhkarVersionProvider);
  await ref.watch(adhkarInitProvider.future);
  final service = ref.watch(adhkarServiceProvider);
  return service.getFavorites();
});

final adhkarSearchProvider = FutureProvider.family<List<AdhkarModel>, String>((
  ref,
  query,
) async {
  ref.watch(adhkarVersionProvider);
  await ref.watch(adhkarInitProvider.future);
  final service = ref.watch(adhkarServiceProvider);
  return service.search(query);
});

final adhkarRemainingProvider =
    FutureProvider.family<int, ({int id, int repeat})>((ref, payload) async {
      ref.watch(adhkarVersionProvider);
      await ref.watch(adhkarInitProvider.future);
      final service = ref.watch(adhkarServiceProvider);
      return service.getRemainingRepeat(
        payload.id,
        fallbackRepeat: payload.repeat,
      );
    });
