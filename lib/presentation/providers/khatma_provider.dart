import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/khatma_plan.dart';
import 'package:islam_home/data/models/khatma_completion.dart';

class KhatmaState {
  final List<KhatmaPlan> plans;
  final int currentPage;
  final List<KhatmaCompletion> completions;

  KhatmaState({
    this.plans = const [],
    this.currentPage = 1,
    this.completions = const [],
  });

  KhatmaPlan? get activePlan => plans.isNotEmpty ? plans.first : null;

  KhatmaState copyWith({
    List<KhatmaPlan>? plans,
    int? currentPage,
    List<KhatmaCompletion>? completions,
  }) {
    return KhatmaState(
      plans: plans ?? this.plans,
      currentPage: currentPage ?? this.currentPage,
      completions: completions ?? this.completions,
    );
  }
}

class KhatmaNotifier extends Notifier<KhatmaState> {
  @override
  KhatmaState build() {
    final box = Hive.box('settings');
    final plansJson = box.get('khatma_plans', defaultValue: []);
    final lastPage = box.get('last_mushaf_page', defaultValue: 1);

    final plans = (plansJson as List)
        .map((e) => KhatmaPlan.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Fallback for old single plan data
    if (plans.isEmpty) {
      final oldPlanJson = box.get('khatma_plan');
      if (oldPlanJson != null) {
        plans.add(KhatmaPlan.fromJson(Map<String, dynamic>.from(oldPlanJson)));
      }
    }

    final completionsJson = box.get('khatma_history', defaultValue: []);
    final completions = (completionsJson as List)
        .map((e) => KhatmaCompletion.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return KhatmaState(
      plans: plans,
      currentPage: lastPage,
      completions: completions,
    );
  }

  Future<void> setPlan(int days, {required String title}) async {
    final box = Hive.box('settings');
    final lastPage = box.get('last_mushaf_page', defaultValue: 1);

    final newPlan = KhatmaPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetDays: days,
      startDate: DateTime.now(),
      startPage: lastPage,
    );

    final newPlans = [newPlan, ...state.plans];
    await box.put('khatma_plans', newPlans.map((e) => e.toJson()).toList());
    state = state.copyWith(plans: newPlans);
  }

  Future<void> updateProgress(int page) async {
    final box = Hive.box('settings');
    await box.put('last_mushaf_page', page);
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeKhatma(String planId) async {
    final box = Hive.box('settings');
    final plan = state.plans.cast<KhatmaPlan?>().firstWhere(
      (p) => p?.id == planId,
      orElse: () => null,
    );

    if (state.currentPage >= 604) {
      final completion = KhatmaCompletion(
        completionDate: DateTime.now(),
        startDate: plan?.startDate ?? DateTime.now(),
        totalDays: plan != null
            ? DateTime.now().difference(plan.startDate).inDays
            : 0,
      );

      final newHistory = [...state.completions, completion];
      await box.put(
        'khatma_history',
        newHistory.map((e) => e.toJson()).toList(),
      );
      state = state.copyWith(completions: newHistory);
    }

    final newPlans = state.plans.where((p) => p.id != planId).toList();
    await box.put('khatma_plans', newPlans.map((e) => e.toJson()).toList());

    // If it was the last mushaf page reference, maybe reset to 1
    if (newPlans.isEmpty) {
      await box.put('last_mushaf_page', 1);
      state = state.copyWith(plans: newPlans, currentPage: 1);
    } else {
      state = state.copyWith(plans: newPlans);
    }
  }

  Future<void> cancelPlan(String planId) async {
    final box = Hive.box('settings');
    final newPlans = state.plans.where((p) => p.id != planId).toList();
    await box.put('khatma_plans', newPlans.map((e) => e.toJson()).toList());
    state = state.copyWith(plans: newPlans);
  }

  // Business Logic
  int get pagesNeededToday {
    final plan = state.activePlan;
    if (plan == null) return 0;

    final now = DateTime.now();
    // Use smart allocation: how many pages per day from NOW to finish on time
    final smartDaily = plan.smartPagesPerDay(state.currentPage, now);

    // If they are behind, smartDaily will be higher than original pagesPerDay
    // We can show the ceiling of it as the target for today
    return smartDaily.ceil();
  }

  double get overallProgress {
    return (state.currentPage / 604).clamp(0.0, 1.0);
  }
}

final khatmaProvider = NotifierProvider<KhatmaNotifier, KhatmaState>(() {
  return KhatmaNotifier();
});
