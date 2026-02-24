import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/data/services/audio_player_service.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/reading_view.dart';
import 'package:islam_home/presentation/widgets/player_controls.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _isReadingMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final audioService = ref.watch(audioPlayerServiceProvider);

    // If audio service not initialized, show error screen
    if (audioService == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.nowPlaying)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_off, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Audio service is initializing...',
                style: GoogleFonts.cairo(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A), // Dark blue
              Color(0xFF1B263B), // Navy
              Color(0xFF411D13), // Dark Maroon/Reddish
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Header
                            SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            onPressed: () => context.pop(),
                                          ),
                                          if (Scaffold.maybeOf(
                                                context,
                                              )?.hasDrawer ??
                                              false)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.menu_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              onPressed: () => Scaffold.of(
                                                context,
                                              ).openDrawer(),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      l10n.nowPlaying,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                          color: Colors.white,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'Sleep Timer') {
                                            _showSleepTimerSheet(
                                              context,
                                              audioService,
                                            );
                                          } else if (value == 'Share') {
                                            final metadata =
                                                audioService
                                                        .player
                                                        .sequenceState
                                                        ?.currentSource
                                                        ?.tag
                                                    as MediaItem?;
                                            if (metadata != null) {
                                              _shareCurrentRecitation(
                                                context,
                                                metadata,
                                              );
                                            }
                                          }
                                        },
                                        color: const Color(0xFF1E293B),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'Sleep Timer',
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.timer_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  l10n.sleepTimer,
                                                  style: GoogleFonts.cairo(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'Share',
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.share_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  l10n.share,
                                                  style: GoogleFonts.cairo(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Artwork / Reading Area
                            StreamBuilder<SequenceState?>(
                              stream: audioService.player.sequenceStateStream,
                              builder: (context, snapshot) {
                                return GestureDetector(
                                  onTap: () {
                                    final metadata =
                                        snapshot.data?.currentSource?.tag
                                            as MediaItem?;
                                    final isQuran =
                                        metadata?.album == 'القرآن الكريم';

                                    if (isQuran) {
                                      setState(() {
                                        _isReadingMode = !_isReadingMode;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.readingModeOnlyForQuran,
                                            style: GoogleFonts.cairo(),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: _isReadingMode
                                      ? ReadingView(
                                          audioService: audioService,
                                          constraints: constraints,
                                        )
                                      : Hero(
                                          tag: 'artwork',
                                          child: Container(
                                            width:
                                                (constraints.maxWidth * 0.8) >
                                                    (constraints.maxHeight *
                                                        0.35)
                                                ? (constraints.maxHeight * 0.35)
                                                : (constraints.maxWidth * 0.8),
                                            height:
                                                (constraints.maxWidth * 0.8) >
                                                    (constraints.maxHeight *
                                                        0.35)
                                                ? (constraints.maxHeight * 0.35)
                                                : (constraints.maxWidth * 0.8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 40,
                                                  spreadRadius: -5,
                                                  offset: const Offset(0, 20),
                                                ),
                                                BoxShadow(
                                                  color: AppTheme.primaryColor
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 30,
                                                  spreadRadius: -10,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 10,
                                                  sigmaY: 10,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          32,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: StreamBuilder<MediaItem?>(
                                                      stream: audioService
                                                          .mediaItemStream,
                                                      builder: (context, snapshot) {
                                                        final metadata =
                                                            snapshot.data;
                                                        final artUri = metadata
                                                            ?.artUri
                                                            ?.toString();
                                                        final isQuran =
                                                            metadata?.album ==
                                                            'القرآن الكريم';

                                                        if (artUri != null &&
                                                            artUri.isNotEmpty) {
                                                          return ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  32,
                                                                ),
                                                            child: CachedNetworkImage(
                                                              imageUrl: artUri,
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                              placeholder: (context, url) => Center(
                                                                child: CircularProgressIndicator(
                                                                  color: AppTheme
                                                                      .primaryColor
                                                                      .withValues(
                                                                        alpha:
                                                                            0.5,
                                                                      ),
                                                                ),
                                                              ),
                                                              errorWidget:
                                                                  (
                                                                    context,
                                                                    url,
                                                                    error,
                                                                  ) =>
                                                                      _buildFallbackIcon(
                                                                        isQuran,
                                                                      ),
                                                            ),
                                                          );
                                                        }

                                                        return _buildFallbackIcon(
                                                          isQuran,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Metadata
                            StreamBuilder<MediaItem?>(
                              stream: audioService.mediaItemStream,
                              builder: (context, snapshot) {
                                final metadata = snapshot.data;
                                if (metadata == null) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite_border_rounded,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                        onPressed: () {},
                                      ),
                                      const Spacer(),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              Localizations.localeOf(
                                                    context,
                                                  ).languageCode ==
                                                  'ar'
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              metadata.title,
                                              style: GoogleFonts.tajawal(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                height: 1.5,
                                              ),
                                              textAlign:
                                                  Localizations.localeOf(
                                                        context,
                                                      ).languageCode ==
                                                      'ar'
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              metadata.artist ?? '',
                                              style: GoogleFonts.cairo(
                                                color: Colors.white60,
                                                fontSize: 16,
                                              ),
                                              textAlign:
                                                  Localizations.localeOf(
                                                        context,
                                                      ).languageCode ==
                                                      'ar'
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            const SizedBox(height: 32),
                            // Controls
                            PlayerControls(
                              audioService: audioService,
                              onShowQueue: (ctx, service, widgetRef) =>
                                  _showQueueBottomSheet(
                                    ctx,
                                    service,
                                    widgetRef,
                                  ),
                            ),
                            const Spacer(),
                            const Spacer(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQueueBottomSheet(
    BuildContext context,
    AudioPlayerService audioService,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: StreamBuilder<SequenceState?>(
            stream: audioService.player.sequenceStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final sequence = state?.sequence ?? [];
              final currentIndex = state?.currentIndex ?? 0;

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.queue_music_rounded,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.currentPlaylist,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.audioCount(sequence.length.toString()),
                          style: GoogleFonts.cairo(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.white12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sequence.length,
                      padding: const EdgeInsets.only(bottom: 32),
                      itemBuilder: (context, index) {
                        final metadata = sequence[index].tag as MediaItem;
                        final isCurrent = index == currentIndex;

                        return Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppTheme.primaryColor.withValues(alpha: 0.08)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 0.5,
                              ),
                              left: isCurrent
                                  ? const BorderSide(
                                      color: AppTheme.primaryColor,
                                      width: 4,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            onTap: () {
                              audioService.player.seek(
                                Duration.zero,
                                index: index,
                              );
                              Navigator.pop(
                                context,
                              ); // Close sheet after selection
                            },
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppTheme.primaryColor.withValues(
                                        alpha: 0.2,
                                      )
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: isCurrent
                                    ? const Icon(
                                        Icons.bar_chart_rounded,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: GoogleFonts.tajawal(
                                          color: Colors.white54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              metadata.title,
                              style: GoogleFonts.tajawal(
                                color: isCurrent
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: isCurrent
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              metadata.artist ?? '',
                              style: GoogleFonts.tajawal(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isCurrent
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.nowPlayingLabel,
                                      style: GoogleFonts.cairo(
                                        color: AppTheme.primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSleepTimerSheet(
    BuildContext context,
    AudioPlayerService audioService,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.sleepTimer,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<Duration?>(
              stream: audioService.sleepTimerStream,
              builder: (context, snapshot) {
                final remaining = snapshot.data;
                if (remaining == null) return const SizedBox.shrink();
                return Text(
                  l10n.timeRemaining(_formatDuration(remaining)),
                  style: GoogleFonts.cairo(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            _buildTimerOption(
              context,
              audioService,
              l10n,
              l10n.timerOption('15'),
              const Duration(minutes: 15),
            ),
            _buildTimerOption(
              context,
              audioService,
              l10n,
              l10n.timerOption('30'),
              const Duration(minutes: 30),
            ),
            _buildTimerOption(
              context,
              audioService,
              l10n,
              l10n.timerOption('45'),
              const Duration(minutes: 45),
            ),
            _buildTimerOption(
              context,
              audioService,
              l10n,
              l10n.timerOption('60'),
              const Duration(minutes: 60),
            ),
            _buildTimerOption(
              context,
              audioService,
              l10n,
              l10n.timerOption('90'),
              const Duration(minutes: 90),
            ),
            ListTile(
              leading: const Icon(
                Icons.timer_off_outlined,
                color: Colors.redAccent,
              ),
              title: Text(
                l10n.stopTimer,
                style: GoogleFonts.cairo(color: Colors.redAccent),
              ),
              onTap: () {
                audioService.cancelSleepTimer();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.sleepTimerStopped,
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerOption(
    BuildContext context,
    AudioPlayerService audioService,
    AppLocalizations l10n,
    String title,
    Duration duration,
  ) {
    return ListTile(
      leading: const Icon(Icons.timer_outlined, color: Colors.white70),
      title: Text(title, style: GoogleFonts.cairo(color: Colors.white)),
      onTap: () {
        audioService.setSleepTimer(duration);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.timerSetFor(title), style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildFallbackIcon(bool isQuran) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Icon(
        isQuran ? Icons.menu_book_rounded : Icons.headset_rounded,
        size: 100,
        color: AppTheme.primaryColor.withValues(alpha: 0.9),
      ),
    );
  }

  void _shareCurrentRecitation(BuildContext context, MediaItem metadata) {
    final l10n = AppLocalizations.of(context)!;
    final text = l10n.shareRecitationText(
      metadata.title,
      metadata.artist ?? l10n.reciterLabel,
      metadata.id,
    );
    // ignore: deprecated_member_use
    Share.share(text);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
