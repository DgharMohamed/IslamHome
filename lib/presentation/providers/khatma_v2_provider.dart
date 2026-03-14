import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class KhatmaV2State {
  final List<KhatmaTrack> tracks;
  final bool isLoading;
  final String? activeListeningTrackId;

  KhatmaV2State({
    this.tracks = const [],
    this.isLoading = false,
    this.activeListeningTrackId,
  });

  KhatmaV2State copyWith({
    List<KhatmaTrack>? tracks,
    bool? isLoading,
    String? activeListeningTrackId,
  }) {
    return KhatmaV2State(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      activeListeningTrackId:
          activeListeningTrackId ?? this.activeListeningTrackId,
    );
  }

  KhatmaTrack? getTrack(String id) {
    for (final track in tracks) {
      if (track.id == id) return track;
    }
    return null;
  }
}

class RemediationPlan {
  final RemediationStrategy strategy;
  final int suggestedDailyGoal;
  final int catchUpDays;
  final int catchUpExtraPerDay;
  final int backlogUnits;
  final int extraDaysNeeded;
  final DateTime? extendedTargetDate;
  final String details;

  const RemediationPlan({
    required this.strategy,
    required this.suggestedDailyGoal,
    this.catchUpDays = 0,
    this.catchUpExtraPerDay = 0,
    this.backlogUnits = 0,
    this.extraDaysNeeded = 0,
    this.extendedTargetDate,
    required this.details,
  });
}

class KhatmaV2Notifier extends Notifier<KhatmaV2State> {
  late Box<KhatmaTrack> _box;
  late Box _settingsBox;
  static const String _activeListeningTrackKey = 'active_listening_track_id';

  @override
  KhatmaV2State build() {
    _box = Hive.box<KhatmaTrack>('khatma_tracks_box');
    _settingsBox = Hive.box('settings_box');
    return _composeState();
  }

  Future<void> addTrack(KhatmaTrack track) async {
    validateTrack(track);
    await _box.put(track.id, track);
    if (track.type == KhatmaType.listening &&
        track.unit == KhatmaUnit.surah &&
        _settingsBox.get(_activeListeningTrackKey) == null) {
      await _settingsBox.put(_activeListeningTrackKey, track.id);
    }
    _refreshState();
  }

  Future<void> updateProgress(String trackId, int newPage) async {
    final track = _box.get(trackId);
    if (track == null) return;

    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    // Update progress map
    final currentProgress = Map<String, int>.from(track.progress);
    final normalizedNew = newPage.clamp(track.startPage - 1, track.endPage);
    final unitsToday = (normalizedNew - track.currentPage).clamp(
      0,
      track.totalUnits,
    );
    currentProgress[dateKey] = (currentProgress[dateKey] ?? 0) + unitsToday;
    final newCurrent = normalizedNew > track.currentPage
        ? normalizedNew
        : track.currentPage;

    final updatedTrack = track.copyWith(
      currentPage: newCurrent,
      progress: currentProgress,
    );

    await _box.put(trackId, updatedTrack);
    _refreshState();
  }

  Future<void> deleteTrack(String trackId) async {
    await _box.delete(trackId);
    if (_settingsBox.get(_activeListeningTrackKey) == trackId) {
      await _settingsBox.delete(_activeListeningTrackKey);
    }
    _refreshState();
  }

  Future<void> setActiveListeningTrack(String? trackId) async {
    if (trackId == null) {
      await _settingsBox.delete(_activeListeningTrackKey);
      _refreshState();
      return;
    }

    final track = _box.get(trackId);
    final isValidListeningTrack =
        track != null &&
        track.type == KhatmaType.listening &&
        track.unit == KhatmaUnit.surah;
    if (!isValidListeningTrack) return;

    await _settingsBox.put(_activeListeningTrackKey, trackId);
    _refreshState();
  }

