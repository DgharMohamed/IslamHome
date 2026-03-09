import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/data/models/qf_recitation_model.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islam_home/data/services/audio_player_service.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/presentation/providers/audio_ui_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_riwaya_provider.dart';

class AyahDedicatedPlayer extends ConsumerWidget {
  const AyahDedicatedPlayer({super.key});

  void _showReciterPicker(
    BuildContext context,
    WidgetRef ref,
    MushafTheme theme,
    List<QFRecitation> reciters,
    String riwayaName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 450),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: theme.backgroundColor.computeLuminance() < 0.3
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'اختر القارئ (آية بآية)',
                    style: GoogleFonts.cairo(
                      color: theme.secondaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: theme.textColor.withValues(alpha: 0.08),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      itemCount: reciters.length,
                      itemBuilder: (context, index) {
                        return _ReciterListTile(
                          reciter: reciters[index],
                          theme: theme,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTimerPicker(
    BuildContext context,
    AudioPlayerService service,
    MushafTheme theme,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "مؤقت النوم",
                  style: GoogleFonts.amiri(
                    color: theme.secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    "15 دقيقة",
                    style: TextStyle(color: theme.textColor),
                  ),
                  onTap: () {
                    service.setSleepTimer(const Duration(minutes: 15));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    "30 دقيقة",
                    style: TextStyle(color: theme.textColor),
                  ),
                  onTap: () {
                    service.setSleepTimer(const Duration(minutes: 30));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    "60 دقيقة",
                    style: TextStyle(color: theme.textColor),
                  ),
                  onTap: () {
                    service.setSleepTimer(const Duration(minutes: 60));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    "إيقاف المؤقت",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    service.cancelSleepTimer();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioPlayerServiceProvider);
    if (audioService == null) return const SizedBox.shrink();

    final selectedReciter = ref.watch(selectedReciterProvider);
    final selectedRiwaya = ref.watch(selectedRiwayaProvider);
    final riwayaRecitersAsync = ref.watch(ayahAudioRecitersProvider);
    final mushafTheme = ref.watch(mushafThemeProvider);
    final isMinimized = ref.watch(audioPlayerMinimizedProvider);
    final riwayaReciters = riwayaRecitersAsync.maybeWhen(
      data: (reciters) => reciters,
      orElse: () => const <QFRecitation>[],
    );
    final reciterLabel =
        selectedReciter?.displayName ??
        (riwayaReciters.isNotEmpty
            ? riwayaReciters.first.displayName
            : 'مشاري العفاسي');

    return StreamBuilder<MediaItem?>(
      stream: audioService.mediaItemStream,
      builder: (context, metadataSnapshot) {
        return StreamBuilder<PlayerState>(
          stream: audioService.player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            if (playerState?.processingState == ProcessingState.idle ||
                playerState == null) {
              return const SizedBox.shrink();
            }

            final playing = playerState.playing;

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: isMinimized
                        ? const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          )
                        : const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mushafTheme.backgroundColor.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color:
                            mushafTheme.backgroundColor.computeLuminance() < 0.3
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              mushafTheme.backgroundColor.computeLuminance() <
                                  0.3
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.2),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMinimized) ...[
                          // --- COMPACT HEADER ---
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => audioService.stop(),
                                icon: const Icon(Icons.close_rounded, size: 20),
                                color: mushafTheme.textColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              // Sleep Timer
                              StreamBuilder<Duration?>(
                                stream: audioService.sleepTimerStream,
                                builder: (context, timerSnap) {
                                  final hasTimer = timerSnap.data != null;
                                  return IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _showTimerPicker(
                                      context,
                                      audioService,
                                      mushafTheme,
                                    ),
                                    icon: Icon(
                                      hasTimer
                                          ? Icons.timer_rounded
                                          : Icons.timer_outlined,
                                      size: 18,
                                    ),
                                    color: hasTimer
                                        ? mushafTheme.secondaryColor
                                        : mushafTheme.textColor.withValues(
                                            alpha: 0.5,
                                          ),
                                  );
                                },
                              ),
                              const Spacer(),
                              // Reciter Selector (Center)
                              GestureDetector(
                                onTap: () => riwayaRecitersAsync.when(
                                  data: (reciters) {
                                    if (reciters.isEmpty) return;
                                    _showReciterPicker(
                                      context,
                                      ref,
                                      mushafTheme,
                                      reciters,
                                      selectedRiwaya.name,
                                    );
                                  },
                                  loading: () {},
                                  error: (_, __) {},
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mushafTheme.textColor.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        reciterLabel,
                                        style: GoogleFonts.amiri(
                                          color: mushafTheme.textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: mushafTheme.textColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => ref
                                    .read(audioPlayerMinimizedProvider.notifier)
                                    .setMinimized(true),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 24,
                                ),
                                color: mushafTheme.textColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // --- PRIMARY CONTROLS ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Repeat Mode
                              StreamBuilder<LoopMode>(
                                stream: audioService.loopModeStream,
                                builder: (context, loopSnap) {
                                  final mode = loopSnap.data ?? LoopMode.off;
                                  IconData icon = mode == LoopMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded;
                                  Color color = mode != LoopMode.off
                                      ? mushafTheme.secondaryColor
                                      : mushafTheme.textColor.withValues(
                                          alpha: 0.3,
                                        );
                                  return IconButton(
                                    onPressed: () =>
                                        audioService.toggleRepeat(),
                                    icon: Icon(icon, color: color, size: 20),
                                  );
                                },
                              ),
                              // Prev
                              IconButton(
                                onPressed: () => audioService.skipToPrevious(),
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  size: 32,
                                ),
                                color: mushafTheme.textColor,
                              ),
                              // Play/Pause
                              GestureDetector(
                                onTap: () => playing
                                    ? audioService.pause()
                                    : audioService.resume(),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: mushafTheme.textColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: mushafTheme.backgroundColor,
                                    size: 36,
                                  ),
                                ),
                              ),
                              // Next
                              IconButton(
                                onPressed: () => audioService.skipToNext(),
                                icon: const Icon(
                                  Icons.skip_previous_rounded,
                                  size: 32,
                                ),
                                color: mushafTheme.textColor,
                              ),
                              // Speed
                              StreamBuilder<double>(
                                stream: audioService.speedStream,
                                builder: (context, speedSnap) {
                                  final speed = speedSnap.data ?? 1.0;
                                  return TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(44, 44),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
                                      final speeds = [1.0, 1.25, 1.5, 2.0];
                                      final nextIdx =
                                          (speeds.indexOf(speed) + 1) %
                                          speeds.length;
                                      audioService.player.setSpeed(
                                        speeds[nextIdx],
                                      );
                                    },
                                    child: Text(
                                      "${speed}x",
                                      style: TextStyle(
                                        color: mushafTheme.textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // --- PROGRESS BAR ---
                          StreamBuilder<Duration>(
                            stream: audioService.player.positionStream,
                            builder: (context, posSnap) {
                              final duration =
                                  audioService.player.duration ?? Duration.zero;
                              final position = posSnap.data ?? Duration.zero;
                              final progress = (duration.inMilliseconds > 0)
                                  ? (position.inMilliseconds /
                                            duration.inMilliseconds)
                                        .clamp(0.0, 1.0)
                                  : 0.0;

                              return Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 10,
                                          ),
                                      activeTrackColor:
                                          mushafTheme.secondaryColor,
                                      inactiveTrackColor: mushafTheme.textColor
                                          .withValues(alpha: 0.1),
                                      thumbColor: mushafTheme.textColor,
                                    ),
                                    child: Slider(
                                      value: progress,
                                      onChanged: (v) {
                                        final target = Duration(
                                          milliseconds:
                                              (v * duration.inMilliseconds)
                                                  .toInt(),
                                        );
                                        audioService.seek(target);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style: TextStyle(
                                            color: mushafTheme.textColor
                                                .withValues(alpha: 0.4),
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style: TextStyle(
                                            color: mushafTheme.textColor
                                                .withValues(alpha: 0.4),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ] else ...[
                          // --- MINIMIZED SLIM BAR ---
                          GestureDetector(
                            onTap: () => ref
                                .read(audioPlayerMinimizedProvider.notifier)
                                .setMinimized(false),
                            child: SizedBox(
                              height: 48,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => playing
                                        ? audioService.pause()
                                        : audioService.resume(),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: mushafTheme.textColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        playing
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: mushafTheme.backgroundColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reciterLabel,
                                          style: GoogleFonts.amiri(
                                            color: mushafTheme.textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "انقر للتوسيع والتحكم",
                                          style: TextStyle(
                                            color: mushafTheme.textColor
                                                .withValues(alpha: 0.5),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _showReciterPicker(
                                      context,
                                      ref,
                                      mushafTheme,
                                      riwayaReciters,
                                      selectedRiwaya.name,
                                    ),
                                    icon: const Icon(
                                      Icons.people_alt_rounded,
                                      size: 22,
                                    ),
                                    color: mushafTheme.textColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => audioService.stop(),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                    ),
                                    color: mushafTheme.textColor.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

class _ReciterListTile extends ConsumerStatefulWidget {
  final QFRecitation reciter;
  final MushafTheme theme;

  const _ReciterListTile({required this.reciter, required this.theme});

  @override
  ConsumerState<_ReciterListTile> createState() => _ReciterListTileState();
}

class _ReciterListTileState extends ConsumerState<_ReciterListTile> {
  bool _isDownloaded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final downloadService = ref.read(audioDownloadServiceProvider);
    final isDownloaded = await downloadService.isReciterDownloaded(
      widget.reciter.id,
    );
    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        ref.watch(selectedReciterProvider)?.id == widget.reciter.id;
    final downloadService = ref.watch(audioDownloadServiceProvider);
    final progressNotifier = downloadService.getDownloadProgress(
      widget.reciter.id,
    );

    return ListTile(
      title: Text(
        widget.reciter.displayName,
        style: GoogleFonts.amiri(
          color: isSelected
              ? widget.theme.secondaryColor
              : widget.theme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: _isChecking
          ? const SizedBox(width: 24, height: 24)
          : ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, progress, child) {
                if (progress > 0 && progress < 1.0) {
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      color: widget.theme.secondaryColor,
                    ),
                  );
                }

                if (_isDownloaded || progress == 1.0) {
                  return IconButton(
                    icon: Icon(
                      Icons.check_circle_rounded,
                      color: widget.theme.secondaryColor,
                      size: 24,
                    ),
                    onPressed: () async {
                      // Optional: confirm deletion
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: widget.theme.backgroundColor,
                          title: Text(
                            'حذف الملفات الصوتية',
                            style: TextStyle(color: widget.theme.textColor),
                          ),
                          content: Text(
                            'هل تريد مسح التلاوة المحملة لهذا القارئ من الجهاز؟',
                            style: TextStyle(color: widget.theme.textColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(color: widget.theme.textColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await downloadService.deleteReciterAudio(
                          widget.reciter.id,
                        );
                        setState(() {
                          _isDownloaded = false;
                        });
                      }
                    },
                  );
                }

                // Not downloaded, show download button
                return IconButton(
                  icon: Icon(
                    Icons.download_rounded,
                    color: widget.theme.textColor.withValues(alpha: 0.5),
                    size: 24,
                  ),
                  onPressed: () async {
                    // Start download (fire and forget)
                    downloadService.downloadReciterAudio(widget.reciter.id);
                  },
                );
              },
            ),
      onTap: () {
        final oldReciter = ref.read(selectedReciterProvider);
        if (oldReciter?.id != widget.reciter.id) {
          ref.read(selectedReciterProvider.notifier).setReciter(widget.reciter);
        }
        Navigator.pop(context);
      },
    );
  }
}
