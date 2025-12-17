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

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
    routes: [
      // Onboarding route (outside shell)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Paywall route (outside shell)
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),

      // History route (outside shell)
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),

      // Inquiry player route (outside shell - full screen experience)
      GoRoute(
        path: '/inquiry/:id',
        builder: (context, state) {
          final inquiryId = state.pathParameters['id'] ?? 'random';
          return InquiryPlayerScreen(inquiryId: inquiryId);
        },
      ),

      // Lineages route (outside shell - preferences screen)
      GoRoute(
        path: '/lineages',
        builder: (context, state) => const LineagesScreen(),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Inquiry tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inquiry',
                builder: (context, state) => const InquiryScreen(),
              ),
            ],
          ),

          // Library tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          // Settings tab
          StatefulShellBranch(
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
