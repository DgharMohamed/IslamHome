import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islam_home/data/database/adhkar_database.dart';
import 'package:islam_home/data/models/adhkar_model.dart';

class AdhkarImportService {
  static const String _adhkarAssetPath = 'assets/adhkar/adhkar.json';
  static const int _datasetVersion = 3;
  static const String _datasetVersionKey = 'dataset_version';

  Future<void> importIfNeeded() async {
    final box = AdhkarDatabase.adhkarBox;
    final metaBox = AdhkarDatabase.metaBox;
    final favoriteBox = AdhkarDatabase.favoriteBox;
    final progressBox = AdhkarDatabase.progressBox;

    final storedVersion =
        metaBox.get(_datasetVersionKey, defaultValue: 0) as int? ?? 0;
    final needsImport = box.isEmpty || storedVersion < _datasetVersion;

    if (!needsImport) {
      return;
    }

    try {
      if (box.isNotEmpty) {
        await box.clear();
      }
      await favoriteBox.clear();
      await progressBox.clear();

      final jsonString = await rootBundle.loadString(_adhkarAssetPath);
      final dynamic decoded = jsonDecode(jsonString);
      final parsed = _parseJson(decoded);

      if (parsed.isEmpty) return;

      final Map<int, AdhkarModel> entries = {
        for (final item in parsed) item.id: item,
      };
      await box.putAll(entries);
      await metaBox.put(_datasetVersionKey, _datasetVersion);
      debugPrint(
        'AdhkarImportService: imported ${entries.length} adhkar items (v$_datasetVersion)',
      );
    } catch (e) {
      debugPrint('AdhkarImportService: import failed: $e');
      rethrow;
    }
  }

  List<AdhkarModel> _parseJson(dynamic decoded) {
    if (decoded is List) {
      return _parseList(decoded);
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded['items'] is List) {
        return _parseList(decoded['items'] as List);
      }

      // Support category-keyed maps if needed.
      final all = <AdhkarModel>[];
      int generatedId = 1;
      decoded.forEach((category, value) {
        if (value is! List) return;
        for (final item in value) {
          if (item is! Map<String, dynamic>) continue;
          final withCategory = Map<String, dynamic>.from(item);
          withCategory['category'] ??= category;
          final parsed = AdhkarModel.fromJson(withCategory);
          final id = parsed.id == 0 ? generatedId++ : parsed.id;
          all.add(parsed.copyWith(id: id));
        }
      });
      return all;
    }

    return const [];
  }

  List<AdhkarModel> _parseList(List<dynamic> list) {
    final result = <AdhkarModel>[];
    int generatedId = 1;

    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final parsed = AdhkarModel.fromJson(item);
      final id = parsed.id == 0 ? generatedId++ : parsed.id;
      result.add(parsed.copyWith(id: id));
    }

    return result;
  }
}
