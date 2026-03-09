import 'package:flutter_test/flutter_test.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/presentation/providers/khatma_v2_provider.dart';

void main() {
  group('KhatmaTrack progress math', () {
    test('starts at zero when currentUnit is start-1', () {
      final track = KhatmaTrack(
        id: 't1',
        title: 'T1',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 30),
        startPage: 1,
        endPage: 604,
        currentPage: 0,
        unit: KhatmaUnit.page,
      );

      expect(track.completedUnits, 0);
      expect(track.remainingUnits, 604);
      expect(track.overallProgress, 0);
    });

    test('reaches 100% at end unit', () {
      final track = KhatmaTrack(
        id: 't2',
        title: 'T2',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 30),
        startPage: 1,
        endPage: 30,
        currentPage: 30,
        unit: KhatmaUnit.juz,
      );

      expect(track.completedUnits, 30);
      expect(track.remainingUnits, 0);
      expect(track.overallProgress, 1);
    });
  });

  group('Daily goal and remediation', () {
    test('daily goal includes current day', () {
      final track = KhatmaTrack(
        id: 't3',
        title: 'T3',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 10),
        startPage: 1,
        endPage: 10,
        currentPage: 4, // completed 4 units, remaining 6
        unit: KhatmaUnit.page,
      );

      final goal = KhatmaV2Notifier.calculateDailyGoalForTrack(
        track,
        now: DateTime(2026, 3, 8),
      );

      // Remaining days are 8,9,10 => 3 days
      expect(goal, 2);
    });

    test('catch-up plan adds backlog over a short window', () {
      final track = KhatmaTrack(
        id: 't4',
        title: 'T4',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 10),
        startPage: 1,
        endPage: 10,
        currentPage: 3,
        unit: KhatmaUnit.page,
      );

      final plan = KhatmaV2Notifier.buildRemediationPlan(
        track,
        RemediationStrategy.catchUp,
        now: DateTime(2026, 3, 7),
      );

      expect(plan.catchUpDays, inInclusiveRange(1, 3));
      expect(plan.suggestedDailyGoal, greaterThanOrEqualTo(1));
      expect(plan.backlogUnits, greaterThanOrEqualTo(0));
    });

    test('extend plan produces bounded extra days', () {
      final track = KhatmaTrack(
        id: 't5',
        title: 'T5',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 10),
        startPage: 1,
        endPage: 604,
        currentPage: 50,
        unit: KhatmaUnit.page,
      );

      final plan = KhatmaV2Notifier.buildRemediationPlan(
        track,
        RemediationStrategy.extend,
        now: DateTime(2026, 3, 9),
      );

      expect(plan.extraDaysNeeded, inInclusiveRange(0, 3650));
      expect(plan.extendedTargetDate, isNotNull);
    });
  });

  group('Track validation', () {
    test('rejects start > end', () {
      final track = KhatmaTrack(
        id: 't6',
        title: 'T6',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 10),
        startPage: 20,
        endPage: 10,
        currentPage: 19,
        unit: KhatmaUnit.page,
      );

      expect(
        () => KhatmaV2Notifier.validateTrack(track),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects out-of-range unit boundaries', () {
      final track = KhatmaTrack(
        id: 't7',
        title: 'T7',
        type: KhatmaType.reading,
        schedulingMode: SchedulingMode.smartRemediation,
        startDate: DateTime(2026, 3, 1),
        targetDate: DateTime(2026, 3, 10),
        startPage: 1,
        endPage: 50,
        currentPage: 0,
        unit: KhatmaUnit.juz,
      );

      expect(
        () => KhatmaV2Notifier.validateTrack(track),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
