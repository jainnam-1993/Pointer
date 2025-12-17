import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme mode options
enum AppThemeMode {
  light,
  dark,
  system;

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.dark,
    );
  }
}

/// Custom colors theme extension for Pointer app
/// Access via: Theme.of(context).extension<PointerColors>()!
@immutable
class PointerColors extends ThemeExtension<PointerColors> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color glassBorder;
  final Color glassBackground;
  final Color glassBorderActive;
  final Color gold;
  final Color iconColor;
  // Enhanced glass morphism properties
  final Color glassHighlight;
  final Color glassGlow;
  final Color shimmerColor;
  // High contrast mode specific
  final Color cardBackground;
  // Accent color for UI highlights
  final Color accent;

  const PointerColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.glassBorder,
    required this.glassBackground,
    required this.glassBorderActive,
    required this.gold,
    required this.iconColor,
    required this.glassHighlight,
    required this.glassGlow,
    required this.shimmerColor,
    this.cardBackground = const Color(0xFF1A1A1A),
    this.accent = const Color(0xFF8B5CF6), // Purple accent
  });

  /// Dark theme colors - Enhanced liquid glass morphism for black background
  static const dark = PointerColors(
    textPrimary: Colors.white,
    textSecondary: Color(0x99FFFFFF), // white with 0.6 alpha
    textMuted: Color(0x66FFFFFF), // white with 0.4 alpha
    glassBorder: Color(0x4DFFFFFF), // 30% opacity for visible liquid glass border
    glassBackground: Color(0x1AFFFFFF), // 10% opacity for glass fill
    glassBorderActive: Color(0x66FFFFFF), // 40% opacity for active state
    gold: Color(0xFFFFD700),
    iconColor: Colors.white,
    glassHighlight: Color(0x33FFFFFF), // Stronger top-left highlight
    glassGlow: Color(0x1A8B5CF6), // Subtle purple accent glow
    shimmerColor: Color(0x338B5CF6), // Purple shimmer accent
    cardBackground: Color(0xFF0A0A0A), // Near black for dark mode cards
  );

  /// Light theme colors
  static const light = PointerColors(
    textPrimary: Color(0xFF1F1F1F),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    glassBorder: Color(0x1A000000),
    glassBackground: Color(0x0D000000),
    glassBorderActive: Color(0x33000000),
    gold: Color(0xFFD97706),
    iconColor: Color(0xFF1F1F1F),
    glassHighlight: Color(0x80FFFFFF), // White highlight
    glassGlow: Color(0x0D7C3AED), // Subtle purple glow
    shimmerColor: Color(0x147C3AED), // Purple shimmer
    cardBackground: Color(0xFFFFFFFF), // White for light mode cards
  );

  /// High contrast theme colors - AAA compliant (7:1+ contrast ratio)
  /// Pure black background with pure white text for maximum readability
  static const highContrast = PointerColors(
    textPrimary: Colors.white,
    textSecondary: Colors.white,
    textMuted: Color(0xFFCCCCCC), // Light gray, still high contrast on black
    glassBorder: Colors.white, // Strong white border for clear boundaries
    glassBackground: Colors.black, // Solid black, no transparency
    glassBorderActive: Colors.white,
    gold: Color(0xFFFFD700),
    iconColor: Colors.white,
    glassHighlight: Colors.white,
    glassGlow: Colors.transparent, // No glow effects in high contrast
    shimmerColor: Colors.transparent, // No shimmer in high contrast
    cardBackground: Color(0xFF1A1A1A), // Solid dark gray for cards
  );

  /// OLED black mode - Pure black (#000000) for OLED displays
  /// Battery savings + eye comfort while maintaining glass aesthetic
  static const oled = PointerColors(
    textPrimary: Colors.white,
    textSecondary: Color(0xB3FFFFFF), // 70% white
    textMuted: Color(0x80FFFFFF), // 50% white
    glassBorder: Color(0x33FFFFFF), // 20% border for subtle glass effect
    glassBackground: Color(0x0DFFFFFF), // 5% glass fill - very subtle on black
    glassBorderActive: Color(0x4DFFFFFF), // 30% for active state
    gold: Color(0xFFFFD700),
    iconColor: Colors.white,
    glassHighlight: Color(0x1AFFFFFF), // Very subtle highlight
    glassGlow: Color(0x0D8B5CF6), // Minimal purple glow
    shimmerColor: Color(0x1A8B5CF6), // Subtle shimmer
    cardBackground: Colors.black, // Pure black for OLED
  );

  @override
  PointerColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? glassBorder,
    Color? glassBackground,
    Color? glassBorderActive,
    Color? gold,
    Color? iconColor,
    Color? glassHighlight,
    Color? glassGlow,
    Color? shimmerColor,
    Color? cardBackground,
    Color? accent,
  }) {
    return PointerColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorderActive: glassBorderActive ?? this.glassBorderActive,
      gold: gold ?? this.gold,
      iconColor: iconColor ?? this.iconColor,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      glassGlow: glassGlow ?? this.glassGlow,
      shimmerColor: shimmerColor ?? this.shimmerColor,
      cardBackground: cardBackground ?? this.cardBackground,
      accent: accent ?? this.accent,
    );
  }

  @override
  PointerColors lerp(ThemeExtension<PointerColors>? other, double t) {
    if (other is! PointerColors) return this;
    return PointerColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorderActive: Color.lerp(glassBorderActive, other.glassBorderActive, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      glassGlow: Color.lerp(glassGlow, other.glassGlow, t)!,
      shimmerColor: Color.lerp(shimmerColor, other.shimmerColor, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

/// App color palette - dark theme (deep black/cosmic)
/// @deprecated Use PointerColors extension instead
class AppColors {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF0A0A0A);
  static const primary = Color(0xFF8B5CF6);
  static const secondary = Color(0xFFEC4899);
  static const accent = Color(0xFF06B6D4);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFF666666);

  static const glassBorder = Color(0x40FFFFFF);
  static const glassBackground = Color(0x1AFFFFFF);
  static const glassBorderActive = Color(0x60FFFFFF);

  static const gold = Color(0xFFFFD700);
}

/// Light theme color palette
/// @deprecated Use PointerColors extension instead
class AppColorsLight {
  static const background = Color(0xFFF8F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF7C3AED);
  static const secondary = Color(0xFFDB2777);
  static const accent = Color(0xFF0891B2);

  static const textPrimary = Color(0xFF1F1F1F);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  static const glassBorder = Color(0x1A000000);
  static const glassBackground = Color(0x0D000000);
  static const glassBorderActive = Color(0x33000000);

  static const gold = Color(0xFFD97706);
}

/// App gradients - Enhanced for consistent liquid glass morphism feel
class AppGradients {
  /// Dark mode background gradient - Deep black with subtle color hints
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

  /// Light mode background gradient - Soft lavender
  static const backgroundLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF3E8FF),
      Color(0xFFF8F7FC),
      Color(0xFFEDE9FE),
    ],
  );

  /// Dark mode animated colors for shimmer effects
  static const animatedColors = [
    Color(0xFF0D0D0D),
    Color(0xFF1A1A1A),
    Color(0xFF050505),
    Color(0xFF0A0A0A),
  ];

  /// Light mode animated colors for shimmer effects
  static const animatedColorsLight = [
    Color(0xFFF3E8FF),
    Color(0xFFE9D5FF),
    Color(0xFFF3E8FF),
    Color(0xFFF8F7FC),
  ];

  /// Dark mode glass gradient for cards and overlays - Enhanced liquid glass
  static LinearGradient get glassDark => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Light mode glass gradient for cards and overlays
  static LinearGradient get glassLight => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.7),
          Colors.white.withValues(alpha: 0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// Scale-aware text styles for Dynamic Type / Accessibility support
///
/// These styles respect system text scale settings while clamping to
/// reasonable bounds (0.8x - 1.5x) to prevent layout breakage.
class AppTextStyles {
  /// Set to true in tests to use system fonts instead of Google Fonts.
  /// This avoids network requests and font loading issues in test environment.
  static bool useSystemFonts = false;

  /// Get the clamped text scale factor from MediaQuery
  static double _getClampedScale(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    // Scale a reference value of 1.0 to get the effective scale factor
    final scale = textScaler.scale(1.0);
    return scale.clamp(0.8, 1.5);
  }

  /// Main pointing text style - contemplative reading
  /// Base: 20pt, scales 16-30pt
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
    return GoogleFonts.inter(
      fontSize: 20 * scale,
      height: 1.7,
      letterSpacing: 0.3,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
    );
  }

  /// Instruction text style - subtle guidance
  /// Base: 16pt, scales 12.8-24pt
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

  /// Teacher attribution text style
  /// Base: 14pt, scales 11.2-21pt
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
    return GoogleFonts.inter(
      fontSize: 14 * scale,
      height: 1.5,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w500,
      color: colors.textMuted,
    );
  }

  /// Footer / hint text style
  /// Base: 12pt, scales 9.6-18pt
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
    return GoogleFonts.inter(
      fontSize: 12 * scale,
      height: 1.4,
      letterSpacing: 0.3,
      fontWeight: FontWeight.w400,
      color: colors.textMuted,
    );
  }

  /// Heading text style - for sheet/dialog titles
  /// Base: 24pt, scales 19.2-36pt
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
    return GoogleFonts.inter(
      fontSize: 24 * scale,
      height: 1.3,
      letterSpacing: -0.5,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }

  /// Body text style - for paragraphs and descriptions
  /// Base: 15pt, scales 12-22.5pt
  static TextStyle bodyText(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15 * scale,
        height: 1.6,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: 15 * scale,
      height: 1.6,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
    );
  }

  /// Section header text style - for section titles
  /// Base: 16pt, scales 12.8-24pt
  static TextStyle sectionHeader(BuildContext context) {
    final scale = _getClampedScale(context);
    final colors = Theme.of(context).extension<PointerColors>() ?? PointerColors.dark;
    if (useSystemFonts) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16 * scale,
        height: 1.4,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: 16 * scale,
      height: 1.4,
      letterSpacing: 0.3,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }
}

/// App theme configuration
class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: Color(0xFFEF4444),
      ),
      extensions: const [PointerColors.dark],
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColorsLight.background,
      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.primary,
        secondary: AppColorsLight.secondary,
        surface: AppColorsLight.surface,
        error: Color(0xFFDC2626),
      ),
      extensions: const [PointerColors.light],
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColorsLight.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColorsLight.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColorsLight.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColorsLight.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColorsLight.textMuted,
          letterSpacing: 1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColorsLight.primary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.primary.withValues(alpha: 0.4);
          }
          return AppColorsLight.textMuted.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  /// Get ThemeMode for MaterialApp
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

/// Extension to check if current theme is dark and access custom colors
extension ThemeCheck on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get PointerColors from current theme
  /// Usage: context.colors.textPrimary, context.colors.gold, etc.
  PointerColors get colors => Theme.of(this).extension<PointerColors>() ?? PointerColors.dark;
}
