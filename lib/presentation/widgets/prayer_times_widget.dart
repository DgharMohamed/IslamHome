import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/services/notification_service.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class PrayerTimesWidget extends ConsumerStatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  ConsumerState<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends ConsumerState<PrayerTimesWidget> {
  Timer? _timer;
  String _timeUntilNext = "";
  String _nextPrayerName = "";
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      debugPrint('Error calculating next prayer: $e');
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

    final currentCityDisplay = '${prayerState.city}, ${prayerState.country}';

    return prayerState.timings.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        return GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 16,
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.nextPrayer,
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nextPrayerName.isEmpty ? '...' : _nextPrayerName,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.hijriDate,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        tooltip: 'تجربة الأذان',
                        onPressed: () => NotificationService().testAthan(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _timeUntilNext.isEmpty ? '00:00:00' : _timeUntilNext,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.explore_outlined,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentCityDisplay (${l10n.qibla}: 102°)',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPrayerTimeSmall('Fajr', l10n.fajr, data.getFajr()),
                  _buildPrayerTimeSmall('Dhuhr', l10n.dhuhr, data.getDhuhr()),
                  _buildPrayerTimeSmall('Asr', l10n.asr, data.getAsr()),
                  _buildPrayerTimeSmall(
                    'Maghrib',
                    l10n.maghrib,
                    data.getMaghrib(),
                  ),
                  _buildPrayerTimeSmall('Isha', l10n.isha, data.getIsha()),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildPrayerTimeSmall(String id, String name, String time) {
    // Basic time cleanup (remove trailing zone info)
    final cleanTime = time.split(' ')[0];
    final box = Hive.box('settings');
    final bool isAthanEnabled = box.get(
      'athan_enabled_$id',
      defaultValue: true,
    );

    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          cleanTime,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            ref
                .read(prayerNotifierProvider.notifier)
                .togglePrayerAthan(id, !isAthanEnabled);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAthanEnabled
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAthanEnabled
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              isAthanEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              size: 20,
              color: isAthanEnabled ? AppTheme.primaryColor : Colors.white38,
            ),
          ),
        ),
      ],
    );
  }
}
