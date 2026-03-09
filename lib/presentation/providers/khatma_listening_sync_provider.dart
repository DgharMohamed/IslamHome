import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/khatma_v2_provider.dart';
import 'package:just_audio/just_audio.dart';

/// Keeps listening Khatma tracks in sync with completed surahs in the audio player.
final khatmaListeningSyncProvider = Provider<void>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  if (audioService == null) return;

  final sync = _KhatmaListeningSync(ref, audioService.player);
  ref.onDispose(sync.dispose);
});

class _KhatmaListeningSync {
  _KhatmaListeningSync(this._ref, this._player) {
    _lastIndex = _player.currentIndex;
    _lastPosition = _player.position;
    _currentDuration = _player.duration ?? Duration.zero;

    _positionSub = _player.positionStream.listen((position) {
      _lastPosition = position;
    });

    _durationSub = _player.durationStream.listen((duration) {
      _currentDuration = duration ?? Duration.zero;
    });

    _discontinuitySub = _player.positionDiscontinuityStream.listen((event) {
      _lastDiscontinuityReason = event.reason;
    });

    _indexSub = _player.currentIndexStream.listen(_handleIndexChange);
    _stateSub = _player.playerStateStream.listen(_handlePlayerState);
  }

  final Ref _ref;
  final AudioPlayer _player;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PositionDiscontinuity>? _discontinuitySub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<PlayerState>? _stateSub;

  Duration _lastPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  int? _lastIndex;
  PositionDiscontinuityReason? _lastDiscontinuityReason;

  int? _lastRecordedSurah;
  DateTime _lastRecordedAt = DateTime.fromMillisecondsSinceEpoch(0);

  void _handleIndexChange(int? newIndex) {
    final previousIndex = _lastIndex;
    if (previousIndex != null &&
        newIndex != null &&
        newIndex != previousIndex &&
        _lastDiscontinuityReason == PositionDiscontinuityReason.autoAdvance &&
        _looksLikeNaturalCompletion()) {
      unawaited(_recordCompletionForIndex(previousIndex));
    }

    _lastDiscontinuityReason = null;
    _lastIndex = newIndex;
    _lastPosition = _player.position;
    _currentDuration = _player.duration ?? Duration.zero;
  }

  void _handlePlayerState(PlayerState state) {
    if (state.processingState != ProcessingState.completed) return;
    final currentIndex = _player.currentIndex;
    if (currentIndex == null || !_looksLikeNaturalCompletion()) return;
    unawaited(_recordCompletionForIndex(currentIndex));
  }

  bool _looksLikeNaturalCompletion() {
    if (_currentDuration <= Duration.zero) return false;
    final threshold = _currentDuration - const Duration(seconds: 2);
    return _lastPosition >= threshold;
  }

  Future<void> _recordCompletionForIndex(int index) async {
    final sequence = _player.sequence;
    if (sequence == null || index < 0 || index >= sequence.length) return;

    final source = sequence[index];
    final tag = source.tag;
    if (tag is! MediaItem) return;

    final surahRaw = tag.extras?['surahNumber'];
    final surahNumber = surahRaw is int
        ? surahRaw
        : int.tryParse(surahRaw?.toString() ?? '');
    if (surahNumber == null) return;

    // Dedupe quick duplicate callbacks for the same finished item.
    final now = DateTime.now();
    if (_lastRecordedSurah == surahNumber &&
        now.difference(_lastRecordedAt) < const Duration(seconds: 5)) {
      return;
    }
    _lastRecordedSurah = surahNumber;
    _lastRecordedAt = now;

    final recorded = await _ref
        .read(khatmaV2Provider.notifier)
        .autoRecordListeningSurah(surahNumber);

    if (recorded) {
      debugPrint(
        'KhatmaListeningSync: Recorded completion for surah $surahNumber',
      );
    }
  }

  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _discontinuitySub?.cancel();
    _indexSub?.cancel();
    _stateSub?.cancel();
  }
}
