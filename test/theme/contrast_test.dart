import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';

double _channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// WCAG 2.x contrast ratio of [fg] composited over the opaque [bg].
double contrast(Color fg, Color bg) {
  final a = _luminance(Color.alphaBlend(fg, bg));
  final b = _luminance(bg);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  final themes = <String, (PointerColors, GlassMaterial)>{
    'dark': (PointerColors.dark, GlassMaterial.dark),
    'light': (PointerColors.light, GlassMaterial.light),
    'highContrast': (PointerColors.highContrast, GlassMaterial.highContrast),
    'oled': (PointerColors.oled, GlassMaterial.oled),
  };

  for (final MapEntry(key: name, value: (colors, glass)) in themes.entries) {
    group('$name contrast', () {
      // Every surface text can sit on: the page, and glass at each intensity (both gradient stops).
      final surfaces = <String, Color>{'background': colors.background, 'surface': colors.surface};
      for (final (i, label) in const [(0, 'light'), (1, 'standard'), (2, 'heavy')]) {
        for (final (stop, alpha) in [('top', glass.levels[i].top), ('bottom', glass.levels[i].bottom)]) {
          surfaces['glass-$label-$stop'] = Color.alphaBlend(glass.fill.withValues(alpha: alpha), colors.background);
        }
      }
      // Frost suppressed (opaque sheets): plain glass over the sheet surface.
      for (final (i, label) in const [(0, 'light'), (1, 'standard'), (2, 'heavy')]) {
        final l = glass.onSurfaceLevels[i];
        surfaces['onSurface-$label-top'] = Color.alphaBlend(glass.fill.withValues(alpha: l.top), colors.surface);
        surfaces['onSurface-$label-bottom'] = Color.alphaBlend(glass.fill.withValues(alpha: l.bottom), colors.surface);
      }
      // Button labels are textPrimary: check that alone over both button fills.
      for (final (label, l) in [('primary', glass.buttonPrimary), ('secondary', glass.buttonSecondary)]) {
        final bg = Color.alphaBlend(glass.fill.withValues(alpha: l.top), colors.background);
        test('button label on $label button is at least 4.5:1', () {
          expect(contrast(colors.textPrimary, bg), greaterThanOrEqualTo(4.5), reason: '$name button-$label');
        });
      }
      final texts = <String, Color>{
        'textPrimary': colors.textPrimary,
        'textSecondary': colors.textSecondary,
        'textMuted': colors.textMuted,
        'accent': colors.accent,
      };

      for (final t in texts.entries) {
        for (final s in surfaces.entries) {
          test('${t.key} on ${s.key} is at least 4.5:1', () {
            final ratio = contrast(t.value, s.value);
            expect(ratio, greaterThanOrEqualTo(4.5), reason: '$name ${t.key} on ${s.key}: ${ratio.toStringAsFixed(2)}:1');
          });
        }
      }

      test('large text (gold) on glass is at least 3:1', () {
        for (final s in surfaces.entries) {
          expect(contrast(colors.gold, s.value), greaterThanOrEqualTo(3.0), reason: '$name gold on ${s.key}');
        }
      });

      if (name != 'highContrast') {
        test('secondary and muted text are distinct steps', () {
          final p = _luminance(colors.textPrimary), s = _luminance(colors.textSecondary), m = _luminance(colors.textMuted);
          // Monotonic hierarchy away from the background, each step visibly apart.
          final dark = _luminance(colors.background) < 0.5;
          expect(dark ? (p > s && s > m) : (p < s && s < m), isTrue, reason: '$name hierarchy');
          expect(contrast(colors.textSecondary, colors.textMuted), greaterThanOrEqualTo(1.25), reason: '$name secondary vs muted');
        });
      }
    });
  }

  test('palette no longer uses stock Tailwind violet or pink', () {
    const stock = [Color(0xFF8B5CF6), Color(0xFFEC4899)];
    for (final c in [PointerColors.dark, PointerColors.light, PointerColors.oled, PointerColors.highContrast]) {
      for (final s in stock) {
        expect([c.primary, c.secondary, c.accent].contains(s), isFalse);
      }
    }
  });
}
