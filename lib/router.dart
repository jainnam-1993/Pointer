/**
 * Application routing configuration using [GoRouter].
 *
 * Defines all top-level routes and the four-tab [StatefulShellRoute] that drives [MainShell].
 * The router is a **singleton** ([_appRouter]) because [StatefulShellRoute] allocates internal
 * [GlobalKey]s that must not be duplicated in the widget tree.
 *
 * **Redirect logic** (evaluated on every navigation):
 * 1. First cold-start navigation is intercepted to show [SplashScreen] with a `?dest=` param.
 * 2. Users who have not completed onboarding are sent to [OnboardingScreen].
 * 3. Users who revisit `/onboarding` after completion are redirected to `/`.
 *
 * [SharedPreferences] is injected via [setRouterSharedPreferences] **before** the router is
 * created so redirects can check onboarding status synchronously — the router redirect
 * function cannot be async.
 *
 * Route structure:
 * - `/splash` — [SplashScreen] (cold-start video, outside shell)
 * - `/onboarding` — [OnboardingScreen] (outside shell)
 * - `/history` — [HistoryScreen] (outside shell)
 * - `/inquiry/:id` — [InquiryPlayerScreen] (full-screen, outside shell)
 * - `/lineages` — [LineagesScreen] (outside shell)
 * - `/` — [HomeScreen] (tab 0, inside [MainShell])
 * - `/inquiry` — [InquiryScreen] (tab 1)
 * - `/library` — [LibraryScreen] (tab 2)
 * - `/settings` — [SettingsScreen] (tab 3)
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'layout/tab_crossfade.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/ambient.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/inquiry_player_screen.dart';
import 'screens/library_screen.dart';
import 'screens/library/all_inquiries_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/history_screen.dart';
import 'screens/main_shell.dart';
import 'screens/article_reader_screen.dart';
import 'screens/lineages_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/animated_transitions.dart';

/** Navigator key for the root [GoRouter] navigator (routes outside the shell). */
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/** Navigator key for the Home tab branch inside [StatefulShellRoute]. */
final _homeNavigatorKey = GlobalKey<NavigatorState>();

/** Navigator key for the Library tab branch inside [StatefulShellRoute]. */
final _libraryNavigatorKey = GlobalKey<NavigatorState>();

/** Navigator key for the Saved tab branch inside [StatefulShellRoute]. */
final _savedNavigatorKey = GlobalKey<NavigatorState>();

/**
 * In-memory flag ensuring the [SplashScreen] is shown only once per cold start.
 *
 * Resets naturally when the OS kills the process.
 */
bool _hasShownSplash = false;

/**
 * [SharedPreferences] reference used synchronously by the redirect function.
 *
 * Set by [main] via [setRouterSharedPreferences] **before** the router is created,
 * because [GoRouter.redirect] cannot be async.
 */
SharedPreferences? _sharedPrefs;

/**
 * Injects the [SharedPreferences] instance for synchronous redirect checks.
 *
 * Must be called in [main] before [runApp] so that [_isOnboardingCompleted] and
 * the splash-redirect logic have access to persisted state.
 */
void setRouterSharedPreferences(SharedPreferences prefs) {
  _sharedPrefs = prefs;
}

/**
 * Lazily-created singleton [GoRouter] instance.
 *
 * The router **must** be a singleton because [StatefulShellRoute] uses internal [GlobalKey]s
 * that cannot be duplicated. Re-creating the router would cause a [GlobalKey] conflict crash.
 */
GoRouter? _appRouter;

/** Returns the singleton [GoRouter], creating it on first access via [_createRouter]. */
GoRouter _getOrCreateRouter() {
  return _appRouter ??= _createRouter();
}

/**
 * Checks onboarding completion status directly from [SharedPreferences].
 *
 * Returns `false` if [_sharedPrefs] has not been set or the key is absent.
 */
bool _isOnboardingCompleted() {
  return _sharedPrefs?.getBool(StorageKeys.onboardingCompleted) ?? false;
}

/**
 * The router's redirect rules, free of [GoRouterState] so they can be tested.
 *
 * - The splash shows once per cold start, then continues to the location that
 *   was asked for. That is Home on a fresh launch, and the restored tab (for
 *   example `/library`) after Android killed the process in the background.
 * - Until onboarding is done, everything goes to `/onboarding`; after it,
 *   `/onboarding` goes Home.
 */
@visibleForTesting
String? appRedirect({required String matchedLocation, required String location, required bool onboardingCompleted, required bool hasShownSplash}) {
  final isSplash = matchedLocation == '/splash';
  final isOnboarding = matchedLocation == '/onboarding';

  if (!hasShownSplash && !isSplash && !isOnboarding) {
    final dest = onboardingCompleted ? location : '/onboarding';
    return '/splash?dest=${Uri.encodeComponent(dest)}';
  }

  // Splash self-navigates when it finishes.
  if (isSplash) return null;
  if (!onboardingCompleted && !isOnboarding) return '/onboarding';
  if (onboardingCompleted && isOnboarding) return '/';
  return null;
}

/**
 * Constructs the [GoRouter] with all route definitions and redirect logic.
 *
 * See the library-level documentation for the full route structure and redirect rules.
 */
