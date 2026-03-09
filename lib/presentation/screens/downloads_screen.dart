import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/presentation/providers/download_state.dart';
import 'package:islam_home/data/services/download_service.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final downloads = ref.watch(downloadProvider);
    final historyAsync = ref.watch(downloadHistoryProvider);

    final activeCount = downloads.values
        .where((e) => e.status == DownloadStatus.downloading)
        .length;
    final totalDownloaded = historyAsync.maybeWhen(
      data: (h) => h.length,
      orElse: () => 0,
    );

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _buildHeader(context, activeCount, totalDownloaded, l10n),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      tabs: [
                        Tab(text: l10n.downloadingTab),
                        Tab(text: l10n.downloadedTab),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: TabBarView(
                    children: [_ActiveDownloadsTab(), _HistoryTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int active,
    int total,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  l10n.downloadsTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance the leading icon
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                l10n.activeDownloads,
                active.toString(),
                Icons.cloud_download,
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 15),
              _buildStatCard(
                l10n.completedDownloads,
                total.toString(),
                Icons.check_circle,
                Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveDownloadsTab extends ConsumerWidget {
  const _ActiveDownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final downloads = ref.watch(downloadProvider);
    final allActive = downloads.entries
        .where(
          (e) =>
              e.value.status == DownloadStatus.downloading ||
              e.value.status == DownloadStatus.idle,
        )
        .map((e) => e.value)
        .toList();

    if (allActive.isEmpty) {
      return _buildEmptyState(
        l10n.noActiveDownloads,
        l10n.noActiveDownloadsDesc,
        Icons.cloud_download_outlined,
      );
    }

    final categories = <String, Map<String, List<DownloadItemState>>>{};
    for (final item in allActive) {
      final category = item.id.startsWith('seerah_')
          ? 'seerah'
          : item.id.startsWith('tafsir_')
          ? 'tafsir'
          : 'quran';

      categories.putIfAbsent(category, () => {});
      categories[category]!.update(
        item.reciterName,
        (list) => list..add(item),
        ifAbsent: () => [item],
      );
    }

    final categoryOrder = ['quran', 'tafsir', 'seerah'];
    final sortedCategories = categories.keys.toList()
      ..sort(
        (a, b) => categoryOrder.indexOf(a).compareTo(categoryOrder.indexOf(b)),
      );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedCategories.length,
      itemBuilder: (context, catIndex) {
        final category = sortedCategories[catIndex];
        final reciters = categories[category]!;

        final categoryTitle = category == 'seerah'
            ? l10n.seerahSection
            : category == 'tafsir'
            ? l10n.audioTafsir
            : l10n.quranSection;

        final categoryIcon = category == 'seerah'
            ? Icons.history_edu_rounded
            : category == 'tafsir'
            ? Icons.menu_book_rounded
            : Icons.auto_stories_rounded;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, categoryTitle, categoryIcon),
            ...reciters.entries.map((entry) {
              final reciterName = entry.key;
              final items = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  borderRadius: 20,
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category == 'quran'
                              ? Icons.person
                              : Icons.mic_external_on_rounded,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        reciterName,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${items.length} ${l10n.activeDownloads}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white54,
                      childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: items
                          .map((item) => _buildDownloadCard(context, ref, item))
                          .toList(),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(
    BuildContext context,
    WidgetRef ref,
    DownloadItemState item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.downloading,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(item.progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => ref
                      .read(downloadProvider.notifier)
                      .cancelDownload(item.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: item.progress > 0 ? item.progress : null,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(downloadHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return _buildEmptyState(
            l10n.emptyDownloadsHistory,
            l10n.emptyDownloadsHistoryDesc,
            Icons.history,
          );
        }

        final categories = <String, Map<String, List<DownloadRequest>>>{};
        for (final item in history) {
          final category = item.type; // already has quran, seerah, tafsir

          categories.putIfAbsent(category, () => {});
          categories[category]!.update(
            item.reciterName,
            (list) => list..add(item),
            ifAbsent: () => [item],
          );
        }

        final categoryOrder = ['quran', 'tafsir', 'seerah', 'general'];
        final sortedCategories = categories.keys.toList()
          ..sort(
            (a, b) =>
                categoryOrder.indexOf(a).compareTo(categoryOrder.indexOf(b)),
          );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: sortedCategories.length,
          itemBuilder: (context, catIndex) {
            final category = sortedCategories[catIndex];
            final reciters = categories[category]!;

            final categoryTitle = category == 'seerah'
                ? l10n.seerahSection
                : category == 'tafsir'
                ? l10n.audioTafsir
                : category == 'quran'
                ? l10n.quranSection
                : 'أخرى';

            final categoryIcon = category == 'seerah'
                ? Icons.history_edu_rounded
                : category == 'tafsir'
                ? Icons.menu_book_rounded
                : category == 'quran'
                ? Icons.auto_stories_rounded
                : Icons.folder_open_rounded;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, categoryTitle, categoryIcon),
                ...reciters.entries.map((entry) {
                  final reciterName = entry.key;
                  final items = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category == 'quran'
                                  ? Icons.person
                                  : Icons.mic_external_on_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            reciterName,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${items.length} ملف محمل',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white54,
                          childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          children: items
                              .map(
                                (item) => _buildHistoryCard(context, ref, item),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(l10n.errorOccurred)),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    DownloadRequest item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 20,
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.type == 'seerah'
                  ? Icons.history_edu_rounded
                  : Icons.audiotrack,
              color: AppTheme.primaryColor,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            item.type == 'seerah' ? item.reciterId : 'سورة ${item.surahNumber}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: AppTheme.primaryColor,
                  size: 36,
                ),
                onPressed: () async {
                  final audioService = ref.read(audioPlayerServiceProvider);
                  if (audioService != null) {
                    final dir = await DownloadService().getFilePath(
                      item.reciterId,
                      item.moshafType,
                      item.surahNumber,
                      type: item.type,
                    );
                    audioService.playFile(
                      dir,
                      title: item.title,
                      artist: item.type == 'seerah'
                          ? item.reciterId
                          : 'القرآن الكريم',
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent.withValues(alpha: 0.8),
                ),
                onPressed: () async {
                  await ref
                      .read(downloadProvider.notifier)
                      .deleteFileById(item.id);
                  ref.invalidate(downloadHistoryProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildEmptyState(String title, String subtitle, IconData icon) {
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
            title,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}
