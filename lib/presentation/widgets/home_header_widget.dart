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
          setState(() {
            _nextPrayerName = nextName;
            _timeUntilNext = remStr;
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
      height: 420, // Increased to prevent overflow on some screens
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
          // 1. Sky Effects (Stars)
          if (showStars)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SkyPainter(_animationController.value, _stars),
                  size: Size.infinite,
                );
              },
            ),

          // 2. Mosque Silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: MosqueSilhouettePainter(color: mosqueColor),
              size: const Size(double.infinity, 220),
            ),
          ),

          // 3. Optional celestial body (Moon/Sun)
          if (showStars)
            Positioned(
              top: 50, // Moved up to avoid overlap with search/menu
              right: 20, // Moved further right
              child: Opacity(
                opacity: 0.6,
                child: CustomPaint(
                  painter: CrescentMoonPainter(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  size: const Size(24, 24), // Slightly smaller
                ),
              ),
            ),

          // 4. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date Info in Glassmorphic Container
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        borderRadius: 16,
                        opacity: 0.15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                                if (offset != 0) {
                                  // HijriCalendar has hDay, hMonth, hYear.
                                  // We should regenerate it with normalized dates if possible.
                                  // Simplified: just add/subtract from day.
                                  // Note: hijri package doesn't have a direct 'addDays'.
                                  // We can use DateTime conversion.
                                  final dt = adjustedHijri.hijriToGregorian(
                                    adjustedHijri.hYear,
                                    adjustedHijri.hMonth,
                                    adjustedHijri.hDay,
                                  );
                                  final adjustedDt = dt.add(
                                    Duration(days: offset),
                                  );
                                  final newHijri = HijriCalendar.fromDate(
                                    adjustedDt,
                                  );
                                  return FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '$gregorianDate | ${newHijri.hDay} ${newHijri.longMonthName} ${newHijri.hYear}',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$gregorianDate | ${adjustedHijri.hDay} ${adjustedHijri.longMonthName} ${adjustedHijri.hYear}',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Menu and Language Buttons
                      Row(
                        children: [
                          // Language Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                final currentLocale = ref.read(localeProvider);
                                final newLocale =
                                    currentLocale.languageCode == 'ar'
                                    ? const Locale('en')
                                    : const Locale('ar');
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(newLocale);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.language,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Menu Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => GlobalScaffoldService.openDrawer(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Prayer Countdown
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _nextPrayerName.isEmpty
                              ? '...'
                              : '${l10n.nextPrayer} $_nextPrayerName',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Timer with Subtl Glow - Slimmer Font
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              _timeUntilNext.isEmpty
                                  ? '00:00:00'
                                  : _timeUntilNext,
                              style: GoogleFonts.montserrat(
                                fontSize: 52,
                                fontWeight: FontWeight.w100, // Slimmer
                                color: Colors.white.withValues(alpha: 0.05),
                                letterSpacing: 4,
                              ),
                            ),
                            Text(
                              _timeUntilNext.isEmpty
                                  ? '00:00:00'
                                  : _timeUntilNext,
                              style: GoogleFonts.montserrat(
                                fontSize: 48,
                                fontWeight: FontWeight.w200, // Slimmer
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Location Badge (Interactive)
                        InkWell(
                          onTap: () => _showQuickLocationPicker(context, ref),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                locationState.isLoading
                                    ? SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.amber,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.amber, // Gold
                                      ),
                                const SizedBox(width: 6),
                                Text(
                                  currentCityDisplay,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // All Prayer Times Row
                        prayerState.timings.when(
                          data: (data) {
                            if (data == null) {
                              return const SizedBox.shrink();
                            }
                            final timings = data.timings;
                            final prayerList = [
                              {'name': l10n.fajr, 'time': timings['Fajr']},
                              {'name': l10n.dhuhr, 'time': timings['Dhuhr']},
                              {'name': l10n.asr, 'time': timings['Asr']},
                              {
                                'name': l10n.maghrib,
                                'time': timings['Maghrib'],
                              },
                              {'name': l10n.isha, 'time': timings['Isha']},
                            ];

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: prayerList.map((p) {
                                    final isNext = p['name'] == _nextPrayerName;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: GlassContainer(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 12,
                                        ),
                                        borderRadius: 20,
                                        opacity: isNext ? 0.25 : 0.1,
                                        borderColor: isNext
                                            ? Colors.white.withValues(
                                                alpha: 0.4,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderWidth: isNext ? 2 : 1,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              p['name']!,
                                              style: GoogleFonts.tajawal(
                                                fontSize: 12,
                                                color: isNext
                                                    ? Colors.white
                                                    : Colors.white.withValues(
                                                        alpha: 0.6,
                                                      ),
                                                fontWeight: isNext
                                                    ? FontWeight.w900
                                                    : FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              p['time']?.split(' ')[0] ??
                                                  '--:--',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: isNext
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                          loading: () => Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.1),
                            highlightColor: Colors.white.withValues(alpha: 0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                (i) => Container(
                                  width: 60,
                                  height: 50,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickLocationPicker(BuildContext context, WidgetRef ref) {
    // final locationState = ref.read(locationProvider); // Removed
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        blur: 40,
        opacity: 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            // Use GPS Option
            // Use GPS Option - Removed as it's now enforced
            /*
            ListTile(
              onTap: () {
                ref.read(locationProvider.notifier).toggleGPS(true);
                Navigator.pop(context);
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                l10n.useAutoLocation,
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Switch(
                value: locationState.useGPS,
                onChanged: (val) {
                  ref.read(locationProvider.notifier).toggleGPS(val);
                  Navigator.pop(context);
                },
                activeTrackColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            */
            // Manual Hijri Adjustment Option
            ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(),
              builder: (context, box, widget) {
                final offset =
                    box.get('hijri_adjustment_days', defaultValue: 0) as int;
                return ListTile(
                  onTap: () => _showHijriAdjustmentDialog(context, ref, l10n),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    l10n.hijriAdjustment,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    l10n.hijriAdjustmentSubtitle +
                        (offset != 0
                            ? ' (${offset > 0 ? '+' : ''}$offset ${l10n.adjustDays(offset)})'
                            : ''),
                    style: GoogleFonts.tajawal(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.edit_calendar_rounded,
                    color: Colors.white24,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Manual Prayer Adjustment Option
            ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(),
              builder: (context, box, widget) {
                final adjustment =
                    box.get('prayer_adjustment_minutes', defaultValue: 0)
                        as int;
                return ListTile(
                  onTap: () => _showPrayerAdjustmentDialog(context, ref, l10n),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.av_timer_rounded,
                      color: Colors.amber,
                    ),
                  ),
                  title: Text(
                    l10n.prayerAdjustment,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    l10n.prayerAdjustmentSubtitle +
                        (adjustment != 0
                            ? ' (${adjustment > 0 ? '+' : ''}$adjustment ${l10n.minutes(adjustment)})'
                            : ''),
                    style: GoogleFonts.tajawal(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white24,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/prayer-times');
                },
                child: Text(
                  l10n.moreSettings,
                  style: GoogleFonts.tajawal(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
