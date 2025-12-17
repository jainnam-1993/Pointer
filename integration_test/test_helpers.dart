// Integration test helpers for Pointer app
// Provides common utilities for setting up and running integration tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/main.dart';
import 'package:pointer/providers/providers.dart';

/// Test tags for categorizing integration tests
class TestTags {
  static const smoke = 'smoke';
  static const navigation = 'navigation';
  static const interaction = 'interaction';
  static const settings = 'settings';
  static const premium = 'premium';
  static const onboarding = 'onboarding';
  static const sessions = 'sessions';
}

/// Initialize integration test binding
IntegrationTestWidgetsFlutterBinding ensureIntegrationTestInitialized() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Creates a test app with configurable SharedPreferences
///
/// [onboardingCompleted] - whether to skip onboarding (default: true for most tests)
/// [isPremium] - whether to set premium subscription (default: false)
Future<Widget> createTestApp({
  bool onboardingCompleted = true,
  bool isPremium = false,
}) async {
  // Set up mock SharedPreferences
  final prefs = <String, Object>{
    'pointer_onboarding_completed': onboardingCompleted,
  };

  if (isPremium) {
    prefs['pointer_subscription'] = 'premium';
  }

  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const PointerApp(),
  );
}

/// Clears all app state by resetting SharedPreferences
Future<void> clearAppState() async {
  SharedPreferences.setMockInitialValues({});
}

/// Pump the widget and wait for all animations to complete
Future<void> pumpAndSettle(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(
    duration,
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

/// Skip onboarding flow by tapping through all pages
Future<void> skipOnboarding(WidgetTester tester) async {
  // Wait for onboarding to load
  await pumpAndSettle(tester);

  // Check if we're on the onboarding screen
  final welcomeText = find.text('Welcome to Pointer');
  if (welcomeText.evaluate().isEmpty) {
    // Not on onboarding, already completed
    return;
  }

  // Page 1: Welcome - tap Continue
  await tester.tap(find.text('Continue'));
  await pumpAndSettle(tester);

  // Page 2: Traditions - tap Continue
  await tester.tap(find.text('Continue'));
  await pumpAndSettle(tester);

  // Page 3: Daily Pointings - tap Continue
  await tester.tap(find.text('Continue'));
  await pumpAndSettle(tester);

  // Page 4: Notifications - tap Maybe Later
  await tester.tap(find.text('Maybe Later'));
  await pumpAndSettle(tester);
}

/// Complete onboarding flow by enabling notifications
Future<void> completeOnboarding(WidgetTester tester) async {
  // Wait for onboarding to load
  await pumpAndSettle(tester);

  // Check if we're on the onboarding screen
  final welcomeText = find.text('Welcome to Pointer');
  if (welcomeText.evaluate().isEmpty) {
    // Not on onboarding, already completed
    return;
  }

  // Page 1: Welcome - tap Continue
  await tester.tap(find.text('Continue'));
  await pumpAndSettle(tester);

  // Page 2: Traditions - tap Continue
  await tester.tap(find.text('Continue'));
  await pumpAndSettle(tester);

  // Page 3: Daily Pointings - tap Continue
  await tester.tap(find.text('Continue'));
  await pumpAndSettle(tester);

  // Page 4: Notifications - tap Enable Notifications
  await tester.tap(find.text('Enable Notifications'));
  await pumpAndSettle(tester);
}

/// Navigate to a specific tab by tapping the nav item
Future<void> navigateToTab(WidgetTester tester, String tabLabel) async {
  final tabFinder = find.text(tabLabel);
  expect(tabFinder, findsOneWidget, reason: 'Tab "$tabLabel" should exist');
  await tester.tap(tabFinder);
  await pumpAndSettle(tester);
}

/// Navigate to Home tab
Future<void> navigateToHome(WidgetTester tester) async {
  await navigateToTab(tester, 'Home');
}

/// Navigate to Inquiry tab
Future<void> navigateToInquiry(WidgetTester tester) async {
  await navigateToTab(tester, 'Inquiry');
}

/// Navigate to Lineages tab
Future<void> navigateToLineages(WidgetTester tester) async {
  await navigateToTab(tester, 'Lineages');
}

/// Navigate to Settings tab
Future<void> navigateToSettings(WidgetTester tester) async {
  await navigateToTab(tester, 'Settings');
}

/// Find text that contains a substring (partial match)
Finder findTextContaining(String substring) {
  return find.byWidgetPredicate(
    (widget) => widget is Text &&
        widget.data != null &&
        widget.data!.contains(substring),
  );
}

/// Find a widget by its semantics label
Finder findBySemanticsLabel(String label) {
  return find.bySemanticsLabel(label);
}

/// Scroll down in a scrollable widget
Future<void> scrollDown(WidgetTester tester, {double delta = 300}) async {
  await tester.drag(find.byType(Scrollable).first, Offset(0, -delta));
  await pumpAndSettle(tester);
}

/// Scroll up in a scrollable widget
Future<void> scrollUp(WidgetTester tester, {double delta = 300}) async {
  await tester.drag(find.byType(Scrollable).first, Offset(0, delta));
  await pumpAndSettle(tester);
}

/// Verify that a text widget is visible on screen
void expectTextVisible(String text, {String? reason}) {
  expect(
    find.text(text),
    findsWidgets,
    reason: reason ?? 'Text "$text" should be visible',
  );
}

/// Verify that a text widget is NOT visible on screen
void expectTextNotVisible(String text, {String? reason}) {
  expect(
    find.text(text),
    findsNothing,
    reason: reason ?? 'Text "$text" should not be visible',
  );
}

/// Verify that at least one widget is visible
void expectWidgetVisible(Finder finder, {String? reason}) {
  expect(finder, findsWidgets, reason: reason);
}

/// Wait for a widget to appear with timeout
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure('Widget not found within timeout: $finder');
}

/// Tap on a widget if it exists, otherwise do nothing
Future<bool> tapIfExists(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder);
    await pumpAndSettle(tester);
    return true;
  }
  return false;
}

/// Extension methods for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Pump and settle with default timeout
  Future<void> settle({Duration timeout = const Duration(seconds: 10)}) async {
    await this.pumpAndSettle(timeout);
  }

  /// Tap on text widget
  Future<void> tapText(String text) async {
    await tap(find.text(text));
    await settle();
  }

  /// Tap on widget by key
  Future<void> tapKey(Key key) async {
    await tap(find.byKey(key));
    await settle();
  }
}
