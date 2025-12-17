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
  });

  /// Dark theme colors - Enhanced glass morphism
  static const dark = PointerColors(
    textPrimary: Colors.white,
    textSecondary: Color(0x99FFFFFF), // white with 0.6 alpha
    textMuted: Color(0x66FFFFFF), // white with 0.4 alpha
    glassBorder: Color(0x33FFFFFF), // Increased from 0x26 for visibility
    glassBackground: Color(0x15FFFFFF), // Increased from 0x0D for glass effect
    glassBorderActive: Color(0x50FFFFFF), // Increased from 0x40
    gold: Color(0xFFFFD700),
    iconColor: Colors.white,
    glassHighlight: Color(0x26FFFFFF), // Top-left highlight
    glassGlow: Color(0x0D8B5CF6), // Subtle purple glow
    shimmerColor: Color(0x268B5CF6), // Purple shimmer
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
    );
  }
}

/// App color palette - dark theme (deep purple/cosmic)
/// @deprecated Use PointerColors extension instead
class AppColors {
  static const background = Color(0xFF0F0524);
  static const surface = Color(0xFF1A0A3A);
  static const primary = Color(0xFF8B5CF6);
  static const secondary = Color(0xFFEC4899);
  static const accent = Color(0xFF06B6D4);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFF666666);

  static const glassBorder = Color(0x26FFFFFF);
  static const glassBackground = Color(0x0DFFFFFF);
  static const glassBorderActive = Color(0x40FFFFFF);

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

/// App gradients - Enhanced for consistent glass morphism feel
class AppGradients {
  /// Dark mode background gradient - Rich purple depths
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.6, 1.0],
    colors: [
      Color(0xFF2D1B4E), // Rich purple at top
      Color(0xFF1A0A3A), // Deep violet
      Color(0xFF0F0524), // Dark base
      Color(0xFF1E1145), // Subtle purple glow at bottom
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
    Color(0xFF2D1B4E),
    Color(0xFF3D2B5E),
    Color(0xFF1A0A3A),
    Color(0xFF1E1145),
  ];

  /// Light mode animated colors for shimmer effects
  static const animatedColorsLight = [
    Color(0xFFF3E8FF),
    Color(0xFFE9D5FF),
    Color(0xFFF3E8FF),
    Color(0xFFF8F7FC),
  ];

  /// Dark mode glass gradient for cards and overlays
  static LinearGradient get glassDark => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.05),
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
