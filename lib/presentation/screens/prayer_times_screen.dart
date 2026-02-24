import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/data/models/prayer_method.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islam_home/data/services/audio_player_service.dart';
import 'package:islam_home/data/services/notification_service.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  // List<Map<String, String>> _habousCities = []; // Removed
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String _nextPrayerName = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // _loadCities(); // Removed
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

      // If no more prayers today, next is Fajr tomorrow
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

  /*
  Future<void> _loadCities() async {
    final jsonStr = await rootBundle.loadString(
      'assets/json/habous_cities.json',
    );
    final data = json.decode(jsonStr);
    if (mounted) {
      setState(() {
        _habousCities = List<Map<String, String>>.from(
          data.map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }
  */

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    // final isArabic = Localizations.localeOf(context).languageCode == 'ar'; // removed unused

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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.15),
              AppTheme.backgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.top + 60),
            ),

            // Premium Header (Inspired by screenshot)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildHeader(state, l10n),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Timings List
            state.timings.when(
              data: (data) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (data != null) ...[
                      _buildPrayerItem(
                        l10n.fajr,
                        data.getFajr(),
                        Icons.wb_twilight,
                        'Fajr',
                        l10n,
                      ),
                      _buildPrayerItem(
                        l10n.sunrise,
                        data.getSunrise(),
                        Icons.wb_sunny_outlined,
                        'Sunrise',
                        l10n,
                      ),
                      _buildPrayerItem(
                        l10n.dhuhr,
                        data.getDhuhr(),
                        Icons.wb_sunny,
                        'Dhuhr',
                        l10n,
                      ),
                      _buildPrayerItem(
                        l10n.asr,
                        data.getAsr(),
                        Icons.cloud_queue_rounded,
                        'Asr',
                        l10n,
                      ),
                      _buildPrayerItem(
                        l10n.maghrib,
                        data.getMaghrib(),
                        Icons.nights_stay_outlined,
                        'Maghrib',
                        l10n,
                      ),
                      _buildPrayerItem(
                        l10n.isha,
                        data.getIsha(),
                        Icons.nights_stay_rounded,
                        'Isha',
                        l10n,
                      ),
                    ] else
                      Center(
                        child: Text(
                          l10n.noPrayerTimesFound,
                          style: GoogleFonts.cairo(color: Colors.white54),
                        ),
                      ),
                  ]),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    e.toString(),
                    style: GoogleFonts.cairo(color: Colors.redAccent),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Settings Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildLocationSettings(state, l10n),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PrayerState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.city,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.location_on_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _getLocalizedPrayerName(_nextPrayerName, l10n),
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDuration(_remaining),
            style: GoogleFonts.montserrat(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الوقت المتبقي للأذان',
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(
    String name,
    String time,
    IconData icon,
    String key,
    AppLocalizations l10n,
  ) {
    final isNext = _nextPrayerName == key;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isNext
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.surfaceColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: isNext
            ? Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.8),
                width: 2,
              )
            : Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isNext
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isNext ? AppTheme.primaryColor : Colors.white38,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: isNext ? FontWeight.w900 : FontWeight.bold,
                  color: isNext ? AppTheme.primaryColor : Colors.white70,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                time,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(
                  keys: ['athan_global_enabled', 'athan_enabled_$key'],
                ),
                builder: (context, box, widget) {
                  final globalEnabled =
                      box.get('athan_global_enabled', defaultValue: true)
                          as bool;
                  final isEnabled =
                      box.get('athan_enabled_$key', defaultValue: true) as bool;

                  if (key == 'Sunrise') return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(prayerNotifierProvider.notifier)
                          .togglePrayerAthan(key, !isEnabled);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isEnabled && globalEnabled)
                            ? AppTheme.primaryColor.withValues(alpha: 0.15)
                            : Colors.black26,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isEnabled && globalEnabled)
                              ? AppTheme.primaryColor.withValues(alpha: 0.3)
                              : Colors.white10,
                        ),
                      ),
                      child: Icon(
                        (isEnabled && globalEnabled)
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: (isEnabled && globalEnabled)
                            ? AppTheme.primaryColor
                            : Colors.white24,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSettings(PrayerState state, AppLocalizations l10n) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings_rounded, color: Colors.white38, size: 20),
            const SizedBox(width: 8),
            Text(
              'الإعدادات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (Platform.isAndroid)
          FutureBuilder<bool>(
            future: NotificationService().holdsExactAlarmPermission(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == false) {
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic
                                  ? 'تنبيهات الآذان قد لا تعمل'
                                  : 'Adhan alerts might not work',
                              style: GoogleFonts.cairo(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              isArabic
                                  ? 'الرجاء تفعيل إذن "التنبيهات الدقيقة" من الإعدادات.'
                                  : 'Please enable "Exact Alarms" in system settings.',
                              style: GoogleFonts.cairo(
                                color: Colors.amber.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            NotificationService().requestExactAlarmPermission(),
                        child: Text(
                          isArabic ? 'تفعيل' : 'Enable',
                          style: GoogleFonts.cairo(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        const SizedBox(height: 16),
        // Adhan Settings
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ValueListenableBuilder(
            valueListenable: Hive.box(
              'settings',
            ).listenable(keys: ['athan_global_enabled']),
            builder: (context, box, widget) {
              final isEnabled =
                  box.get('athan_global_enabled', defaultValue: true) as bool;
              return ListTile(
                onTap: () {
                  ref
                      .read(prayerNotifierProvider.notifier)
                      .toggleAthan(!isEnabled);
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: isEnabled ? Colors.amber : Colors.white38,
                    size: 20,
                  ),
                ),
                title: Text(
                  isArabic ? 'تنبيهات الآذان' : 'Adhan Notifications',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (val) {
                    ref.read(prayerNotifierProvider.notifier).toggleAthan(val);
                  },
                  activeThumbColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Pre-Prayer Reminders Settings
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ValueListenableBuilder(
            valueListenable: Hive.box('settings').listenable(
              keys: ['athan_pre_reminders_enabled', 'athan_reminder_minutes'],
            ),
            builder: (context, box, widget) {
              final isEnabled =
                  box.get('athan_pre_reminders_enabled', defaultValue: false)
                      as bool;
              final reminderMin =
                  box.get('athan_reminder_minutes', defaultValue: 15) as int;
              return ListTile(
                onTap: () {
                  ref
                      .read(prayerNotifierProvider.notifier)
                      .togglePreAthanReminders(!isEnabled);
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: isEnabled ? AppTheme.primaryColor : Colors.white38,
                    size: 20,
                  ),
                ),
                title: Text(
                  isArabic ? 'تذكير ما قبل الصلاة' : 'Pre-Prayer Reminders',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  isArabic
                      ? 'تنبيه للاستعداد والأذكار قبل الصلاة بـ $reminderMin دقيقة'
                      : 'Reminder to prepare and read Azkar $reminderMin mins before',
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                ),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (val) {
                    ref
                        .read(prayerNotifierProvider.notifier)
                        .togglePreAthanReminders(val);
                  },
                  activeThumbColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Reminder Timing Picker (shown only when reminders enabled)
        ValueListenableBuilder(
          valueListenable: Hive.box('settings').listenable(
            keys: ['athan_pre_reminders_enabled', 'athan_reminder_minutes'],
          ),
          builder: (context, box, _) {
            final isEnabled =
                box.get('athan_pre_reminders_enabled', defaultValue: false)
                    as bool;
            if (!isEnabled) return const SizedBox.shrink();

            final selected =
                box.get('athan_reminder_minutes', defaultValue: 15) as int;
            final options = [5, 10, 15, 30];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isArabic ? 'وقت التذكير' : 'Remind before',
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ...options.map(
                    (min) => GestureDetector(
                      onTap: () => ref
                          .read(prayerNotifierProvider.notifier)
                          .setReminderMinutes(min),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected == min
                              ? AppTheme.primaryColor
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${min}د',
                          style: GoogleFonts.cairo(
                            color: selected == min
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Adhan Preview
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final audioService = ref.watch(audioPlayerServiceProvider);
              final player = ref.watch(playerProvider);

              return StreamBuilder<PlayerState>(
                stream: player?.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing ?? false;

                  // Check if the current audio is the athan preview
                  bool isAthanPlaying =
                      playing &&
                      (processingState != ProcessingState.completed &&
                          processingState != ProcessingState.idle);

                  // More specific check if possible, but since we set id to 'athan_preview'
                  final currentItem =
                      player?.sequenceState?.currentSource?.tag as MediaItem?;
                  isAthanPlaying =
                      isAthanPlaying && currentItem?.id == 'athan_preview';

                  return ListTile(
                    onTap: () async {
                      if (audioService == null) return;
                      if (isAthanPlaying) {
                        await audioService.stop();
                      } else {
                        await audioService.playAthan();
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAthanPlaying
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAthanPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color: isAthanPlaying
                            ? AppTheme.primaryColor
                            : Colors.white38,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      isArabic ? 'سماع صوت الآذان' : 'Preview Adhan Sound',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      isArabic
                          ? (isAthanPlaying
                                ? 'جاري التشغيل...'
                                : 'اضغط للاستماع')
                          : (isAthanPlaying
                                ? 'Now playing...'
                                : 'Tap to listen'),
                      style: GoogleFonts.cairo(
                        color: isAthanPlaying
                            ? AppTheme.primaryColor
                            : Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isAthanPlaying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: Colors.white10,
                          ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              // Manual location selection removed - GPS enforced
              /*
              _buildSettingRow(
                'الدولة',
                state.country,
                Icons.public_rounded,
                () => _showCountryPicker(),
              ),
              const Divider(color: Colors.white10, height: 1, indent: 60),
              _buildSettingRow(
                'المدينة',
                state.city,
                Icons.location_city_rounded,
                () => state.country == 'Morocco' || state.country == 'المغرب'
                    ? _showHabousCityPicker()
                    : _showManualCityInput(),
              ),
              const Divider(color: Colors.white10, height: 1, indent: 60),
              */
              // Calculation Method Option
              _buildSettingRow(
                isArabic ? 'طريقة الحساب' : 'Calculation Method',
                _getSelectedMethodName(state.calculationMethodId, isArabic),
                Icons.calculate_rounded,
                () => _showCalculationMethodDialog(state, isArabic, l10n),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white24,
                  size: 14,
                ),
              ),
              const Divider(color: Colors.white10, height: 1, indent: 60),
              // Manual Prayer Adjustment Option
              ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(),
                builder: (context, box, widget) {
                  final adjustment =
                      box.get('prayer_adjustment_minutes', defaultValue: 0)
                          as int;
                  return _buildSettingRow(
                    l10n.prayerAdjustment,
                    adjustment != 0
                        ? '${adjustment > 0 ? '+' : ''}$adjustment ${l10n.minutes(adjustment)}'
                        : '0 ${l10n.minutes(0)}',
                    Icons.av_timer_rounded,
                    () => _showPrayerAdjustmentDialog(context, ref, l10n),
                    trailing: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  ListTile _buildSettingRow(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 14,
              ),
        ],
      ),
    );
  }

  /*
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPickerOption('المغرب', 'Morocco', true),
            const SizedBox(height: 12),
            _buildPickerOption('دولة أخرى', 'Other', false),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(String label, String value, bool isMorocco) {
    return ListTile(
      title: Text(label, style: GoogleFonts.cairo(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (isMorocco) {
          ref
              .read(prayerNotifierProvider.notifier)
              .updateLocation(
                city: 'الرباط',
                country: 'Morocco',
                habousId: '1',
              );
        } else {
          _showManualCityInput();
        }
      },
    );
  }

  void _showHabousCityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _habousCities.length,
                itemBuilder: (context, index) {
                  final city = _habousCities[index];
                  return ListTile(
                    title: Text(
                      city['name'] ?? '',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    onTap: () {
                      ref
                          .read(prayerNotifierProvider.notifier)
                          .updateLocation(
                            city: city['name']!,
                            country: 'Morocco',
                            habousId: city['id'],
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualCityInput() {
    final l10n = AppLocalizations.of(context)!;
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'إدخال يدوي',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(hintText: 'المدينة'),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(hintText: 'الدولة'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(prayerNotifierProvider.notifier)
                  .updateLocation(
                    city: cityController.text,
                    country: countryController.text,
                  );
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
  */

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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  String _getSelectedMethodName(int id, bool isArabic) {
    try {
      final method = PrayerMethod.methods.firstWhere((m) => m.id == id);
      return isArabic ? method.nameAr : method.nameEn;
    } catch (_) {
      return isArabic ? 'رابطة العالم الإسلامي' : 'Muslim World League';
    }
  }

  void _showCalculationMethodDialog(
    PrayerState state,
    bool isArabic,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'طريقة الحساب' : 'Calculation Method',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: PrayerMethod.methods.length,
                itemBuilder: (context, index) {
                  final method = PrayerMethod.methods[index];
                  final isSelected = state.calculationMethodId == method.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    title: Text(
                      isArabic ? method.nameAr : method.nameEn,
                      style: GoogleFonts.cairo(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(prayerNotifierProvider.notifier)
                          .updateCalculationMethod(method.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedPrayerName(String key, AppLocalizations l10n) {
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
        return '...';
    }
  }
}
