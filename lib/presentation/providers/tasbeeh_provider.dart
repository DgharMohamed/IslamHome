import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/data/services/tasbeeh_service.dart';

final tasbeehServiceProvider = Provider((ref) => TasbeehService());

final tasbeehListProvider =
    NotifierProvider<TasbeehNotifier, List<TasbeehModel>>(TasbeehNotifier.new);

class TasbeehNotifier extends Notifier<List<TasbeehModel>> {
  TasbeehService get _service => ref.read(tasbeehServiceProvider);

  @override
  List<TasbeehModel> build() {
    // Hive boxes are already opened in main.dart, so we can access them synchronously.
    return _service.getDhikrList();
  }

  Future<void> increment(String id) async {
    final dhikr = state.firstWhere((d) => d.id == id);
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
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) dhikr.copyWith(count: 0) else dhikr,
    ];

    final updatedDhikr = state.firstWhere((d) => d.id == id);
    await _service.updateDhikr(updatedDhikr);
  }

  Future<void> updateTarget(String id, int target) async {
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) dhikr.copyWith(target: target) else dhikr,
    ];

    final updatedDhikr = state.firstWhere((d) => d.id == id);
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
  @override
  String? build() {
    // Return null initially. The UI or first list load will handle selection.
    return null;
  }

  void set(String? id) {
    if (state != id) {
      state = id;
    }
  }
}
