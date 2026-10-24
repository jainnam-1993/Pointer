import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/theme/contrast_level.dart';

/**
 * Contrast levels (lib/theme/contrast_level.dart). The system contrast setting (Android contrast_level 1.0 arrives as
 * MediaQuery.highContrast on Flutter 3.47) is ContrastLevel.increased: full colour, accents and glass, with a little
 * more frost. Only the in-app High contrast switch gives the solid theme (ContrastLevel.maximum).
 */
void main() {
  Future<(PointerColors, GlassMaterial)> resolve(WidgetTester tester, ThemeMode mode, {required bool system, bool inApp = false}) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(highContrast: system);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    late PointerColors colors;
    late GlassMaterial glass;
    await tester.pumpWidget(
      MaterialApp(
        // The same theme wiring as PointerApp in lib/main.dart.
        theme: inApp ? AppTheme.highContrastLight : AppTheme.light,
        darkTheme: inApp ? AppTheme.highContrastDark : AppTheme.dark,
        themeMode: mode,
        builder: (context, child) => Theme(
          data: themeForContrast(Theme.of(context), resolveContrastLevel(inApp: inApp, system: MediaQuery.of(context).highContrast)),
          child: child!,
        ),
        home: Builder(
          builder: (context) {
            colors = context.colors;
            glass = GlassMaterial.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return (colors, glass);
  }

  test('levels: in-app switch is maximum, system setting is increased, neither is standard', () {
    expect(resolveContrastLevel(inApp: true, system: false), ContrastLevel.maximum);
    expect(resolveContrastLevel(inApp: true, system: true), ContrastLevel.maximum);
    expect(resolveContrastLevel(inApp: false, system: true), ContrastLevel.increased);
    expect(resolveContrastLevel(inApp: false, system: false), ContrastLevel.standard);
  });

  testWidgets('system contrast in light mode keeps the light colours, the accent and non-solid glass, with more frost', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.light, system: true);
    expect(colors, PointerColors.light);
    expect(colors.accent, PointerColors.light.accent);
    expect(glass.opaque, isFalse);
    expect(glass.levels[1].frost, greaterThan(GlassMaterial.light.levels[1].frost));
    expect(glass.rimTop.a, greaterThan(GlassMaterial.light.rimTop.a));
  });

  testWidgets('system contrast in dark mode keeps the dark colours and glass', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.dark, system: true);
    expect(colors, PointerColors.dark);
    expect(glass.opaque, isFalse);
  });

  testWidgets('only the in-app switch gives the solid theme', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.light, system: false, inApp: true);
    expect(colors, PointerColors.highContrastLight);
    expect(glass.opaque, isTrue);
  });

  testWidgets('the in-app switch in dark mode, with the system setting on too, is still the solid theme', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.dark, system: true, inApp: true);
    expect(glass.opaque, isTrue);
    expect(colors.textPrimary.computeLuminance(), greaterThan(0.9));
  });

  testWidgets('neither on keeps the normal glass theme', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.light, system: false);
    expect(colors, PointerColors.light);
    expect(glass, GlassMaterial.light);
  });

  test('main.dart wires contrast through the one resolver and has no system high-contrast theme', () {
    final src = File('lib/main.dart').readAsStringSync();
    expect(src, contains('theme: highContrast ? AppTheme.highContrastLight : AppTheme.light'));
    expect(src, contains('resolveContrastLevel(inApp: highContrast, system: media.highContrast)'));
    expect(src, contains('themeForContrast('));
    expect(src, isNot(contains('highContrastTheme:')));
    expect(src, isNot(contains('highContrastDarkTheme:')));
  });
}
