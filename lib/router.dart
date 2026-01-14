import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'providers/subscription_providers.dart' show kFreeAccessEnabled;
import 'screens/home_screen.dart';
import 'screens/inquiry_screen.dart';
import 'screens/inquiry_player_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/history_screen.dart';
import 'screens/main_shell.dart';
import 'screens/lineages_screen.dart';
import 'widgets/animated_transitions.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _inquiryNavigatorKey = GlobalKey<NavigatorState>();
final _libraryNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

/// SharedPreferences reference for redirect checks
/// Set by main.dart before runApp()
SharedPreferences? _sharedPrefs;

/// Set SharedPreferences reference for router redirect checks
void setRouterSharedPreferences(SharedPreferences prefs) {
  _sharedPrefs = prefs;
}

/// Singleton router - created lazily to avoid GlobalKey conflicts
/// The router MUST be a singleton because StatefulShellRoute uses GlobalKeys
/// that cannot be duplicated in the widget tree.
GoRouter? _appRouter;

GoRouter _getOrCreateRouter() {
  return _appRouter ??= _createRouter();
}

/// Check onboarding status directly from SharedPreferences
bool _isOnboardingCompleted() {
  return _sharedPrefs?.getBool('pointer_onboarding_completed') ?? false;
}

GoRouter _createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';
      final onboardingCompleted = _isOnboardingCompleted();

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
      // Onboarding route (outside shell) - fade through for entry
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => FadeThroughPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // Paywall route (outside shell) - vertical axis for modal feel
      // When kFreeAccessEnabled, redirect to home (no IAP available)
      GoRoute(
        path: '/paywall',
        redirect: (context, state) => kFreeAccessEnabled ? '/' : null,
        pageBuilder: (context, state) => SharedAxisPage(
          key: state.pageKey,
          transitionType: SharedAxisTransitionType.vertical,
          child: const PaywallScreen(),
        ),
      ),

      // History route (outside shell) - horizontal for related content
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => SharedAxisPage(
          key: state.pageKey,
          transitionType: SharedAxisTransitionType.horizontal,
          child: const HistoryScreen(),
        ),
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
        pageBuilder: (context, state) => SharedAxisPage(
          key: state.pageKey,
          transitionType: SharedAxisTransitionType.horizontal,
          child: const LineagesScreen(),
        ),
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
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Inquiry tab
          StatefulShellBranch(
            navigatorKey: _inquiryNavigatorKey,
            routes: [
              GoRoute(
                path: '/inquiry',
                builder: (context, state) => const InquiryScreen(),
              ),
            ],
          ),

          // Library tab
          StatefulShellBranch(
            navigatorKey: _libraryNavigatorKey,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          // Settings tab
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Provider that returns the singleton router
/// IMPORTANT: This provider does NOT watch any state to prevent router rebuild
/// The redirect checks SharedPreferences directly (set via setRouterSharedPreferences)
final routerProvider = Provider<GoRouter>((ref) {
  return _getOrCreateRouter();
});
