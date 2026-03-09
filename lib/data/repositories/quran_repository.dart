import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/quran_page_model.dart';
import 'package:islam_home/data/services/quran_api_service.dart';
import 'package:islam_home/data/services/quran_transformation_layer.dart';

class QuranRepository {
  final QuranApiService _apiService;
  static const String _boxName = 'quran_pages_v5';

  QuranRepository(this._apiService);

  /// Initializes the local storage for Quran pages.
  Future<void> init() async {
    await Hive.openBox<QuranPage>(_boxName);
  }

  /// Gets a specific Quran page, checking local cache first.
  Future<QuranPage> getPage(int pageNumber) async {
    final box = Hive.box<QuranPage>(_boxName);

    // Check cache
    if (box.containsKey(pageNumber)) {
      return box.get(pageNumber)!;
    }

    // Fetch from API
    final rawData = await _apiService.getPageData(pageNumber);

    // Transform to our 15-line model
    final transformation = QuranTransformationLayer.transform(
      rawData,
      pageNumber,
    );

    // Cache the result
    await box.put(pageNumber, transformation);

    return transformation;
  }

  /// Clears the entire Quran page cache.
  Future<void> clearCache() async {
    final box = Hive.box<QuranPage>(_boxName);
    await box.clear();
  }
}
