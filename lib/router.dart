import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/providers.dart';
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

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
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
      GoRoute(
        path: '/paywall',
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
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';

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
  );
});
