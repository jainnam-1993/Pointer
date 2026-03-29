/**
 * Theme system for the Pointer app providing dark, light, high-contrast, and OLED color schemes.
 *
 * This file defines the complete visual identity: color palettes ([PointerColors]),
 * gradient backgrounds ([AppGradients]), accessibility-aware text styles ([AppTextStyles]),
 * Material [ThemeData] configurations ([AppTheme]), and layout spacing constants ([AppSpacing]).
 *
 * Access the active color scheme from any widget via the [ThemeCheck] extension:
 * ```dart
 * final bg = context.colors.background;
 * final isDark = context.isDarkMode;
 * ```
 */
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  /** Dark theme colors - Enhanced liquid glass morphism for black background */
  static const dark = PointerColors(
    background: Color(0xFF000000),
    surface: Color(0xFF0A0A0A),
    primary: Color(0xFF8B5CF6),
    secondary: Color(0xFFEC4899),
    textPrimary: Colors.white,
    textSecondary: Color(0x99FFFFFF), // white with 0.6 alpha
    textMuted: Color(0x99FFFFFF), // white with 0.6 alpha
    glassBorder: Color(0x4DFFFFFF), // 30% opacity for visible liquid glass border
    glassBackground: Color(0x1AFFFFFF), // 10% opacity for glass fill
    glassBorderActive: Color(0x66FFFFFF), // 40% opacity for active state
    gold: Color(0xFFFFD700),
    accent: Color(0xFF8B5CF6), // Violet accent
    iconColor: Colors.white,
    glassHighlight: Color(0x33FFFFFF), // Stronger top-left highlight
    glassGlow: Color(0x1A8B5CF6), // Subtle purple accent glow
    shimmerColor: Color(0x338B5CF6), // Purple shimmer accent
    cardBackground: Color(0xFF0A0A0A), // Near black for dark mode cards
  );

  /** Light theme colors - Subtle liquid glass aesthetic */
  static const light = PointerColors(
    background: Color(0xFFF5F5F7), // Apple-style neutral gray
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF5B5B5B), // Neutral dark gray
    secondary: Color(0xFF8E8E93), // iOS gray
    textPrimary: Color(0xFF1C1C1E), // Near black
    textSecondary: Color(0xFF636366), // Medium gray
    textMuted: Color(0xFF8E8E93), // iOS gray
    glassBorder: Color(0x15000000), // Very subtle border
    glassBackground: Color(0x08FFFFFF), // Frosted glass fill
    glassBorderActive: Color(0x22000000),
    gold: Color(0xFFB8860B), // Darker gold
    accent: Color(0xFF8B5CF6), // Violet accent
    iconColor: Color(0xFF3C3C43), // Dark gray icons
    glassHighlight: Color(0x60FFFFFF), // Soft white highlight
    glassGlow: Color(0x088B5CF6), // Subtle violet glow
    shimmerColor: Color(0x108B5CF6), // Violet shimmer
    cardBackground: Color(0xFFFFFFFF), // Pure white cards
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
    textMuted: Color(0xFFCCCCCC), // Light gray, still high contrast on black
    glassBorder: Colors.white, // Strong white border for clear boundaries
    glassBackground: Colors.black, // Solid black, no transparency
    glassBorderActive: Colors.white,
    gold: Color(0xFFFFD700),
    accent: Color(0xFF8B5CF6), // Violet accent
    iconColor: Colors.white,
    glassHighlight: Colors.white,
    glassGlow: Colors.transparent, // No glow effects in high contrast
    shimmerColor: Colors.transparent, // No shimmer in high contrast
    cardBackground: Color(0xFF1A1A1A), // Solid dark gray for cards
  );

  /**
   * OLED black mode - Pure black (#000000) for OLED displays
   * Battery savings + eye comfort while maintaining glass aesthetic
   */
  static const oled = PointerColors(
    background: Colors.black,
    surface: Colors.black,
    primary: Color(0xFF8B5CF6),
    secondary: Color(0xFFEC4899),
    textPrimary: Colors.white,
    textSecondary: Color(0xB3FFFFFF), // 70% white
    textMuted: Color(0x80FFFFFF), // 50% white
    glassBorder: Color(0x33FFFFFF), // 20% border for subtle glass effect
    glassBackground: Color(0x0DFFFFFF), // 5% glass fill - very subtle on black
    glassBorderActive: Color(0x4DFFFFFF), // 30% for active state
    gold: Color(0xFFFFD700),
    accent: Color(0xFF8B5CF6), // Violet accent
    iconColor: Colors.white,
    glassHighlight: Color(0x1AFFFFFF), // Very subtle highlight
    glassGlow: Color(0x0D8B5CF6), // Minimal purple glow
    shimmerColor: Color(0x1A8B5CF6), // Subtle shimmer
    cardBackground: Colors.black, // Pure black for OLED
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
  static LinearGradient get glassDark => LinearGradient(
    colors: [Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.08)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /** Light mode glass gradient for cards and overlays */
  static LinearGradient get glassLight => LinearGradient(
    colors: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0.4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/**
 * Scale-aware text styles for Dynamic Type / Accessibility support
 *
 * These styles respect system text scale settings while clamping to
 * reasonable bounds (0.8x - 1.5x) to prevent layout breakage.
 */
class AppTextStyles {
  /**
   * Set to true in tests to use system fonts instead of Google Fonts.
   * This avoids network requests and font loading issues in test environment.
   */
  static bool useSystemFonts = false;

  /** Get the clamped text scale factor from MediaQuery */
  static double _getClampedScale(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    // Scale a reference value of 1.0 to get the effective scale factor
    final scale = textScaler.scale(1.0);
    return scale.clamp(0.8, 1.5);
  }

  /**
   * Main pointing text style - contemplative reading
   * Base: 20pt, scales 16-30pt
   */
  static TextStyle pointingText(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20 * scale,
        height: 1.7,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      );
    }
    return GoogleFonts.inter(fontSize: 20 * scale, height: 1.7, letterSpacing: 0.3, fontWeight: FontWeight.w400, color: colors.textPrimary);
  }

  /**
   * Instruction text style - subtle guidance
   * Base: 16pt, scales 12.8-24pt
   */
  static TextStyle instructionText(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16 * scale,
        height: 1.6,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        color: colors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: 16 * scale,
      height: 1.6,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.italic,
      color: colors.textSecondary,
    );
  }

  /**
   * Teacher attribution text style
   * Base: 14pt, scales 11.2-21pt
   */
  static TextStyle teacherText(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14 * scale,
        height: 1.5,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
        color: colors.textMuted,
      );
    }
    return GoogleFonts.inter(fontSize: 14 * scale, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.w500, color: colors.textMuted);
  }

  /**
   * Footer / hint text style
   * Base: 12pt, scales 9.6-18pt
   */
  static TextStyle footerText(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12 * scale,
        height: 1.4,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
        color: colors.textMuted,
      );
    }
    return GoogleFonts.inter(fontSize: 12 * scale, height: 1.4, letterSpacing: 0.3, fontWeight: FontWeight.w400, color: colors.textMuted);
  }

  /**
   * Heading text style - for titles and headers
   * Base: 24pt, scales 19-36pt
   */
  static TextStyle heading(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24 * scale,
        height: 1.3,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      );
    }
    return GoogleFonts.inter(fontSize: 24 * scale, height: 1.3, letterSpacing: -0.5, fontWeight: FontWeight.w600, color: colors.textPrimary);
  }

  /**
   * Body text style - for content and descriptions
   * Base: 16pt, scales 13-24pt
   */
  static TextStyle bodyText(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16 * scale,
        height: 1.5,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      );
    }
    return GoogleFonts.inter(fontSize: 16 * scale, height: 1.5, letterSpacing: 0.1, fontWeight: FontWeight.w400, color: colors.textSecondary);
  }

  /**
   * Section header text style - for section titles
   * Base: 14pt, scales 11-21pt
   */
  static TextStyle sectionHeader(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14 * scale,
        height: 1.4,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
        color: colors.textMuted,
      );
    }
    return GoogleFonts.inter(fontSize: 14 * scale, height: 1.4, letterSpacing: 0.5, fontWeight: FontWeight.w600, color: colors.textMuted);
  }
}

/**
 * Factory for complete [ThemeData] instances wired with [PointerColors], [GoogleFonts], and
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
  /** Dark [ThemeData] using [PointerColors.dark] with Inter font family and transparent app bars. */
  static ThemeData get dark {
    const colors = PointerColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(primary: colors.primary, secondary: colors.secondary, surface: colors.surface, error: const Color(0xFFEF4444)),
      extensions: const [PointerColors.dark],
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white.withValues(alpha: 0.4);
          }
          return Colors.white.withValues(alpha: 0.2);
        }),
      ),
    );
  }

  /** Light [ThemeData] using [PointerColors.light] with Inter font family and transparent app bars. */
  static ThemeData get light {
    const colors = PointerColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(primary: colors.primary, secondary: colors.secondary, surface: colors.surface, error: const Color(0xFFDC2626)),
      extensions: const [PointerColors.light],
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: colors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(colors.primary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.4);
          }
          return colors.textMuted.withValues(alpha: 0.3);
        }),
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
  static const Color direct = Color(0xFF8B5CF6);

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
