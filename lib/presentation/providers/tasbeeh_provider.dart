import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/data/services/tasbeeh_service.dart';

final tasbeehServiceProvider = Provider((ref) => TasbeehService());

final tasbeehListProvider =
    NotifierProvider<TasbeehNotifier, List<TasbeehModel>>(TasbeehNotifier.new);

class TasbeehNotifier extends Notifier<List<TasbeehModel>> {
  TasbeehService get _service => ref.read(tasbeehServiceProvider);

  @override
  List<TasbeehModel> build() {
    // Hive boxes are opened in main.dart; still guard against corrupted local data.
    try {
      return _service.getDhikrList();
    } catch (e) {
      debugPrint('TasbeehNotifier: failed to load dhikr list: $e');
      return const [];
    }
  }

  Future<void> increment(String id) async {
    if (state.isEmpty) return;
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final dhikr = state[index];
    final newCount = dhikr.count + 1;
    final isTargetReached = newCount >= dhikr.target;

    state = [
      for (final d in state)
        if (d.id == id)
          d.copyWith(
            count: isTargetReached ? 0 : newCount,
            totalCount: d.totalCount + 1,
          )
        else
          d,
    ];

    final updatedDhikr = state.firstWhere((d) => d.id == id);
    await _service.updateDhikr(updatedDhikr);
    await _service.incrementTotalCount();

    // Log the increment, and if target reached, log as a completed set
    await _service.logIncrement(
      id,
      count: isTargetReached ? dhikr.target : 1,
      isSetComplete: isTargetReached,
    );

    if (isTargetReached) {
      // Switch to next dhikr
      final currentIndex = state.indexWhere((d) => d.id == id);
      final nextIndex = (currentIndex + 1) % state.length;
      ref.read(activeDhikrProvider.notifier).set(state[nextIndex].id);
    }
  }

  Future<void> reset(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) dhikr.copyWith(count: 0) else dhikr,
    ];

    final updatedDhikr = state[index];
    await _service.updateDhikr(updatedDhikr);
  }

  Future<void> updateTarget(String id, int target) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final safeTarget = target < 1 ? 1 : target;
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) dhikr.copyWith(target: safeTarget) else dhikr,
    ];

    final updatedDhikr = state[index];
    await _service.updateDhikr(updatedDhikr);
  }

  int getTotalCount() {
    try {
      return _service.getTotalCount();
    } catch (e) {
      debugPrint('TasbeehNotifier: Error getting total count: $e');
      return 0;
    }
  }
}

final activeDhikrProvider = NotifierProvider<ActiveDhikrNotifier, String?>(
  ActiveDhikrNotifier.new,
);

class ActiveDhikrNotifier extends Notifier<String?> {
  static const String _activeDhikrKey = 'active_dhikr_id';
  static const String _defaultDhikrId = 'subhanallah';

  @override
  String? build() {
    final box = Hive.box('settings_box');
    final raw = box.get(_activeDhikrKey);
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return _defaultDhikrId;
  }

  void set(String? id) {
    if (state != id) {
      final safeId = (id == null || id.isEmpty) ? _defaultDhikrId : id;
      state = safeId;
      Hive.box('settings_box').put(_activeDhikrKey, safeId);
    }
  }
}
