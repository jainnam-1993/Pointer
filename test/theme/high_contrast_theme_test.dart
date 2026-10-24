import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';

/**
 * Regression for the black glass cards on Flutter 3.47: the OS contrast setting
 * now arrives as MediaQuery.highContrast, and the app drew opaque near-black
 * high-contrast cards while text kept the light theme's dark ink. High contrast
 * must resolve to a full theme that follows light and dark mode.
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
        highContrastTheme: AppTheme.highContrastLight,
        highContrastDarkTheme: AppTheme.highContrastDark,
        themeMode: mode,
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

  testWidgets('system high contrast in light mode keeps light, opaque cards with dark text', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.light, system: true);
    expect(colors, PointerColors.highContrastLight);
    expect(glass, GlassMaterial.highContrastLight);
    expect(glass.opaque, isTrue);
    expect(colors.textPrimary.computeLuminance(), lessThan(0.05));
    expect(glass.fill.computeLuminance(), greaterThan(0.9));
  });

  testWidgets('system high contrast in dark mode gives dark, opaque cards with light text', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.dark, system: true);
    expect(colors, PointerColors.highContrast);
    expect(glass, GlassMaterial.highContrast);
    expect(colors.textPrimary.computeLuminance(), greaterThan(0.9));
  });

  testWidgets('the in-app setting alone also gives high contrast', (tester) async {
    final (colors, _) = await resolve(tester, ThemeMode.light, system: false, inApp: true);
    expect(colors, PointerColors.highContrastLight);
  });

  testWidgets('neither on keeps the normal glass theme', (tester) async {
    final (colors, glass) = await resolve(tester, ThemeMode.light, system: false);
    expect(colors, PointerColors.light);
    expect(glass.opaque, isFalse);
  });

  test('lib/main.dart wires both high-contrast themes for the system and the in-app setting', () {
    final src = File('lib/main.dart').readAsStringSync();
    expect(src, contains('theme: highContrast ? AppTheme.highContrastLight : AppTheme.light'));
    expect(src, contains('darkTheme: highContrast ? AppTheme.highContrastDark : AppTheme.dark'));
    expect(src, contains('highContrastTheme: AppTheme.highContrastLight'));
    expect(src, contains('highContrastDarkTheme: AppTheme.highContrastDark'));
  });
}
