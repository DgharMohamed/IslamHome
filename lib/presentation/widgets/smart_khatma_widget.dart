import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/khatma_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/presentation/widgets/khatma_setup_dialog.dart';
import 'package:islam_home/presentation/widgets/dua_khatm_dialog.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';

class SmartKhatmaWidget extends ConsumerWidget {
  const SmartKhatmaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khatmaProvider);
    final notifier = ref.read(khatmaProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final plan = state.activePlan;
    final progress = notifier.overallProgress;
    final surahName = QuranUtils.getSurahNameByPage(
      state.currentPage,
      isEnglish: l10n.localeName == 'en',
    );
    final juzNumber = QuranUtils.getJuzByPage(state.currentPage);

    return GlassContainer(
      borderRadius: 28,
      blur: 20,
      opacity: 0.1,
      child: Stack(
        children: [
          // Decorative background pattern
          Positioned(
            left: -30,
            top: -30,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.menu_book_rounded,
                size: 150,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Circular Progress Indicator (New)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.continueYourKhatma,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              l10n.juzAndSurah(juzNumber.toString(), surahName),
                              style: GoogleFonts.cairo(
                                color: AppTheme.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showSetup(context),
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (plan == null)
                  _buildSmartSuggestions(context, ref, l10n)
                else
                  _buildPlanStatus(context, state, l10n, notifier),

                if (state.completions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildKhatmaHistory(state, l10n),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (progress >= 1.0) {
                        _showDua(context);
                      } else {
                        final surahNum = QuranUtils.getSurahNumberByPage(
                          state.currentPage,
                        );
                        context.push('/quran-text?surah=$surahNum');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: progress >= 1.0
                          ? AppTheme.primaryColor
                          : Colors.white.withValues(alpha: 0.1),
                      foregroundColor: progress >= 1.0
                          ? Colors.black
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: progress >= 1.0
                              ? Colors.transparent
                              : Colors.white10,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          progress >= 1.0
                              ? Icons.workspace_premium_rounded
                              : Icons.play_arrow_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          progress >= 1.0
                              ? l10n.duaKhatm
                              : l10n.continueReading,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

  Widget _buildSmartSuggestions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.smartSuggestionsForNewPlan,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSuggestionCard(
                  icon: Icons.flash_on_rounded,
                  title: l10n.khatmaInMonth,
                  subtitle: l10n.oneJuzDaily,
                  onTap: () => ref
                      .read(khatmaProvider.notifier)
                      .setPlan(30, title: l10n.khatmaInMonth),
                ),
                const SizedBox(width: 10),
                _buildSuggestionCard(
                  icon: Icons.calendar_month_rounded,
                  title: l10n.khatmaInTwoMonths,
                  subtitle: l10n.fifteenPagesDaily,
                  onTap: () => ref
                      .read(khatmaProvider.notifier)
                      .setPlan(60, title: l10n.khatmaInTwoMonths),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStatus(
    BuildContext context,
    KhatmaState state,
    AppLocalizations l10n,
    KhatmaNotifier notifier,
  ) {
    final remaining = notifier.pagesNeededToday;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: remaining > 0
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                remaining > 0
                    ? Icons.trending_up_rounded
                    : Icons.task_alt_rounded,
                color: remaining > 0 ? Colors.orange : Colors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                remaining > 0
                    ? l10n.pagesRemainingToday(remaining.toString())
                    : l10n.onTrack,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: remaining > 0 ? Colors.orange[200] : Colors.green[200],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showHistory(context, state, l10n),
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.white38,
                size: 22,
              ),
              tooltip: l10n.khatmaHistory,
            ),
            IconButton(
              onPressed: () => _showSetup(context),
              icon: const Icon(
                Icons.settings_suggest_rounded,
                color: Colors.white38,
                size: 22,
              ),
              tooltip: l10n.khatmaSettings,
            ),
          ],
        ),
      ],
    );
  }

  void _showHistory(
    BuildContext context,
    KhatmaState state,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFDFBF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.previousKhatmaHistory,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 24),
            if (state.completions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_edu_rounded,
                      size: 64,
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noKhatmasRecorded,
                      style: GoogleFonts.cairo(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: state.completions.reversed.map((completion) {
                      final dateStr =
                          '${completion.completionDate.day}/${completion.completionDate.month}/${completion.completionDate.year}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.blessedKhatma,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.daysCount(completion.totalDays),
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
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

  void _showDua(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const DuaKhatmDialog(),
    );
  }

  Widget _buildKhatmaHistory(KhatmaState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              size: 16,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.previousAchievements,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.completions.reversed.take(3).map((completion) {
          final dateStr =
              '${completion.completionDate.day}/${completion.completionDate.month}/${completion.completionDate.year}';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.khatmCompletedPraise,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.daysCount(completion.totalDays),
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
