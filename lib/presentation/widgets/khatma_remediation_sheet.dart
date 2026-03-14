import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/presentation/providers/khatma_v2_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class KhatmaRemediationSheet extends ConsumerWidget {
  final KhatmaTrack track;
  final RemediationPlan plan;

  const KhatmaRemediationSheet({
    super.key,
    required this.track,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final backlog = plan.backlogUnits;
    final remainingDays = plan.extraDaysNeeded > 0 ? plan.extraDaysNeeded : track.daysRemaining;
    final unitLabel = track.unit == KhatmaUnit.page 
        ? l10n.khatmaV2UnitPage 
        : track.unit == KhatmaUnit.juz 
            ? l10n.khatmaV2UnitJuz 
            : l10n.khatmaV2UnitSurah;

    // Current metrics
    final currentEndDate = track.targetDate ?? DateTime.now();
    final currentDailyGoal = ref.read(khatmaV2Provider.notifier).calculateDailyGoal(track.id);
    final safeDailyGoal = currentDailyGoal > 0 ? currentDailyGoal : 1;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.khatmaRemediationSheetTitle,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.khatmaRemediationSheetSubtitle(backlog, unitLabel),
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Double Effort (Catch Up)
            _buildRemediationOption(
              context,
              ref,
              title: l10n.khatmaRemediationCatchUp,
              description: l10n.khatmaRemediationCatchUpDesc,
              icon: Icons.bolt,
              color: Colors.amber,
              onTap: () {
                ref.read(khatmaV2Provider.notifier).applyRemediation(
                      track.id,
                      RemediationStrategy.catchUp,
                    );
                Navigator.of(context).pop();
              },
            ),

            // Option 2: Distribute Load
            _buildRemediationOption(
              context,
              ref,
              title: l10n.khatmaRemediationDistribute,
              description: l10n.khatmaRemediationDistributeDesc,
              icon: Icons.auto_graph,
              color: Colors.blue,
              metric1: l10n.khatmaRemediationCurrentGoal('$currentDailyGoal'),
              // Very rough estimation just for UI visualization
              metric2: l10n.khatmaRemediationNewGoal('${currentDailyGoal + (backlog / remainingDays).ceil()}'),
              onTap: () {
                ref.read(khatmaV2Provider.notifier).applyRemediation(
                      track.id,
                      RemediationStrategy.distribute,
                    );
                Navigator.of(context).pop();
              },
            ),

            // Option 3: Extend Deadline
            _buildRemediationOption(
              context,
              ref,
              title: l10n.khatmaRemediationExtend,
              description: l10n.khatmaRemediationExtendDesc,
              icon: Icons.calendar_month,
              color: Colors.orangeAccent,
              metric1: l10n.khatmaRemediationCurrentDate('${currentEndDate.day}/${currentEndDate.month}/${currentEndDate.year}'),
              metric2: l10n.khatmaRemediationNewDate('${currentEndDate.add(Duration(days: (backlog / safeDailyGoal).ceil())).day}/${currentEndDate.add(Duration(days: (backlog / safeDailyGoal).ceil())).month}/${currentEndDate.add(Duration(days: (backlog / safeDailyGoal).ceil())).year}'),
              onTap: () {
                ref.read(khatmaV2Provider.notifier).applyRemediation(
                      track.id,
                      RemediationStrategy.extend,
                    );
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRemediationOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? metric1,
    String? metric2,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (metric1 != null && metric2 != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          metric1,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.white54,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 12, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          metric2,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
