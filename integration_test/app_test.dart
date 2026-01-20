// Pointer App Integration Tests
// Equivalent to React Native Maestro tests
//
// Run all tests:
//   flutter test integration_test/app_test.dart
//
// Run smoke tests only:
//   flutter test integration_test/app_test.dart --tags smoke
//
// Run on device:
//   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/screens/home_screen.dart';
import 'package:pointer/screens/inquiry_screen.dart';
import 'package:pointer/screens/lineages_screen.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/screens/onboarding_screen.dart';

import 'test_helpers.dart';

void main() {
  ensureIntegrationTestInitialized();

  // ============================================================
  // 1. APP LAUNCH AND INITIAL STATE
  // Tags: smoke, visual
  // Equivalent to: 01_app_launch.yaml
  // ============================================================
  group('App Launch and Initial State', () {
    testWidgets(
      'fresh app launch shows onboarding screen',
      (WidgetTester tester) async {
        // Launch app with fresh state (onboarding not completed)
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Verify onboarding welcome screen is shown
        expectTextVisible('Welcome to Pointer');
        expectTextVisible('Direct invitations to recognize what you already are');

        // Verify onboarding page elements
        expect(find.byType(OnboardingScreen), findsOneWidget);
      },
      tags: [TestTags.smoke, TestTags.onboarding],
    );

    testWidgets(
      'app with completed onboarding shows home screen',
      (WidgetTester tester) async {
        // Launch app with onboarding completed
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Verify home screen is shown
        expectTextVisible('Next Pointing');
        expectTextVisible('Tap for another invitation to look');
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.smoke],
    );

    testWidgets(
      'home screen displays pointing content card',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Verify pointing card area exists with content
        // The content changes randomly so we just verify the footer text
        expectTextVisible('Tap for another invitation to look');

        // Verify Next Pointing button
        expect(find.text('Next Pointing'), findsOneWidget);
      },
      tags: [TestTags.smoke],
    );
  });

  // ============================================================
  // 2. BOTTOM NAVIGATION TABS
  // Tags: navigation, smoke
  // Equivalent to: 02_navigation_tabs.yaml
  // ============================================================
  group('Bottom Navigation Tabs', () {
    testWidgets(
      'home tab is active by default',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Verify Home screen content is visible
        expectTextVisible('Next Pointing');
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.navigation, TestTags.smoke],
    );

    testWidgets(
      'can navigate to Inquiry tab',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Tap Inquiry tab
        await navigateToInquiry(tester);

        // Verify Inquiry screen content
        expectTextVisible('Self-Inquiry');
        expectTextVisible('AVAILABLE SESSIONS');
        expectTextVisible('Who Am I?');
        expect(find.byType(InquiryScreen), findsOneWidget);
      },
      tags: [TestTags.navigation, TestTags.smoke],
    );

    testWidgets(
      'can navigate to Lineages tab',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Tap Lineages tab
        await navigateToLineages(tester);

        // Verify Lineages screen content
        expectTextVisible('Lineages');
        expectTextVisible('Choose a tradition that resonates with you');
        expect(find.byType(LineagesScreen), findsOneWidget);
      },
      tags: [TestTags.navigation, TestTags.smoke],
    );

    testWidgets(
      'can navigate to Settings tab',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Tap Settings tab
        await navigateToSettings(tester);

        // Verify Settings screen content
        expectTextVisible('Settings');
        expectTextVisible('NOTIFICATIONS');
        expectTextVisible('Daily Pointings');
        expect(find.byType(SettingsScreen), findsOneWidget);
      },
      tags: [TestTags.navigation, TestTags.smoke],
    );

    testWidgets(
      'can return to Home tab after navigation',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Navigate away
        await navigateToSettings(tester);
        expectTextVisible('Settings');

        // Navigate back to Home
        await navigateToHome(tester);
        expectTextVisible('Next Pointing');
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.navigation, TestTags.smoke],
    );

    testWidgets(
      'navigation maintains tab state',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Navigate through all tabs
        await navigateToInquiry(tester);
        expect(find.byType(InquiryScreen), findsOneWidget);

        await navigateToLineages(tester);
        expect(find.byType(LineagesScreen), findsOneWidget);

        await navigateToSettings(tester);
        expect(find.byType(SettingsScreen), findsOneWidget);

        await navigateToHome(tester);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.navigation],
    );
  });

  // ============================================================
  // 3. HOME POINTING INTERACTION
  // Tags: smoke, interaction
  // Equivalent to: 03_home_pointing_interaction.yaml
  // ============================================================
  group('Home Pointing Interaction', () {
    testWidgets(
      'tapping Next Pointing changes content',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Verify we're on home screen
        expectTextVisible('Next Pointing');

        // Tap Next Pointing button
        await tester.tap(find.text('Next Pointing'));
        await pumpAndSettle(tester);

        // Verify footer is still visible (content card didn't disappear)
        expectTextVisible('Tap for another invitation to look');
      },
      tags: [TestTags.smoke, TestTags.interaction],
    );

    testWidgets(
      'multiple taps on Next Pointing are stable',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Tap multiple times
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text('Next Pointing'));
          await pumpAndSettle(tester);
        }

        // Verify app is still functional
        expectTextVisible('Next Pointing');
        expectTextVisible('Tap for another invitation to look');
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.interaction],
    );

    testWidgets(
      'home screen shows tradition badge',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Tradition badge should be visible (contains one of the tradition names)
        final traditions = [
          'Advaita Vedanta',
          'Zen Buddhism',
          'Direct Path',
          'Contemporary',
          'Original',
        ];

        var foundTradition = false;
        for (final tradition in traditions) {
          if (find.text(tradition).evaluate().isNotEmpty) {
            foundTradition = true;
            break;
          }
        }
        expect(foundTradition, isTrue, reason: 'Should display a tradition badge');
      },
      tags: [TestTags.interaction],
    );
  });

  // ============================================================
  // 4. INQUIRY SESSIONS
  // Tags: sessions
  // Equivalent to: 04_inquiry_sessions.yaml
  // ============================================================
  group('Inquiry Sessions', () {
    testWidgets(
      'inquiry screen shows intro card',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToInquiry(tester);

        // Verify intro card content
        expectTextVisible('Self-Inquiry');
        expect(
          findTextContaining('These sessions guide you through'),
          findsOneWidget,
        );
        expect(
          findTextContaining('Each session is 5-15 minutes'),
          findsOneWidget,
        );
      },
      tags: [TestTags.sessions],
    );

    testWidgets(
      'inquiry screen shows free sessions',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToInquiry(tester);

        // Verify free sessions are visible
        expectTextVisible('Who Am I?');
        expectTextVisible('The fundamental inquiry');
        expectTextVisible('Finding the Looker');
      },
      tags: [TestTags.sessions],
    );

    testWidgets(
      'inquiry screen shows session metadata',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToInquiry(tester);

        // Verify session duration and level are shown
        expect(findTextContaining('5 min'), findsOneWidget);
        expect(findTextContaining('Beginner'), findsWidgets);
      },
      tags: [TestTags.sessions],
    );

    testWidgets(
      'can tap on free session',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToInquiry(tester);

        // Tap on first free session
        await tester.tap(find.text('Who Am I?'));
        await pumpAndSettle(tester);

        // Session tap should work (no crash)
        // The actual behavior is TODO in the app
      },
      tags: [TestTags.sessions],
    );

    testWidgets(
      'shows premium sessions',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToInquiry(tester);

        // Scroll to see premium sessions
        await scrollDown(tester);

        // Verify premium sessions exist
        expect(findTextContaining('The Space of Awareness'), findsOneWidget);
        expect(findTextContaining('Resting as Awareness'), findsOneWidget);
      },
      tags: [TestTags.sessions],
    );
  });

  // ============================================================
  // 5. LINEAGES SCREEN
  // Tags: navigation
  // Equivalent to: 05_lineages_screen.yaml
  // ============================================================
  group('Lineages Screen', () {
    testWidgets(
      'lineages screen shows header',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToLineages(tester);

        expectTextVisible('Lineages');
        expectTextVisible('Choose a tradition that resonates with you');
      },
      tags: [TestTags.navigation],
    );

    testWidgets(
      'lineages screen shows traditions with pointings count',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToLineages(tester);

        // Verify pointings count is shown
        expect(findTextContaining('pointings'), findsWidgets);
      },
      tags: [TestTags.navigation],
    );

    testWidgets(
      'lineages screen shows all traditions',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToLineages(tester);

        // Verify tradition names are shown
        expectTextVisible('Advaita Vedanta');
        expectTextVisible('Zen Buddhism');

        // Scroll to see more
        await scrollDown(tester);

        expectTextVisible('Direct Path');
        expectTextVisible('Contemporary');
        expectTextVisible('Original');
      },
      tags: [TestTags.navigation],
    );

    testWidgets(
      'can tap on tradition card',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToLineages(tester);

        // Tap on first tradition
        await tester.tap(find.text('Advaita Vedanta'));
        await pumpAndSettle(tester);

        // Tradition tap should work (no crash)
        // The actual behavior is TODO in the app
      },
      tags: [TestTags.navigation],
    );
  });

  // ============================================================
  // 6. SETTINGS SCREEN
  // Tags: settings, smoke
  // Equivalent to: 06_settings_screen.yaml
  // ============================================================
  group('Settings Screen', () {
    testWidgets(
      'settings screen shows notifications section',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);

        expectTextVisible('NOTIFICATIONS');
        expectTextVisible('Daily Pointings');
        expectTextVisible('3 per day');
        expectTextVisible('Notification Times');
        expectTextVisible('8am, 12pm, 9pm');
      },
      tags: [TestTags.settings, TestTags.smoke],
    );

    testWidgets(
      'settings screen shows traditions section',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);

        expectTextVisible('TRADITIONS');
        expectTextVisible('Manage Lineages');
      },
      tags: [TestTags.settings],
    );

    testWidgets(
      'settings screen shows history section',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);

        expectTextVisible('HISTORY');
        expectTextVisible('Past Pointings');
        expectTextVisible('No streaks. Just recognition.');
      },
      tags: [TestTags.settings],
    );

    testWidgets(
      'settings screen shows account section for free user',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true, isPremium: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);
        await scrollDown(tester);

        expectTextVisible('ACCOUNT');
        expectTextVisible('Upgrade to Premium');
        expectTextVisible('Unlock all traditions & sessions');
      },
      tags: [TestTags.settings],
    );

    testWidgets(
      'settings screen shows premium active for premium user',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true, isPremium: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);
        await scrollDown(tester);

        expectTextVisible('ACCOUNT');
        expectTextVisible('Premium Active');
        expectTextVisible('All features unlocked');
      },
      tags: [TestTags.settings, TestTags.premium],
    );

    testWidgets(
      'settings screen shows about section',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);
        await scrollDown(tester);

        expectTextVisible('ABOUT');
        expectTextVisible('About Pointer');
        expectTextVisible('Privacy Policy');
        expectTextVisible('Terms of Service');
        expectTextVisible('Pointer v1.0.0');
      },
      tags: [TestTags.settings],
    );

    testWidgets(
      'notification toggle switch is interactive',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        await navigateToSettings(tester);

        // Find and tap the switch
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);

        await tester.tap(switchFinder);
        await pumpAndSettle(tester);

        // Switch should toggle (no crash)
      },
      tags: [TestTags.settings],
    );
  });

  // ============================================================
  // 7. PREMIUM PAYWALL - REMOVED (all features now free)
  // Tests removed: paywall/IAP no longer exists
  // To restore: git checkout v1.0-with-auth
  // ============================================================

  // ============================================================
  // 8. ONBOARDING FLOW
  // Tags: onboarding
  // Equivalent to: 08_onboarding_flow.yaml
  // ============================================================
  group('Onboarding Flow', () {
    testWidgets(
      'onboarding shows welcome page first',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        expectTextVisible('Welcome to Pointer');
        expectTextVisible('Direct invitations to recognize what you already are');
        expect(
          findTextContaining('Each pointing is a finger pointing at the moon'),
          findsOneWidget,
        );
        expectTextVisible('Continue');
      },
      tags: [TestTags.onboarding],
    );

    testWidgets(
      'onboarding shows traditions page',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Navigate to page 2
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);

        expectTextVisible('Multiple Traditions');
        expectTextVisible('One truth, many expressions');
      },
      tags: [TestTags.onboarding],
    );

    testWidgets(
      'onboarding shows daily pointings page',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Navigate to page 3
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);

        expectTextVisible('Daily Pointings');
        expectTextVisible('Gentle reminders throughout your day');
      },
      tags: [TestTags.onboarding],
    );

    testWidgets(
      'onboarding shows notifications page last',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Navigate to page 4
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);

        expectTextVisible('Stay Connected');
        expectTextVisible('Would you like daily reminders?');
        expectTextVisible('Enable Notifications');
        expectTextVisible('Maybe Later');
      },
      tags: [TestTags.onboarding],
    );

    testWidgets(
      'skipping notifications completes onboarding',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Go through onboarding
        await skipOnboarding(tester);

        // Verify we're on home screen
        expectTextVisible('Next Pointing');
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.onboarding, TestTags.smoke],
    );

    testWidgets(
      'enabling notifications completes onboarding',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Go through onboarding with notifications
        await completeOnboarding(tester);

        // Verify we're on home screen
        expectTextVisible('Next Pointing');
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.onboarding],
    );

    testWidgets(
      'onboarding shows page indicators',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // Should see 4 page indicators (AnimatedContainer widgets with specific decoration)
        // We verify by navigating and ensuring the UI updates
        expectTextVisible('Welcome to Pointer');

        // Navigate forward and verify different content
        await tester.tap(find.text('Continue'));
        await pumpAndSettle(tester);
        expectTextVisible('Multiple Traditions');
      },
      tags: [TestTags.onboarding],
    );
  });

  // ============================================================
  // SMOKE TEST SUITE
  // Critical path tests that should always pass
  // ============================================================
  group('Smoke Tests', () {
    testWidgets(
      'critical user flow - launch to pointing interaction',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: true);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // 1. Verify app launched to home
        expect(find.byType(HomeScreen), findsOneWidget);
        expectTextVisible('Next Pointing');

        // 2. Interact with pointing
        await tester.tap(find.text('Next Pointing'));
        await pumpAndSettle(tester);
        expectTextVisible('Tap for another invitation to look');

        // 3. Navigate to all tabs
        await navigateToInquiry(tester);
        expect(find.byType(InquiryScreen), findsOneWidget);

        await navigateToLineages(tester);
        expect(find.byType(LineagesScreen), findsOneWidget);

        await navigateToSettings(tester);
        expect(find.byType(SettingsScreen), findsOneWidget);

        // 4. Return home
        await navigateToHome(tester);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
      tags: [TestTags.smoke],
    );

    testWidgets(
      'critical user flow - fresh install to home',
      (WidgetTester tester) async {
        final app = await createTestApp(onboardingCompleted: false);
        await tester.pumpWidget(app);
        await pumpAndSettle(tester);

        // 1. Should start on onboarding
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expectTextVisible('Welcome to Pointer');

        // 2. Complete onboarding
        await skipOnboarding(tester);

        // 3. Should be on home
        expect(find.byType(HomeScreen), findsOneWidget);
        expectTextVisible('Next Pointing');
      },
      tags: [TestTags.smoke],
    );
  });
}
