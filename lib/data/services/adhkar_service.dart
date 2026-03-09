import 'package:islam_home/data/database/adhkar_database.dart';
import 'package:islam_home/data/models/adhkar_model.dart';
import 'package:islam_home/data/services/adhkar_import_service.dart';

class AdhkarService {
  static const List<String> orderedCategories = [
    'Morning',
    'Evening',
    'Sleep',
    'Prayer',
    'After Prayer',
    'Mosque',
    'Food',
    'Travel',
    'Home',
    'General',
    'Tasbeeh',
    'Quran Dua',
  ];

  static const Map<String, String> _categoryAliases = {
    'morning_azkar': 'Morning',
    'evening_azkar': 'Evening',
    'sleep_azkar': 'Sleep',
    'wake_up_azkar': 'Sleep',
    'adhan_azkar': 'Prayer',
    'wudu_azkar': 'Prayer',
    'mosque_azkar': 'Mosque',
    'miscellaneous_azkar': 'General',
    'prophetic_duas': 'General',
    'prophets_duas': 'General',
    'quran_duas': 'Quran Dua',
  };

  static const Map<String, List<String>> _searchAliases = {
    'morning': ['fajr', 'sunrise', 'sabah', 'الصباح', 'اذكار الصباح'],
    'evening': ['night', 'maghrib', 'isha', 'masa', 'المساء', 'اذكار المساء'],
    'sleep': ['bed', 'wake', 'sleeping', 'النوم'],
    'prayer': ['salah', 'salat', 'wudu', 'athan', 'prayers', 'الصلاة'],
    'after prayer': ['after salah', 'taslim', 'post prayer', 'بعد الصلاة'],
    'mosque': ['masjid', 'jumuah', 'المسجد'],
    'food': ['eat', 'drink', 'meal', 'الطعام'],
    'travel': ['journey', 'trip', 'ride', 'السفر'],
    'home': ['house', 'entering home', 'المنزل'],
    'tasbeeh': ['tasbih', 'tahmid', 'takbir', 'تسبيح'],
    'quran dua': ['ayah', 'surah', 'rabbana', 'دعاء قرآني'],
    'general': ['dua', 'dhikr', 'zikr', 'ذكر'],
  };

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
    final existing = all.map((e) => normalizeCategory(e.category)).toSet();
    return orderedCategories.where(existing.contains).toList(growable: false);
  }

  Future<List<AdhkarModel>> getByCategory(String category) async {
    await bootstrap();
    final normalized = normalizeCategory(category);
    final box = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;

    final filtered = box.values
        .where((item) => normalizeCategory(item.category) == normalized)
        .map((item) {
          final isFavorite = favoriteBox.get(item.id.toString()) ?? false;
          return item.copyWith(
            category: normalized,
            favorite: isFavorite,
            title: item.title.isEmpty ? normalized : item.title,
          );
        })
        .toList(growable: false);

    filtered.sort((a, b) => a.id.compareTo(b.id));
    return filtered;
  }

  Future<AdhkarModel?> getById(int id) async {
    await bootstrap();
    final box = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;
    final item = box.get(id);
    if (item == null) return null;
    return item.copyWith(
      category: normalizeCategory(item.category),
      favorite: favoriteBox.get(id.toString()) ?? false,
    );
  }

  Future<List<AdhkarModel>> search(String query) async {
    await bootstrap();
    final normalizedQuery = _normalizeForSearch(query);
    if (normalizedQuery.isEmpty) return const [];
    final queryTokens = _expandQueryTokens(normalizedQuery);

    final box = AdhkarDatabase.adhkarBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;

    final results = box.values
        .where((item) {
          final haystack = _normalizeForSearch(
            '${item.title} ${item.textAr} ${item.textEn} '
            '${item.reference} ${normalizeCategory(item.category)}',
          );
          if (haystack.contains(normalizedQuery)) return true;
          for (final token in queryTokens) {
            if (!haystack.contains(token)) {
              return false;
            }
          }
          return queryTokens.isNotEmpty;
        })
        .map((item) {
          final isFavorite = favoriteBox.get(item.id.toString()) ?? false;
          return item.copyWith(
            category: normalizeCategory(item.category),
            favorite: isFavorite,
          );
        })
        .toList(growable: false);

    results.sort((a, b) => a.id.compareTo(b.id));
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
            category: normalizeCategory(item.category),
            favorite: true,
          ),
        )
        .toList(growable: false);

    favorites.sort((a, b) => a.id.compareTo(b.id));
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

  Set<String> _expandQueryTokens(String normalizedQuery) {
    final expanded = <String>{};
    final tokens = normalizedQuery.split(' ').where((e) => e.isNotEmpty);
    expanded.addAll(tokens);

    final whole = normalizedQuery;
    if (_searchAliases.containsKey(whole)) {
      expanded.addAll(_searchAliases[whole]!);
    }

    for (final entry in _searchAliases.entries) {
      final key = entry.key;
      final aliases = entry.value.map(_normalizeForSearch).toSet();
      if (expanded.contains(key) ||
          aliases.any((alias) => expanded.contains(alias))) {
        expanded.add(key);
        expanded.addAll(aliases);
      }
    }

    return expanded.map(_normalizeForSearch).where((e) => e.isNotEmpty).toSet();
  }

  String normalizeCategory(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'General';

    if (orderedCategories.contains(trimmed)) return trimmed;

    final lower = trimmed.toLowerCase();
    if (_categoryAliases.containsKey(lower)) {
      return _categoryAliases[lower]!;
    }

    switch (lower) {
      case 'morning':
        return 'Morning';
      case 'evening':
        return 'Evening';
      case 'sleep':
        return 'Sleep';
      case 'prayer':
        return 'Prayer';
      case 'after prayer':
      case 'after_prayer':
        return 'After Prayer';
      case 'mosque':
        return 'Mosque';
      case 'food':
        return 'Food';
      case 'travel':
        return 'Travel';
      case 'home':
        return 'Home';
      case 'general':
        return 'General';
      case 'tasbeeh':
        return 'Tasbeeh';
      case 'quran dua':
      case 'qurandua':
        return 'Quran Dua';
      default:
        return 'General';
    }
  }
}
