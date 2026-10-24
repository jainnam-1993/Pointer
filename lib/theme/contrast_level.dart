/**
 * Contrast levels. One place decides how much contrast the app draws, so no widget reads MediaQuery.highContrast on
 * its own.
 *
 * - [ContrastLevel.standard]: the normal glass theme.
 * - [ContrastLevel.increased]: the system's increased-contrast setting (Android contrast_level, iOS Increase Contrast).
 *   It keeps full colour, the accents, the ambient gradient and the glass; glass gets a little more frost and a
 *   slightly stronger rim. (Before 2026-10-24 the system setting switched the whole app to the solid theme, which
 *   users on contrast_level 1.0 saw as black and white with heavy borders.)
 * - [ContrastLevel.maximum]: only the in-app High contrast switch: the solid, opaque theme.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart' show highContrastProvider;
import 'app_theme.dart';

enum ContrastLevel { standard, increased, maximum }

/** The level for [inApp] (the app's High contrast switch) and [system] (the platform's contrast setting). */
ContrastLevel resolveContrastLevel({required bool inApp, required bool system}) =>
    inApp ? ContrastLevel.maximum : (system ? ContrastLevel.increased : ContrastLevel.standard);

/** The current level, from the app setting and the system setting. */
ContrastLevel contrastLevelOf(BuildContext context, WidgetRef ref) =>
    resolveContrastLevel(inApp: ref.watch(highContrastProvider), system: MediaQuery.maybeHighContrastOf(context) ?? false);

/**
 * Glass for [ContrastLevel.increased]: more frost (calmer, more even backdrop behind text), a slightly denser fill in
 * light themes and a stronger rim hairline. Dark fills stay as they are, because their fill is white and denser white
 * would lower the contrast of light text.
 */
GlassMaterial increasedContrastGlass(GlassMaterial g, {required bool dark}) {
  GlassLevel up(GlassLevel l) =>
      GlassLevel((l.frost + 0.2).clamp(0.0, 1.0), dark ? l.top : (l.top * 1.35).clamp(0.0, 1.0), dark ? l.bottom : (l.bottom * 1.35).clamp(0.0, 1.0));
  Color rim(Color c) => c.withValues(alpha: (c.a + 0.12).clamp(0.0, 1.0));
  return g.copyWith(levels: [for (final l in g.levels) up(l)], rimTop: rim(g.rimTop), rimBottom: rim(g.rimBottom));
}

/** Applies [ContrastLevel.increased] glass to [theme] (no change for the other levels). */
ThemeData themeForContrast(ThemeData theme, ContrastLevel level) {
  if (level != ContrastLevel.increased) return theme;
  final glass = theme.extension<GlassMaterial>();
  if (glass == null || glass.opaque) return theme;
  final dark = theme.brightness == Brightness.dark;
  return theme.copyWith(
    extensions: [
      for (final e in theme.extensions.values)
        if (e is GlassMaterial) increasedContrastGlass(e, dark: dark) else e,
    ],
  );
}
