import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/data/models/prayer_method.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String _nextPrayerName = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _calculateNextPrayer();
    });
  }

  void _calculateNextPrayer() {
    final state = ref.read(prayerNotifierProvider);
    state.timings.whenData((data) {
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
          nextName = name;
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
        nextName = 'Fajr';
      }

      if (mounted) {
        setState(() {
          _remaining = nextTime!.difference(now);
          _nextPrayerName = nextName;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color _prayerAccentColor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Colors.tealAccent;
      case 'Sunrise':
        return Colors.orangeAccent;
      case 'Dhuhr':
        return Colors.amberAccent;
      case 'Asr':
        return Colors.deepOrangeAccent;
      case 'Maghrib':
        return Colors.pinkAccent;
      case 'Isha':
        return Colors.purpleAccent;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final nextColor = _prayerAccentColor(_nextPrayerName);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.prayerTimesTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showSettingsBottomSheet(state, l10n),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background subtle gradient based on next prayer color
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    nextColor.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.top + 60),
              ),
              // Modern Hero Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildHeroSection(state, l10n, nextColor),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
              // Clean Timeline List
              state.timings.when(
                data: (data) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (data != null) ...[
                        _buildTimelineItem(l10n.fajr, data.getFajr(), Icons.wb_twilight, 'Fajr'),
                        _buildTimelineItem(l10n.sunrise, data.getSunrise(), Icons.wb_sunny_outlined, 'Sunrise'),
                        _buildTimelineItem(l10n.dhuhr, data.getDhuhr(), Icons.wb_sunny, 'Dhuhr'),
                        _buildTimelineItem(l10n.asr, data.getAsr(), Icons.cloud_queue_rounded, 'Asr'),
                        _buildTimelineItem(l10n.maghrib, data.getMaghrib(), Icons.nights_stay_outlined, 'Maghrib'),
                        _buildTimelineItem(l10n.isha, data.getIsha(), Icons.nights_stay_rounded, 'Isha', isLast: true),
                      ] else
                        Center(
                          child: Text(
                            l10n.noPrayerTimesFound,
                            style: GoogleFonts.cairo(color: Colors.white54),
                          ),
                        ),
                      const SizedBox(height: 60),
                    ]),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'حدث خطأ في تحميل البيانات',
                      style: GoogleFonts.cairo(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(PrayerState state, AppLocalizations l10n, Color nextColor) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hasCountdown = _nextPrayerName.isNotEmpty && _remaining.inSeconds > 0;
    final h = hasCountdown ? twoDigits(_remaining.inHours) : '--';
    final m = hasCountdown ? twoDigits(_remaining.inMinutes.remainder(60)) : '--';
    final s = hasCountdown ? twoDigits(_remaining.inSeconds.remainder(60)) : '--';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, color: nextColor, size: 16),
              const SizedBox(width: 8),
              Text(
                '${state.city}, ${state.country}',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _nextPrayerName.isEmpty ? '...' : _getLocalizedPrayerName(_nextPrayerName, l10n),
            style: GoogleFonts.cairo(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _timeDigit(h, nextColor),
              _timeColon(nextColor),
              _timeDigit(m, nextColor),
              _timeColon(nextColor),
              _timeDigit(s, nextColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.timeUntilAdhan,
            style: GoogleFonts.cairo(
              color: Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeDigit(String val, Color color) {
    return Text(
      val,
      style: GoogleFonts.montserrat(
        fontSize: 48,
        fontWeight: FontWeight.w200,
        color: color,
        letterSpacing: 2,
      ),
    );
  }

  Widget _timeColon(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.w200,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  String _getLocalizedPrayerName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Fajr': return l10n.fajr;
      case 'Sunrise': return l10n.sunrise;
      case 'Dhuhr': return l10n.dhuhr;
      case 'Asr': return l10n.asr;
      case 'Maghrib': return l10n.maghrib;
      case 'Isha': return l10n.isha;
      default: return '...';
    }
  }

  Widget _buildTimelineItem(String name, String time, IconData icon, String key, {bool isLast = false}) {
    final isNext = _nextPrayerName == key;
    final color = _prayerAccentColor(key);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: isNext ? color : AppTheme.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isNext ? color : Colors.white24,
                      width: 3,
                    ),
                    boxShadow: isNext
                        ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isNext ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNext ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.03),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: isNext ? color : Colors.white54, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                              color: isNext ? Colors.white : Colors.white70,
                            ),
                          ),
                          Text(
                            time,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                              color: isNext ? color : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (key != 'Sunrise')
                      ValueListenableBuilder(
                        valueListenable: Hive.box('settings').listenable(
                          keys: ['athan_global_enabled', 'athan_enabled_$key'],
                        ),
                        builder: (context, box, widget) {
                          final globalEnabled = box.get('athan_global_enabled', defaultValue: true) as bool;
                          final isEnabled = box.get('athan_enabled_$key', defaultValue: true) as bool;
                          final active = isEnabled && globalEnabled;

                          return GestureDetector(
                            onTap: () => ref.read(prayerNotifierProvider.notifier).togglePrayerAthan(key, !isEnabled),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                active ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                                color: active ? color : Colors.white24,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(PrayerState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.settings,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Global Adhan Settings
                ValueListenableBuilder(
                  valueListenable: Hive.box('settings').listenable(keys: ['athan_global_enabled']),
                  builder: (context, box, _) {
                    final isEnabled = box.get('athan_global_enabled', defaultValue: true) as bool;
                    return _buildSettingsTile(
                      title: l10n.athanNotifications,
                      icon: isEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                      trailing: Switch(
                        value: isEnabled,
                        onChanged: (val) => ref.read(prayerNotifierProvider.notifier).toggleAthan(val),
                        activeThumbColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),

                // Calculation Method
                _buildSettingsTile(
                  title: l10n.calculationMethodTitle,
                  subtitle: PrayerMethod.getLocalizedName(state.calculationMethodId, l10n),
                  icon: Icons.calculate_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    _showCalculationMethodDialog(state, l10n);
                  },
                ),

                // Prayer Adjustment
                ValueListenableBuilder(
                  valueListenable: Hive.box('settings').listenable(keys: ['prayer_adjustment_minutes']),
                  builder: (context, box, _) {
                    final adjustment = box.get('prayer_adjustment_minutes', defaultValue: 0) as int;
                    return _buildSettingsTile(
                      title: l10n.prayerAdjustment,
                      subtitle: adjustment != 0
                          ? '${adjustment > 0 ? '+' : ''}$adjustment ${l10n.minutes(adjustment)}'
                          : '0 ${l10n.minutes(0)}',
                      icon: Icons.av_timer_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        _showPrayerAdjustmentDialog(context, ref, l10n);
                      },
                    );
                  },
                ),

                // Pre-Prayer Reminders
                ValueListenableBuilder(
                  valueListenable: Hive.box('settings').listenable(
                    keys: ['athan_pre_reminders_enabled', 'athan_reminder_minutes'],
                  ),
                  builder: (context, box, _) {
                    final isEnabled = box.get('athan_pre_reminders_enabled', defaultValue: false) as bool;
                    final reminderMin = box.get('athan_reminder_minutes', defaultValue: 15) as int;
                    return Column(
                      children: [
                        _buildSettingsTile(
                          title: l10n.prePrayerReminders,
                          subtitle: l10n.prePrayerReminderSubtitle(reminderMin),
                          icon: Icons.auto_awesome_rounded,
                          trailing: Switch(
                            value: isEnabled,
                            onChanged: (val) => ref.read(prayerNotifierProvider.notifier).togglePreAthanReminders(val),
                            activeThumbColor: AppTheme.primaryColor,
                          ),
                        ),
                        if (isEnabled)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [5, 10, 15, 30].map((min) => GestureDetector(
                                onTap: () => ref.read(prayerNotifierProvider.notifier).setReminderMinutes(min),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: reminderMin == min ? AppTheme.primaryColor : Colors.white10,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('$minد', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              )).toList(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        title: Text(title, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13)) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
      ),
    );
  }

  void _showCalculationMethodDialog(PrayerState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: PrayerMethod.methods.length,
        itemBuilder: (context, index) {
          final method = PrayerMethod.methods[index];
          final isSelected = state.calculationMethodId == method.id;
          return ListTile(
            title: Text(PrayerMethod.getLocalizedName(method.id, l10n), style: GoogleFonts.cairo(color: Colors.white)),
            trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
            onTap: () {
              ref.read(prayerNotifierProvider.notifier).updateCalculationMethod(method.id);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _showPrayerAdjustmentDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final box = Hive.box('settings');
    int currentAdjustment = box.get('prayer_adjustment_minutes', defaultValue: 0) as int;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(l10n.prayerAdjustment, style: GoogleFonts.cairo(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                      onPressed: () => setDialogState(() => currentAdjustment--),
                    ),
                    Text('$currentAdjustment', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      onPressed: () => setDialogState(() => currentAdjustment++),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
              ElevatedButton(
                onPressed: () {
                  ref.read(prayerNotifierProvider.notifier).updateAdjustment(currentAdjustment);
                  Navigator.pop(context);
                },
                child: Text(l10n.done),
              ),
            ],
          );
        },
      ),
    );
  }
}
