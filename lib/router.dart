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

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/inquiry_screen.dart';
import 'screens/inquiry_player_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/history_screen.dart';
import 'screens/main_shell.dart';
import 'screens/lineages_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/animated_transitions.dart';

/// Navigator key for the root [GoRouter] navigator (routes outside the shell).
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navigator key for the Home tab branch inside [StatefulShellRoute].
final _homeNavigatorKey = GlobalKey<NavigatorState>();

/// Navigator key for the Inquiry tab branch inside [StatefulShellRoute].
final _inquiryNavigatorKey = GlobalKey<NavigatorState>();

/// Navigator key for the Library tab branch inside [StatefulShellRoute].
final _libraryNavigatorKey = GlobalKey<NavigatorState>();

/// Navigator key for the Settings tab branch inside [StatefulShellRoute].
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

/// In-memory flag ensuring the [SplashScreen] is shown only once per cold start.
///
/// Resets naturally when the OS kills the process.
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

/// Returns the singleton [GoRouter], creating it on first access via [_createRouter].
GoRouter _getOrCreateRouter() {
  return _appRouter ??= _createRouter();
}

/// Checks onboarding completion status directly from [SharedPreferences].
///
/// Returns `false` if [_sharedPrefs] has not been set or the key is absent.
bool _isOnboardingCompleted() {
  return _sharedPrefs?.getBool('pointer_onboarding_completed') ?? false;
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
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';
      final onboardingCompleted = _isOnboardingCompleted();

      // Splash: show once per cold start (always, regardless of animation settings)
      if (!_hasShownSplash && !isSplash && !isOnboarding) {
        _hasShownSplash = true;
        final dest = onboardingCompleted ? '/' : '/onboarding';
        return '/splash?dest=${Uri.encodeComponent(dest)}';
      }

      // Don't redirect away from splash (it self-navigates)
      if (isSplash) return null;

      // If onboarding not completed and not on onboarding page, redirect
      if (!onboardingCompleted && !isOnboarding) {
        return '/onboarding';
      }

      // If onboarding completed and on onboarding page, redirect to home
      if (onboardingCompleted && isOnboarding) {
        return '/';
      }

      return null;
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

      // History route (outside shell) - horizontal for related content
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) =>
            SharedAxisPage(key: state.pageKey, transitionType: SharedAxisTransitionType.horizontal, child: const HistoryScreen()),
      ),

      // Inquiry player route (outside shell - full screen experience)
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

      // Lineages route (outside shell - preferences screen)
      GoRoute(
        path: '/lineages',
        pageBuilder: (context, state) =>
            SharedAxisPage(key: state.pageKey, transitionType: SharedAxisTransitionType.horizontal, child: const LineagesScreen()),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
          ),

          // Inquiry tab
          StatefulShellBranch(
            navigatorKey: _inquiryNavigatorKey,
            routes: [GoRoute(path: '/inquiry', builder: (context, state) => const InquiryScreen())],
          ),

          // Library tab
          StatefulShellBranch(
            navigatorKey: _libraryNavigatorKey,
            routes: [GoRoute(path: '/library', builder: (context, state) => const LibraryScreen())],
          ),

          // Settings tab
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())],
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
