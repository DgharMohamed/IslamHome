import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioPlayerServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    // Don't show mini player if audio service not yet initialized
    if (audioService == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<MediaItem?>(
      stream: audioService.mediaItemStream,
      builder: (context, metadataSnapshot) {
        return StreamBuilder<PlayerState>(
          stream: audioService.player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.idle ||
                processingState == null) {
              return const SizedBox.shrink();
            }

            final metadata = metadataSnapshot.data;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 25,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GlassContainer(
                  borderRadius: 24,
                  blur: 25,
                  opacity: 0.1,
                  borderColor: Colors.white.withValues(alpha: 0.15),
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/player'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                            child: Row(
                              children: [
                                // Premium Mini Artwork
                                Hero(
                                  tag: 'artwork',
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: metadata?.artUri != null
                                          ? CachedNetworkImage(
                                              imageUrl: metadata!.artUri!
                                                  .toString(),
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  _buildFallbackArt(metadata),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      _buildFallbackArt(
                                                        metadata,
                                                      ),
                                            )
                                          : _buildFallbackArt(metadata),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Metadata
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        metadata?.title ?? l10n.nowPlaying,
                                        style: GoogleFonts.tajawal(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                          height: 1.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        metadata?.artist ?? l10n.reciterLabel,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 11,
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          height: 1.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Play/Pause Button
                                _ControlButton(
                                  onPressed: () {
                                    if (playing == true) {
                                      audioService.pause();
                                    } else {
                                      audioService.resume();
                                    }
                                  },
                                  icon: playing == true
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  isPrimary: true,
                                ),
                              ],
                            ),
                          ),
                          // Subtle Progress Line
                          StreamBuilder<Duration>(
                            stream: audioService.player.positionStream,
                            builder: (context, positionSnapshot) {
                              final position =
                                  positionSnapshot.data ?? Duration.zero;
                              final duration =
                                  audioService.player.duration ?? Duration.zero;
                              final double progress =
                                  duration.inMilliseconds > 0
                                  ? (position.inMilliseconds /
                                            duration.inMilliseconds)
                                        .clamp(0.0, 1.0)
                                  : 0.0;

                              return Stack(
                                children: [
                                  Container(
                                    height: 2,
                                    width: double.infinity,
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.5),
                                            blurRadius: 4,
                                            offset: const Offset(0, -1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
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

  Widget _buildFallbackArt(MediaItem? metadata) {
    final isQuran = metadata?.album == 'القرآن الكريم';
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          isQuran ? Icons.menu_book_rounded : Icons.headset_rounded,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final bool isPrimary;

  const _ControlButton({
    required this.onPressed,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPrimary
            ? AppTheme.primaryColor
            : Colors.white.withValues(alpha: 0.1),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: 26,
            color: isPrimary ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