GoRouter _createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    // Pauses the ambient clock while a modal sheet or dialog is open.
    observers: [AmbientRouteObserver()],
    // Restores the open tab and each tab's stack after Android kills the
    // process in the background. A fresh launch has no saved state and starts
    // at initialLocation, so it still opens on Home.
    restorationScopeId: 'router',
    redirect: (context, state) {
      final redirect = appRedirect(
        matchedLocation: state.matchedLocation,
        location: state.uri.toString(),
        onboardingCompleted: _isOnboardingCompleted(),
        hasShownSplash: _hasShownSplash,
      );
      if (redirect != null && redirect.startsWith('/splash')) _hasShownSplash = true;
      return redirect;
    },
    routes: [
      // Splash video route (outside shell) - calm fade for branded entry
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) {
          final dest = state.uri.queryParameters['dest'] ?? '/';
          return CalmPageTransition(
            key: state.pageKey,
            child: SplashScreen(destination: dest),
          );
        },
      ),

      // Onboarding route (outside shell) - fade through for entry
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => FadeThroughPage(key: state.pageKey, child: const OnboardingScreen()),
      ),

      // History route (outside shell) - native page push keeps the iOS edge-swipe back
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const HistoryScreen()),
      ),

      // Inquiry player route (outside shell - full screen experience)
      // The Inquiry tab is gone: its sessions lead Library (P2).
      GoRoute(path: '/inquiry', redirect: (context, state) => '/library?section=inquiry'),

      // Every inquiry, from Library > Guided Inquiry > See all.
      GoRoute(path: '/inquiries', builder: (context, state) => const AllInquiriesScreen()),

      // Settings is a sheet from the gear on Today, over the tabs, with Done.
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, fullscreenDialog: true, child: const SettingsScreen(asSheet: true)),
      ),

      GoRoute(
        path: '/inquiry/:id',
        pageBuilder: (context, state) {
          final inquiryId = state.pathParameters['id'] ?? 'random';
          return CalmPageTransition(
            key: state.pageKey,
            child: InquiryPlayerScreen(inquiryId: inquiryId),
          );
        },
      ),

      // Lineages route (outside shell) - native page push keeps the iOS edge-swipe back
      GoRoute(
        path: '/lineages',
        pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: const LineagesScreen()),
      ),

      // Article reader (outside shell, so the dock hides while reading) - native page push
      GoRoute(
        path: '/article/:id',
        pageBuilder: (context, state) {
          final articleId = state.pathParameters['id']!;
          return MaterialPage<void>(
            key: state.pageKey,
            child: ArticleReaderScreen(articleId: articleId),
          );
        },
      ),

      // Main app with bottom navigation
      // Tabs cross-fade over the one shared ambient background instead of cutting (TabCrossFadeContainer).
      StatefulShellRoute(
        // 'shell' held the old 4-tab index (Home, Inquiry, Library, Settings). A new
        // id drops that index; the restored location picks the tab by path, so
        // /library stays Library and /inquiry or /settings redirect below.
        restorationScopeId: 'shell-3tab',
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) =>
            TabCrossFadeContainer(currentIndex: navigationShell.currentIndex, children: children),
        branches: [
          // Home tab
          StatefulShellBranch(
            observers: [AmbientRouteObserver()],
            navigatorKey: _homeNavigatorKey,
            restorationScopeId: 'home',
            routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
          ),

          // Library tab
          StatefulShellBranch(
            observers: [AmbientRouteObserver()],
            navigatorKey: _libraryNavigatorKey,
            // Built at startup, off screen: the first visit used to build the whole page in the switch frame
            // (Library's first visit: raster p90 17 ms and 36 janky frames on the user Fold, revisits 4 ms and 0).
            preload: true,
            restorationScopeId: 'library',
            routes: [GoRoute(path: '/library', builder: (context, state) => const LibraryScreen())],
          ),

          // Saved tab
          StatefulShellBranch(
            observers: [AmbientRouteObserver()],
            navigatorKey: _savedNavigatorKey,
            // Built at startup, off screen: the first visit used to build the whole page in the switch frame
            // (Library's first visit: raster p90 17 ms and 36 janky frames on the user Fold, revisits 4 ms and 0).
            preload: true,
            restorationScopeId: 'saved',
            routes: [GoRoute(path: '/saved', builder: (context, state) => const SavedScreen())],
          ),
        ],
      ),
    ],
  );
}

/**
 * Riverpod provider exposing the singleton [GoRouter] instance.
 *
 * **Critical**: This provider intentionally does **not** watch any reactive state.
 * Using `ref.watch` would cause [MaterialApp.router] to rebuild whenever watched
 * providers change, which triggers [GlobalKey] conflicts inside [StatefulShellRoute].
 * Consumers should always access this via `ref.read(routerProvider)`.
 *
 * Redirect logic reads [SharedPreferences] directly (set via [setRouterSharedPreferences])
 * rather than through a provider, keeping the router completely static after creation.
 */
final routerProvider = Provider<GoRouter>((ref) {
  return _getOrCreateRouter();
});
