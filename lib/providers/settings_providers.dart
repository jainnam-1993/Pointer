/// Settings providers - User preferences, accessibility, and appearance
///
/// Includes: Zen mode, OLED mode, typography, accessibility (reduced motion,
/// high contrast), theme mode, and notification settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import 'core_providers.dart';

// ============================================================
// Auto-Advance - Automatic pointing rotation
// ============================================================

/// Auto-advance enabled provider - pointings advance automatically
/// Default: ON (opt-out model for dynamic experience)
final autoAdvanceProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.autoAdvance;
});

/// Auto-advance delay in seconds (default: 60)
final autoAdvanceDelayProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.autoAdvanceDelay;
});

// ============================================================
// Zen Mode - Distraction-free reading
// ============================================================

/// Zen mode provider - hides all UI except pointing text
/// Initialized from stored settings for persistence across sessions
final zenModeProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.zenMode;
});

// ============================================================
// Typography Customization
// ============================================================

// ============================================================
// OLED Black Mode - True black for OLED displays
// ============================================================

/// OLED mode provider - pure black background for battery savings
final oledModeProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.oledMode;
});

// ============================================================
// Accessibility - Reduced Motion
// ============================================================

/// App-level override for reduce motion setting, derived from animationsEnabled.
///
/// - `null`: Follow system setting (animationsEnabled == true)
/// - `true`: Force reduce motion ON (animationsEnabled == false)
///
/// Note: When system disableAnimations is true, we always respect it.
/// The app override can only enable reduce motion, not disable it when
/// the system requires it for accessibility.
final reduceMotionOverrideProvider = Provider<bool?>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.animationsEnabled ? null : true;
});

/// Helper function to determine if motion should be reduced.
///
/// Returns true if:
/// - System disableAnimations is enabled (MediaQuery.disableAnimations), OR
/// - App override is set to true
///
/// The system setting always takes precedence when it requires reduced motion.
bool shouldReduceMotion(BuildContext context, bool? appOverride) {
  final systemReduceMotion = MediaQuery.of(context).disableAnimations;

  // System accessibility setting always takes precedence
  if (systemReduceMotion) {
    return true;
  }

  // App override can enable reduce motion (but not disable system setting)
  return appOverride == true;
}

/// Whether background gradient shimmer is active (for GlassCard optimization).
/// When true, GlassCard skips its own breathing shimmer to avoid redundant GPU work.
final backgroundShimmerActiveProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.animationsEnabled && !AnimatedGradient.disableAnimations;
});

// ============================================================
// Accessibility - High Contrast
// ============================================================

/// High contrast mode provider
/// Initialized from stored settings, can be toggled manually or detected via system preference
final highContrastProvider = StateProvider<bool>((ref) {
  // Initialize from stored settings
  final settings = ref.watch(settingsProvider);
  return settings.highContrast;
});

/// Helper to check if high contrast is enabled (either via provider or system setting)
/// Usage: isHighContrastEnabled(context, ref)
bool isHighContrastEnabled(BuildContext context, WidgetRef ref) {
  final providerEnabled = ref.watch(highContrastProvider);
  final systemEnabled = MediaQuery.of(context).highContrast;
  return providerEnabled || systemEnabled;
}

// ============================================================
// App Settings State
// ============================================================

/// Settings provider - manages AppSettings state
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(_storage.settings);

  Future<void> update(AppSettings newSettings) async {
    await _storage.updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> setTheme(AppThemeMode mode) async {
    final newSettings = state.copyWith(theme: mode.name);
    await update(newSettings);
  }

  /// Toggle high contrast mode
  Future<void> setHighContrast(bool enabled) async {
    final newSettings = state.copyWith(highContrast: enabled);
    await update(newSettings);
  }

  /// Toggle zen mode
  Future<void> setZenMode(bool enabled) async {
    final newSettings = state.copyWith(zenMode: enabled);
    await update(newSettings);
  }

  /// Toggle auto-advance
  Future<void> setAutoAdvance(bool enabled) async {
    final newSettings = state.copyWith(autoAdvance: enabled);
    await update(newSettings);
  }

  /// Set auto-advance delay (in seconds)
  Future<void> setAutoAdvanceDelay(int seconds) async {
    final newSettings = state.copyWith(autoAdvanceDelay: seconds);
    await update(newSettings);
  }

  /// Toggle background animations
  Future<void> setAnimationsEnabled(bool enabled) async {
    final newSettings = state.copyWith(animationsEnabled: enabled);
    await update(newSettings);
  }
}

// ============================================================
// Theme Mode Providers
// ============================================================

/// Theme mode provider - derives from settings
final themeModeProvider = Provider<AppThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppThemeMode.fromString(settings.theme);
});

/// Flutter ThemeMode provider for MaterialApp
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeModeProvider);
  return AppTheme.toThemeMode(appThemeMode);
});

