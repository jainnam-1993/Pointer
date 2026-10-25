/**
 * Theme system for the Pointer app providing dark, light, high-contrast, and OLED color schemes.
 *
 * This file defines the complete visual identity: color palettes ([PointerColors]),
 * gradient backgrounds ([AppGradients]), accessibility-aware text styles ([AppTextStyles]),
 * Material [ThemeData] configurations ([AppTheme]), the glass material ([GlassMaterial]), the type scale ([AppType]), and layout spacing constants ([AppSpacing]).
 *
 * Access the active color scheme from any widget via the [ThemeCheck] extension:
 * ```dart
 * final bg = context.colors.background;
 * final isDark = context.isDarkMode;
 * ```
 */
library;

import 'package:flutter/material.dart';

import '../layout/adaptive.dart';

/**
 * User-facing theme mode selection persisted in [SharedPreferences].
 *
 * Converted to Flutter's [ThemeMode] via [AppTheme.toThemeMode] for use in
 * [MaterialApp.themeMode]. Serialized/deserialized by name with [fromString].
 */
enum AppThemeMode {
  /** Forces the light color scheme regardless of system setting. */
  light,

  /** Forces the dark color scheme regardless of system setting. */
  dark,

  /** Follows the platform brightness (default). */
  system;

  /**
   * Parses a persisted string back to an [AppThemeMode] value.
   *
   * Returns [AppThemeMode.system] if [value] does not match any variant name.
   */
  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere((e) => e.name == value, orElse: () => AppThemeMode.system);
  }
}

/**
 * Custom color palette registered as a [ThemeExtension] on [ThemeData].
 *
 * Four pre-built variants are available as static constants:
 * - [dark] -- default dark mode with liquid glass morphism.
 * - [light] -- subtle neutral tones inspired by Apple's design language.
 * - [highContrast] -- WCAG AAA (7:1+) compliant, solid backgrounds.
 * - [oled] -- pure-black surfaces for OLED battery savings.
 *
 * Prefer the [ThemeCheck.colors] shorthand (`context.colors`) over the
 * verbose `Theme.of(context).extension<PointerColors>()!` accessor.
 *
 * All colors support animated transitions between themes via [lerp].
 */
@immutable
class PointerColors extends ThemeExtension<PointerColors> {
  /** Primary background color for scaffolds and full-screen surfaces. */
  final Color background;

  /** Elevated surface color for cards, bottom sheets, and dialogs. */
  final Color surface;

  /** Brand primary color used for interactive elements and focus indicators. */
  final Color primary;

  /** Secondary brand color used for gradients and complementary accents. */
  final Color secondary;

  /** Highest-emphasis text color for headings and body content. */
  final Color textPrimary;

  /** Medium-emphasis text color for descriptions and supporting content. */
  final Color textSecondary;

  /** Lowest-emphasis text color for hints, captions, and disabled labels. */
  final Color textMuted;

  /** Border color for [GlassCard] and other glassmorphism containers at rest. */
  final Color glassBorder;

  /** Semi-transparent fill color for glassmorphism container backgrounds. */
  final Color glassBackground;

  /** Border color for glassmorphism containers in pressed or focused state. */
  final Color glassBorderActive;

  /** Decorative gold accent used for tradition highlights. */
  final Color gold;

  /** General-purpose accent color (violet) for buttons and interactive states. */
  final Color accent;

  /** Default tint for icons throughout the app. */
  final Color iconColor;

  /** Top-left highlight gradient stop inside glassmorphism cards. */
  final Color glassHighlight;

  /** Subtle outer glow applied behind glassmorphism containers. */
  final Color glassGlow;

  /** Color of the traveling shimmer highlight on [GlassCard] surfaces. */
  final Color shimmerColor;

  /** Opaque card background used in high-contrast mode where transparency is avoided. */
  final Color cardBackground;

