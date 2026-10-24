import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';

double _luminance(Color c) => c.computeLuminance();
double _contrast(Color a, Color b) {
  final l1 = _luminance(a), l2 = _luminance(b);
  return (l1 > l2 ? l1 + 0.05 : l2 + 0.05) / (l1 > l2 ? l2 + 0.05 : l1 + 0.05);
}

/**
 * Regression for the black glass cards on Flutter 3.47: the OS contrast
 * setting now arrives as MediaQuery.highContrast, and the app drew opaque
 * near-black high-contrast cards while text kept the light theme's dark ink.
 * High contrast must resolve to one theme whose text reads on those cards.
 */
void main() {
  testWidgets('system high contrast in light mode resolves the high-contrast palette', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    late PointerColors colors;
    late GlassMaterial glass;
    await tester.pumpWidget(
      MaterialApp(
        // The same theme wiring as PointerApp in lib/main.dart.
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        highContrastTheme: AppTheme.highContrast,
        highContrastDarkTheme: AppTheme.highContrast,
        themeMode: ThemeMode.light,
        home: Builder(
          builder: (context) {
            colors = context.colors;
            glass = GlassMaterial.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors, PointerColors.highContrast);
    expect(glass.opaque, isTrue);
    expect(_contrast(colors.textPrimary, glass.fill), greaterThanOrEqualTo(7));
    expect(_contrast(colors.textSecondary, glass.fill), greaterThanOrEqualTo(7));
  });

  test('lib/main.dart wires the high-contrast theme for both system and in-app high contrast', () {
    final src = File('lib/main.dart').readAsStringSync();
    expect(src, contains('highContrastTheme: AppTheme.highContrast'));
    expect(src, contains('highContrastDarkTheme: AppTheme.highContrast'));
    expect(src, contains('theme: highContrast ? AppTheme.highContrast : AppTheme.light'));
  });
}
