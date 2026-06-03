import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/widgets/daily_inspiration_widget.dart';
import 'package:islam_home/presentation/widgets/spiritual_moods_widget.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/presentation/providers/prayer_notifier.dart';
import 'package:islam_home/presentation/widgets/home_header_widget.dart';
import 'package:islam_home/presentation/widgets/feature_grid_widget.dart';
import 'package:islam_home/presentation/widgets/khatma_dashboard_card.dart';
import 'package:islam_home/presentation/providers/daily_content_rotation_provider.dart';
import 'package:islam_home/core/services/home_widget_sync_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(dailyContentRotationProvider.notifier).rotateOnHomeEnter();
      await syncDailyContentHomeWidget(ref);
      _checkAdhanOnboarding();
    });
  }

  Future<void> _checkAdhanOnboarding() async {
    if (!Hive.isBoxOpen('settings')) {
      debugPrint('⚠️ HomeScreen: settings box not open yet');
      return;
    }
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
          l10n.athanOnboardingPrompt,
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
    if (!Hive.isBoxOpen('settings')) return;
    final box = Hive.box('settings');
    await box.put('athan_onboarding_shown', true);
    await ref.read(prayerNotifierProvider.notifier).toggleAthan(enabled);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 HomeScreen: build started');
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 900;
        if (isWideLayout) {
          return Scaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const HomeHeaderWidget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Area: Feature Grid
                    const Expanded(
                      flex: 3,
                      child: FeatureGridWidget(),
                    ),
                    const SizedBox(width: 32),
                    // Sidebar Area: Daily Tools
                    Expanded(
                      flex: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
                        child: const Column(
                          children: [
                            KhatmaDashboardCard(),
                            SizedBox(height: 24),
                            DailyInspirationWidget(),
                            SizedBox(height: 24),
                            SpiritualMoodsWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
        }
        
        // Mobile/Tablet layout
        return const Scaffold(
          extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            child: Column(
              children: [
                HomeHeaderWidget(),
                Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: KhatmaDashboardCard(),
                      ),
                      SizedBox(height: 32),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: DailyInspirationWidget(),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SpiritualMoodsWidget(),
                      ),
                      SizedBox(height: 32),
                      FeatureGridWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
