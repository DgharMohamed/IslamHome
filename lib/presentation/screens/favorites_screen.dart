import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/data/models/hadith_model.dart';
import 'package:islam_home/data/models/playlist_model.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/providers/favorites_provider.dart';
import 'package:islam_home/presentation/screens/hadith_screen.dart';
import 'package:islam_home/presentation/screens/playlists_screen.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:just_audio/just_audio.dart';

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
    final favoriteTafsir = favorites['tafsir']!;
    final favoriteSeerah = favorites['seerah']!;
    final favoritePlaylists = favorites['playlists']!;
    final topPadding = MediaQuery.of(context).padding.top;
    final tabs = [
      _FavoritesTabData(
        label: l10n.reciters,
        icon: Icons.record_voice_over_rounded,
        count: favoriteReciters.length,
      ),
      _FavoritesTabData(
        label: l10n.surahs,
        icon: Icons.auto_stories_rounded,
        count: favoriteSurahs.length,
      ),
      _FavoritesTabData(
        label: l10n.audioTafsir,
        icon: Icons.headphones_rounded,
        count: favoriteTafsir.length,
      ),
      _FavoritesTabData(
        label: l10n.videoLibraryTitle,
        icon: Icons.history_edu_rounded,
        count: favoriteSeerah.length,
      ),
      _FavoritesTabData(
        label: l10n.playlists,
        icon: Icons.queue_music_rounded,
        count: favoritePlaylists.length,
      ),
      _FavoritesTabData(
        label: l10n.hadith,
        icon: Icons.menu_book_rounded,
        count: favoriteHadiths.length,
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: AuroraBackground(
          child: Column(
            children: [
              SizedBox(height: topPadding + 12),
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
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  borderRadius: 24,
                  opacity: 0.1,
                  borderColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: TabBar(
                    isScrollable: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsetsDirectional.only(
                      start: 4,
                      end: 4,
                    ),
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppTheme.primaryColor.withValues(alpha: 0.18),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.34),
                      ),
                    ),
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    tabs: tabs
                        .map(
                          (tab) => Tab(
                            height: 52,
                            child: _FavoritesTabChip(tab: tab),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRecitersList(context, favoriteReciters),
                    _buildSurahsList(context, favoriteSurahs),
                    _buildTafsirList(context, favoriteTafsir),
                    _buildSeerahList(context, favoriteSeerah),
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
        context: context,
        title: l10n.noFavoriteReciters,
        hint: _favoritesEmptyHint(context, l10n.reciters),
        icon: Icons.record_voice_over_rounded,
        actionLabel: _openSectionLabel(context, l10n.allRecitersTitle),
        onAction: () => context.push('/all-reciters'),
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
      return _buildEmptyState(
        context: context,
        title: l10n.noFavoriteSurahs,
        hint: _favoritesEmptyHint(context, l10n.surahs),
        icon: Icons.auto_stories_rounded,
        actionLabel: _openSectionLabel(context, l10n.surahs),
        onAction: () => context.push('/quran'),
      );
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
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
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
                      color: Colors.white54,
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

  Widget _buildTafsirList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: _noFavoriteTafsirLabel(context),
        hint: _favoritesEmptyHint(context, l10n.audioTafsir),
        icon: Icons.headphones_rounded,
        actionLabel: _openSectionLabel(context, l10n.audioTafsir),
        onAction: () => context.push('/tafsir'),
      );
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
                item['part_name'] ?? '',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                item['tafsir_name'] ?? '',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
              ),
              onTap: () async {
                final audioService = ref.read(audioPlayerServiceProvider);
                if (audioService == null) return;

                final queue = items.map((i) {
                  return MediaItem(
                    id: i['url'],
                    title: i['part_name'],
                    album: i['tafsir_name'],
                    artist: l10n.audioTafsir,
                    artUri: Uri.parse(
                      'https://www.mp3quran.net/images/logo_mp3.png',
                    ),
                  );
                }).toList();

                await audioService.playQueue(queue, initialIndex: index);
                if (context.mounted) context.push('/player');
              },
              trailing: IconButton(
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavoriteTafsir(
                        tafsirName: item['tafsir_name'],
                        surahPart: _DummyPart(
                          id: item['part_id'],
                          name: item['part_name'],
                          url: item['url'],
                          surahId: item['surah_id'],
                        ),
                      );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeerahList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: _noFavoriteSeerahLabel(context),
        hint: _favoritesEmptyHint(context, l10n.videoLibraryTitle),
        icon: Icons.history_edu_rounded,
        actionLabel: _openSectionLabel(context, l10n.videoLibraryTitle),
        onAction: () => context.push('/sira'),
      );
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
                item['episode_title'] ?? '',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                item['scholar_name'] ?? '',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
              ),
              onTap: () async {
                final audioService = ref.read(audioPlayerServiceProvider);
                if (audioService == null) return;

                final queue = items.map((i) {
                  return MediaItem(
                    id: i['url'],
                    title: i['episode_title'],
                    artist: i['scholar_name'],
                    album: l10n.videoLibraryTitle,
                    artUri: Uri.parse(
                      'https://www.mp3quran.net/images/logo_mp3.png',
                    ),
                  );
                }).toList();

                await audioService.playQueue(queue, initialIndex: index);
                if (context.mounted) context.push('/player');
              },
              trailing: IconButton(
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavoriteSeerah(
                        _DummyEpisode(
                          id: item['episode_id'],
                          title: item['episode_title'],
                          url: item['url'],
                        ),
                        item['scholar_name'],
                      );
                },
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
      return _buildEmptyState(
        context: context,
        title: l10n.noFavoriteHadiths,
        hint: _favoritesEmptyHint(context, l10n.hadith),
        icon: Icons.menu_book_rounded,
        actionLabel: _openSectionLabel(context, l10n.hadith),
        onAction: () => context.push('/hadith'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final hadithJson = items[index] as Map<String, dynamic>;
        final hadith = HadithModel.fromJson(hadithJson);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: HadithCard(
              key: ValueKey('fav_hadith_${hadith.id}'),
              hadith: hadith,
            ),
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
      useRootNavigator: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(24),
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
                        playlist.icon ?? '\u2B50',
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

  Widget _buildEmptyState({
    required BuildContext context,
    required String title,
    required String hint,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: GlassContainer(
            borderRadius: 28,
            opacity: 0.12,
            borderColor: Colors.white.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 42,
                    color: AppTheme.primaryColor.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                    label: Text(
                      actionLabel,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _favoritesEmptyHint(BuildContext context, String section) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.favoritesEmptyHint(section);
  }

  String _openSectionLabel(BuildContext context, String section) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.openSectionLabel(section);
  }

  String _noFavoriteTafsirLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.noFavoriteTafsirClips;
  }

  String _noFavoriteSeerahLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.noFavoriteSeerahClips;
  }
}

class _DummySurah {
  final int number;
  final String name;

  _DummySurah({required this.number, required this.name});
}

class _DummyPart {
  final int id;
  final String name;
  final String? url;
  final int? surahId;

  _DummyPart({required this.id, required this.name, this.url, this.surahId});
}

class _DummyEpisode {
  final String id;
  final String title;
  final String? url;

  _DummyEpisode({required this.id, required this.title, this.url});
}

class _FavoritesTabData {
  final String label;
  final IconData icon;
  final int count;

  const _FavoritesTabData({
    required this.label,
    required this.icon,
    required this.count,
  });
}

class _FavoritesTabChip extends StatelessWidget {
  final _FavoritesTabData tab;

  const _FavoritesTabChip({required this.tab});

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        DefaultTextStyle.of(context).style.color ?? Colors.white;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.icon, size: 18),
          const SizedBox(width: 8),
          Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          if (tab.count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: foregroundColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: foregroundColor.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                '${tab.count}',
                style: GoogleFonts.cairo(
                  color: foregroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
