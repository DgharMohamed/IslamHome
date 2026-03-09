import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/providers/tasbeeh_history_provider.dart';
import 'package:islam_home/presentation/providers/tasbeeh_provider.dart';
import 'package:islam_home/data/models/tasbeeh_log.dart';

class TasbeehHistoryScreen extends ConsumerWidget {
  const TasbeehHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedHistoryDateProvider);
    final dailyStats = ref.watch(tasbeehHistoryStatsProvider(selectedDate));
    final hourlyStats = ref.watch(tasbeehHourlyStatsProvider(selectedDate));
    final dhikrList = ref.watch(tasbeehListProvider);
    final weeklyStats = ref.watch(tasbeehWeeklyStatsProvider);
    final streak = ref.watch(tasbeehStreakProvider);
    final allTimeTotal = ref.read(tasbeehListProvider.notifier).getTotalCount();

    return Scaffold(
      body: AuroraBackground(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildHeader(context, l10n, selectedDate, ref),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSummaryBanner(l10n, streak, allTimeTotal, dailyStats),
                  const SizedBox(height: 24),
                  _buildWeeklyChart(context, l10n, weeklyStats),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildDailySummary(context, l10n, dailyStats, dhikrList),
                  const SizedBox(height: 24),
                  _buildHourlyBreakdown(l10n, hourlyStats),
                  const SizedBox(height: 24),
                  _buildDetailedSessions(
                    context,
                    l10n,
                    ref.watch(tasbeehDetailedLogsProvider(selectedDate)),
                    dhikrList,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    DateTime selectedDate,
    WidgetRef ref,
  ) {
    final formattedDate = DateFormat('d MMM').format(selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                l10n.tasbeehHistory,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                formattedDate,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                ref.read(selectedHistoryDateProvider.notifier).setDate(picked);
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── Summary Banner ───────────────────────────────────────────────────────

  Widget _buildSummaryBanner(
    AppLocalizations l10n,
    int streak,
    int allTimeTotal,
    Map<String, int> dailyStats,
  ) {
    final todayTotal = dailyStats.values.fold<int>(0, (sum, v) => sum + v);

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          _buildBannerStat(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orangeAccent,
            value: streak > 0 ? l10n.streakDays(streak) : '—',
            label: l10n.streak,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.today_rounded,
            iconColor: AppTheme.primaryColor,
            value: '$todayTotal',
            label: l10n.todayTotal,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.all_inclusive_rounded,
            iconColor: Colors.purpleAccent,
            value: '$allTimeTotal',
            label: l10n.allTimeTasbeehs,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    width: 1,
    height: 50,
    color: Colors.white10,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  // ─── Weekly Chart ─────────────────────────────────────────────────────────

  Widget _buildWeeklyChart(
    BuildContext context,
    AppLocalizations l10n,
    Map<DateTime, int> weeklyStats,
  ) {
    final sortedDays = weeklyStats.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    final maxVal = weeklyStats.values.fold<int>(0, (m, v) => v > m ? v : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weeklyActivity,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sortedDays.map((day) {
              final count = weeklyStats[day] ?? 0;
              final heightFactor = maxVal == 0 ? 0.0 : count / maxVal;
              final isToday =
                  day.day == DateTime.now().day &&
                  day.month == DateTime.now().month;
              return _buildBar(day, count, heightFactor, isToday);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(DateTime day, int count, double heightFactor, bool isToday) {
    final label = DateFormat('E').format(day).substring(0, 3);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                color: isToday ? AppTheme.primaryColor : Colors.white38,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: 28,
          height: 80 * heightFactor + (count > 0 ? 4 : 2),
          decoration: BoxDecoration(
            gradient: heightFactor > 0
                ? LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isToday
                        ? [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withValues(alpha: 0.5),
                          ]
                        : [Colors.white24, Colors.white10],
                  )
                : null,
            color: heightFactor == 0 ? Colors.white10 : null,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: isToday ? AppTheme.primaryColor : Colors.white38,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ─── Daily Summary ────────────────────────────────────────────────────────

  Widget _buildDailySummary(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, int> stats,
    List<dynamic> dhikrs,
  ) {
    if (stats.isEmpty) {
      return GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Text(
            l10n.noTasbeehToday,
            style: GoogleFonts.cairo(color: Colors.white54),
          ),
        ),
      );
    }

    final totalToday = stats.values.fold<int>(0, (s, v) => s + v);
    final maxEntry = stats.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dailySummary,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ...stats.entries.map((entry) {
          final dhikr = dhikrs.where((d) => d.id == entry.key).firstOrNull;
          final fraction = totalToday == 0 ? 0.0 : entry.value / totalToday;
          final isBest = entry.key == maxEntry.key;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isBest) ...[
                            const Icon(
                              Icons.star_rounded,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? (dhikr?.arabicText ?? entry.key)
                                : (dhikr?.text ?? entry.key),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily:
                                  Localizations.localeOf(
                                        context,
                                      ).languageCode ==
                                      'ar'
                                  ? 'Amiri'
                                  : GoogleFonts.cairo().fontFamily,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value}',
                        style: GoogleFonts.cairo(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 5,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isBest
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Hourly Breakdown ─────────────────────────────────────────────────────

  Widget _buildHourlyBreakdown(
    AppLocalizations l10n,
    Map<int, int> hourlyStats,
  ) {
    if (hourlyStats.isEmpty) return const SizedBox.shrink();
    final maxCount = hourlyStats.values.fold<int>(0, (m, v) => v > m ? v : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.hourlyBreakdown,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(24, (index) {
              final count = hourlyStats[index] ?? 0;
              if (count == 0) return const SizedBox.shrink();
              final fraction = maxCount == 0 ? 0.0 : count / maxCount;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Text(
                        '${index == 0
                            ? 12
                            : index > 12
                            ? index - 12
                            : index} ${index >= 12 ? 'PM' : 'AM'}',
                        style: GoogleFonts.cairo(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: fraction.clamp(0.03, 1.0),
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── Detailed Sessions ────────────────────────────────────────────────────

  Widget _buildDetailedSessions(
    BuildContext context,
    AppLocalizations l10n,
    List<TasbeehLog> logs,
    List<dynamic> dhikrs,
  ) {
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detailedLog,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ...logs.map((log) {
          final dhikr = dhikrs.where((d) => d.id == log.dhikrId).firstOrNull;
          final time = log.timestamp ?? log.date.add(Duration(hours: log.hour));

          return GlassContainer(
            borderRadius: 15,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? (dhikr?.arabicText ?? log.dhikrId)
                            : (dhikr?.text ?? log.dhikrId),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Amiri'
                              : GoogleFonts.cairo().fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.cairo(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${log.count}',
                    style: GoogleFonts.cairo(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