  /// Auto-record completed surah for the first matching listening track.
  ///
  /// Returns true when progress was recorded.
  Future<bool> autoRecordListeningSurah(int surahNumber) async {
    final activeTrackId = state.activeListeningTrackId;
    if (activeTrackId != null) {
      final activeTrack = _box.get(activeTrackId);
      final isMatchingActiveTrack =
          activeTrack != null &&
          activeTrack.type == KhatmaType.listening &&
          activeTrack.unit == KhatmaUnit.surah &&
          surahNumber >= activeTrack.startPage &&
          surahNumber <= activeTrack.endPage &&
          activeTrack.currentPage < surahNumber;
      if (isMatchingActiveTrack) {
        await updateProgress(activeTrack.id, surahNumber);
        return true;
      }
    }

    KhatmaTrack? candidate;
    for (final track in state.tracks) {
      final isMatchingListeningTrack =
          track.type == KhatmaType.listening &&
          track.unit == KhatmaUnit.surah &&
          surahNumber >= track.startPage &&
          surahNumber <= track.endPage &&
          track.currentPage < surahNumber;
      if (isMatchingListeningTrack) {
        candidate = track;
        break;
      }
    }

    if (candidate == null) return false;
    await updateProgress(candidate.id, surahNumber);
    return true;
  }

  // --- Smart Engine Logic ---

  int calculateDailyGoal(String trackId) {
    final track = _box.get(trackId);
    if (track == null || track.targetDate == null) return 0;
    return calculateDailyGoalForTrack(track);
  }

  Future<void> applyRemediation(
    String trackId,
    RemediationStrategy strategy,
  ) async {
    final track = _box.get(trackId);
    if (track == null || track.targetDate == null) return;

    KhatmaTrack updatedTrack;
    final now = DateTime.now();
    final plan = buildRemediationPlan(track, strategy, now: now);
    final logEntry =
        '${DateFormat('yyyy-MM-dd HH:mm').format(now)} | ${plan.details}';

    switch (strategy) {
      case RemediationStrategy.distribute:
        updatedTrack = track.copyWith(
          remediationLog: [...track.remediationLog, logEntry],
        );
        break;
      case RemediationStrategy.catchUp:
        updatedTrack = track.copyWith(
          remediationLog: [...track.remediationLog, logEntry],
        );
        break;
      case RemediationStrategy.extend:
        final newTargetDate = plan.extendedTargetDate ?? track.targetDate!;
        updatedTrack = track.copyWith(
          targetDate: newTargetDate,
          remediationLog: [...track.remediationLog, logEntry],
        );
        break;
    }

    await _box.put(trackId, updatedTrack);
    _refreshState();
  }

  double getOverallProgress() {
    if (state.tracks.isEmpty) return 0.0;
    final totalProgress = state.tracks.fold(
      0.0,
      (sum, track) => sum + track.overallProgress,
    );
    return totalProgress / state.tracks.length;
  }

  KhatmaV2State _composeState() {
    final tracks = _box.values.toList();
    final activeTrackId = _settingsBox.get(_activeListeningTrackKey) as String?;

    final hasValidActiveListeningTrack =
        activeTrackId != null &&
        tracks.any(
          (track) =>
              track.id == activeTrackId &&
              track.type == KhatmaType.listening &&
              track.unit == KhatmaUnit.surah,
        );

    return KhatmaV2State(
      tracks: tracks,
      activeListeningTrackId: hasValidActiveListeningTrack
          ? activeTrackId
          : null,
    );
  }

  void _refreshState() {
    state = _composeState();
  }

  @visibleForTesting
  static void validateTrack(KhatmaTrack track) {
    final maxUnit = _maxUnitFor(track.unit);
    if (track.startPage < 1 || track.startPage > maxUnit) {
      throw FormatException('start_out_of_range:$maxUnit');
    }
    if (track.endPage < 1 || track.endPage > maxUnit) {
      throw FormatException('end_out_of_range:$maxUnit');
    }
    if (track.startPage > track.endPage) {
      throw const FormatException('range_order_invalid');
    }
    final minCurrent = track.startPage - 1;
    if (track.currentPage < minCurrent || track.currentPage > track.endPage) {
      throw const FormatException('current_out_of_range');
    }
  }