  const PointerColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.glassBorder,
    required this.glassBackground,
    required this.glassBorderActive,
    required this.gold,
    required this.accent,
    required this.iconColor,
    required this.glassHighlight,
    required this.glassGlow,
    required this.shimmerColor,
    this.cardBackground = const Color(0xFF1A1A1A),
  });

  /**
   * Dark theme: sumi ink on black. The accent is the enso's indigo ink
   * (#1A0A3A) lifted to a readable lavender; text steps are opaque so contrast
   * holds on any glass (see test/theme/contrast_test.dart).
   */
  static const dark = PointerColors(
    background: Color(0xFF000000),
    surface: Color(0xFF0B0A10),
    primary: InkPalette.inkLavender,
    secondary: InkPalette.inkDusk,
    textPrimary: Color(0xFFF5F3FA),
    textSecondary: Color(0xFFC9C5D3),
    textMuted: Color(0xFFA8A3B3),
    glassBorder: Color(0x38FFFFFF),
    glassBackground: Color(0x1FFFFFFF),
    glassBorderActive: Color(0x5CFFFFFF),
    gold: Color(0xFFD9B26F),
    accent: InkPalette.inkLavender,
    iconColor: Color(0xFFF5F3FA),
    glassHighlight: Color(0x29FFFFFF),
    glassGlow: Color(0x14A597E0),
    shimmerColor: Color(0x29A597E0),
    cardBackground: Color(0xFF0B0A10),
  );

  /** Light theme: ink on warm paper. */
  /**
   * Light theme: "Sage and sand" (2026-10-24, main's default after the user asked for something other than pink).
   * Warm off-white paper, deep sage ink for accents and selection, muted warm gold as the rare secondary.
   */
  static const light = PointerColors(
    background: Color(0xFFF5F2EA),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF355C46),
    secondary: Color(0xFF6E6248),
    textPrimary: Color(0xFF1B1F1A),
    textSecondary: Color(0xFF3F463F),
    textMuted: Color(0xFF5F665E),
    glassBorder: Color(0x14000000),
    glassBackground: Color(0xCCFFFFFF),
    glassBorderActive: Color(0x24000000),
    gold: Color(0xFF8A6420),
    accent: Color(0xFF3F6B52),
    iconColor: Color(0xFF283028),
    glassHighlight: Color(0x99FFFFFF),
    glassGlow: Color(0x0A4E6A58),
    shimmerColor: Color(0x104E6A58),
    cardBackground: Color(0xFFFFFFFF),
  );

  /**
   * High contrast theme colors - AAA compliant (7:1+ contrast ratio)
   * Pure black background with pure white text for maximum readability
   */
  static const highContrast = PointerColors(
    background: Colors.black,
    surface: Color(0xFF1A1A1A),
    primary: Colors.white,
    secondary: Colors.white,
    textPrimary: Colors.white,
    textSecondary: Colors.white,
    textMuted: Color(0xFFCCCCCC),
    glassBorder: Colors.white,
    glassBackground: Colors.black,
    glassBorderActive: Colors.white,
    gold: Color(0xFFFFD700),
    accent: Color(0xFFD4CBF5),
    iconColor: Colors.white,
    glassHighlight: Colors.white,
    glassGlow: Colors.transparent,
    shimmerColor: Colors.transparent,
    cardBackground: Color(0xFF1A1A1A),
  );
  /**
   * Light high contrast: the light theme's paper and ink, pushed to AAA (7:1+).
   * Opaque white cards with near-black text and strong borders.
   */
  static const highContrastLight = PointerColors(
    background: Color(0xFFF6F4F1),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF0D0B12),
    secondary: Color(0xFF2B2536),
    textPrimary: Color(0xFF0D0B12),
    textSecondary: Color(0xFF1F1A28),
    textMuted: Color(0xFF2F2A38),
    glassBorder: Color(0xFF1A1622),
    glassBackground: Color(0xFFFFFFFF),
    glassBorderActive: Color(0xFF0D0B12),
    gold: Color(0xFF5E4210),
    accent: Color(0xFF2E2470),
    iconColor: Color(0xFF0D0B12),
    glassHighlight: Colors.transparent,
    glassGlow: Colors.transparent,
    shimmerColor: Colors.transparent,
    cardBackground: Color(0xFFFFFFFF),
  );

  /** OLED black mode: pure black surfaces, same ink palette as [dark]. */
  static const oled = PointerColors(
    background: Colors.black,
    surface: Colors.black,
    primary: InkPalette.inkLavender,
    secondary: InkPalette.inkDusk,
    textPrimary: Color(0xFFF5F3FA),
    textSecondary: Color(0xFFC9C5D3),
    textMuted: Color(0xFFA8A3B3),
    glassBorder: Color(0x2EFFFFFF),
    glassBackground: Color(0x0FFFFFFF),
    glassBorderActive: Color(0x4DFFFFFF),
    gold: Color(0xFFD9B26F),
    accent: InkPalette.inkLavender,
    iconColor: Color(0xFFF5F3FA),
    glassHighlight: Color(0x1AFFFFFF),
    glassGlow: Color(0x0DA597E0),
    shimmerColor: Color(0x1AA597E0),
    cardBackground: Colors.black,
  );

  @override
  PointerColors copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? glassBorder,
    Color? glassBackground,
    Color? glassBorderActive,
    Color? gold,
    Color? accent,
    Color? iconColor,
    Color? glassHighlight,
    Color? glassGlow,
    Color? shimmerColor,
    Color? cardBackground,
  }) {
    return PointerColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorderActive: glassBorderActive ?? this.glassBorderActive,
      gold: gold ?? this.gold,
      accent: accent ?? this.accent,
      iconColor: iconColor ?? this.iconColor,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      glassGlow: glassGlow ?? this.glassGlow,
      shimmerColor: shimmerColor ?? this.shimmerColor,
      cardBackground: cardBackground ?? this.cardBackground,
    );
  }

  @override
  PointerColors lerp(ThemeExtension<PointerColors>? other, double t) {
    if (other is! PointerColors) return this;
    return PointerColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorderActive: Color.lerp(glassBorderActive, other.glassBorderActive, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      glassGlow: Color.lerp(glassGlow, other.glassGlow, t)!,
      shimmerColor: Color.lerp(shimmerColor, other.shimmerColor, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }
}

/**
 * Brand hues derived from the enso mark's ink (#1A0A3A in assets/icons/enso_icon.svg).
 *
 * Replaces the stock Tailwind violet (#8B5CF6) and pink (#EC4899).
 */
class InkPalette {
  /** The enso ink itself: deep indigo, used for light-theme primary surfaces. */
  static const Color ink = Color(0xFF2A2238);

  /** Ink diluted for light-theme accents and links (9:1 on white). */
  static const Color inkDeep = Color(0xFF4B3D8F);

  /** Ink lifted for dark-theme accents (7:1 on black). */
  static const Color inkLavender = Color(0xFFA597E0);

  /** Softer companion hue for gradients. */
  static const Color inkDusk = Color(0xFF8E7CC3);
}

/** Frost amount and fill alphas for one glass intensity. */
@immutable
class GlassLevel {
  /** Analytic frost amount (0..1) handed to the ambient frost shader. */
  final double frost;

  /** Fill alpha at the top-left gradient stop. */
  final double top;

  /** Fill alpha at the bottom-right gradient stop. */
  final double bottom;

  const GlassLevel(this.frost, this.top, this.bottom);

  GlassLevel lerp(GlassLevel o, double t) => GlassLevel(frost + (o.frost - frost) * t, top + (o.top - top) * t, bottom + (o.bottom - bottom) * t);
}

/**
 * The one glass material: frost, fill, rim, highlight, and shadow tokens per theme.
 *
 * Feeds the analytic-frost glass in [GlassCard], [GlassButton], and
 * [GlassDialog]; read it with [GlassMaterial.of]. [levels] holds the light,
 * standard, and heavy intensities in that order; [onSurfaceLevels] are the
 * plain fills used where FrostScope suppresses frost (opaque sheets). Contrast for every text color over every fill is enforced by
 * test/theme/contrast_test.dart.
 */
@immutable
class GlassMaterial extends ThemeExtension<GlassMaterial> {
  /** Fill tint (alpha comes from [levels]). */
  final Color fill;

  /** Light, standard, heavy. */
  final List<GlassLevel> levels;

  /** Plain (unfrosted) fill per intensity where frost is suppressed (opaque sheets); frost is ignored. */
  final List<GlassLevel> onSurfaceLevels;

  /** Fill for primary and secondary [GlassButton]s. */
  final GlassLevel buttonPrimary;
  final GlassLevel buttonSecondary;

  /** Rim (border) color at the lit top-left edge. */
  final Color rimTop;

  /** Rim color at the bottom-right edge. */
  final Color rimBottom;

  /** Rim stroke width. */
  final double rimWidth;

  /** Top-edge sheen color (fades to transparent over [highlightExtent]). */
  final Color highlight;

  /** Fraction of the height the sheen covers. */
  final double highlightExtent;

  /** Drop shadow color. */
  final Color shadow;

  /** Drop shadow blur radius. */
  final double shadowBlur;

  /** Blur sigma for the few surfaces that still use a live backdrop blur (dialogs, toasts). */
  final double blurSigma;

  /** Whether the material is opaque (high contrast): no frost, solid fill. */
  final bool opaque;

  const GlassMaterial({
    required this.fill,
    required this.levels,
    required this.onSurfaceLevels,
    required this.buttonPrimary,
    required this.buttonSecondary,
    required this.rimTop,
    required this.rimBottom,
    this.rimWidth = 1.0,
    required this.highlight,
    this.highlightExtent = 0.35,
    required this.shadow,
    this.shadowBlur = 24,
    this.blurSigma = 30,
    this.opaque = false,
    this.primaryFill,
    this.onPrimary,
  });

  /** Primary button fill colour when it is not the glass fill (light theme: sage), and the label colour on it. */
  final Color? primaryFill;

  final Color? onPrimary;

  static const dark = GlassMaterial(
    fill: Colors.white,
    levels: [GlassLevel(0.6, 0.07, 0.03), GlassLevel(0.8, 0.10, 0.04), GlassLevel(1.0, 0.16, 0.07)],
    onSurfaceLevels: [GlassLevel(0, 0.10, 0.05), GlassLevel(0, 0.14, 0.07), GlassLevel(0, 0.18, 0.09)],
    buttonPrimary: GlassLevel(0.7, 0.30, 0.15),
    buttonSecondary: GlassLevel(0.7, 0.22, 0.10),
    // A top-weighted glass rim (about 15% fading to 6%), tuned to sit as quietly as
    // the light theme's warm hairline.
    rimTop: Color(0x3DFFFFFF),
    rimBottom: Color(0x0FFFFFFF),
    rimWidth: 1.5,
    highlight: Color(0x12FFFFFF),
    // One soft ambient lift (CalmGlassBrief): 25% black, wide blur, pulled in by the
    // spread so no solid core shows under the card's lower edge.
    shadow: Color(0x40000000),
    shadowBlur: 32,
    // The same filled lavender as Today's Inquire pill, so every primary action matches (Done, Continue).
    primaryFill: InkPalette.inkLavender,
    onPrimary: Color(0xFF24182C),
  );

  static const light = GlassMaterial(
    fill: Colors.white,
    levels: [GlassLevel(0.6, 0.16, 0.08), GlassLevel(0.8, 0.22, 0.12), GlassLevel(1.0, 0.34, 0.20)],
    onSurfaceLevels: [GlassLevel(0, 0.70, 0.45), GlassLevel(0, 0.85, 0.60), GlassLevel(0, 0.95, 0.75)],
    buttonPrimary: GlassLevel(0.7, 0.92, 0.65),
    buttonSecondary: GlassLevel(0.7, 0.85, 0.55),
    // A warm hairline at about 11% carries the card's edge on cream now that the
    // shadow is a soft lift, not a dark band (design panel, light mode).
    rimTop: Color(0x243A2A1A),
    rimBottom: Color(0x173A2A1A),
    highlight: Color(0x59FFFFFF),
    // A warm, just-visible lift (about 10%), so the cream card reads as raised.
    shadow: Color(0x2E4A3220),
    shadowBlur: 28,
    // Sage and sand: a filled sage primary button with white text (Continue, Done).
    primaryFill: Color(0xFF3F6B52),
    onPrimary: Color(0xFFFFFFFF),
  );

  static const oled = GlassMaterial(
    fill: Colors.white,
    levels: [GlassLevel(0.5, 0.05, 0.02), GlassLevel(0.7, 0.07, 0.03), GlassLevel(0.9, 0.11, 0.05)],
    onSurfaceLevels: [GlassLevel(0, 0.08, 0.04), GlassLevel(0, 0.12, 0.06), GlassLevel(0, 0.16, 0.08)],
    buttonPrimary: GlassLevel(0.6, 0.22, 0.10),
    buttonSecondary: GlassLevel(0.6, 0.15, 0.07),
    rimTop: Color(0x33FFFFFF),
    rimBottom: Color(0x0AFFFFFF),
    highlight: Color(0x0DFFFFFF),
    shadow: Colors.transparent,
    primaryFill: InkPalette.inkLavender,
    onPrimary: Color(0xFF24182C),
  );

  static const highContrast = GlassMaterial(
    fill: Color(0xFF1A1A1A),
    levels: [GlassLevel(0, 1, 1), GlassLevel(0, 1, 1), GlassLevel(0, 1, 1)],
    onSurfaceLevels: [GlassLevel(0, 1, 1), GlassLevel(0, 1, 1), GlassLevel(0, 1, 1)],
    buttonPrimary: GlassLevel(0, 1, 1),
    buttonSecondary: GlassLevel(0, 1, 1),
    rimTop: Colors.white,
    rimBottom: Colors.white,
    rimWidth: 2,
    highlight: Colors.transparent,
    shadow: Colors.transparent,
    blurSigma: 0,
    opaque: true,
  );
  /** Light high contrast: opaque white surfaces with a strong near-black rim. */
  static const highContrastLight = GlassMaterial(
    fill: Color(0xFFFFFFFF),
    levels: [GlassLevel(0, 1, 1), GlassLevel(0, 1, 1), GlassLevel(0, 1, 1)],
    onSurfaceLevels: [GlassLevel(0, 1, 1), GlassLevel(0, 1, 1), GlassLevel(0, 1, 1)],
    buttonPrimary: GlassLevel(0, 1, 1),
    buttonSecondary: GlassLevel(0, 1, 1),
    rimTop: Color(0xFF1A1622),
    rimBottom: Color(0xFF1A1622),
    rimWidth: 2,
    highlight: Colors.transparent,
    shadow: Colors.transparent,
    blurSigma: 0,
    opaque: true,
  );

  /**
   * Fill of a bottom sheet body (notification schedule, time picker): the app's own
   * surface, ink-tinted in dark, warm white in light, never a neutral grey. Text and
   * the plain glass levels on it are checked in test/theme/contrast_test.dart.
   */
  static Color sheetSurface(PointerColors colors) {
    if (identical(colors, PointerColors.dark)) return const Color(0xFA0C0A13);
    if (identical(colors, PointerColors.light)) return const Color(0xF0FFFDF8);
    return colors.surface;
  }

  /** Index of each intensity in [levels]. */
  static const int lightLevel = 0, standardLevel = 1, heavyLevel = 2;

  /** Legacy multipliers relative to the standard level (kept for older call sites). */
  static const double lightFactor = 0.7;
  static const double heavyFactor = 1.6;

  /** Resolves the material for [context]; [highContrast] forces the opaque variant. */
  static GlassMaterial of(BuildContext context, {bool highContrast = false}) {
    if (highContrast) return context.isDarkMode ? GlassMaterial.highContrast : GlassMaterial.highContrastLight;
    if (context.colors == PointerColors.oled) return GlassMaterial.oled;
    return Theme.of(context).extension<GlassMaterial>() ?? (context.isDarkMode ? GlassMaterial.dark : GlassMaterial.light);
  }

  /** Standard-level fill alphas. */
  double get fillTopAlpha => levels[standardLevel].top;
  double get fillBottomAlpha => levels[standardLevel].bottom;

  /** The frosted fill gradient for [level] (see [lightLevel], [standardLevel], [heavyLevel]). */
  LinearGradient fillAt(int level) => LinearGradient(
    colors: [
      fill.withValues(alpha: levels[level].top),
      fill.withValues(alpha: levels[level].bottom),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /** The fill gradient scaled from the standard level by [factor] (1.0 = standard). */
  LinearGradient fillFor([double factor = 1.0]) => LinearGradient(
    colors: [
      fill.withValues(alpha: (fillTopAlpha * factor).clamp(0.0, 1.0)),
      fill.withValues(alpha: (fillBottomAlpha * factor).clamp(0.0, 1.0)),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /** Plain fill for [level] where frost is suppressed (opaque sheets and dialogs). */
  LinearGradient onSurfaceAt(int level) => _gradient(onSurfaceLevels[level]);

  /** Button fill. */
  LinearGradient buttonFill({required bool primary}) => primary && primaryFill != null
      ? LinearGradient(colors: [primaryFill!, primaryFill!.withValues(alpha: 0.92)], begin: Alignment.topLeft, end: Alignment.bottomRight)
      : _gradient(primary ? buttonPrimary : buttonSecondary);

  LinearGradient _gradient(GlassLevel l) => LinearGradient(
    colors: [
      fill.withValues(alpha: l.top),
      fill.withValues(alpha: l.bottom),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /** The rim gradient with a custom lit color (fades to 30%). */
  LinearGradient rimWith(Color c) => LinearGradient(
    colors: [
      c,
      c.withValues(alpha: c.a * 0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /** The rim gradient, lit from the top-left. */
  /** Top-weighted rim: light catches the top edge and fades down the sides, as on iOS glass. */
  LinearGradient get rim =>
      LinearGradient(colors: [rimTop, rimBottom, rimBottom], stops: const [0, 0.5, 1], begin: Alignment.topCenter, end: Alignment.bottomCenter);

  /** Top-edge sheen painted behind card content. */
  LinearGradient get sheen => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, highlightExtent],
    colors: [highlight, highlight.withValues(alpha: 0)],
  );

  /** Drop shadows, empty when [shadow] is transparent. */
  /**
   * The card's one drop shadow. The negative spread keeps the shadow's solid core
   * inside the card's footprint, so only the soft blur shows below it; with
   * spread 0 and a 6 dp drop, the core showed as a hard dark lip under the card.
   */
  List<BoxShadow> get shadows =>
      shadow.a == 0 ? const [] : [BoxShadow(color: shadow, blurRadius: shadowBlur, offset: const Offset(0, 8), spreadRadius: -shadowBlur / 4)];

  @override
  GlassMaterial copyWith({Color? fill, List<GlassLevel>? levels, Color? rimTop, Color? rimBottom, Color? highlight, Color? shadow}) {
    return GlassMaterial(
      fill: fill ?? this.fill,
      levels: levels ?? this.levels,
      onSurfaceLevels: onSurfaceLevels,
      buttonPrimary: buttonPrimary,
      buttonSecondary: buttonSecondary,
      rimTop: rimTop ?? this.rimTop,
      rimBottom: rimBottom ?? this.rimBottom,
      rimWidth: rimWidth,
      highlight: highlight ?? this.highlight,
      highlightExtent: highlightExtent,
      shadow: shadow ?? this.shadow,
      shadowBlur: shadowBlur,
      blurSigma: blurSigma,
      opaque: opaque,
      primaryFill: primaryFill,
      onPrimary: onPrimary,
    );
  }

  @override
  GlassMaterial lerp(ThemeExtension<GlassMaterial>? other, double t) {
    if (other is! GlassMaterial) return this;
    double l(double a, double b) => a + (b - a) * t;
    return GlassMaterial(
      fill: Color.lerp(fill, other.fill, t)!,
      levels: [for (var i = 0; i < levels.length; i++) levels[i].lerp(other.levels[i], t)],
      onSurfaceLevels: [for (var i = 0; i < onSurfaceLevels.length; i++) onSurfaceLevels[i].lerp(other.onSurfaceLevels[i], t)],
      buttonPrimary: buttonPrimary.lerp(other.buttonPrimary, t),
      buttonSecondary: buttonSecondary.lerp(other.buttonSecondary, t),
      rimTop: Color.lerp(rimTop, other.rimTop, t)!,
      rimBottom: Color.lerp(rimBottom, other.rimBottom, t)!,
      rimWidth: l(rimWidth, other.rimWidth),
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightExtent: l(highlightExtent, other.highlightExtent),
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shadowBlur: l(shadowBlur, other.shadowBlur),
      blurSigma: l(blurSigma, other.blurSigma),
      opaque: t < 0.5 ? opaque : other.opaque,
      primaryFill: Color.lerp(primaryFill, other.primaryFill, t),
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t),
    );
  }
}

/**
 * Bundled font families (assets/fonts, OFL). No runtime fetching.
 */
class AppFonts {
  /** Refined serif for pointings and quotes. */
  static const String serif = 'Newsreader';

  /** UI sans. */
  static const String sans = 'Inter';
}

/**
 * The six-size type scale. Every shared style uses one of these sizes.
 *
 * Sizes are logical pixels before the user's text scale; [Text] applies the
 * scale once, clamped at the app root.
 */
class AppType {
  /** 28: pointings (serif). */
  static const double display = 28;

  /** The hero pointing one step up, on medium and expanded windows (iPad, unfolded phones). */
  static const double hero = 32;

  /** 22: screen titles and headings. */
  static const double title = 22;

  /** 18: card titles, quotes, instructions. */
  static const double headline = 18;

  /** 16: body copy and button labels. */
  static const double body = 16;

  /** 14: supporting text, attributions. */
  static const double callout = 14;

  /** 12: captions, section labels, footers. */
  static const double caption = 12;

  /** All six sizes, largest first. */
  static const List<double> scale = [display, title, headline, body, callout, caption];
}

/**
 * Pre-defined [LinearGradient] backgrounds and animated color sets for the liquid glass aesthetic.
 *
 * Provides separate dark and light variants for both static backgrounds and shimmer animation
 * color arrays used by [AnimatedGradient].
 */
class AppGradients {
  /** Dark mode background gradient - Deep black with subtle color hints */
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
    colors: [
      Color(0xFF0D0D0D), // Very dark gray at top
      Color(0xFF050505), // Near black
      Color(0xFF000000), // Pure black center
      Color(0xFF0A0A0A), // Subtle lift at bottom
    ],
  );

  /** Light mode background gradient - Subtle liquid glass */
  static const backgroundLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAFAFA), // Near white
      Color(0xFFF5F5F7), // Apple gray
      Color(0xFFEFEFF1), // Slightly darker edge
    ],
  );

  /** Dark mode animated colors for shimmer effects */
  static const animatedColors = [Color(0xFF0D0D0D), Color(0xFF1A1A1A), Color(0xFF050505), Color(0xFF0A0A0A)];

  /** Light mode animated colors for shimmer effects - Subtle neutral */
  static const animatedColorsLight = [Color(0xFFFAFAFA), Color(0xFFF0F0F2), Color(0xFFF5F5F7), Color(0xFFEDEDEF)];

  /** Dark mode glass gradient for cards and overlays - Enhanced liquid glass */
  static LinearGradient get glassDark => GlassMaterial.dark.fillFor();

  /** Light mode glass gradient for cards and overlays */
  static LinearGradient get glassLight => GlassMaterial.light.fillFor();
}

/**
 * Shared text styles on the [AppType] scale.
 *
 * Sizes are unscaled: [Text] applies the user's text scale once, and the app
 * root clamps it with [MediaQuery.withClampedTextScaling]. Do not multiply by
 * the text scale here or in callers (that scaled text twice).
 */
class AppTextStyles {
  /** Retained for older tests; fonts are bundled so there is nothing to switch. */
  static bool useSystemFonts = false;

  static PointerColors _colors(BuildContext context) => Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;

  /** Pointing text: Newsreader at [AppType.display] with a reading line height. */
  static TextStyle pointingText(BuildContext context) => TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: AppType.display,
    height: 1.36,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w400,
    color: _colors(context).textPrimary,
  );

  /**
   * The hero pointing on Home: [pointingText], one step up to [AppType.hero]
   * on medium and expanded windows, where the card has room for it.
   */
  static TextStyle heroPointingText(BuildContext context) =>
      pointingText(context).copyWith(fontSize: WindowLayout.of(context).sizeClass == WindowSizeClass.compact ? AppType.display : AppType.hero);

  /** Quote text: Newsreader italic at [AppType.headline]. */
  static TextStyle quoteText(BuildContext context) => TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: AppType.headline,
    height: 1.5,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    color: _colors(context).textSecondary,
  );

  /** Instruction text: quiet serif italic guidance. */
  static TextStyle instructionText(BuildContext context) => quoteText(context);

  /** Teacher attribution. */
  static TextStyle teacherText(BuildContext context) => TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: AppType.callout,
    height: 1.45,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w500,
    color: _colors(context).textMuted,
  );

  /** Footer and hint text. */
  static TextStyle footerText(BuildContext context) => TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: AppType.callout,
    height: 1.4,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w400,
    color: _colors(context).textSecondary,
  );

  /** Headings and screen titles. */
  static TextStyle heading(BuildContext context) => TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: AppType.title,
    height: 1.3,
    letterSpacing: -0.3,
    fontWeight: FontWeight.w600,
    color: _colors(context).textPrimary,
  );

  /** Body copy. */
  static TextStyle bodyText(BuildContext context) =>
      TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.body, height: 1.5, fontWeight: FontWeight.w400, color: _colors(context).textSecondary);

  /** Section labels. */
  static TextStyle sectionHeader(BuildContext context) => TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: AppType.caption,
    height: 1.4,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w600,
    color: _colors(context).textMuted,
  );

  /** Button labels. */
  static TextStyle buttonLabel(BuildContext context) =>
      TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.body, height: 1.25, fontWeight: FontWeight.w600, color: _colors(context).textPrimary);
}

