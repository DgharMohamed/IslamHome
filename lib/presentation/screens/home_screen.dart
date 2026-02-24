import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/presentation/widgets/daily_inspiration_widget.dart';
import 'package:islam_home/presentation/widgets/spiritual_moods_widget.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';

import 'package:islam_home/presentation/widgets/home_header_widget.dart';
import 'package:islam_home/presentation/widgets/feature_grid_widget.dart';
import 'package:islam_home/presentation/widgets/smart_khatma_widget.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdhanOnboarding();
    });
  }

  Future<void> _checkAdhanOnboarding() async {
    final box = Hive.box('settings');
    final shown =
        box.get('athan_onboarding_shown', defaultValue: false) as bool;

    if (!shown) {
      if (!mounted) return;
      _showAdhanOnboardingDialog();
    }
  }

  void _showAdhanOnboardingDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.athanNotifications,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل ترغب في تفعيل تنبيهات الآذان لكل صلاة؟ يمكنك دائماً تغيير هذا من إعدادات مواقيت الصلاة.'
              : 'Would you like to enable Adhan notifications for prayer times? You can always change this in Prayer Times settings.',
          style: GoogleFonts.cairo(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    await _finishOnboarding(false);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    l10n.later,
                    style: GoogleFonts.cairo(color: Colors.white38),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _finishOnboarding(true);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.activateNow,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Future<void> _finishOnboarding(bool enabled) async {
    final box = Hive.box('settings');
    await box.put('athan_onboarding_shown', true);
    await ref.read(prayerNotifierProvider.notifier).toggleAthan(enabled);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 HomeScreen: build started');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow header to go behind status bar
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Premium Header
            const HomeHeaderWidget(),

            // 2. Main Content
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 100), // Spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slim Floating Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () => context.push('/search'),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        borderRadius: 20,
                        opacity: 0.1,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.white54,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.globalSearch,
                              style: GoogleFonts.tajawal(
                                color: Colors.white38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Colors.white38,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Spiritual Moods - MOVED TO TOP
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SpiritualMoodsWidget(),
                  ),

                  const SizedBox(height: 32),

                  // Feature Grid
                  const FeatureGridWidget(),

                  const SizedBox(height: 32),

                  // Reading Progress (Dynamic)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle(
                      context,
                      l10n.khatmaProgress,
                      l10n,
                      onPressed: () {
                        context.push('/khatma');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SmartKhatmaWidget(),
                  ),

                  const SizedBox(height: 32),

                  // Daily Inspiration Carousel
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: DailyInspirationWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    AppLocalizations l10n, {
    VoidCallback? onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (onPressed != null)
          TextButton(
            onPressed: onPressed,
            child: Text(
              l10n.viewAll,
              style: GoogleFonts.cairo(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
