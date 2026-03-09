import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/services/notification_service.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationDiagnosticsScreen extends StatefulWidget {
  const NotificationDiagnosticsScreen({super.key});

  @override
  State<NotificationDiagnosticsScreen> createState() =>
      _NotificationDiagnosticsScreenState();
}

class _NotificationDiagnosticsScreenState
    extends State<NotificationDiagnosticsScreen>
    with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();

  bool _loading = true;
  bool _notificationsEnabled = false;
  bool _exactAlarmsEnabled = false;
  bool _batteryOptimizationIgnored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatuses();
    }
  }

  Future<void> _refreshStatuses() async {
    setState(() => _loading = true);
    final notifications = await _notificationService
        .holdsNotificationPermission();
    final exactAlarms = await _notificationService.holdsExactAlarmPermission();
    final batteryBypass = await _notificationService
        .isIgnoringBatteryOptimizations();

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = notifications;
      _exactAlarmsEnabled = exactAlarms;
      _batteryOptimizationIgnored = batteryBypass;
      _loading = false;
    });
  }

  Future<void> _fixNotifications() async {
    await _notificationService.ensureNotificationPermission();
    await _refreshStatuses();
  }

  Future<void> _fixExactAlarms() async {
    await _notificationService.requestExactAlarmPermission();
    await _refreshStatuses();
  }

  Future<void> _fixBatteryOptimization() async {
    await _notificationService.requestIgnoreBatteryOptimizations();
    await _refreshStatuses();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allGood =
        _notificationsEnabled &&
        _exactAlarmsEnabled &&
        _batteryOptimizationIgnored;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.notificationDiagnosticsTitle,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : null,
        actions: [
          IconButton(
            onPressed: _loading ? null : _refreshStatuses,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: l10n.refreshStatus,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(
                  isHealthy: allGood,
                  title: allGood
                      ? l10n.notificationDiagnosticsHealthy
                      : l10n.notificationDiagnosticsNeedsFix,
                  subtitle: l10n.notificationDiagnosticsSubtitle,
                ),
                const SizedBox(height: 12),
                _buildStatusCard(
                  context: context,
                  icon: Icons.notifications_active_rounded,
                  title: l10n.notificationPermissionTitle,
                  subtitle: l10n.notificationPermissionSubtitle,
                  isEnabled: _notificationsEnabled,
                  onFix: _notificationsEnabled ? null : _fixNotifications,
                ),
                const SizedBox(height: 10),
                _buildStatusCard(
                  context: context,
                  icon: Icons.alarm_on_rounded,
                  title: l10n.exactAlarmPermissionTitle,
                  subtitle: l10n.exactAlarmPermissionSubtitle,
                  isEnabled: _exactAlarmsEnabled,
                  onFix: _exactAlarmsEnabled ? null : _fixExactAlarms,
                ),
                const SizedBox(height: 10),
                _buildStatusCard(
                  context: context,
                  icon: Icons.battery_charging_full_rounded,
                  title: l10n.batteryOptimizationTitle,
                  subtitle: Platform.isAndroid
                      ? l10n.batteryOptimizationSubtitle
                      : l10n.notRequiredOnThisDevice,
                  isEnabled: Platform.isAndroid
                      ? _batteryOptimizationIgnored
                      : true,
                  onFix: Platform.isAndroid && !_batteryOptimizationIgnored
                      ? _fixBatteryOptimization
                      : null,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: openAppSettings,
                  icon: const Icon(Icons.settings_rounded),
                  label: Text(l10n.openSystemSettings),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard({
    required bool isHealthy,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHealthy
              ? Colors.greenAccent.withValues(alpha: 0.45)
              : Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: isHealthy ? Colors.greenAccent : Colors.amber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required Future<void> Function()? onFix,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isEnabled ? Colors.green : Colors.orange).withValues(
                    alpha: 0.16,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEnabled ? l10n.enabled : l10n.requiresFix,
                  style: GoogleFonts.cairo(
                    color: isEnabled ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
          ),
          if (onFix != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onFix,
                icon: const Icon(Icons.build_circle_outlined),
                label: Text(l10n.fixNow),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
