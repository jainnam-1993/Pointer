import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/widgets/ambient.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/theme/app_theme.dart';

void main() {
  group('Reduced Motion - AnimatedGradient', () {
    setUp(() {
      AnimatedGradient.forceMotionInTests = true;
      AmbientClock.instance.debugReset();
    });
    tearDown(() {
      AnimatedGradient.forceMotionInTests = false;
      AmbientClock.instance.debugReset();
    });

    Future<void> unmount(WidgetTester tester) => tester.pumpWidget(const SizedBox());

    testWidgets('system reduce motion freezes the clock on the still frame', (tester) async {
      await tester.pumpWidget(_gradientApp(oled: false, mode: AppThemeMode.dark, systemDisable: true));
      final bg = tester.widget<AmbientBackground>(find.byType(AmbientBackground));
      expect(bg.animate, isFalse);
      expect(AmbientClock.instance.isRunning, isFalse);
      expect(AmbientClock.instance.value, kAmbientStillTime);
      await unmount(tester);
    });

    testWidgets('animates when motion is allowed', (tester) async {
      await tester.pumpWidget(_gradientApp(oled: false, mode: AppThemeMode.dark));
      expect(tester.widget<AmbientBackground>(find.byType(AmbientBackground)).animate, isTrue);
      expect(AmbientClock.instance.isRunning, isTrue);
      await unmount(tester);
      expect(AmbientClock.instance.isRunning, isFalse, reason: 'clock stops with no listeners');
    });

    testWidgets('app override true freezes the clock', (tester) async {
      await tester.pumpWidget(_gradientApp(oled: false, mode: AppThemeMode.dark, reduceOverride: true));
      expect(tester.widget<AmbientBackground>(find.byType(AmbientBackground)).animate, isFalse);
      expect(AmbientClock.instance.isRunning, isFalse);
      expect(AmbientClock.instance.value, kAmbientStillTime);
      await unmount(tester);
    });

    testWidgets('dark theme uses a dark time-of-day palette with aurora', (tester) async {
      await tester.pumpWidget(_gradientApp(oled: false, mode: AppThemeMode.dark));
      final p = tester.widget<AmbientBackground>(find.byType(AmbientBackground)).palette;
      expect(p.isDark, isTrue);
      expect(p.top.toARGB32(), lessThan(0xFF202020));
      expect(p.aurora, greaterThan(0));
      await unmount(tester);
    });

    testWidgets('light theme uses the light palette', (tester) async {
      await tester.pumpWidget(_gradientApp(oled: false, mode: AppThemeMode.light));
      final p = tester.widget<AmbientBackground>(find.byType(AmbientBackground)).palette;
      expect(p, AmbientPalette.light);
      expect(p.top.toARGB32(), greaterThan(0xFFE0E0E0));
      await unmount(tester);
    });
  });

  group('Reduced Motion - Provider', () {
    test('reduceMotionOverrideProvider defaults to null', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          oledModeProvider.overrideWith((ref) => false),
          themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
        ],
      );
      addTearDown(container.dispose);

      final value = container.read(reduceMotionOverrideProvider);
      expect(value, isNull);
    });

    test('reduceMotionOverrideProvider can be set to true', () {
      final container = ProviderContainer(
        overrides: [
          oledModeProvider.overrideWith((ref) => false),
          themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
          reduceMotionOverrideProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      final value = container.read(reduceMotionOverrideProvider);
      expect(value, true);
    });

    test('reduceMotionOverrideProvider can be set to false', () {
      final container = ProviderContainer(
        overrides: [
          oledModeProvider.overrideWith((ref) => false),
          themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
          reduceMotionOverrideProvider.overrideWith((ref) => false),
        ],
      );
      addTearDown(container.dispose);

      final value = container.read(reduceMotionOverrideProvider);
      expect(value, false);
    });
  });

  group('Reduced Motion - shouldReduceMotion helper', () {
    testWidgets('returns true when system setting is enabled', (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  result = shouldReduceMotion(context, null);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('returns false when system setting is disabled and no override', (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: Builder(
                builder: (context) {
                  result = shouldReduceMotion(context, null);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(result, false);
    });

    testWidgets('override true takes precedence over system false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: Builder(
                builder: (context) {
                  result = shouldReduceMotion(context, true);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('override false does NOT disable when system is true', (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  // When system says reduce motion, we should respect it
                  // App override can enable reduce motion, but not disable it
                  result = shouldReduceMotion(context, false);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // System accessibility setting should be respected even with app override
      expect(result, true, reason: 'System accessibility setting should always be respected');
    });
  });
}

Widget _gradientApp({required bool oled, required AppThemeMode mode, bool? reduceOverride, bool systemDisable = false}) {
  return ProviderScope(
    overrides: [
      oledModeProvider.overrideWith((ref) => oled),
      themeModeProvider.overrideWith((ref) => mode),
      reduceMotionOverrideProvider.overrideWith((ref) => reduceOverride),
    ],
    child: MaterialApp(
      theme: mode == AppThemeMode.light ? AppTheme.light : AppTheme.dark,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: systemDisable),
        child: const Scaffold(body: AnimatedGradient()),
      ),
    ),
  );
}
