/// Settings providers - User preferences, accessibility, and appearance
///
/// Includes: Zen mode, OLED mode, typography, accessibility (reduced motion,
/// high contrast), theme mode, and notification settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'core_providers.dart';

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

/// Font size multiplier (1.0 = default, 0.8-1.4 range)
final fontSizeMultiplierProvider = StateProvider<double>((ref) => 1.0);

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

/// Optional app-level override for reduce motion setting.
///
/// - `null`: Follow system setting (default)
/// - `true`: Force reduce motion ON (app setting can enable)
/// - `false`: Follow system setting (app cannot override system accessibility)
///
/// Note: When system disableAnimations is true, we always respect it.
/// The app override can only enable reduce motion, not disable it when
/// the system requires it for accessibility.
final reduceMotionOverrideProvider = StateProvider<bool?>((ref) => null);

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

// ============================================================
// Notification Settings
// ============================================================

/// Notification settings state
class NotificationSettingsState {
  final bool isEnabled;
  final List<NotificationTime> times;
  final bool isLoading;

  const NotificationSettingsState({
    this.isEnabled = false,
    this.times = const [],
    this.isLoading = false,
  });

  NotificationSettingsState copyWith({
    bool? isEnabled,
    List<NotificationTime>? times,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
      isEnabled: isEnabled ?? this.isEnabled,
      times: times ?? this.times,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notification settings provider
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
        (ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(notificationService);
});

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  final NotificationService _service;

  NotificationSettingsNotifier(this._service)
      : super(const NotificationSettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final enabled = _service.isNotificationsEnabled;
    final times = _service.getNotificationTimes();
    state = NotificationSettingsState(isEnabled: enabled, times: times);
  }

  /// Toggle notifications enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.setNotificationsEnabled(enabled);
      state = state.copyWith(isEnabled: enabled, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Update a specific notification time
  Future<void> updateTime(NotificationTime updated) async {
    final newTimes =
        state.times.map((t) => t.id == updated.id ? updated : t).toList();
    state = state.copyWith(times: newTimes, isLoading: true);
    try {
      await _service.saveNotificationTimes(newTimes);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Add a new notification time
  Future<void> addTime(NotificationTime time) async {
    final newTimes = [...state.times, time];
    state = state.copyWith(times: newTimes, isLoading: true);
    try {
      await _service.saveNotificationTimes(newTimes);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Remove a notification time
  Future<void> removeTime(String id) async {
    final newTimes = state.times.where((t) => t.id != id).toList();
    state = state.copyWith(times: newTimes, isLoading: true);
    try {
      await _service.saveNotificationTimes(newTimes);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Send a test notification
  Future<void> sendTestNotification() async {
    await _service.sendTestNotification();
  }

  /// Reschedule all notifications (useful after app update)
  Future<void> rescheduleAll() async {
    await _service.scheduleAllNotifications();
  }
}
