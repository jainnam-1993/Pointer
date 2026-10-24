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
  static const light = PointerColors(
    background: Color(0xFFF6F4F1),
    surface: Color(0xFFFFFFFF),
    primary: InkPalette.ink,
    secondary: Color(0xFF6F6585),
    textPrimary: Color(0xFF1A1622),
    textSecondary: Color(0xFF45404F),
    textMuted: Color(0xFF69636F),
    glassBorder: Color(0x14000000),
    glassBackground: Color(0xCCFFFFFF),
    glassBorderActive: Color(0x24000000),
    gold: Color(0xFF8A6420),
    accent: InkPalette.inkDeep,
    iconColor: Color(0xFF2A2533),
    glassHighlight: Color(0x99FFFFFF),
    glassGlow: Color(0x0A4B3D8F),
    shimmerColor: Color(0x104B3D8F),
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
 * standard, and heavy intensities in that order. [onSurfaceTop] and
 * [onSurfaceBottom] are the plain fill used where frost is suppressed (opaque
 * sheets). Contrast for every text color over every fill is enforced by
 * test/theme/contrast_test.dart.
 */
@immutable
class GlassMaterial extends ThemeExtension<GlassMaterial> {
  /** Fill tint (alpha comes from [levels]). */
  final Color fill;

  /** Light, standard, heavy. */
  final List<GlassLevel> levels;

  /** Plain fill at the top-left when frost is suppressed. */
  final Color onSurfaceTop;

  /** Plain fill at the bottom-right when frost is suppressed. */
  final Color onSurfaceBottom;

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
    required this.onSurfaceTop,
    required this.onSurfaceBottom,
    required this.rimTop,
    required this.rimBottom,
    this.rimWidth = 1.0,
    required this.highlight,
    this.highlightExtent = 0.35,
    required this.shadow,
    this.shadowBlur = 24,
    this.blurSigma = 30,
    this.opaque = false,
  });

  static const dark = GlassMaterial(
    fill: Colors.white,
    levels: [GlassLevel(0.6, 0.07, 0.03), GlassLevel(0.8, 0.10, 0.04), GlassLevel(1.0, 0.16, 0.07)],
    onSurfaceTop: Color(0x24FFFFFF),
    onSurfaceBottom: Color(0x0FFFFFFF),
    rimTop: Color(0x47FFFFFF),
    rimBottom: Color(0x0FFFFFFF),
    highlight: Color(0x12FFFFFF),
    shadow: Color(0x52000000),
  );

  static const light = GlassMaterial(
    fill: Colors.white,
    levels: [GlassLevel(0.6, 0.16, 0.08), GlassLevel(0.8, 0.22, 0.12), GlassLevel(1.0, 0.34, 0.20)],
    onSurfaceTop: Color(0x091A0A3A),
    onSurfaceBottom: Color(0x051A0A3A),
    rimTop: Color(0x14000000),
    rimBottom: Color(0x08000000),
    highlight: Color(0x59FFFFFF),
    shadow: Color(0x141A0A3A),
    shadowBlur: 20,
  );

  static const oled = GlassMaterial(
    fill: Colors.white,
    levels: [GlassLevel(0.5, 0.05, 0.02), GlassLevel(0.7, 0.07, 0.03), GlassLevel(0.9, 0.11, 0.05)],
    onSurfaceTop: Color(0x1AFFFFFF),
    onSurfaceBottom: Color(0x0AFFFFFF),
    rimTop: Color(0x33FFFFFF),
    rimBottom: Color(0x0AFFFFFF),
    highlight: Color(0x0DFFFFFF),
    shadow: Colors.transparent,
  );

  static const highContrast = GlassMaterial(
    fill: Color(0xFF1A1A1A),
    levels: [GlassLevel(0, 1, 1), GlassLevel(0, 1, 1), GlassLevel(0, 1, 1)],
    onSurfaceTop: Color(0xFF1A1A1A),
    onSurfaceBottom: Color(0xFF1A1A1A),
    rimTop: Colors.white,
    rimBottom: Colors.white,
    rimWidth: 2,
    highlight: Colors.transparent,
    shadow: Colors.transparent,
    blurSigma: 0,
    opaque: true,
  );

  /** Index of each intensity in [levels]. */
  static const int lightLevel = 0, standardLevel = 1, heavyLevel = 2;

  /** Legacy multipliers relative to the standard level (kept for older call sites). */
  static const double lightFactor = 0.7;
  static const double heavyFactor = 1.6;

  /** Resolves the material for [context]; [highContrast] forces the opaque variant. */
  static GlassMaterial of(BuildContext context, {bool highContrast = false}) {
    if (highContrast) return GlassMaterial.highContrast;
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

  /** Plain fill used where frost is suppressed (opaque sheets and dialogs). */
  LinearGradient get onSurfaceFill => LinearGradient(colors: [onSurfaceTop, onSurfaceBottom], begin: Alignment.topLeft, end: Alignment.bottomRight);

  /** The rim gradient, lit from the top-left. */
  LinearGradient get rim => LinearGradient(colors: [rimTop, rimBottom], begin: Alignment.topLeft, end: Alignment.bottomRight);

  /** Top-edge sheen as a foreground gradient. */
  LinearGradient get sheen => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, highlightExtent],
    colors: [highlight, highlight.withValues(alpha: 0)],
  );

  /** Drop shadows, empty when [shadow] is transparent. */
  List<BoxShadow> get shadows => shadow.a == 0 ? const [] : [BoxShadow(color: shadow, blurRadius: shadowBlur, offset: const Offset(0, 6))];

  @override
  GlassMaterial copyWith({Color? fill, List<GlassLevel>? levels, Color? rimTop, Color? rimBottom, Color? highlight, Color? shadow}) {
    return GlassMaterial(
      fill: fill ?? this.fill,
      levels: levels ?? this.levels,
      onSurfaceTop: onSurfaceTop,
      onSurfaceBottom: onSurfaceBottom,
      rimTop: rimTop ?? this.rimTop,
      rimBottom: rimBottom ?? this.rimBottom,
      rimWidth: rimWidth,
      highlight: highlight ?? this.highlight,
      highlightExtent: highlightExtent,
      shadow: shadow ?? this.shadow,
      shadowBlur: shadowBlur,
      blurSigma: blurSigma,
      opaque: opaque,
    );
  }

  @override
  GlassMaterial lerp(ThemeExtension<GlassMaterial>? other, double t) {
    if (other is! GlassMaterial) return this;
    double l(double a, double b) => a + (b - a) * t;
    return GlassMaterial(
      fill: Color.lerp(fill, other.fill, t)!,
      levels: [for (var i = 0; i < levels.length; i++) levels[i].lerp(other.levels[i], t)],
      onSurfaceTop: Color.lerp(onSurfaceTop, other.onSurfaceTop, t)!,
      onSurfaceBottom: Color.lerp(onSurfaceBottom, other.onSurfaceBottom, t)!,
      rimTop: Color.lerp(rimTop, other.rimTop, t)!,
      rimBottom: Color.lerp(rimBottom, other.rimBottom, t)!,
      rimWidth: l(rimWidth, other.rimWidth),
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightExtent: l(highlightExtent, other.highlightExtent),
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shadowBlur: l(shadowBlur, other.shadowBlur),
      blurSigma: l(blurSigma, other.blurSigma),
      opaque: t < 0.5 ? opaque : other.opaque,
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
    fontSize: AppType.caption,
    height: 1.4,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w400,
    color: _colors(context).textMuted,
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