/** Builds the Material [TextTheme] from the [AppType] scale. */
TextTheme _textTheme(TextTheme base, PointerColors colors) {
  return base
      .apply(fontFamily: AppFonts.sans, bodyColor: colors.textPrimary, displayColor: colors.textPrimary)
      .copyWith(
        displayLarge: TextStyle(fontFamily: AppFonts.serif, fontSize: AppType.display, height: 1.36, color: colors.textPrimary),
        headlineMedium: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: AppType.title,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.headline, fontWeight: FontWeight.w600, color: colors.textPrimary),
        bodyLarge: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.body, color: colors.textPrimary),
        bodyMedium: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.callout, color: colors.textSecondary),
        labelSmall: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: AppType.caption,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
          letterSpacing: 1,
        ),
      );
}

/**
 * Factory for complete [ThemeData] instances wired with [PointerColors], [GlassMaterial], bundled fonts, and
 * Material 3 component overrides (switches, app bar transparency).
 *
 * Usage in `MaterialApp`:
 * ```dart
 * MaterialApp(
 *   theme: AppTheme.light,
 *   darkTheme: AppTheme.dark,
 *   themeMode: AppTheme.toThemeMode(selectedMode),
 * )
 * ```
 */
class AppTheme {
  /** Dark [ThemeData]: bundled Inter, ink palette, one glass material, no ink splashes. */
  static ThemeData get dark {
    const colors = PointerColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.sans,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(primary: colors.primary, secondary: colors.secondary, surface: colors.surface, error: const Color(0xFFEF4444)),
      extensions: const [PointerColors.dark, GlassMaterial.dark],
      textTheme: _textTheme(ThemeData.dark().textTheme, colors),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accent;
          return colors.textMuted.withValues(alpha: 0.32);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /**
   * High-contrast themes follow light and dark mode and keep the app's style:
   * opaque surfaces instead of glass, strong rims, AAA text, a subdued ambient.
   * Used for the in-app High contrast setting and whenever the OS reports high
   * contrast (MaterialApp.highContrastTheme / highContrastDarkTheme; Flutter
   * 3.47+ reports Android's system contrast setting there).
   */
  static ThemeData get highContrastDark {
    const colors = PointerColors.highContrast;
    final base = dark;
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: base.colorScheme.copyWith(primary: colors.primary, secondary: colors.secondary, surface: colors.surface),
      extensions: const [PointerColors.highContrast, GlassMaterial.highContrast],
      textTheme: _textTheme(ThemeData.dark().textTheme, colors),
    );
  }

