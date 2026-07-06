import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/adhkar_settings_provider.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class AdhkarSettingsScreen extends ConsumerWidget {
  const AdhkarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(adhkarSettingsProvider);
    final notifier = ref.read(adhkarSettingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.adhkarTasbeehSettingsTitle,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(l10n.morningAdhkar),
          _buildSwitchTile(
            title: l10n.morningAdhkarEnable,
            value: settings.morningEnabled,
            onChanged: (val) {
              notifier.updateSettings(morningEnabled: val);
              ref.read(prayerNotifierProvider.notifier).refresh();
            },
          ),
          if (settings.morningEnabled)
            _buildSliderTile(
              title: l10n.morningAdhkarOffset,
              value: settings.morningMinutesAfterFajr.toDouble(),
              min: 0,
              max: 120,
              label: l10n.minutes(settings.morningMinutesAfterFajr),
              onChanged: (val) {
                notifier.updateSettings(morningMinutesAfterFajr: val.toInt());
                ref.read(prayerNotifierProvider.notifier).refresh();
              },
            ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.eveningAdhkar),
          _buildSwitchTile(
            title: l10n.eveningAdhkarEnable,
            value: settings.eveningEnabled,
            onChanged: (val) {
              notifier.updateSettings(eveningEnabled: val);
              ref.read(prayerNotifierProvider.notifier).refresh();
            },
          ),
          if (settings.eveningEnabled)
            _buildSliderTile(
              title: l10n.eveningAdhkarOffset,
              value: settings.eveningMinutesAfterAsr.toDouble(),
              min: 0,
              max: 120,
              label: l10n.minutes(settings.eveningMinutesAfterAsr),
              onChanged: (val) {
                notifier.updateSettings(eveningMinutesAfterAsr: val.toInt());
                ref.read(prayerNotifierProvider.notifier).refresh();
              },
            ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.sleepAdhkar),
          _buildSwitchTile(
            title: l10n.sleepAdhkarEnable,
            value: settings.sleepEnabled,
            onChanged: (val) {
              notifier.updateSettings(sleepEnabled: val);
              ref.read(prayerNotifierProvider.notifier).refresh();
            },
          ),
          if (settings.sleepEnabled)
            _buildSliderTile(
              title: l10n.sleepAdhkarOffset,
              value: settings.sleepMinutesAfterIsha.toDouble(),
              min: 0,
              max: 240, // Up to 4 hours after Isha
              label: l10n.minutes(settings.sleepMinutesAfterIsha),
              onChanged: (val) {
                notifier.updateSettings(sleepMinutesAfterIsha: val.toInt());
                ref.read(prayerNotifierProvider.notifier).refresh();
              },
            ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.dailyTasbeeh),
          _buildSwitchTile(
            title: l10n.dailyTasbeehEnable,
            subtitle: l10n.dailyTasbeehEnableSubtitle,
            value: settings.tasbeehReminderEnabled,
            onChanged: (val) {
              notifier.updateSettings(tasbeehReminderEnabled: val);
              ref.read(prayerNotifierProvider.notifier).refresh();
            },
          ),
          if (settings.tasbeehReminderEnabled)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                l10n.reminderTime,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
              ),
              trailing: Text(
                '${settings.tasbeehReminderHour.toString().padLeft(2, '0')}:${settings.tasbeehReminderMinute.toString().padLeft(2, '0')}',
                style: GoogleFonts.montserrat(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.tasbeehReminderHour,
                    minute: settings.tasbeehReminderMinute,
                  ),
                );
                if (time != null) {
                  notifier.updateSettings(
                    tasbeehReminderHour: time.hour,
                    tasbeehReminderMinute: time.minute,
                  );
                  ref.read(prayerNotifierProvider.notifier).refresh();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: AppTheme.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.cairo(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              )
            : null,
        value: value,
        activeThumbColor: AppTheme.primaryColor,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min) ~/ 5, // 5 min increments
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.white24,
            label: label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
