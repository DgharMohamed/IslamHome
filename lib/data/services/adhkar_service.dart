import 'package:islam_home/data/database/adhkar_database.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/services/adhkar_import_service.dart';

class AdhkarService {
  final AdhkarImportService _importService;

  AdhkarService({AdhkarImportService? importService})
    : _importService = importService ?? AdhkarImportService();

  Future<void> bootstrap() async {
    await AdhkarDatabase.init();
    await _importService.importIfNeeded();
  }

  Future<List<String>> getCategories() async {
    await bootstrap();
    final box = AdhkarDatabase.adhkarBox;
    final all = box.values.toList(growable: false);
    final categories = all.map((e) => e.category).toSet().toList();
    // Maintain a basic sensible order for main categories if they exist
    final topOrder = ['أذكار الصباح', 'أذكار المساء', 'أذكار النوم', 'أذكار الصلاة'];
    categories.sort((a, b) {
      final indexA = topOrder.indexOf(a);
      final indexB = topOrder.indexOf(b);
      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.compareTo(b);
    });
    return categories;
  }

  Future<List<AdhkarModel>> getByCategory(String category) async {
    await bootstrap();
    final box = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;

    final filtered = box.values
        .where((item) => item.category == category)
        .map((item) {
          final isFavorite = favoriteBox.get(item.id.toString()) ?? false;
          return item.copyWith(
            favorite: isFavorite,
            title: item.title.isEmpty ? category : item.title,
          );
        })
        .toList(growable: false);

    return filtered;
  }

  Future<AdhkarModel?> getById(int id) async {
    await bootstrap();
    final box = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;
    final item = box.get(id);
    if (item == null) return null;
    return item.copyWith(
      favorite: favoriteBox.get(id.toString()) ?? false,
    );
  }

  Future<List<AdhkarModel>> search(String query) async {
    await bootstrap();
    final normalizedQuery = _normalizeForSearch(query);
    if (normalizedQuery.isEmpty) return const [];

    final box = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;

    final results = box.values
        .where((item) {
          final haystack = _normalizeForSearch(
            '${item.title} ${item.textAr} ${item.textEn} '
            '${item.reference} ${item.category} '
            '${item.textArWithoutDiacritics}',
          );
          return haystack.contains(normalizedQuery);
        })
        .map((item) {
          final isFavorite = favoriteBox.get(item.id.toString()) ?? false;
          return item.copyWith(
            favorite: isFavorite,
          );
        })
        .toList(growable: false);

    return results;
  }

  Future<void> toggleFavorite(int id) async {
    await bootstrap();
    final favoriteBox = AdhkarDatabase.favoriteBox;
    final current = favoriteBox.get(id.toString()) ?? false;
    await favoriteBox.put(id.toString(), !current);

    final adhkarBox = AdhkarDatabase.adhkarBox;
    final item = adhkarBox.get(id);
    if (item != null) {
      await adhkarBox.put(id, item.copyWith(favorite: !current));
    }
  }

  Future<List<AdhkarModel>> getFavorites() async {
    await bootstrap();
    final adhkarBox = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;

    final favorites = adhkarBox.values
        .where((item) => favoriteBox.get(item.id.toString()) ?? false)
        .map(
          (item) => item.copyWith(
            favorite: true,
          ),
        )
        .toList(growable: false);

    return favorites;
  }

  Future<int> getRemainingRepeat(int id, {required int fallbackRepeat}) async {
    await bootstrap();
    final progressBox = AdhkarDatabase.progressBox;
    return progressBox.get(id.toString()) ?? fallbackRepeat;
  }

  Future<int> decrementRepeat(int id, {required int fallbackRepeat}) async {
    await bootstrap();
    final progressBox = AdhkarDatabase.progressBox;
    final current = progressBox.get(id.toString()) ?? fallbackRepeat;
    final next = current > 0 ? current - 1 : 0;
    await progressBox.put(id.toString(), next);
    return next;
  }

  Future<void> resetRepeat(int id, {required int fallbackRepeat}) async {
    await bootstrap();
    final progressBox = AdhkarDatabase.progressBox;
    await progressBox.put(id.toString(), fallbackRepeat);
  }

  String _normalizeForSearch(String value) {
    var normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return '';

    normalized = normalized
        .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');

    normalized = normalized
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalized;
  }

  String normalizeCategory(String raw) {
    return raw.trim();
  }
}
