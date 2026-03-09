import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/tafsir_provider.dart';
import 'package:islam_home/data/models/tafsir_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';

import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/data/services/audio_player_service.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/presentation/widgets/tafsir_download_button.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/providers/favorites_provider.dart';

class TafsirScreen extends ConsumerStatefulWidget {
  const TafsirScreen({super.key});

  @override
  ConsumerState<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends ConsumerState<TafsirScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _playTafsirContext(
    BuildContext context,
    TafsirSurah surah,
    AudioPlayerService audioService,
    List<TafsirSurah> allSurahs,
    TafsirItem currentTafsir,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // Create queue from all surahs
    final queue = allSurahs.map((s) {
      return MediaItem(
        id: s.url,
        title: s.name,
        album: currentTafsir.name,
        artist: l10n.quranMushaf, // Or some suitable label like l10n.tafsir
        artUri: Uri.parse('https://www.mp3quran.net/images/logo_mp3.png'),
        extras: {'isRadio': false, 'isLive': false},
      );
    }).toList();

    final startIndex = allSurahs.indexWhere((s) => s.id == surah.id);
    await audioService.playQueue(
      queue,
      initialIndex: startIndex >= 0 ? startIndex : 0,
    );

    if (context.mounted) {
      context.push('/player');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availableTafasirAsync = ref.watch(availableTafasirProvider);
    final tafsirSurahsAsync = ref.watch(tafsirSurahsProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(l10n),
          _buildTafsirSelector(availableTafasirAsync),
          _buildSearchBar(l10n),
          _buildSurahsList(
            tafsirSurahsAsync,
            availableTafasirAsync,
            audioService,
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundColor,
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            AuroraBackground(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 60,
                      color: AppTheme.primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.audioTafsir,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
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

  Widget _buildTafsirSelector(
    AsyncValue<List<TafsirItem>> availableTafasirAsync,
  ) {
    return SliverToBoxAdapter(
      child: availableTafasirAsync.when(
        data: (tafasir) {
          if (tafasir.isEmpty) return const SizedBox.shrink();

          final selectedId =
              ref.watch(selectedTafsirIdProvider) ?? tafasir.first.id;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tafasir.map((tafsir) {
                  final isSelected = tafsir.id == selectedId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        tafsir.name,
                        style: GoogleFonts.cairo(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.secondaryColor,
                      backgroundColor: AppTheme.surfaceColor,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(selectedTafsirIdProvider.notifier)
                              .setId(tafsir.id);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.searchSurah,
              hintStyle: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsList(
    AsyncValue<List<TafsirSurah>> tafsirSurahsAsync,
    AsyncValue<List<TafsirItem>> availableTafasirAsync,
    AudioPlayerService? audioService,
  ) {
    return tafsirSurahsAsync.when(
      data: (surahs) {
        if (surahs.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                'No surahs available for this tafsir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final groupedSurahs = <int, List<TafsirSurah>>{};
        for (final surah in surahs) {
          groupedSurahs.putIfAbsent(surah.surahId, () => []).add(surah);
        }

        final filteredSurahIds = _searchQuery.isEmpty
            ? groupedSurahs.keys.toList()
            : groupedSurahs.keys.where((id) {
                final surahName = QuranUtils.getSurahName(id);
                return QuranUtils.matchesSearch(surahName, _searchQuery);
              }).toList();

        return SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final surahId = filteredSurahIds[index];
              final parts = groupedSurahs[surahId]!;
              final surahName = 'سورة ${QuranUtils.getSurahName(surahId)}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            surahId.toString(),
                            style: GoogleFonts.cairo(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        surahName,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      children: parts.map((part) {
                        return InkWell(
                          onTap: () {
                            if (audioService != null) {
                              availableTafasirAsync.whenData((tafasir) {
                                final selectedId =
                                    ref.read(selectedTafsirIdProvider) ??
                                    (tafasir.isNotEmpty
                                        ? tafasir.first.id
                                        : null);
                                final currentTafsir = tafasir.firstWhere(
                                  (t) => t.id == selectedId,
                                  orElse: () => TafsirItem(
                                    id: 0,
                                    name: 'Unknown',
                                    url: '',
                                  ),
                                );
                                _playTafsirContext(
                                  context,
                                  part,
                                  audioService,
                                  parts,
                                  currentTafsir,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    part.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    availableTafasirAsync.when(
                                      data: (tafasir) {
                                        final selectedId =
                                            ref.read(
                                              selectedTafsirIdProvider,
                                            ) ??
                                            (tafasir.isNotEmpty
                                                ? tafasir.first.id
                                                : null);
                                        final currentTafsir = tafasir
                                            .firstWhere(
                                              (t) => t.id == selectedId,
                                              orElse: () => TafsirItem(
                                                id: 0,
                                                name: 'Unknown',
                                                url: '',
                                              ),
                                            );
                                        final isFav = ref
                                            .watch(favoritesProvider.notifier)
                                            .isFavoriteTafsir(
                                              currentTafsir.name,
                                              part.id,
                                            );
                                        return IconButton(
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            color: isFav
                                                ? AppTheme.primaryColor
                                                : Colors.white38,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(
                                                  favoritesProvider.notifier,
                                                )
                                                .toggleFavoriteTafsir(
                                                  tafsirName:
                                                      currentTafsir.name,
                                                  surahPart: part,
                                                );
                                          },
                                        );
                                      },
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                                    availableTafasirAsync.when(
                                      data: (tafasir) {
                                        final selectedId =
                                            ref.read(
                                              selectedTafsirIdProvider,
                                            ) ??
                                            (tafasir.isNotEmpty
                                                ? tafasir.first.id
                                                : null);
                                        final currentTafsir = tafasir
                                            .firstWhere(
                                              (t) => t.id == selectedId,
                                              orElse: () => TafsirItem(
                                                id: 0,
                                                name: 'Unknown',
                                                url: '',
                                              ),
                                            );
                                        return TafsirDownloadButton(
                                          tafsirName: currentTafsir.name,
                                          surahPart: part,
                                          color: AppTheme.primaryColor,
                                        );
                                      },
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }, childCount: filteredSurahIds.length),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverFillRemaining(
        child: Center(
          child: Text(
            'Error loading tafsir',
            style: GoogleFonts.cairo(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
