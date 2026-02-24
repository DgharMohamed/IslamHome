import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/favorites_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/presentation/screens/hadith_screen.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';

import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/screens/playlists_screen.dart';
import 'package:islam_home/data/models/playlist_model.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  final String? importData;
  const FavoritesScreen({super.key, this.importData});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.importData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context)!;
        ref.read(favoritesProvider.notifier).importPlaylist(widget.importData!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.playlistImportedSuccessfully)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoritesProvider);
    final favoriteReciters = favorites['reciters']!;
    final favoriteSurahs = favorites['surahs']!;
    final favoriteHadiths = favorites['hadiths']!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: AuroraBackground(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Direction-Aware Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (context.canPop())
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => context.pop(),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => GlobalScaffoldService.openDrawer(),
                      ),
                    Expanded(
                      child: Text(
                        l10n.favoritesTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 48,
                    ), // Spacer to balance the leading icon
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Premium TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    tabs: [
                      Tab(text: l10n.reciters),
                      Tab(text: l10n.surahs),
                      Tab(text: l10n.playlists),
                      Tab(text: l10n.hadith),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRecitersList(context, favoriteReciters),
                    _buildSurahsList(context, favoriteSurahs),
                    const PlaylistsScreen(),
                    _buildHadithsList(context, favoriteHadiths),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecitersList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(
        l10n.noFavoriteReciters,
        Icons.person_outline_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final reciter = Reciter.fromJson(items[index]);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => context.push('/reciter', extra: reciter),
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.2),
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    reciter.name?[0] ?? '',
                    style: GoogleFonts.cairo(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              title: Text(
                reciter.name ?? '',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.primaryColor,
                  size: 26,
                ),
                onPressed: () => ref
                    .read(favoritesProvider.notifier)
                    .toggleFavoriteReciter(reciter),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahsList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(l10n.noFavoriteSurahs, Icons.menu_book_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              title: Text(
                item['surah_name'] ?? '',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                item['reciter_name'] ?? '',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
              ),
              onTap: () async {
                final sources = items.map((s) {
                  return AudioSource.uri(
                    Uri.parse(s['url']),
                    tag: MediaItem(
                      id: s['url'],
                      title: s['surah_name'] ?? l10n.surahName(''),
                      artist: s['reciter_name'] ?? l10n.reciterName(''),
                      artUri: Uri.parse(
                        'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
                      ),
                      extras: {'surahNumber': s['surah_number']},
                    ),
                  );
                }).toList();

                try {
                  final audioService = ref.read(audioPlayerServiceProvider);
                  if (audioService == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.audioServiceNotReady,
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    return;
                  }
                  await audioService.setPlaylist(
                    sources: sources,
                    initialIndex: index,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.playlistPlayError(e.toString()),
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.playlist_add_rounded,
                      color: Colors.white38,
                    ),
                    onPressed: () => _showPlaylistSelector(context, item),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      final reciter = Reciter(
                        id: int.tryParse(item['reciter_id'].toString()),
                        name: item['reciter_name'],
                      );
                      final dummySurah = _DummySurah(
                        number: item['surah_number'] ?? 0,
                        name: item['surah_name'] ?? '',
                      );
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavoriteSurah(dummySurah, reciter);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHadithsList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(l10n.noFavoriteHadiths, Icons.book_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final hadithJson = items[index] as Map<String, dynamic>;
        final hadith = HadithModel.fromJson(hadithJson);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HadithCard(
            key: ValueKey('fav_hadith_${hadith.id}'),
            hadith: hadith,
          ),
        );
      },
    );
  }

  void _showPlaylistSelector(BuildContext context, dynamic item) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.read(favoritesProvider);
    final playlists = (favorites['playlists'] as List)
        .map((p) => Playlist.fromJson(p))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.addToPlaylist,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.noPlaylistsMessage,
                  style: GoogleFonts.cairo(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: Text(
                        playlist.icon ?? '⭐',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        playlist.name,
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                      onTap: () {
                        final reciter = Reciter(
                          id: int.tryParse(item['reciter_id'].toString()),
                          name: item['reciter_name'],
                        );
                        final surah = _DummySurah(
                          number: item['surah_number'] ?? 0,
                          name: item['surah_name'] ?? '',
                        );
                        ref
                            .read(favoritesProvider.notifier)
                            .addToPlaylist(
                              playlist.id,
                              surah,
                              reciter,
                              item['url'],
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.addedToPlaylist(playlist.name),
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: GlassContainer(
        borderRadius: 30,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DummySurah {
  final int number;
  final String name;
  _DummySurah({required this.number, required this.name});
}