  static int calculateDailyGoalForTrack(
    KhatmaTrack track, {
    DateTime? now,
  }) {
    if (track.targetDate == null) return 0;
    final nowDate = now ?? DateTime.now();
    final remainingUnits = track.remainingUnits;
    final remainingDays = track.targetDate!.difference(nowDate).inDays + 1;

    if (remainingUnits <= 0) return 0;
    if (remainingDays <= 0) return remainingUnits;
    return (remainingUnits / remainingDays).ceil();
  }

  static RemediationPlan buildRemediationPlan(
    KhatmaTrack track,
    RemediationStrategy strategy, {
    DateTime? now,
  }) {
    final nowDate = now ?? DateTime.now();
    final baseGoal = calculateDailyGoalForTrack(track, now: nowDate);

    final totalDays = track.targetDate == null
        ? 1
        : (track.targetDate!
                  .difference(track.startDate)
                  .inDays +
              1)
            .clamp(1, 100000);
    final elapsedDays = (nowDate.difference(track.startDate).inDays + 1).clamp(
      1,
      totalDays,
    );
    final expectedCompleted =
        ((elapsedDays / totalDays) * track.totalUnits).floor().clamp(
          0,
          track.totalUnits,
        );
    final backlog = (expectedCompleted - track.completedUnits).clamp(
      0,
      track.totalUnits,
    );
    final remainingDays = track.targetDate == null
        ? 0
        : (track.targetDate!.difference(nowDate).inDays + 1).clamp(0, 100000);

    switch (strategy) {
      case RemediationStrategy.distribute:
        return RemediationPlan(
          strategy: strategy,
          suggestedDailyGoal: baseGoal,
          backlogUnits: backlog,
          details:
              'Distribute: daily goal $baseGoal, backlog $backlog over remaining days.',
        );
      case RemediationStrategy.catchUp:
        final catchUpDays = remainingDays <= 0 ? 1 : remainingDays.clamp(1, 3);
        final extraPerDay = backlog == 0 ? 0 : (backlog / catchUpDays).ceil();
        final suggestedGoal = baseGoal + extraPerDay;
        return RemediationPlan(
          strategy: strategy,
          suggestedDailyGoal: suggestedGoal,
          catchUpDays: catchUpDays,
          catchUpExtraPerDay: extraPerDay,
          backlogUnits: backlog,
          details:
              'Catch-up: daily $suggestedGoal ($baseGoal + $extraPerDay) for $catchUpDays days; backlog $backlog.',
        );
      case RemediationStrategy.extend:
        final plannedDailyRate = totalDays <= 0
            ? 1
            : (track.totalUnits / totalDays).ceil().clamp(1, 100000);
        final neededDays = (track.remainingUnits / plannedDailyRate)
            .ceil()
            .clamp(0, 36500);
        final extraDays = (neededDays - remainingDays).clamp(0, 3650);
        final newTargetDate = track.targetDate?.add(Duration(days: extraDays));
        return RemediationPlan(
          strategy: strategy,
          suggestedDailyGoal: plannedDailyRate,
          backlogUnits: backlog,
          extraDaysNeeded: extraDays,
          extendedTargetDate: newTargetDate,
          details:
              'Extend: +$extraDays days, new target ${newTargetDate?.toIso8601String().split('T').first}, daily $plannedDailyRate.',
        );
    }
  }

  static int _maxUnitFor(KhatmaUnit unit) {
    switch (unit) {
      case KhatmaUnit.page:
        return 604;
      case KhatmaUnit.juz:
        return 30;
      case KhatmaUnit.surah:
        return 114;
    }
  }
}

final khatmaV2Provider = NotifierProvider<KhatmaV2Notifier, KhatmaV2State>(() {
  return KhatmaV2Notifier();
});
