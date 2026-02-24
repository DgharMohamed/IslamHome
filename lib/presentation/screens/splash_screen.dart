import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔔 SplashScreen: initState');
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Minimal delay to ensure routing context is ready
    if (!mounted) return;

    // Check onboarding status
    final box = await Hive.openBox('settings');
    final String? language = box.get('language');
    final bool onboardingCompleted = box.get(
      'onboarding_completed',
      defaultValue: false,
    );

    if (!mounted) return;

    if (language == null) {
      // Step 1: Language Selection
      context.go('/language-selection');
    } else if (!onboardingCompleted) {
      // Step 2: Permissions Onboarding
      context.go('/onboarding-permissions');
    } else {
      // Already completed: Go Home
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    if (mounted) {
      debugPrint('🚀 SplashScreen: Attempting context.go("/")');
      try {
        context.go('/');
      } catch (e, stack) {
        debugPrint('❌ SplashScreen: Navigation error: $e');
        debugPrint(stack.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SizedBox.shrink(),
    );
  }
}
