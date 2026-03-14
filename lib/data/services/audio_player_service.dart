import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/services/audio_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:islam_home/data/models/video_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:async';

// Provider to hold the AudioHandler instance
// Provider to hold the AudioHandler instance
final audioHandlerProvider = FutureProvider<AudioHandler>((ref) async {
  return await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.islamhome.app.audio',
      androidNotificationChannelName: 'Islam Home Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
});

// Provider to hold the underlying AudioPlayer for UI streams
// Returns null if handler not yet initialized
// Provider to hold the underlying AudioPlayer for UI streams
final playerProvider = Provider<AudioPlayer?>((ref) {
  final handlerAsync = ref.watch(audioHandlerProvider);
  return handlerAsync.when(
    data: (handler) => (handler as AudioPlayerHandler).player,
    loading: () => null,
    error: (_, __) => null,
  );
});

class AudioPlayerService {
  final AudioHandler _handler;
  AudioHandler get handler => _handler;
  Timer? _sleepTimer;
  final _sleepTimerController = StreamController<Duration?>.broadcast();
  final _yt = YoutubeExplode();

  AudioPlayerService(this._handler);

  bool _isInterruptionOrAbortError(Object error) {
    final type = error.runtimeType.toString().toLowerCase();
    final message = error.toString().toLowerCase();
    return type.contains('playerinterruptedexception') ||
        message.contains('playerinterruptedexception') ||
        message.contains('connection aborted');
  }

  // Expose player and streams for widgets
  AudioPlayer get player => (_handler as dynamic).player;
  Stream<MediaItem?> get mediaItemStream => _handler.mediaItem;

  Future<void> playYoutubeAudio(
    String url, {
    String? title,
    String? artist,
    String? thumbUrl,
  }) async {
    try {
      debugPrint('🎵 Service: playYoutubeAudio called - url: $url');
      final videoId = VideoId.parseVideoId(url);
      if (videoId == null) {
        throw Exception('رابط غير صالح');
      }

      debugPrint('🎵 Service: Fetching YouTube manifest for $videoId');
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly;

      if (audioStreams.isEmpty) {
        throw Exception('لا توجد مسارات صوتية متاحة لهذا المقطع');
      }

      // Fallback Strategy:
      // 1. Try high-quality M4A
      // 2. Try any high-quality audio
      // 3. Try any audio (as last resort)
      final m4aStream = audioStreams
          .where((s) => s.container.name.toLowerCase() == 'm4a')
          .toList();

      final streamInfo = m4aStream.isNotEmpty
          ? m4aStream.withHighestBitrate()
          : audioStreams.withHighestBitrate();

      final streamUrl = streamInfo.url.toString();
      debugPrint(
        '🎵 Service: Resolved ${streamInfo.container.name} stream (${streamInfo.bitrate}): ${streamUrl.substring(0, 30)}...',
      );

      final source = AudioSource.uri(
        Uri.parse(streamUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Mobile Safari/537.36',
          'Referer': 'https://www.youtube.com/',
          'Origin': 'https://www.youtube.com/',
        },
        tag: MediaItem(
          id: url,
          album: 'السيرة النبوية',
          title: title ?? 'مقطع مرئي',
          artist: artist ?? 'الشيخ بدر المشاري',
          artUri: thumbUrl != null ? Uri.parse(thumbUrl) : null,
          displayTitle: title ?? 'مقطع مرئي',
          displaySubtitle: artist ?? 'الشيخ بدر المشاري',
        ),
      );

      debugPrint('🎵 Service: Setting audio source in handler');
      // Set a short timeout for source loading
      // Both AudioPlayerHandler and QuranAudioHandler have setAudioSource method
      await (_handler as dynamic)
          .setAudioSource(source)
          .timeout(const Duration(seconds: 15));

      debugPrint('🎵 Service: Starting playback');
      await _handler.play();
      debugPrint('🎵 Service: playYoutubeAudio completed successfully');
    } catch (e, st) {
      debugPrint('🎵 Service: Youtube Audio Error: $e');
      if (e is TimeoutException) {
        throw Exception('انتهت مهلة انتظار اتصال البث، يرجى المحاولة مرة أخرى');
      }
      if (_isInterruptionOrAbortError(e)) {
        debugPrint(
          '[AudioService] Playback interrupted while loading source; skipping transient error.',
        );
        return;
      }
      debugPrintStack(stackTrace: st);
      throw Exception('Unable to start playback for this source');
    }
  }

