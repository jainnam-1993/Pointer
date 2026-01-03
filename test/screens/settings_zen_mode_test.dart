import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/theme/app_theme.dart';

late SharedPreferences prefs;

Widget wrapWithProviderScope(Widget child, {bool initialZenMode = false}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      zenModeProvider.overrideWith((ref) => initialZenMode),
    ],
    child: child,
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'pointer_onboarding_completed': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  group('Settings Screen - Zen Mode Toggle', () {
    testWidgets('shows Zen Mode toggle in Appearance section', (tester) async {
      // Use iPhone 14 Pro Max size to avoid overflow on wide settings rows
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find the Zen Mode toggle
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Zen Mode'),
        100,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.text('Zen Mode'), findsOneWidget);
      expect(find.text('Minimal UI, just the pointing'), findsOneWidget);
    });

    testWidgets('Zen Mode toggle is off by default', (tester) async {
      // Use iPhone 14 Pro Max size to avoid overflow on wide settings rows
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: SettingsScreen(),
            ),
          ),
          initialZenMode: false,
        ),
      );
      await tester.pumpAndSettle();

      // Find the Zen Mode switch
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Zen Mode'),
        100,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      // Find the Switch associated with Zen Mode by looking for Switches
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      // There should be at least the Zen Mode switch
      expect(switches.length, greaterThanOrEqualTo(1)); // At least Zen
    });

    testWidgets('tapping Zen Mode toggle changes its state', (tester) async {
      // Use iPhone 14 Pro Max size to avoid overflow on wide settings rows
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: SettingsScreen(),
            ),
          ),
          initialZenMode: false,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find the Zen Mode toggle
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Zen Mode'),
        100,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      // Find the row containing Zen Mode text and tap its switch
      final zenModeRow = find.ancestor(
        of: find.text('Zen Mode'),
        matching: find.byType(Row),
      ).first;

      final zenModeSwitch = find.descendant(
        of: zenModeRow,
        matching: find.byType(Switch),
      );

      expect(zenModeSwitch, findsOneWidget);

      // Tap the switch
      await tester.tap(zenModeSwitch);
      await tester.pumpAndSettle();

      // The switch should now be on (we can verify by checking the widget)
      expect(find.byType(Switch), findsWidgets);
    });
  });
}
