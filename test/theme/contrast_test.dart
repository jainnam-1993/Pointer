import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/theme/contrast_level.dart';
import 'package:pointer/widgets/ambient.dart';

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
    'highContrastLight': (PointerColors.highContrastLight, GlassMaterial.highContrastLight),
    'oled': (PointerColors.oled, GlassMaterial.oled),
    // System increased contrast keeps the colours and glass, with more frost and a stronger rim.
    'darkIncreased': (PointerColors.dark, increasedContrastGlass(GlassMaterial.dark, dark: true)),
    'lightIncreased': (PointerColors.light, increasedContrastGlass(GlassMaterial.light, dark: false)),
    'oledIncreased': (PointerColors.oled, increasedContrastGlass(GlassMaterial.oled, dark: true)),
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
      // The real page is the ambient gradient, not the flat background token: text on each
      // period's gradient stops, bare and under glass at each intensity.
      final ambient = switch (name) {
        'dark' || 'darkIncreased' => AmbientPalette.dark,
        'light' || 'lightIncreased' => const [AmbientPalette.light],
        'oled' || 'oledIncreased' => const [AmbientPalette.oled],
        _ => const <AmbientPalette>[],
      };
      for (final (p, palette) in ambient.indexed) {
        for (final (stop, c) in [('top', palette.top), ('mid', palette.mid), ('bottom', palette.bottom)]) {
          surfaces['ambient$p-$stop'] = c;
          for (final (i, label) in const [(0, 'light'), (1, 'standard'), (2, 'heavy')]) {
            surfaces['ambient$p-$stop-glass-$label'] = Color.alphaBlend(glass.fill.withValues(alpha: glass.levels[i].top), c);
          }
        }
      }
      // Bottom sheets (notification schedule, time picker) over the darkest and lightest page,
      // bare and under the plain glass that sits inside them.
      final sheetFill = GlassMaterial.sheetSurface(colors);
      for (final (under, page) in [('page', colors.background), ...ambient.map((a) => ('ambient', a.top))]) {
        final sheet = Color.alphaBlend(sheetFill, page);
        surfaces['sheet-over-$under'] = sheet;
        for (final (i, label) in const [(0, 'light'), (1, 'standard'), (2, 'heavy')]) {
          surfaces['sheet-over-$under-$label'] = Color.alphaBlend(glass.fill.withValues(alpha: glass.onSurfaceLevels[i].top), sheet);
        }
      }
      // Button labels are textPrimary: check that alone over both button fills.
      for (final (label, l) in [('primary', glass.buttonPrimary), ('secondary', glass.buttonSecondary)]) {
        final filled = label == 'primary' && glass.primaryFill != null;
        final bg = filled ? glass.primaryFill! : Color.alphaBlend(glass.fill.withValues(alpha: l.top), colors.background);
        final ink = filled ? glass.onPrimary! : colors.textPrimary;
        test('button label on $label button is at least 4.5:1', () {
          expect(contrast(ink, bg), greaterThanOrEqualTo(4.5), reason: '$name button-$label');
        });
      }
      test('light tradition colours keep 4.5:1 on the light surfaces', () {
        if (colors != PointerColors.light) return;
        for (final c in const [
          TraditionAccentColors.advaitaLight,
          TraditionAccentColors.zenLight,
          TraditionAccentColors.directLight,
          TraditionAccentColors.contemporaryLight,
          TraditionAccentColors.originalLight,
        ]) {
          expect(contrast(c, Color.alphaBlend(glass.fill.withValues(alpha: glass.levels[1].top), colors.background)), greaterThanOrEqualTo(4.5));
        }
      });
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

      // High contrast is WCAG AAA: body text at least 7:1 on every surface it can sit on.
      if (glass.opaque) {
        for (final t in texts.entries) {
          for (final s in surfaces.entries) {
            test('${t.key} on ${s.key} is at least 7:1 (AAA)', () {
              final ratio = contrast(t.value, s.value);
              expect(ratio, greaterThanOrEqualTo(7), reason: '$name ${t.key} on ${s.key}: ${ratio.toStringAsFixed(2)}:1');
            });
          }
        }
        test('cards and buttons have a strong opaque rim', () {
          expect(glass.rimWidth, greaterThanOrEqualTo(1));
          expect(glass.rimTop.a, 1.0);
          expect(contrast(glass.rimTop, glass.fill), greaterThanOrEqualTo(3), reason: '$name rim vs card');
        });
      }

      if (!glass.opaque) {
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
    for (final c in [PointerColors.dark, PointerColors.light, PointerColors.oled, PointerColors.highContrast, PointerColors.highContrastLight]) {
      for (final s in stock) {
        expect([c.primary, c.secondary, c.accent].contains(s), isFalse);
      }
    }
  });
}
