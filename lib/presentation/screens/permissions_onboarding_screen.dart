import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';

class PermissionsOnboardingScreen extends StatefulWidget {
  const PermissionsOnboardingScreen({super.key});

  @override
  State<PermissionsOnboardingScreen> createState() =>
      _PermissionsOnboardingScreenState();
}

class _PermissionsOnboardingScreenState
    extends State<PermissionsOnboardingScreen>
    with WidgetsBindingObserver {
  bool _notificationsGranted = false;
  bool _locationGranted = false;
  bool _installGranted = false;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;
    final installStatus = await Permission.requestInstallPackages.status;

    if (mounted) {
      setState(() {
        _notificationsGranted = notificationStatus.isGranted;
        _locationGranted = locationStatus.isGranted;
        _installGranted = installStatus.isGranted;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (mounted) {
      context.go('/prayer-method-selection');
    }
  }

  Future<void> _handlePermissionChange(
    Permission permission,
    bool isGranted,
    Function(bool) updateState,
  ) async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      if (isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن إلغاء الصلاحيات من داخل التطبيق. يرجى تعديلها من إعدادات الجهاز.',
              style: GoogleFonts.cairo(),
            ),
            action: SnackBarAction(
              label: 'الإعدادات',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      } else {
        final status = await permission.request();
        if (mounted) {
          updateState(status.isGranted);
        }
        if (status.isPermanentlyDenied && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم رفض الصلاحية. يرجى تفعيلها من الإعدادات.',
                style: GoogleFonts.cairo(),
              ),
              action: SnackBarAction(
                label: 'الإعدادات',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final locale = ref.watch(localeProvider);
        final isArabic = locale.languageCode == 'ar';

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'أهلاً بك' : 'Welcome',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'لنقم بإعداد تجربتك'
                          : 'Let\'s set up your experience',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Expanded(
                      child: ListView(
                        children: [
                          _buildPermissionTile(
                            icon: Icons.notifications_active_rounded,
                            title: isArabic
                                ? 'التنبيهات والتشغيل في الخلفية'
                                : 'Notifications & Background Play',
                            subtitle: isArabic
                                ? 'ابق على اطلاع وواصل تشغيل الصوت'
                                : 'Stay notified and keep audio playing',
                            status: _notificationsGranted,
                            isArabic: isArabic,
                            onTap: () => _handlePermissionChange(
                              Permission.notification,
                              _notificationsGranted,
                              (status) => setState(
                                () => _notificationsGranted = status,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPermissionTile(
                            icon: Icons.location_on_rounded,
                            title: isArabic
                                ? 'مواقيت الصلاة و القبلة'
                                : 'Prayer Times & Qibla',
                            subtitle: isArabic
                                ? 'مواقيت صلاة دقيقة بناءً على الموقع'
                                : 'Accurate prayer times based on GPS',
                            status: _locationGranted,
                            isArabic: isArabic,
                            onTap: () => _handlePermissionChange(
                              Permission.location,
                              _locationGranted,
                              (status) =>
                                  setState(() => _locationGranted = status),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPermissionTile(
                            icon: Icons.system_update_rounded,
                            title: isArabic
                                ? 'التحديثات التلقائية'
                                : 'Automatic Updates',
                            subtitle: isArabic
                                ? 'السماح للتطبيق بالتحديث من الداخل'
                                : 'Allow app to update from within',
                            status: _installGranted,
                            isArabic: isArabic,
                            onTap: () => _handlePermissionChange(
                              Permission.requestInstallPackages,
                              _installGranted,
                              (status) =>
                                  setState(() => _installGranted = status),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isArabic ? 'ابدأ الآن' : 'Start Now',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool status,
    required bool isArabic,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 20,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (status ? Colors.green : AppTheme.primaryColor).withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: status ? Colors.green : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
        ),
        trailing: Switch(
          value: status,
          onChanged: (_) => onTap(),
          activeThumbColor: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
