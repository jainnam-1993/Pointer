// App Theme - Minimal stub for testing
//
// This is a minimal implementation to allow tests to run.
// Full theme implementation exists in the main branch.

import 'package:flutter/material.dart';

/// App Text Styles configuration
class AppTextStyles {
  /// Flag to use system fonts instead of Google Fonts
  /// Useful for testing where network fonts aren't available
  static bool useSystemFonts = false;
}

/// Theme mode options
enum AppThemeMode {
  system,
  light,
  dark,
}

/// App Theme utility class
class AppTheme {
  /// Convert AppThemeMode to Flutter ThemeMode
  static ThemeMode toThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}
