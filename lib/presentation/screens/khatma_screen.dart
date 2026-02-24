import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/khatma_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/khatma_setup_dialog.dart';
import 'package:islam_home/data/models/khatma_plan.dart';

class KhatmaScreen extends ConsumerWidget {
  const KhatmaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khatmaProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.khatmaProgress,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Overview Stats
          SliverToBoxAdapter(
            child: _buildOverviewStats(context, state, l10n, ref),
          ),

          // 2. Active Plans Section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.activePlans,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),

          if (state.plans.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState(context, l10n))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPlanCard(
                  context,
                  state.plans[index],
                  ref,
                  state.currentPage,
                  l10n,
                ),
                childCount: state.plans.length,
              ),
            ),

          // 3. History Section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.khatmaHistory,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),

          if (state.completions.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyHistory(l10n))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildHistoryCard(state.completions[index], l10n),
                childCount: state.completions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSetup(context),
        label: Text(
          l10n.startKhatma,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildOverviewStats(
    BuildContext context,
    KhatmaState state,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final notifier = ref.read(khatmaProvider.notifier);
    final progress = notifier.overallProgress;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalAchievement,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.khatmaCount(state.completions.length),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                l10n.currentPageLabel,
                state.currentPage.toString(),
              ),
              _buildStatItem(
                l10n.remainingLabel,
                (604 - state.currentPage).toString(),
              ),
              _buildStatItem(
                l10n.dailyTargetLabel,
                notifier.pagesNeededToday.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    KhatmaPlan plan,
    WidgetRef ref,
    int currentPage,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final smartPages = plan.smartPagesPerDay(currentPage, now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    plan.type == KhatmaType.listening
                        ? Icons.headphones
                        : Icons.menu_book,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    plan.title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () =>
                    ref.read(khatmaProvider.notifier).cancelPlan(plan.id),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPlanInfoTile(
                Icons.calendar_today,
                l10n.duration,
                l10n.daysCount(plan.targetDays),
                l10n,
              ),
              const SizedBox(width: 24),
              _buildPlanInfoTile(
                Icons.auto_graph,
                l10n.dailyGoal,
                '${smartPages.toStringAsFixed(1)} ${l10n.pageLabel}',
                l10n,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentPage / 604).clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              color: AppTheme.primaryColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoTile(
    IconData icon,
    String label,
    String value,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryCard(dynamic completion, AppLocalizations l10n) {
    final dateStr =
        '${completion.completionDate.day}/${completion.completionDate.month}/${completion.completionDate.year}';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.workspace_premium_rounded,
          color: Color(0xFFD4AF37),
        ),
        title: Text(
          l10n.khatmaSuccessful,
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          dateStr,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.daysCount(completion.totalDays),
            style: GoogleFonts.cairo(
              color: const Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 64,
            color: Colors.white10,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActivePlans,
            style: GoogleFonts.cairo(color: Colors.white38),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showSetup(context),
            child: Text(l10n.startKhatma, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          l10n.noHistoryYet,
          style: GoogleFonts.cairo(color: Colors.white24, fontSize: 14),
        ),
      ),
    );
  }

  void _showSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const KhatmaSetupDialog(),
    );
  }
}
