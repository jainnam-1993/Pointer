// Screenshot tests for Pointer app - User Journey focused
//
// Purpose: Capture screenshots of key user flows to verify UX makes sense.
// These screenshots can be reviewed by humans or AI to identify UX gaps.
//
// Run: flutter test integration_test/screenshot_test.dart -d <device>
//
// NOTE: GoRouter's StatefulShellRoute has known GlobalKey issues in tests.
// Tests are structured to minimize this while still capturing key screenshots.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pointer/main.dart';
import 'package:pointer/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  var surfaceConverted = false;

  /// Creates a fresh ProviderContainer for each test
  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        onboardingCompletedProvider.overrideWith((ref) => true),
      ],
    );
  }

  /// Pump frames for a fixed duration (handles continuous animations)
  Future<void> settle(WidgetTester tester, {int seconds = 2}) async {
    await tester.pump(Duration(seconds: seconds));
  }

  /// Takes a screenshot with the given name
  Future<void> screenshot(WidgetTester tester, String name) async {
    if (!surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      surfaceConverted = true;
    }
    await tester.pump();
    await binding.takeScreenshot(name);
    // ignore: avoid_print
    print('📸 Screenshot: $name');
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'pointer_onboarding_completed': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  setUp(() {
    surfaceConverted = false;
  });

  // ==========================================================================
  // HOME SCREEN - The main landing experience
  // ==========================================================================
  group('Home Screen', () {
    testWidgets('Initial home view', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);
      await screenshot(tester, '01_home_initial');
      expect(find.text('Next'), findsOneWidget);
      container.dispose();
    });

    testWidgets('After tapping Next button', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);

      await tester.tap(find.text('Next'));
      await settle(tester);
      await screenshot(tester, '02_home_after_next');
      container.dispose();
    });

    testWidgets('After swipe up gesture', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);

      // Swipe up to get next pointing
      await tester.drag(find.byType(Scaffold).first, const Offset(0, -300));
      await settle(tester);
      await screenshot(tester, '03_home_after_swipe');
      container.dispose();
    });

    testWidgets('Multiple pointings (freemium flow)', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);
      await screenshot(tester, 'freemium_01_start');

      // View multiple pointings
      for (var i = 0; i < 3; i++) {
        final nextButton = find.text('Next');
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await settle(tester);
          await screenshot(tester, 'freemium_0${i + 2}_view_${i + 1}');
        }
      }

      // Check if paywall appeared (limit is 2/day)
      final paywallIndicator = find.textContaining('Premium');
      if (paywallIndicator.evaluate().isNotEmpty) {
        // ignore: avoid_print
        print('''
╔═══════════════════════════════════════════════════════════════════╗
║  💰 PAYWALL TRIGGERED - Free user hit daily limit                 ║
╠═══════════════════════════════════════════════════════════════════╣
║  Screenshots show progression from initial view to hitting limit. ║
║  Review: Is the upgrade value proposition clear?                  ║
╚═══════════════════════════════════════════════════════════════════╝
''');
      }
      container.dispose();
    });
  });

  // ==========================================================================
  // PAYWALL SCREEN - REMOVED (IAP removed, all features free)
  // To restore: git checkout v1.0-with-auth
  // ==========================================================================

  // ==========================================================================
  // SETTINGS SCREEN - Via navigation tap (demonstrates TTS UX gap)
  // ==========================================================================
  // NOTE: Using tap navigation instead of router.go to minimize GlobalKey issues
  // The screenshot captures the UX gap even if the test reports an error
  group('Settings Screen (TTS UX Gap)', () {
    testWidgets('Settings view - TTS not discoverable', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);

      // Navigate to Settings via bottom nav tap
      await tester.tap(find.text('Settings'));
      await settle(tester);
      await screenshot(tester, 'settings_01_initial');

      // Scroll down to look for audio options
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -400));
        await settle(tester);
        await screenshot(tester, 'settings_02_scrolled');
      }

      // UX GAP documentation
      // ignore: avoid_print
      print('''
╔═══════════════════════════════════════════════════════════════════╗
║  🔍 UX GAP: TTS Configuration Not Discoverable                    ║
╠═══════════════════════════════════════════════════════════════════╣
║  Screenshots show Settings screen. Notice there is NO visible     ║
║  "Audio" or "TTS" section. The feature is hidden behind a         ║
║  7-tap easter egg on the version number.                          ║
║                                                                   ║
║  RECOMMENDATION: Add visible "Audio & TTS" section in Settings    ║
╚═══════════════════════════════════════════════════════════════════╝
''');

      container.dispose();
    });

    testWidgets('Developer menu unlock (7-tap easter egg)', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await settle(tester);

      // Scroll to ABOUT section
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -500));
        await settle(tester);
      }

      // Tap version 7 times to unlock developer menu
      final versionText = find.textContaining('Pointer v');
      if (versionText.evaluate().isNotEmpty) {
        for (var i = 0; i < 7; i++) {
          await tester.tap(versionText.first);
          await tester.pump(const Duration(milliseconds: 100));
        }
        await settle(tester);
        await screenshot(tester, 'settings_03_developer_unlocked');

        // ignore: avoid_print
        print('''
╔═══════════════════════════════════════════════════════════════════╗
║  🎯 DEVELOPER MENU UNLOCKED                                       ║
╠═══════════════════════════════════════════════════════════════════╣
║  After tapping version 7 times, TTS config becomes visible.       ║
║  🚨 No normal user would discover this workflow.                  ║
╚═══════════════════════════════════════════════════════════════════╝
''');
      }

      container.dispose();
    });
  });

  // ==========================================================================
  // OTHER TABS - Quick screenshots via navigation
  // ==========================================================================
  // NOTE: These may report errors due to GoRouter GlobalKey issues,
  // but screenshots are captured before the error occurs.
  group('Other Tabs', () {
    testWidgets('Inquiry screen', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);

      await tester.tap(find.text('Inquiry'));
      await settle(tester);
      await screenshot(tester, 'inquiry_screen');

      container.dispose();
    });

    testWidgets('Library screen', (tester) async {
      final container = createContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const PointerApp()),
      );
      await settle(tester);

      await tester.tap(find.text('Library'));
      await settle(tester);
      await screenshot(tester, 'library_screen');

      container.dispose();
    });
  });
}
