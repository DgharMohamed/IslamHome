import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islam_home/data/models/sira_model.dart';

class LocalSiraService {
  List<SiraStage>? _siraCache;

  /// Load all Sira stages from local JSON file
  Future<List<SiraStage>> loadSira() async {
    if (_siraCache != null) return _siraCache!;

    try {
      debugPrint('📖 Loading sira.json...');
      final jsonString = await rootBundle.loadString(
        'assets/data/sira/sira.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _siraCache = jsonData
          .map((item) => SiraStage.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Loaded ${_siraCache!.length} Sira stages');
      return _siraCache!;
    } catch (e) {
      debugPrint('❌ Error loading Sira: $e');
      return [];
    }
  }

  /// Get a specific stage by ID
  Future<SiraStage?> getStageById(int id) async {
    final all = await loadSira();
    try {
      return all.firstWhere((stage) => stage.id == id);
    } catch (_) {
      return null;
    }
  }
}