  Future<void> playUrl(
    String url, {
    String? title,
    String? artist,
    String? album,
    String? thumbUrl,
  }) async {
    try {
      debugPrint('🎵 Service: playUrl called - title: $title');
      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          album: album ?? 'المكتبة الصوتية',
          title: title ?? 'تلاوة',
          artist: artist ?? 'شخصية إسلامية',
          artUri: Uri.parse(
            thumbUrl ??
                'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
          ),
          displayTitle: title ?? 'تلاوة',
          displaySubtitle: artist ?? 'شخصية إسلامية',
        ),
      );

      await (_handler as dynamic).setAudioSource(source);
      // Wait a brief moment for the player to be ready
      await Future.delayed(const Duration(milliseconds: 100));
      await _handler.play();
      // Wait after play to ensure notification is shown
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint(
        '🎵 Service: playUrl completed, notification should be visible',
      );
    } catch (e) {
      debugPrint('🎵 Service: Audio Error: $e');
    }
  }

  Future<void> setPlaylist({
    required List<AudioSource> sources,
    int initialIndex = 0,
    bool autoPlay = true,
  }) async {
    try {
      debugPrint(
        '🎵 Service: setPlaylist called with ${sources.length} sources, initialIndex=$initialIndex, autoPlay=$autoPlay',
      );
      if (sources.isEmpty) {
        debugPrint('🎵 Service: Empty sources list');
        return;
      }

      // Stop and clear before setting new playlist to avoid (0) Source Error on some platforms
      debugPrint('🎵 Service: Stopping player before new playlist...');
      await _handler.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      final handler = _handler as dynamic;
      debugPrint(
        '🎵 Service: Calling handler.setPlaylist with ${sources.length} items...',
      );
      for (var i = 0; i < sources.length; i++) {
        final source = sources[i];
        if (source is UriAudioSource) {
          debugPrint('🎵 Service: Source [$i]: ${source.uri}');
        }
      }
      await handler.setPlaylist(sources, initialIndex: initialIndex);
      debugPrint(
        '🎵 Service: handler.setPlaylist completed, waiting for player to be ready...',
      );

      // Wait longer for the player to be ready and for the notification to register
      await Future.delayed(const Duration(milliseconds: 300));

      if (autoPlay) {
        debugPrint('🎵 Service: Now playing...');
        await _handler.play();

        // Wait after play to ensure notification is shown
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint(
          '🎵 Service: Play command sent, notification should now be visible',
        );
      } else {
        debugPrint('🎵 Service: autoPlay is false, staying paused.');
      }
    } catch (e, st) {
      debugPrint('🎵 Service: Playlist Error: $e');
      if (_isInterruptionOrAbortError(e)) {
        debugPrint(
          '[AudioService] Playlist replacement interrupted; skipping transient error.',
        );
        return;
      }
      debugPrintStack(stackTrace: st);
      throw Exception('Unable to start playlist playback');
    }
  }

  Future<void> playVideoPlaylist({
    required List<VideoModel> videos,
    int initialIndex = 0,
  }) async {
    try {
      debugPrint(
        '🎵 Service: playVideoPlaylist called with ${videos.length} videos, starting at $initialIndex',
      );

      final Map<String, String> reciterImages = {
        'بدر المشاري': 'https://i.ytimg.com/vi/qJwecTUy8PY/maxresdefault.jpg',
        'نواف السالم':
            'https://pbs.twimg.com/profile_images/1542862587086729216/zYQqXqZJ_400x400.jpg',
      };

      final sources = videos
          .where((v) => v.url != null) // Safety check
          .map((v) {
            final reciterImageUrl = reciterImages[v.reciter];

            return AudioSource.uri(
              Uri.parse(v.url!),
              tag: MediaItem(
                id: v.url!,
                album: v.reciter ?? 'السيرة النبوية',
                title: v.title ?? 'مقطع مرئي',
                artist: v.reciter ?? 'الشيخ بدر المشاري',
                artUri: Uri.parse(
                  reciterImageUrl ??
                      v.thumbUrl ??
                      'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
                ),
                displayTitle: v.title ?? 'مقطع مرئي',
                displaySubtitle: v.reciter ?? 'الشيخ بدر المشاري',
                extras: {'id': v.id},
              ),
            );
          })
          .toList();

      await setPlaylist(sources: sources, initialIndex: initialIndex);
    } catch (e) {
      debugPrint('🎵 Service: playVideoPlaylist Error: $e');
    }
  }

  Future<void> playQueue(List<MediaItem> queue, {int initialIndex = 0}) async {
    try {
      debugPrint(
        '🎵 Service: playQueue called with ${queue.length} items, starting at $initialIndex',
      );

      final sources = queue.map((item) {
        return AudioSource.uri(Uri.parse(item.id), tag: item);
      }).toList();

      await setPlaylist(sources: sources, initialIndex: initialIndex);
    } catch (e) {
      debugPrint('🎵 Service: playQueue Error: $e');
    }
  }

  // Quran audio methods moved to dedicated Quran player or simplified
  /* 
  Future<void> playQuranVerse(QuranVerse verse) async { ... }
  Future<void> playQuranPlaylist(List<QuranVerse> verses, ...) async { ... }
  */

  Future<void> skipForward() async {
    final current = player.position;
    final duration = player.duration ?? Duration.zero;
    final target = current + const Duration(seconds: 10);
    if (target < duration) {
      await player.seek(target);
    } else {
      await player.seek(duration);
    }
  }

  Future<void> skipBackward() async {
    final current = player.position;
    final target = current - const Duration(seconds: 10);
    if (target > Duration.zero) {
      await player.seek(target);
    } else {
      await player.seek(Duration.zero);
    }
  }

  Future<void> playFile(
    String filePath, {
    String? title,
    String? artist,
  }) async {
    try {
      final source = AudioSource.file(
        filePath,
        tag: MediaItem(
          id: filePath,
          album: 'التنزيلات',
          title: title ?? 'تنزيل',
          artist: artist ?? 'القارئ',
          artUri: Uri.parse(
            'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
          ),
        ),
      );
      (_handler as dynamic).mediaItem.add(source.tag as MediaItem);
      await (_handler as dynamic).setAudioSource(source);
      _handler.play();
    } catch (e) {
      debugPrint('Audio Error (File): $e');
    }
  }

  Future<void> playAthan() async {
    try {
      debugPrint('🎵 Service: playAthan called');
      final source = AudioSource.asset(
        'assets/audio/athan.mp3',
        tag: const MediaItem(
          id: 'athan_preview',
          album: 'تنبيهات الآذان',
          title: 'الآذان',
          artist: 'مؤذن إسلام هوم',
          artUri: null,
        ),
      );

      debugPrint('🎵 Service: Attempting to play athan as asset...');
      (_handler as dynamic).mediaItem.add(source.tag as MediaItem);
      await (_handler as dynamic).setAudioSource(source);
      await _handler.play();
    } catch (e) {
      debugPrint('🎵 Service: Asset play failed, attempting file fallback: $e');
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/athan_fallback.mp3');

        if (!await tempFile.exists()) {
          debugPrint('🎵 Service: Extracting asset to ${tempFile.path}');
          final data = await rootBundle.load('assets/audio/athan.mp3');
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          await tempFile.writeAsBytes(bytes);
        }

        final source = AudioSource.file(
          tempFile.path,
          tag: const MediaItem(
            id: 'athan_preview',
            album: 'تنبيهات الآذان',
            title: 'الآذان',
            artist: 'مؤذن إسلام هوم',
            artUri: null,
          ),
        );

        debugPrint('🎵 Service: Playing athan from extracted file');
        (_handler as dynamic).mediaItem.add(source.tag as MediaItem);
        await (_handler as dynamic).setAudioSource(source);
        await _handler.play();
      } catch (fallbackError) {
        debugPrint('🎵 Service: Athan fallback also failed: $fallbackError');
      }
    }
  }

  Future<void> pause() async => await _handler.pause();
  Future<void> resume() async => await _handler.play();
  Future<void> stop() async => await _handler.stop();
  Future<void> seek(Duration position) async => await _handler.seek(position);

  Future<void> skipToNext() async => await _handler.skipToNext();
  Future<void> skipToPrevious() async => await _handler.skipToPrevious();

  Stream<LoopMode> get loopModeStream => player.loopModeStream;
  Stream<double> get speedStream => player.speedStream;

  // Shuffle and Repeat
  Future<void> toggleShuffle() async {
    final enable = !(_handler as dynamic).player.shuffleModeEnabled;
    await (_handler as dynamic).player.setShuffleModeEnabled(enable);
  }

  Future<void> toggleRepeat() async {
    switch ((_handler as dynamic).player.loopMode) {
      case LoopMode.off:
        await (_handler as dynamic).player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await (_handler as dynamic).player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await (_handler as dynamic).player.setLoopMode(LoopMode.off);
        break;
    }
  }

  // Sleep Timer
  Stream<Duration?> get sleepTimerStream => _sleepTimerController.stream;

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    var remaining = duration;
    _sleepTimerController.add(remaining);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining -= const Duration(seconds: 1);
      if (remaining.inSeconds <= 0) {
        pause();
        _sleepTimer?.cancel();
        _sleepTimerController.add(null);
      } else {
        _sleepTimerController.add(remaining);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerController.add(null);
  }
}
