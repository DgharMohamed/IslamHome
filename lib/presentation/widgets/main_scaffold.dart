import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/widgets/drawer_widget.dart';
import 'package:islam_home/presentation/widgets/mini_player_widget.dart';
import 'package:islam_home/presentation/widgets/connectivity_banner.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/core/services/update_manager.dart';
import 'package:islam_home/presentation/providers/navigation_provider.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔔 MainScaffold: initState');

    // Check for updates on app startup
    Future.microtask(() {
      if (mounted) {
        UpdateManager.check(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔔 MainScaffold: build');
    final location = GoRouterState.of(context).uri.toString();
    final l10n = AppLocalizations.of(context)!;

    final isHandledInternally = ref.watch(backButtonInterceptorProvider);

    return PopScope(
      canPop: location == '/' && !isHandledInternally,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If a sub-screen handled it, we just reset the flag
        if (isHandledInternally) {
          ref.read(backButtonInterceptorProvider.notifier).set(false);
          return;
        }

        // If not on home screen, redirect to home instead of popping (exiting)
        if (location != '/') {
          context.go('/');
        }
      },
      child: Scaffold(
        key: GlobalScaffoldService.scaffoldKey,
        drawer: const DrawerWidget(),
        body: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!location.contains('/quran-text')) const MiniPlayerWidget(),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Matching AppTheme dark navy
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    elevation: 0,
                    currentIndex: _getSelectedIndex(location),
                    onTap: (index) => _onItemTapped(index, context),
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.home_filled),
                        activeIcon: const Icon(
                          Icons.home_filled,
                          color: AppTheme.primaryColor,
                        ),
                        label: l10n.home,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.import_contacts_outlined),
                        activeIcon: const Icon(
                          Icons.import_contacts_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        label: l10n.quranMushaf,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.people_outline_rounded),
                        activeIcon: const Icon(
                          Icons.people_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        label: l10n.reciters,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.menu_book_outlined),
                        activeIcon: const Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        label: l10n.hadith,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.account_circle_outlined),
                        activeIcon: const Icon(
                          Icons.account_circle,
                          color: AppTheme.primaryColor,
                        ),
                        label: l10n.myAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/quran-text')) return 1;
    if (location.startsWith('/all-reciters')) return 2;
    if (location.startsWith('/hadith')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    switch (index) {
      case 0:
        if (currentLocation != '/') {
          context.go('/');
        }
        break;
      case 1:
        if (!currentLocation.startsWith('/quran-text')) {
          context.go('/quran-text');
        }
        break;
      case 2:
        if (!currentLocation.startsWith('/all-reciters')) {
          context.go('/all-reciters');
        }
        break;
      case 3:
        if (!currentLocation.startsWith('/hadith')) {
          context.go('/hadith');
        }
        break;
      case 4:
        if (!currentLocation.startsWith('/profile')) {
          context.go('/profile');
        }
        break;
    }
  }
}
