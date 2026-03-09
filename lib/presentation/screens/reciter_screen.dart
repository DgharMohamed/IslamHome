import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/favorites_provider.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/widgets/surah_tile_widget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/widgets/download_button.dart';
import 'package:islam_home/presentation/providers/download_state.dart';
import 'package:islam_home/presentation/screens/downloads_screen.dart';
import 'package:islam_home/data/models/surah_model.dart';
import 'package:islam_home/data/models/playlist_model.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:islam_home/core/utils/quran_utils.dart';

class ReciterScreen extends ConsumerStatefulWidget {
  final Reciter reciter;

  const ReciterScreen({super.key, required this.reciter});

  @override
  ConsumerState<ReciterScreen> createState() => _ReciterScreenState();
}

class _ReciterScreenState extends ConsumerState<ReciterScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final audioService = ref.watch(audioPlayerServiceProvider);

    debugPrint('🎵 ReciterScreen: Building for ${widget.reciter.name}');

    // If audio service not initialized, show loading indicator
    if (audioService == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: Text(widget.reciter.name ?? l10n.reciterLabel)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    ref.watch(favoritesProvider);
    final isFavorite = ref
        .read(favoritesProvider.notifier)
        .isFavoriteReciter(widget.reciter.id.toString());

    final moshaf = widget.reciter.moshaf?.isNotEmpty == true
        ? widget.reciter.moshaf!.first
        : null;
    final surahListRaw = moshaf?.surahList?.split(',') ?? [];

    // Error state if no moshaf
    if (moshaf == null || surahListRaw.isEmpty) {
      return _buildErrorScreen(l10n, l10n.reciterNoSurahsAvailable);
    }

    // Watch surahsProvider ONCE outside the list
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            expandedHeight: 330,
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildConsolidatedHeader(
                context,
                l10n,
                isFavorite,
                moshaf,
                surahsAsync,
              ),
            ),
          ),

          // Surahs List
          StreamBuilder<MediaItem?>(
            stream: audioService.mediaItemStream,
            builder: (context, snapshot) {
              final activeMedia = snapshot.data;
              final activeReciter = activeMedia?.artist;

              return surahsAsync.when(
                data: (surahs) => _buildSurahsList(
                  surahListRaw,
                  surahs,
                  moshaf,
                  activeMedia,
                  activeReciter,
                  audioService,
                  l10n,
                ),
                loading: () => _buildLoadingStateSliver(),
                error: (err, _) => _buildErrorStateSliver(err),
              );
            },
          ),

          // Bottom padding for player
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildConsolidatedHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isFavorite,
    dynamic moshaf,
    AsyncValue<List<dynamic>> surahsAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 1. Top Bar
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                // Back Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                // Downloads Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.download_done_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DownloadsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    widget.reciter.name ?? '',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Favorite Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFavorite
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white54,
                      size: 20,
                    ),
                    onPressed: () => ref
                        .read(favoritesProvider.notifier)
                        .toggleFavoriteReciter(widget.reciter),
                  ),
                ),
              ],
            ),
          ),

          // 2. Reciter Info Card
          _buildReciterInfo(moshaf),

          // 3. Actions
          surahsAsync.maybeWhen(
            data: (surahs) => _buildReciterActions(moshaf, surahs),
            orElse: () => const SizedBox.shrink(),
          ),

          // 4. Search Bar
          _buildSearchBar(l10n),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(AppLocalizations l10n, String message) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.reciter.name ?? l10n.reciterLabel),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReciterInfo(dynamic moshaf) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GlassContainer(
        borderRadius: 20,
        opacity: 0.05,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 32,
                color: Colors.white38,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moshaf.name ?? 'المصحف',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${moshaf.surahList?.split(',').length ?? 0} سورة',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GlassContainer(
        borderRadius: 16,
        opacity: 0.05,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.searchSurah,
            hintStyle: GoogleFonts.cairo(color: Colors.white38),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsList(
    List<String> surahListRaw,
    List<dynamic> surahs,
    dynamic moshaf,
    MediaItem? activeMedia,
    String? activeReciter,
    dynamic audioService,
    AppLocalizations l10n,
  ) {
    // Collect visible items first
    final List<Widget> children = [];

    for (int index = 0; index < surahListRaw.length; index++) {
      final surahId = surahListRaw[index];

      // Get surah name based on current language
      final currentLocale = ref.watch(localeProvider);
      final isEnglish = currentLocale.languageCode == 'en';
      String surahName = QuranUtils.getSurahName(
        int.parse(surahId),
        isEnglish: isEnglish,
      );

      Surah? surahObj;
      try {
        surahObj =
            surahs.firstWhere((s) => s.number.toString() == surahId) as Surah;
        if (isEnglish && surahObj.englishName != null) {
          surahName = surahObj.englishName!;
        } else if (!isEnglish && surahObj.name != null) {
          surahName = surahObj.name!;
        }
      } catch (_) {}

      // Filter by search
      if (searchQuery.isNotEmpty &&
          !QuranUtils.matchesSearch(surahName, searchQuery) &&
          !QuranUtils.matchesSearch(surahId, searchQuery)) {
        continue;
      }

      // Check if playing
      final isPlaying =
          activeReciter == widget.reciter.name &&
          activeMedia?.extras?['surahNumber']?.toString() == surahId;

      // Check if favorite
      ref.watch(favoritesProvider);
      final isFavoriteSurah = ref
          .read(favoritesProvider.notifier)
          .isFavoriteSurah(int.parse(surahId), widget.reciter.id.toString());

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SurahTileWidget(
            surahId: surahId,
            surahName: surahName,
            subtitle: l10n.recitationOf(moshaf.name ?? ''),
            isFavorite: isFavoriteSurah,
            isPlaying: isPlaying,
            onFavorite: () => _handleFavorite(surahId, surahs, moshaf),
            onPlaylistAdd: () => _showPlaylistSelector(surahObj, moshaf),
            onDownload: () {}, // Handled by widget
            onPlay: () => _handlePlay(
              surahListRaw,
              surahs,
              moshaf,
              index,
              audioService,
              l10n,
            ),
            downloadWidget: surahObj != null
                ? DownloadButton(
                    reciter: widget.reciter,
                    moshaf: moshaf,
                    surah: surahObj,
                    color: Colors.white38,
                  )
                : null,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(delegate: SliverChildListDelegate(children)),
    );
  }

  Widget _buildLoadingStateSliver() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildErrorStateSliver(Object err) {
    return SliverFillRemaining(child: _buildErrorState(err));
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ في تحميل البيانات',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistSelector(Surah? surah, dynamic moshaf) {
    if (surah == null) return;

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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'إضافة إلى قائمة تشغيل',
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
                  'لا توجد قوائم تشغيل. أنشئ واحدة من قسم المفضلات.',
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
                        String? url;
                        if (moshaf.server != null) {
                          final paddedId = surah.number.toString().padLeft(
                            3,
                            '0',
                          );
                          url = '${moshaf.server}$paddedId.mp3';
                        }
                        if (url != null) {
                          ref
                              .read(favoritesProvider.notifier)
                              .addToPlaylist(
                                playlist.id,
                                surah,
                                widget.reciter,
                                url,
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تمت الإضافة إلى ${playlist.name}',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                        }
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

  void _handleFavorite(String surahId, List<dynamic> surahs, dynamic moshaf) {
    try {
      final surah = surahs.firstWhere((s) => s.number.toString() == surahId);
      String? url;
      if (moshaf.server != null) {
        final paddedId = surahId.padLeft(3, '0');
        url = '${moshaf.server}$paddedId.mp3';
      }
      ref
          .read(favoritesProvider.notifier)
          .toggleFavoriteSurah(surah, widget.reciter, url: url);
    } catch (_) {}
  }

  Widget _buildReciterActions(dynamic moshaf, List<dynamic>? surahs) {
    if (moshaf == null || surahs == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (surahs.isEmpty) return;
                // Filter surahs that are in the moshaf list
                final moshafSurahIds = moshaf.surahList?.split(',') ?? [];
                final surahsToDownload = surahs
                    .where((s) => moshafSurahIds.contains(s.number.toString()))
                    .cast<Surah>()
                    .toList();

                ref
                    .read(downloadProvider.notifier)
                    .downloadAll(
                      reciter: widget.reciter,
                      moshaf: moshaf,
                      surahs: surahsToDownload,
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.downloadAllStarted)),
                );
              },
              icon: const Icon(Icons.download_rounded),
              label: Text(l10n.downloadAll),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlay(
    List<String> surahListRaw,
    List<dynamic> surahs,
    dynamic moshaf,
    int index,
    dynamic audioService,
    AppLocalizations l10n,
  ) async {
    // Validate that we have a server URL
    if (moshaf.server == null || moshaf.server.toString().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noServerLinkError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('🎵 ReciterScreen: Using server URL: ${moshaf.server}');
    debugPrint('🎵 ReciterScreen: Reciter: ${widget.reciter.name}');

    // Get current locale for surah names
    final currentLocale = ref.read(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';

    final sources = surahListRaw.map((id) {
      final surahNum = int.parse(id);

      // Use the actual moshaf server URL from the API
      final paddedId = id.padLeft(3, '0');
      final url = '${moshaf.server}$paddedId.mp3';

      // Get surah name based on language
      String name = QuranUtils.getSurahName(surahNum, isEnglish: isEnglish);
      try {
        final surah = surahs.firstWhere((s) => s.number.toString() == id);
        if (isEnglish && surah.englishName != null) {
          name = surah.englishName!;
        } else if (!isEnglish && surah.name != null) {
          name = surah.name!;
        }
      } catch (_) {}

      debugPrint('🎵 ReciterScreen: Audio URL for $name: $url');

      return AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: name,
          artist: widget.reciter.name,
          artUri: Uri.parse(
            'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
          ),
          extras: {'surahNumber': surahNum},
        ),
      );
    }).toList();

    try {
      await audioService.setPlaylist(sources: sources, initialIndex: index);
    } catch (e) {
      debugPrint('🎵 ReciterScreen: setPlaylist error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.playlistPlayError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
