import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/presentation/providers/khatma_v2_provider.dart';
import 'package:islam_home/presentation/widgets/khatma_heatmap.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/widgets/khatma_v2_setup_sheet.dart';
import 'package:islam_home/presentation/widgets/khatma_remediation_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class KhatmaDashboardCard extends ConsumerWidget {
  const KhatmaDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khatmaV2Provider);
    final l10n = AppLocalizations.of(context)!;

    if (state.tracks.isEmpty) {
      return _buildEmptyState(context);
    }

    final activeTrack =
        state.tracks.first; // For now, show the first/primary track
    final dailyGoal = ref
        .read(khatmaV2Provider.notifier)
        .calculateDailyGoal(activeTrack.id);
    final completed = activeTrack.completedUnits;
    final total = activeTrack.totalUnits;
    final remaining = activeTrack.remainingUnits;
    final progressPercent = (activeTrack.overallProgress * 100).toInt();
    final unitLabel = _unitSingularLabel(context, activeTrack.unit);

    final remediationPlan = activeTrack.targetDate != null 
        ? KhatmaV2Notifier.buildRemediationPlan(activeTrack, RemediationStrategy.catchUp, now: DateTime.now())
        : null;
    final isBehind = remediationPlan != null && remediationPlan.backlogUnits > 0;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(activeTrack.type),
                        color: AppTheme.primaryColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeTrack.title,
                          style: GoogleFonts.cairo(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _trackTypeLabel(context, activeTrack.type),
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    _showSettingsSheet(context, ref, activeTrack);
                  },
                  icon: const Icon(Icons.settings_outlined),
                  color: AppTheme.textSecondary,
                  tooltip: AppLocalizations.of(context)!.khatmaSettings,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isBehind) _buildRemediationAlert(context, l10n, ref, activeTrack, remediationPlan),
            Row(
              children: [
                _buildMetricChip(
                  label: l10n.completedDownloads,
                  value: '$completed',
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  label: l10n.remainingLabel,
                  value: '$remaining',
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  label: l10n.dailyGoal,
                  value:
                      '$dailyGoal ${_unitSingularLabel(context, activeTrack.unit)}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.khatmaProgress,
                  style: GoogleFonts.tajawal(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$progressPercent%   ($completed/$total $unitLabel)',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: activeTrack.overallProgress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            KhatmaHeatmap(
              progress: activeTrack.progress,
              unit: activeTrack.unit,
              maxUnitsPerDay: dailyGoal > 0 ? dailyGoal : null,
              daysToShow: 21,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (activeTrack.type == KhatmaType.listening) {
                    context.push('/all-reciters');
                    return;
                  }
                  context.push('/quran?trackId=${activeTrack.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size.fromHeight(44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  activeTrack.type == KhatmaType.listening
                      ? l10n.continueListening
                      : l10n.continueReading,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            // Glowing icon container
            Stack(
              alignment: Alignment.center,
              children: [
                // Ambient glow
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.25),
                        AppTheme.primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.22),
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 22,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              AppLocalizations.of(context)!.khatmaV2NoActive,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.khatmaV2StartJourneyDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            // Feature chips row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip(Icons.chrome_reader_mode_outlined, 'قراءة'),
                const SizedBox(width: 6),
                _buildFeatureChip(Icons.headphones_outlined, 'استماع'),
                const SizedBox(width: 6),
                _buildFeatureChip(Icons.psychology_outlined, 'حفظ'),
              ],
            ),

            const SizedBox(height: 14),

            // CTA button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const KhatmaV2SetupSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size.fromHeight(40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.khatmaV2SetupNew,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemediationAlert(
    BuildContext context, 
    AppLocalizations l10n, 
    WidgetRef ref, 
    KhatmaTrack track, 
    RemediationPlan plan
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.khatmaRemediationNeeded(plan.backlogUnits, _unitSingularLabel(context, track.unit)),
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => KhatmaRemediationSheet(
                        track: track,
                        plan: plan,
                      ),
                    );
                  },
                  child: Text(
                    l10n.khatmaRemediationAction,
                    style: GoogleFonts.cairo(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMetricChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.tajawal(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(KhatmaType type) {
    switch (type) {
      case KhatmaType.reading:
        return Icons.chrome_reader_mode_outlined;
      case KhatmaType.memorization:
        return Icons.psychology_outlined;
      case KhatmaType.revision:
        return Icons.history_edu_outlined;
      case KhatmaType.listening:
        return Icons.headphones_outlined;
    }
  }

  String _trackTypeLabel(BuildContext context, KhatmaType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case KhatmaType.reading:
        return l10n.khatmaV2Reading.toUpperCase();
      case KhatmaType.memorization:
        return l10n.khatmaV2Memorization.toUpperCase();
      case KhatmaType.revision:
        return l10n.khatmaV2Revision.toUpperCase();
      case KhatmaType.listening:
        return l10n.khatmaV2Listening.toUpperCase();
    }
  }

  String _unitSingularLabel(BuildContext context, KhatmaUnit unit) {
    final l10n = AppLocalizations.of(context)!;
    switch (unit) {
      case KhatmaUnit.page:
        return l10n.khatmaV2UnitPageSingle;
      case KhatmaUnit.juz:
        return l10n.khatmaV2UnitJuzSingle;
      case KhatmaUnit.surah:
        return l10n.khatmaV2UnitSurahSingle;
    }
  }

  void _showSettingsSheet(
    BuildContext context,
    WidgetRef ref,
    KhatmaTrack track,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(khatmaV2Provider);
    final listeningTracks = state.tracks
        .where(
          (item) =>
              item.type == KhatmaType.listening &&
              item.unit == KhatmaUnit.surah,
        )
        .toList();
    KhatmaTrack? activeListeningTrack;
    for (final item in listeningTracks) {
      if (item.id == state.activeListeningTrackId) {
        activeListeningTrack = item;
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.khatmaSettings,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              track.title,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
              ),
              title: Text(
                l10n.khatmaV2SetupNew,
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const KhatmaV2SetupSheet(),
                );
              },
            ),
            if (listeningTracks.isNotEmpty) ...[
              const Divider(color: Colors.white12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.headphones_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: Text(
                  _setActiveListeningTrackLabel(context),
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                subtitle: activeListeningTrack == null
                    ? null
                    : Text(
                        '${_currentActiveListeningTrackLabel(context)}: ${activeListeningTrack.title}',
                        style: GoogleFonts.tajawal(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showListeningTrackPicker(context, ref);
                },
              ),
            ],
            const Divider(color: Colors.white12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                l10n.khatmaV2DeleteTrack,
                style: GoogleFonts.cairo(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    backgroundColor: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      l10n.khatmaV2DeleteTrackTitle,
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    content: Text(
                      l10n.khatmaV2DeleteTrackBody(track.title),
                      style: GoogleFonts.tajawal(color: AppTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, false),
                        child: Text(
                          l10n.cancel,
                          style: GoogleFonts.cairo(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        child: Text(
                          l10n.delete,
                          style: GoogleFonts.cairo(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(khatmaV2Provider.notifier).deleteTrack(track.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showListeningTrackPicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(khatmaV2Provider);
    final listeningTracks = state.tracks
        .where(
          (item) =>
              item.type == KhatmaType.listening &&
              item.unit == KhatmaUnit.surah,
        )
        .toList();
    final activeId = state.activeListeningTrackId;
    if (listeningTracks.isEmpty) return;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _listeningTrackPickerTitle(context),
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ...listeningTracks.map((item) {
                  final isActive = item.id == activeId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isActive
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isActive
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.cairo(
                        color: isActive ? AppTheme.primaryColor : Colors.white,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      _trackTypeLabel(context, item.type),
                      style: GoogleFonts.tajawal(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      await ref
                          .read(khatmaV2Provider.notifier)
                          .setActiveListeningTrack(item.id);
                      if (!context.mounted) return;
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _activeListeningTrackSetMessage(
                              context,
                              item.title,
                            ),
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                  );
                }),
                if (activeId != null) ...[
                  const Divider(color: Colors.white12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      _clearActiveListeningTrackLabel(context),
                      style: GoogleFonts.cairo(color: Colors.redAccent),
                    ),
                    onTap: () async {
                      await ref
                          .read(khatmaV2Provider.notifier)
                          .setActiveListeningTrack(null);
                      if (!context.mounted) return;
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _setActiveListeningTrackLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.setActiveListeningTrack;
  }

  String _currentActiveListeningTrackLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.currentActiveTrack;
  }

  String _listeningTrackPickerTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.chooseActiveListeningTrack;
  }

  String _activeListeningTrackSetMessage(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.activeListeningTrackSetMessage(title);
  }

  String _clearActiveListeningTrackLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.clearActiveTrack;
  }
}
