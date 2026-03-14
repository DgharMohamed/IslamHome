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
import 'package:islam_home/presentation/providers/khatma_listening_sync_provider.dart';
import 'package:islam_home/core/utils/responsive_utils.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';

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
    final location = GoRouterState.of(context).uri.toString();
    final l10n = AppLocalizations.of(context)!;
    final isHandledInternally = ref.watch(backButtonInterceptorProvider);
    ref.watch(khatmaListeningSyncProvider);

    final isWide = ResponsiveUtils.isWide(context);
    final selectedIndex = _getSelectedIndex(location);
    final playingAyah = ref.watch(playingAyahProvider).value;
    final showMiniPlayer =
        !location.contains('/quran-text') &&
        !location.contains('/quran') &&
        playingAyah == null;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final mobileBottomOverlayHeight = kBottomNavigationBarHeight + bottomInset;

    Widget scaffoldContent = Column(
      children: [
        const ConnectivityBanner(),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getPreferredContentWidth(context),
              ),
              child: widget.child,
            ),
          ),
        ),
      ],
    );

    if (isWide) {
      return Scaffold(
        key: GlobalScaffoldService.scaffoldKey,
        drawer: const DrawerWidget(),
        backgroundColor: const Color(0xFF0F172A), // Match theme for desktop
        body: Column(
          children: [
            if (showMiniPlayer) const MiniPlayerWidget(),
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    extended: ResponsiveUtils.isDesktop(context),
                    backgroundColor: const Color(0xFF0F172A),
                    unselectedIconTheme: const IconThemeData(
                      color: Color(0xFF64748B),
                    ),
                    selectedIconTheme: const IconThemeData(
                      color: AppTheme.primaryColor,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: Color(0xFF64748B),
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.home_filled),
                        label: Text(l10n.home),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.import_contacts_outlined),
                        selectedIcon: const Icon(Icons.import_contacts_rounded),
                        label: Text(l10n.quranMushaf),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.people_outline_rounded),
                        selectedIcon: const Icon(Icons.people_rounded),
                        label: Text(l10n.reciters),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.menu_book_outlined),
                        selectedIcon: const Icon(Icons.menu_book_rounded),
                        label: Text(l10n.hadith),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.account_circle_outlined),
                        selectedIcon: const Icon(Icons.account_circle),
                        label: Text(l10n.myAccount),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) =>
                        _onItemTapped(index, context),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: Colors.white12,
                  ),
                  Expanded(child: scaffoldContent),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A), // Slate 900
            const Color(0xFF1E293B), // Slate 800
            AppTheme.primaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: PopScope(
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
          backgroundColor: Colors.transparent, // Show the gradient container
          // Use Stack to allow content to flow behind floating bars
          body: Stack(
            children: [
              // 1. Main Page Content – fills full screen space
              Padding(
                padding: EdgeInsets.only(bottom: mobileBottomOverlayHeight),
                child: scaffoldContent,
              ),
              // 2. Floating Bottom UI (MiniPlayer + Nav Bar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showMiniPlayer) const MiniPlayerWidget(),
                    // The bottom bar below
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.88),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: BottomNavigationBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              type: BottomNavigationBarType.fixed,
                              selectedItemColor: AppTheme.primaryColor,
                              unselectedItemColor: const Color(0xFF94A3B8),
                              selectedLabelStyle: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: GoogleFonts.cairo(
                                fontSize: 11,
                              ),
                              currentIndex: selectedIndex,
                              onTap: (index) => _onItemTapped(index, context),
                              items: [
                                BottomNavigationBarItem(
                                  icon: const Icon(Icons.home_filled),
                                  activeIcon: const Icon(Icons.home_filled),
                                  label: l10n.home,
                                ),
                                BottomNavigationBarItem(
                                  icon: const Icon(
                                    Icons.import_contacts_outlined,
                                  ),
                                  activeIcon: const Icon(
                                    Icons.import_contacts_rounded,
                                  ),
                                  label: l10n.quranMushaf,
                                ),
                                BottomNavigationBarItem(
                                  icon: const Icon(
                                    Icons.people_outline_rounded,
                                  ),
                                  activeIcon: const Icon(Icons.people_rounded),
                                  label: l10n.reciters,
                                ),
                                BottomNavigationBarItem(
                                  icon: const Icon(Icons.menu_book_outlined),
                                  activeIcon: const Icon(
                                    Icons.menu_book_rounded,
                                  ),
                                  label: l10n.hadith,
                                ),
                                BottomNavigationBarItem(
                                  icon: const Icon(
                                    Icons.account_circle_outlined,
                                  ),
                                  activeIcon: const Icon(Icons.account_circle),
                                  label: l10n.myAccount,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/quran')) return 1;
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
        if (!currentLocation.startsWith('/quran')) {
          context.go('/quran');
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
