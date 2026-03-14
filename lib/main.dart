import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:islam_home/presentation/screens/splash_screen.dart';
import 'package:islam_home/presentation/screens/language_selection_screen.dart';
import 'package:islam_home/presentation/screens/permissions_onboarding_screen.dart';
import 'package:islam_home/presentation/screens/home_screen.dart';
import 'package:islam_home/presentation/screens/all_reciters_screen.dart';
import 'package:islam_home/presentation/screens/reciter_screen.dart';
import 'package:islam_home/presentation/screens/hadith_screen.dart';
import 'package:islam_home/presentation/screens/azkar_screen.dart';
import 'package:islam_home/presentation/screens/tasbeeh_screen.dart';
import 'package:islam_home/presentation/screens/tasbeeh_history_screen.dart';
import 'package:islam_home/presentation/screens/radio_screen.dart';
import 'package:islam_home/presentation/screens/live_tv_screen.dart';
import 'package:islam_home/presentation/screens/video_screen.dart';
import 'package:islam_home/presentation/screens/search_screen.dart';
import 'package:islam_home/presentation/screens/prayer_times_screen.dart';
import 'package:islam_home/presentation/screens/qibla_screen.dart';
import 'package:islam_home/presentation/screens/downloads_screen.dart';
import 'package:islam_home/presentation/screens/favorites_screen.dart';
import 'package:islam_home/presentation/screens/player_screen.dart';
import 'package:islam_home/presentation/screens/settings_screen.dart';
import 'package:islam_home/presentation/screens/notification_diagnostics_screen.dart';
import 'package:islam_home/presentation/screens/sira_screen.dart';
import 'package:islam_home/presentation/screens/sira_detail_screen.dart';
import 'package:islam_home/data/models/sira_model.dart';
import 'package:islam_home/presentation/screens/profile_screen.dart';
import 'package:islam_home/presentation/screens/all_sections_screen.dart';
import 'package:islam_home/presentation/screens/quran_mushaf_screen.dart';
import 'package:islam_home/presentation/screens/tafsir_screen.dart';
import 'package:islam_home/presentation/widgets/main_scaffold.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart' as quran;
import 'package:islam_home/core/services/connectivity_service.dart';
import 'package:islam_home/data/services/offline_cache_service.dart';
import 'package:islam_home/presentation/screens/prayer_method_selection_screen.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/data/models/tasbeeh_log.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/data/models/quran_page_model.dart';
import 'package:islam_home/data/database/adhkar_database.dart';
import 'package:islam_home/data/services/notification_service.dart';
import 'package:islam_home/data/services/background_worker.dart';
import 'package:workmanager/workmanager.dart';
import 'package:islam_home/data/services/adhkar_import_service.dart';
import 'package:islam_home/presentation/screens/adhkar_list_screen.dart';
import 'package:islam_home/presentation/screens/adhkar_details_screen.dart';
import 'package:islam_home/presentation/screens/adhkar_favorite_screen.dart';
import 'package:islam_home/presentation/screens/adhkar_search_screen.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(450, 850),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Islam Home',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Disable runtime fetching for Google Fonts to prevent offline crashes
  GoogleFonts.config.allowRuntimeFetching = false;

  // 1. Core initialization - keep as minimal as possible
  try {
    await Hive.initFlutter();

    // Await ONLY the absolutely essential services needed for the app to function
    // We do them in parallel for speed.
    debugPrint('🎵 Main: Starting essential initialization...');

    // Register adapters before opening boxes
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(TasbeehModelAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(TasbeehLogAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(KhatmaTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(SchedulingModeAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(RemediationStrategyAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(KhatmaTrackAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(KhatmaUnitAdapter());
    }
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(QuranWordAdapter());
    }
    if (!Hive.isAdapterRegistered(31)) {
      Hive.registerAdapter(QuranLineAdapter());
    }
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(QuranPageAdapter());
    }

    await Future.wait([
      Hive.openBox('settings'),
      Hive.openBox('favorites'),
      Hive.openBox('prayer_times_cache'),
      Hive.openBox<TasbeehModel>('tasbeeh_box'),
      Hive.openBox<TasbeehLog>('tasbeeh_history_box'),
      Hive.openBox('settings_box'),
      Hive.openBox<KhatmaTrack>('khatma_tracks_box'),
      Hive.openBox<QuranPage>('quran_pages_v5'),
      AdhkarDatabase.init(),
      OfflineCacheService().init(),
      ConnectivityService().init(),
    ]).timeout(const Duration(seconds: 15));

    await AdhkarImportService().importIfNeeded();

    debugPrint('🎵 Main: Essential services initialized');

    runApp(const ProviderScope(child: IslamicLibraryApp()));

    // Initialize notifications and then register the background Adhan job
    NotificationService().init().then((_) {
      debugPrint('🔔 Main: Notifications ready');
      // workmanager is Android-only — skip on desktop/web/iOS
      if (!kIsWeb && Platform.isAndroid) {
        Workmanager().initialize(callbackDispatcher)
            .then((_) => registerAdhanBackgroundTask());
      }
    });
    // PlaybackSessionService.initialize().catchError(
    //   (e) => debugPrint('📦 PlaybackSession error: $e'),
    // );

    // 3. Debug: Check for Hadith assets (non-blocking)
    if (kDebugMode) {
      _debugCheckAssets();
    }
  } catch (e, stackTrace) {
    debugPrint('🔴 Main: Fatal initialization crash: $e');
    debugPrint('$stackTrace');

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper for non-blocking asset check in debug mode
void _debugCheckAssets() {
  AssetManifest.loadFromAssetBundle(rootBundle)
      .then((manifest) {
        final hadithAssets = manifest.listAssets().where(
          (key) => key.contains('assets/data/hadith/'),
        );
        debugPrint('🎵 Main: Found ${hadithAssets.length} hadith assets');
      })
      .catchError((e) {
        debugPrint('🎵 Main: Failed to load AssetManifest: $e');
      });
}

class DebugNavObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      '🚀 NAV: Pushed ${route.settings.name} (${route.settings.arguments})',
    );
  }
}

final _router = GoRouter(
  observers: [DebugNavObserver()],
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding-permissions',
      builder: (context, state) => const PermissionsOnboardingScreen(),
    ),
    GoRoute(
      path: '/prayer-method-selection',
      builder: (context, state) => const PrayerMethodSelectionScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/all-sections',
          builder: (context, state) => const AllSectionsScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/all-reciters',
          builder: (context, state) => const AllRecitersScreen(),
        ),
        GoRoute(
          path: '/reciter',
          builder: (context, state) {
            try {
              final reciter = state.extra as Reciter;
              return ReciterScreen(reciter: reciter);
            } catch (e) {
              debugPrint('Error casting reciter: $e');
              return const HomeScreen();
            }
          },
        ),
        GoRoute(
          path: '/quran',
          builder: (context, state) {
            final pageParam = int.tryParse(
              state.uri.queryParameters['page'] ?? '',
            );
            final surahParam = int.tryParse(
              state.uri.queryParameters['surah'] ?? '',
            );
            final ayahParam = int.tryParse(
              state.uri.queryParameters['ayah'] ?? '',
            );
            final trackId = state.uri.queryParameters['trackId'];
            final hasExplicitPosition =
                pageParam != null || surahParam != null || ayahParam != null;

            int initialPage = 1;
            if (pageParam != null) {
              initialPage = pageParam.clamp(1, quran.totalPagesCount);
            } else if (surahParam != null) {
              final safeSurah = surahParam.clamp(1, quran.totalSurahCount);
              final safeAyah = (ayahParam ?? 1).clamp(
                1,
                quran.getVerseCount(safeSurah),
              );
              initialPage = quran.getPageNumber(safeSurah, safeAyah);
            }

            return QuranMushafScreen(
              initialPage: initialPage,
              trackId: trackId,
              restoreSavedPosition: !hasExplicitPosition,
            );
          },
        ),
        GoRoute(
          path: '/tafsir',
          builder: (context, state) => const TafsirScreen(),
        ),
        GoRoute(
          path: '/hadith',
          builder: (context, state) => const HadithScreen(),
        ),
        GoRoute(
          path: '/azkar',
          builder: (context, state) => const AzkarScreen(),
        ),
        GoRoute(
          path: '/azkar/list/:category',
          builder: (context, state) {
            final category = Uri.decodeComponent(
              state.pathParameters['category'] ?? 'General',
            );
            return AdhkarListScreen(category: category);
          },
        ),
        GoRoute(
          path: '/azkar/details/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final category = state.uri.queryParameters['category'];
            return AdhkarDetailsScreen(
              id: id,
              category: category == null ? null : Uri.decodeComponent(category),
            );
          },
        ),
        GoRoute(
          path: '/azkar/favorites',
          builder: (context, state) => const AdhkarFavoriteScreen(),
        ),
        GoRoute(
          path: '/azkar/search',
          builder: (context, state) => const AdhkarSearchScreen(),
        ),
        GoRoute(
          path: '/sira',
          builder: (context, state) => const SiraScreen(),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) {
                final stage = state.extra as SiraStage;
                return SiraDetailScreen(stage: stage);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/tasbeeh',
          builder: (context, state) => const TasbeehScreen(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (context, state) => const TasbeehHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/radio',
          builder: (context, state) => const RadioScreen(),
        ),
        GoRoute(
          path: '/live-tv',
          builder: (context, state) => const LiveTVScreen(),
        ),
        GoRoute(
          path: '/video',
          builder: (context, state) => const VideoScreen(),
        ),
        GoRoute(
          path: '/prayer-times',
          builder: (context, state) => const PrayerTimesScreen(),
        ),
        GoRoute(
          path: '/qibla',
          builder: (context, state) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/downloads',
          builder: (context, state) => const DownloadsScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/playlist/import',
          builder: (context, state) {
            final data = state.uri.queryParameters['data'];
            return FavoritesScreen(importData: data);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/notification-diagnostics',
          builder: (context, state) => const NotificationDiagnosticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
        );
      },
    ),
  ],
);

class IslamicLibraryApp extends ConsumerWidget {
  const IslamicLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Islam Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
    );
  }
}