  /** Light high-contrast [ThemeData]; see [highContrastDark]. */
  static ThemeData get highContrastLight {
    const colors = PointerColors.highContrastLight;
    final base = light;
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: base.colorScheme.copyWith(primary: colors.primary, secondary: colors.secondary, surface: colors.surface),
      extensions: const [PointerColors.highContrastLight, GlassMaterial.highContrastLight],
      textTheme: _textTheme(ThemeData.light().textTheme, colors),
    );
  }

  /** Light [ThemeData]: bundled Inter, ink-on-paper palette, one glass material. */
  static ThemeData get light {
    const colors = PointerColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.sans,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(primary: colors.primary, secondary: colors.secondary, surface: colors.surface, error: const Color(0xFFB42318)),
      extensions: const [PointerColors.light, GlassMaterial.light],
      textTheme: _textTheme(ThemeData.light().textTheme, colors),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accent;
          return colors.textMuted.withValues(alpha: 0.32);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /** Converts the app's [AppThemeMode] to Flutter's [ThemeMode] for [MaterialApp.themeMode]. */
  static ThemeMode toThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/**
 * Convenience extension on [BuildContext] for theme introspection.
 *
 * Provides [isDarkMode] for branching on brightness and [colors] for direct
 * access to the active [PointerColors] palette without verbose `Theme.of` calls.
 */
extension ThemeCheck on BuildContext {
  /** Whether the current [ThemeData.brightness] is [Brightness.dark]. */
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /**
   * Get PointerColors from current theme
   * Usage: context.colors.textPrimary, context.colors.gold, etc.
   */
  PointerColors get colors => Theme.of(this).extension<PointerColors>() ?? PointerColors.dark;
}

/**
 * Tradition-specific accent colors for visual differentiation.
 *
 * Each spiritual tradition in the pointing database is mapped to a distinctive hue
 * so users can quickly recognize the source lineage in cards, badges, and share templates.
 */
class TraditionAccentColors {
  /** Gold/Orange accent for Advaita Vedanta tradition */
  static const Color advaita = Color(0xFFD4A574);

  /** Teal accent for Zen Buddhism tradition */
  static const Color zen = Color(0xFF4DD0E1);

  /** Purple accent for Direct Path tradition (matches app primary) */
  static const Color direct = InkPalette.inkLavender;

  /** Cyan/Teal accent for Contemporary teachings */
  static const Color contemporary = Color(0xFF06B6D4);

  /** Silver/White accent for Original content */
  static const Color original = Color(0xFFE0E0E0);

  // Light-theme variants in the sage-and-sand family (dark mode keeps the colours above). Each passes 4.5:1 on the
  // light glass so the level numbers stay readable.
  static const Color advaitaLight = Color(0xFF85652A); // sand
  static const Color zenLight = Color(0xFF3B6763); // teal-grey
  static const Color directLight = Color(0xFF4E6A58); // sage
  static const Color contemporaryLight = Color(0xFF4A5C6B); // slate
  static const Color originalLight = Color(0xFF5F6447); // olive
}

/**
 * Centralized spacing constants for consistent layout
 *
 * Usage: Replace hardcoded values with these constants
 * - EdgeInsets.all(AppSpacing.md) instead of EdgeInsets.all(16)
 * - SizedBox(height: AppSpacing.sm) instead of SizedBox(height: 12)
 *
 * Naming follows t-shirt sizing (xs, sm, md, lg, xl, xxl)
 * with semantic aliases for common use cases.
 */
/**
 * Tint opacities for selectable chips. Selection reads as an accent-tinted fill plus a check mark instead of a drawn
 * outline, so depth comes from the material and not from borders.
 */
class LiquidGlass {
  // Tab bar and rail geometry (CalmGlassBrief 3.2). The bar is a capsule: radius is half its height.

  /** Phone tab bar height. */
  static const double barHeight = 64;

  /** Tab bar height once minimized on scroll. */
  static const double barMinimizedHeight = 48;

  /** Widest the bar grows; wider windows centre it. */
  static const double barMaxWidth = 440;

  /** Gap between the bar and the screen edges. */
  static const double edgeMargin = 16;

  /** Gap between the bar and the bottom safe inset. */
  static const double safeGap = 8;

  /** Rail width (the content keeps [kRailWidth] of padding; the capsule is narrower). */
  static const double railWidth = 72;

  /** Rail inset from the left safe edge. */
  static const double railInset = 12;

  /** Rail cell height. */
  static const double railCellHeight = 64;

  /** Selection pill inset from the bar edge; the pill radius is the bar radius minus this (concentric). */
  static const double pillInset = 6;

  /** Selection pill is this much narrower than its cell. */
  static const double pillCellGap = 8;

  /** Minimized cell width (each icon gets this much). */
  static const double minimizedCell = 48;

  /** The one live blur behind the bar and rail (was 35; Liquid Glass is clearer so the field shows through). */
  static const double blurSigma = 14;

  /** Blur on OLED, where the field is mostly black. */
  static const double blurSigmaOled = 10;

  /** Largest stretch of the pill along its travel, and the speed (px/s) at which it is reached. */
  static const double stretchMax = 0.22;

  static const double stretchVelocity = 2400;

  /** Pill squash across its travel, as a fraction of the stretch. */
  static const double squash = 0.06;

  /** Press glow: peak radius, grow time and fade time. */
  static const double glowRadius = 72;

  static const Duration glowGrow = Duration(milliseconds: 240);

  static const Duration glowFade = Duration(milliseconds: 420);

  /** Scroll distances that minimize (down) and restore (up) the bar. */
  static const double minimizeAfter = 24;

  static const double restoreAfter = 12;

  /** Specular rim width. */
  static const double rimWidth = 1.25;

  /** How much the selection pill magnifies the icon and label under it. */
  static const double pillMagnify = 1.08;
}

class SelectionTint {
  /** Resting chip fill: text primary at this opacity. */
  static const double resting = 0.08;

  /** Selected chip fill in dark themes: accent at this opacity. */
  static const double selectedDark = 0.30;

  /** Selected chip fill in light themes: accent at this opacity. */
  static const double selectedLight = 0.16;

  /** The chip or tile fill for [selected], in place of an outline. */
  static Color fill(PointerColors colors, {required bool selected, required bool isDark}) =>
      selected ? colors.accent.withValues(alpha: isDark ? selectedDark : selectedLight) : colors.textPrimary.withValues(alpha: resting);
}

class AppSpacing {
  // -- Base spacing scale (8pt grid system) --

  /** 4.0 -- Tight spacing for icon gaps and inline elements. */
  static const double xs = 4.0;

  /** 8.0 -- Small spacing for compact list items and icon-to-text gaps. */
  static const double sm = 8.0;

  /** 12.0 -- Medium spacing for card internal padding and list item separation. */
  static const double md = 12.0;

  /** 16.0 -- Large spacing for section gaps and group separation. */
  static const double lg = 16.0;

  /** 24.0 -- Extra-large spacing for screen-edge padding and hero margins. */
  static const double xl = 24.0;

  /** 32.0 -- Maximum spacing for hero sections and prominent visual breaks. */
  static const double xxl = 32.0;

  // -- Semantic aliases --

  /** Horizontal padding at screen edges (24.0). Alias for [xl]. */
  static const double screenPadding = xl;

  /** Internal padding inside cards and modals (24.0). Alias for [xl]. */
  static const double cardPadding = xl;

  /** Vertical gap between content sections (16.0). Alias for [lg]. */
  static const double sectionGap = lg;

  /** Vertical gap between list items (12.0). Alias for [md]. */
  static const double itemGap = md;

  /** Horizontal gap between an icon and its label (8.0). Alias for [sm]. */
  static const double iconGap = sm;

  /** Bottom inset to clear the floating navigation bar (120.0). */
  static const double navBarOffset = 120.0;

  /** Minimum hit size for any control (44.0, Apple HIG; Android's 48 dp comes from Material's tap target padding). */
  static const double minTouchTarget = 44.0;

  /** Capsule radius for chips and pill controls; half of [minTouchTarget] so a one-line chip is a true capsule. */
  static const double radiusPill = minTouchTarget / 2;

  /** Chip insets: horizontal [lg], vertical [sm], so a one-line chip lands on [minTouchTarget] with the root text clamp. */
  static const EdgeInsets chip = EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  // -- Border radius constants --

  /** Small border radius (8.0) for chips and tags. */
  static const double radiusSm = 8.0;

  /** Medium border radius (12.0) for buttons and small cards. */
  static const double radiusMd = 12.0;

  /** Large border radius (16.0) for modals and bottom sheets. */
  static const double radiusLg = 16.0;

  /** Extra-large border radius (24.0) for prominent containers. */
  static const double radiusXl = 24.0;

  /** Default border radius for [GlassCard] and similar card widgets (24.0). */
  static const double radiusCard = 24.0;

  // -- Common EdgeInsets presets --

  /** Symmetric horizontal screen padding ([xl] on left and right). */
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: xl);

  /** Uniform screen padding ([xl] on all sides). */
  static const EdgeInsets screenAll = EdgeInsets.all(xl);

  /** Uniform card internal padding ([xl] on all sides). */
  static const EdgeInsets cardAll = EdgeInsets.all(xl);

  /** Standard list item padding (horizontal [xl], vertical [md]). */
  static const EdgeInsets listItem = EdgeInsets.symmetric(horizontal: xl, vertical: md);
}
