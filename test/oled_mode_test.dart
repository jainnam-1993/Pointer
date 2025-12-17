import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer_flutter/providers/providers.dart';
import 'package:pointer_flutter/services/storage_service.dart';
import 'package:pointer_flutter/widgets/animated_gradient.dart';
import 'package:pointer_flutter/theme/app_theme.dart';

void main() {
  // Disable animations for tests to prevent timer issues
  setUpAll(() {
    AnimatedGradient.disableAnimations = true;
    AppTextStyles.useSystemFonts = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
    AppTextStyles.useSystemFonts = false;
  });

  group('OLED Mode Provider Tests', () {
    test('oledModeProvider reads from settings', () async {
      // Setup - Mock SharedPreferences with OLED mode enabled
      SharedPreferences.setMockInitialValues({
        StorageKeys.settings: '{"oledMode": true}',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Act - Read oledModeProvider
      final oledMode = container.read(oledModeProvider);

      // Assert - Should be true from settings
      expect(oledMode, isTrue);
    });

    test('oledModeProvider defaults to false when not set', () async {
      // Setup - Mock SharedPreferences without OLED mode
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Act - Read oledModeProvider
      final oledMode = container.read(oledModeProvider);

      // Assert - Should default to false
      expect(oledMode, isFalse);
    });
  });

  group('AnimatedGradient OLED Mode Tests', () {
    testWidgets('returns pure black Container when OLED mode enabled',
        (WidgetTester tester) async {
      // Setup - Mock SharedPreferences with OLED mode enabled
      SharedPreferences.setMockInitialValues({
        StorageKeys.settings: '{"oledMode": true}',
      });
      final prefs = await SharedPreferences.getInstance();

      // Build widget with OLED mode enabled
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: AnimatedGradient(),
            ),
          ),
        ),
      );

      // Find the Container widget
      final containerFinder = find.descendant(
        of: find.byType(AnimatedGradient),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsOneWidget);

      // Get the Container widget
      final Container container = tester.widget(containerFinder);

      // Assert - Container should have pure black color, no gradient
      expect(container.decoration, isNull);
      expect(container.color, equals(Colors.black));
      expect(container.color, equals(const Color(0xFF000000)));
    });

    testWidgets('returns gradient when OLED mode disabled',
        (WidgetTester tester) async {
      // Setup - Mock SharedPreferences with OLED mode disabled
      SharedPreferences.setMockInitialValues({
        StorageKeys.settings: '{"oledMode": false}',
      });
      final prefs = await SharedPreferences.getInstance();

      // Build widget with OLED mode disabled
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: AnimatedGradient(),
            ),
          ),
        ),
      );

      // Find the Container widget
      final containerFinder = find.descendant(
        of: find.byType(AnimatedGradient),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsOneWidget);

      // Get the Container widget
      final Container container = tester.widget(containerFinder);

      // Assert - Container should have gradient decoration (not pure black)
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });

  group('OLED Mode Background Color Tests', () {
    test('OLED mode background color is exactly Color(0xFF000000)', () {
      // Assert - Colors.black is exactly #000000
      expect(Colors.black, equals(const Color(0xFF000000)));
      expect(Colors.black.value, equals(0xFF000000));
      expect(Colors.black.red, equals(0));
      expect(Colors.black.green, equals(0));
      expect(Colors.black.blue, equals(0));
      expect(Colors.black.alpha, equals(255));
    });

    test('PointerColors.oled has pure black cardBackground', () {
      // Assert - OLED theme uses pure black for card background
      expect(PointerColors.oled.cardBackground, equals(Colors.black));
      expect(PointerColors.oled.cardBackground, equals(const Color(0xFF000000)));
    });
  });

  group('Settings Toggle Updates oledModeProvider', () {
    test('toggling OLED mode in settings updates provider', () async {
      // Setup - Mock SharedPreferences with OLED mode disabled initially
      SharedPreferences.setMockInitialValues({
        StorageKeys.settings: '{"oledMode": false}',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Initial state - OLED mode should be false
      expect(container.read(oledModeProvider), isFalse);

      // Act - Update settings to enable OLED mode
      final settingsNotifier = container.read(settingsProvider.notifier);
      final currentSettings = container.read(settingsProvider);
      await settingsNotifier.update(currentSettings.copyWith(oledMode: true));

      // Flush pending timers from Riverpod's scheduler
      await Future.delayed(Duration.zero);

      // Assert - OLED mode provider should now be true
      expect(container.read(oledModeProvider), isTrue);

      // Act - Disable OLED mode
      final updatedSettings = container.read(settingsProvider);
      await settingsNotifier.update(updatedSettings.copyWith(oledMode: false));

      // Flush pending timers from Riverpod's scheduler
      await Future.delayed(Duration.zero);

      // Assert - OLED mode provider should now be false
      expect(container.read(oledModeProvider), isFalse);
    });
  });

  group('OLED Mode Persistence Tests', () {
    test('OLED mode persists via SharedPreferences', () async {
      // Setup - Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Act - Enable OLED mode and save settings
      final settingsNotifier = container.read(settingsProvider.notifier);
      final currentSettings = container.read(settingsProvider);
      await settingsNotifier.update(currentSettings.copyWith(oledMode: true));

      // Assert - Settings should be persisted in SharedPreferences
      final storedSettings = prefs.getString(StorageKeys.settings);
      expect(storedSettings, isNotNull);
      expect(storedSettings, contains('"oledMode":true'));
    });

    test('OLED mode survives app restart simulation', () async {
      // Setup - First "app session" with OLED mode enabled
      SharedPreferences.setMockInitialValues({});
      var prefs = await SharedPreferences.getInstance();

      var container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // Enable OLED mode in first session
      final settingsNotifier = container.read(settingsProvider.notifier);
      final currentSettings = container.read(settingsProvider);
      await settingsNotifier.update(currentSettings.copyWith(oledMode: true));

      // Verify it's enabled
      expect(container.read(oledModeProvider), isTrue);

      // Persist the data
      final storedValue = prefs.getString(StorageKeys.settings);
      container.dispose();

      // Simulate app restart - Create new container with persisted data
      SharedPreferences.setMockInitialValues({
        StorageKeys.settings: storedValue!,
      });
      prefs = await SharedPreferences.getInstance();

      final newContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(newContainer.dispose);

      // Assert - OLED mode should still be enabled after "restart"
      expect(newContainer.read(oledModeProvider), isTrue);
      expect(newContainer.read(settingsProvider).oledMode, isTrue);
    });
  });

  group('AnimatedGradient Integration with Settings', () {
    testWidgets('AnimatedGradient updates when oledMode changes',
        (WidgetTester tester) async {
      // Setup - Mock SharedPreferences with OLED mode disabled
      SharedPreferences.setMockInitialValues({
        StorageKeys.settings: '{"oledMode": false}',
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return Column(
                    children: [
                      const Expanded(child: AnimatedGradient()),
                      ElevatedButton(
                        onPressed: () async {
                          final settings = ref.read(settingsProvider);
                          await ref.read(settingsProvider.notifier).update(
                                settings.copyWith(oledMode: true),
                              );
                        },
                        child: const Text('Enable OLED'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should have gradient (OLED mode off)
      Container container = tester.widget(
        find.descendant(
          of: find.byType(AnimatedGradient),
          matching: find.byType(Container),
        ),
      );
      expect(container.decoration, isA<BoxDecoration>());

      // Tap button to enable OLED mode
      await tester.tap(find.text('Enable OLED'));
      await tester.pumpAndSettle();

      // Now should be pure black (OLED mode on)
      container = tester.widget(
        find.descendant(
          of: find.byType(AnimatedGradient),
          matching: find.byType(Container),
        ),
      );
      expect(container.color, equals(Colors.black));
      expect(container.decoration, isNull);
    });
  });
}
