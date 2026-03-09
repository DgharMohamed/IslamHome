import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/widgets/home_header_painters.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/providers/location_provider.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

class HomeHeaderWidget extends ConsumerStatefulWidget {
  const HomeHeaderWidget({super.key});

  @override
  ConsumerState<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends ConsumerState<HomeHeaderWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  String _timeUntilNext = "";
  String _nextPrayerName = "";
  double _dayProgress = 0.0;
  late AnimationController _animationController;
  final List<Star> _stars = Star.generate(50);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateNextPrayer();
      }
    });
  }

  void _calculateNextPrayer() {
    try {
      final prayerState = ref.read(prayerNotifierProvider);
      final l10n = AppLocalizations.of(context)!;

      prayerState.timings.whenData((data) {
        if (data == null) return;

        final now = DateTime.now();
        final prayerTimes = data.timings;
        final names = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        DateTime? nextTime;
        String nextName = '';

        for (var name in names) {
          final timeStr = prayerTimes[name];
          if (timeStr == null) continue;

          final parts = timeStr.split(':');
          if (parts.length < 2) continue;

          final pTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

          if (pTime.isAfter(now)) {
            nextTime = pTime;
            nextName = _getLocalizedName(name, l10n);
            break;
          }
        }

        if (nextTime == null) {
          final fajrStr = prayerTimes['Fajr']!;
          final parts = fajrStr.split(':');
          nextTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          nextName = l10n.fajr;
        }

        final remaining = nextTime.difference(now);
        final remStr = _formatDuration(remaining);

        if (mounted &&
            (_nextPrayerName != nextName || _timeUntilNext != remStr)) {
          final progress = (now.hour * 60 + now.minute) / (24 * 60);
          setState(() {
            _nextPrayerName = nextName;
            _timeUntilNext = remStr;
            _dayProgress = progress;
          });
        }
      });
    } catch (e) {
      debugPrint('Error in HomeHeader timer: $e');
    }
  }

  String _getLocalizedName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Fajr':
        return l10n.fajr;
      case 'Sunrise':
        return l10n.sunrise;
      case 'Dhuhr':
        return l10n.dhuhr;
      case 'Asr':
        return l10n.asr;
      case 'Maghrib':
        return l10n.maghrib;
      case 'Isha':
        return l10n.isha;
      default:
        return key;
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final locationState = ref.watch(locationProvider);

    // final hijri = HijriCalendar.now(); // Removed as we use ValueListenableBuilder below
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', l10n.localeName).format(now);
    final gregorianDate = DateFormat(
      'd MMMM yyyy',
      l10n.localeName,
    ).format(now);

    final currentCityDisplay = '${prayerState.city}, ${prayerState.country}';

    // Dynamic Theme Logic
    final hour = now.hour;
    List<Color> gradientColors;
    bool showStars = false;
    Color mosqueColor;

    if (hour >= 5 && hour < 8) {
      // Dawn
      gradientColors = [const Color(0xFF1A237E), const Color(0xFFE91E63)];
      mosqueColor = const Color(0xFF10153F);
    } else if (hour >= 8 && hour < 17) {
      // Day
      gradientColors = [const Color(0xFF1E88E5), const Color(0xFF4FC3F7)];
      mosqueColor = const Color(0xFF0D47A1).withValues(alpha: 0.3);
    } else if (hour >= 17 && hour < 19) {
      // Sunset
      gradientColors = [const Color(0xFFE64A19), const Color(0xFFFFCC80)];
      mosqueColor = const Color(0xFF3E2723);
    } else {
      // Night
      gradientColors = [const Color(0xFF0F172A), const Color(0xFF1E293B)];
      showStars = true;
      mosqueColor = const Color(0xFF020617);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // 1. Stars (night mode)
          if (showStars)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SkyPainter(_animationController.value, _stars),
                    size: Size.infinite,
                  );
                },
              ),
            ),

          // 2. Mosque Silhouette (compact)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: MosqueSilhouettePainter(color: mosqueColor),
              size: const Size(double.infinity, 120),
            ),
          ),

          // 3. Celestial body (Moon/Sun)
          if (showStars)
            Positioned(
              top: 48,
              right: 20,
              child: Opacity(
                opacity: 0.6,
                child: CustomPaint(
                  painter: CrescentMoonPainter(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  size: const Size(20, 20),
                ),
              ),
            ),

          // 4. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP BAR ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Compact date glass card
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        borderRadius: 14,
                        opacity: 0.15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: Hive.box(
                                'settings',
                              ).listenable(),
                              builder: (context, box, widget) {
                                final offset =
                                    box.get(
                                          'hijri_adjustment_days',
                                          defaultValue: 0,
                                        )
                                        as int;
                                final adjustedHijri = HijriCalendar.now();
                                HijriCalendar displayHijri = adjustedHijri;
                                if (offset != 0) {
                                  final dt = adjustedHijri.hijriToGregorian(
                                    adjustedHijri.hYear,
                                    adjustedHijri.hMonth,
                                    adjustedHijri.hDay,
                                  );
                                  displayHijri = HijriCalendar.fromDate(
                                    dt.add(Duration(days: offset)),
                                  );
                                }
                                return Text(
                                  '$gregorianDate | ${displayHijri.hDay} ${displayHijri.longMonthName} ${displayHijri.hYear}',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons (Language + Menu)
                      Row(
                        children: [
                          _actionButton(
                            onTap: () {
                              final currentLocale = ref.read(localeProvider);
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(
                                    currentLocale.languageCode == 'ar'
                                        ? const Locale('en')
                                        : const Locale('ar'),
                                  );
                            },
                            icon: Icons.language,
                          ),
                          const SizedBox(width: 8),
                          _actionButton(
                            onTap: () => GlobalScaffoldService.openDrawer(),
                            icon: Icons.menu_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── MAIN ROW: Countdown + Progress Ring ──────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Next prayer label + countdown + location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nextPrayerName.isEmpty
                                  ? '...'
                                  : '${l10n.nextPrayer} $_nextPrayerName',
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _timeUntilNext.isEmpty
                                  ? '00:00:00'
                                  : _timeUntilNext,
                              style: GoogleFonts.montserrat(
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Compact Location Badge
                            InkWell(
                              onTap: () =>
                                  _showQuickLocationPicker(context, ref),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    locationState.isLoading
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              color: Colors.amber,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                    const SizedBox(width: 4),
                                    Text(
                                      currentCityDisplay,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 12,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right: Day Progress Ring (P1 element)
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            CircularProgressIndicator(
                              value: _dayProgress,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.75),
                              ),
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                            ),
                            // Center Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              child: Icon(
                                showStars
                                    ? Icons.nightlight_round
                                    : (hour >= 17
                                          ? Icons.wb_twilight_rounded
                                          : Icons.wb_sunny_rounded),
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── PRAYER PILLS ROW (P3 element – flat, equal-width) ──
                  prayerState.timings.when(
                    data: (data) {
                      if (data == null) return const SizedBox.shrink();
                      final timings = data.timings;
                      final prayerList = [
                        {'name': l10n.fajr, 'time': timings['Fajr']},
                        {'name': l10n.dhuhr, 'time': timings['Dhuhr']},
                        {'name': l10n.asr, 'time': timings['Asr']},
                        {'name': l10n.maghrib, 'time': timings['Maghrib']},
                        {'name': l10n.isha, 'time': timings['Isha']},
                      ];
                      return Row(
                        children: prayerList.map((p) {
                          final isNext = p['name'] == _nextPrayerName;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isNext
                                    ? Colors.white.withValues(alpha: 0.22)
                                    : Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isNext
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: isNext ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p['name']!,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 9,
                                      color: isNext
                                          ? Colors.white
                                          : Colors.white60,
                                      fontWeight: isNext
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p['time']?.split(' ')[0] ?? '--:--',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: isNext
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => Shimmer.fromColors(
                      baseColor: Colors.white.withValues(alpha: 0.1),
                      highlightColor: Colors.white.withValues(alpha: 0.2),
                      child: Row(
                        children: List.generate(
                          5,
                          (i) => Expanded(
                            child: Container(
                              height: 44,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required VoidCallback onTap, required IconData icon}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  void _showQuickLocationPicker(BuildContext context, WidgetRef ref) {
    // final locationState = ref.read(locationProvider); // Removed
    final l10n = AppLocalizations.of(context)!;
    final prayerState = ref.read(prayerNotifierProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // ── HEADER ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withValues(alpha: 0.3),
                          Colors.orange.withValues(alpha: 0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${prayerState.city}, ${prayerState.country}',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.prayerTimes,
                        style: GoogleFonts.tajawal(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/prayer-times');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.15,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.moreSettings,
                      style: GoogleFonts.tajawal(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(
              color: Colors.white.withValues(alpha: 0.06),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 8),

            // ── HIJRI ADJUSTMENT ─────────────────────────────────────
            ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(),
              builder: (context, box, widget) {
                final offset =
                    box.get('hijri_adjustment_days', defaultValue: 0) as int;
                return _settingsItem(
                  context: context,
                  onTap: () => _showHijriAdjustmentDialog(context, ref, l10n),
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  iconBg: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                  title: l10n.hijriAdjustment,
                  subtitle: offset != 0
                      ? '${offset > 0 ? '+' : ''}$offset ${l10n.adjustDays(offset)}'
                      : l10n.hijriAdjustmentSubtitle,
                  badge: offset != 0 ? '${offset > 0 ? '+' : ''}$offset' : null,
                  badgeColor: offset != 0 ? const Color(0xFF4CAF50) : null,
                );
              },
            ),

            Divider(
              color: Colors.white.withValues(alpha: 0.05),
              height: 1,
              indent: 68,
              endIndent: 20,
            ),

            // ── PRAYER TIME ADJUSTMENT ───────────────────────────────
            ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(),
              builder: (context, box, widget) {
                final adjustment =
                    box.get('prayer_adjustment_minutes', defaultValue: 0)
                        as int;
                return _settingsItem(
                  context: context,
                  onTap: () => _showPrayerAdjustmentDialog(context, ref, l10n),
                  icon: Icons.av_timer_rounded,
                  iconColor: Colors.amber,
                  iconBg: Colors.amber.withValues(alpha: 0.12),
                  title: l10n.prayerAdjustment,
                  subtitle: adjustment != 0
                      ? '${adjustment > 0 ? '+' : ''}$adjustment ${l10n.minutes(adjustment)}'
                      : l10n.prayerAdjustmentSubtitle,
                  badge: adjustment != 0
                      ? '${adjustment > 0 ? '+' : ''}$adjustment'
                      : null,
                  badgeColor: adjustment != 0 ? Colors.amber : null,
                );
              },
            ),

            const SizedBox(height: 16),

            // ── SAFE AREA BOTTOM ─────────────────────────────────────
            SafeArea(child: const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.montserrat(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showPrayerAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final box = Hive.box('settings');
    int currentAdjustment =
        box.get('prayer_adjustment_minutes', defaultValue: 0) as int;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hours = (currentAdjustment / 60).abs().floor();
            final minutes = (currentAdjustment.abs() % 60);
            final isNegative = currentAdjustment < 0;
            final sign = currentAdjustment > 0 ? '+' : (isNegative ? '-' : '');

            String displayText = '';
            if (currentAdjustment == 0) {
              displayText = '0 ${l10n.minutes(0)}';
            } else {
              if (hours > 0) displayText += '$sign$hours ${l10n.hours(hours)} ';
              if (minutes > 0) {
                displayText +=
                    '${hours > 0 ? '' : sign}$minutes ${l10n.minutes(minutes)}';
              }
            }

            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                l10n.prayerAdjustment,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.manualOffset,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Hours adjustment
                  Text(
                    l10n.hour,
                    style: GoogleFonts.tajawal(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAdjustButtonLocal(
                        icon: Icons.remove,
                        onTap: () =>
                            setDialogState(() => currentAdjustment -= 60),
                      ),
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text(
                          '$hours',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildAdjustButtonLocal(
                        icon: Icons.add,
                        onTap: () =>
                            setDialogState(() => currentAdjustment += 60),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Minutes adjustment
                  Text(
                    l10n.adjustMinutes(1).replaceAll('1', '').trim(),
                    style: GoogleFonts.tajawal(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAdjustButtonLocal(
                        icon: Icons.remove,
                        onTap: () => setDialogState(() => currentAdjustment--),
                      ),
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text(
                          '$minutes',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildAdjustButtonLocal(
                        icon: Icons.add,
                        onTap: () => setDialogState(() => currentAdjustment++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Total Summary
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.manualOffset,
                          style: GoogleFonts.cairo(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayText,
                          style: GoogleFonts.montserrat(
                            color: AppTheme.primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.cairo(color: Colors.white38),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(prayerNotifierProvider.notifier)
                        .updateAdjustment(currentAdjustment);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(100, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.done,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHijriAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final box = Hive.box('settings');
    int currentOffset =
        box.get('hijri_adjustment_days', defaultValue: 0) as int;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                l10n.hijriAdjustment,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.hijriAdjustmentSubtitle,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAdjustButtonLocal(
                        icon: Icons.remove,
                        onTap: () {
                          if (currentOffset > -15) {
                            setDialogState(() => currentOffset--);
                          }
                        },
                      ),
                      Container(
                        width: 120,
                        alignment: Alignment.center,
                        child: Text(
                          '${currentOffset > 0 ? '+' : ''}$currentOffset',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildAdjustButtonLocal(
                        icon: Icons.add,
                        onTap: () {
                          if (currentOffset < 15) {
                            setDialogState(() => currentOffset++);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.adjustDays(currentOffset),
                    style: GoogleFonts.tajawal(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.cairo(color: Colors.white38),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await box.put('hijri_adjustment_days', currentOffset);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(100, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAdjustButtonLocal({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
