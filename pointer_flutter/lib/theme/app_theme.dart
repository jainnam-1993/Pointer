import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette - deep purple/cosmic theme
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

/// App gradients
class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0A3A),
      Color(0xFF0F0524),
      Color(0xFF150A2E),
    ],
  );

  static const animatedColors = [
    Color(0xFF1A0A3A),
    Color(0xFF2D1B4E),
    Color(0xFF1A0A3A),
    Color(0xFF0F0524),
  ];
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
    );
  }
}
