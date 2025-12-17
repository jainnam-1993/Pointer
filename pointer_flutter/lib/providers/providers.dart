import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/widget_service.dart';
import '../data/pointings.dart';
import '../theme/app_theme.dart';

// ============================================================
// Zen Mode - Distraction-free reading
// ============================================================

/// Zen mode provider - hides all UI except pointing text
final zenModeProvider = StateProvider<bool>((ref) => false);

// ============================================================
// Freemium - Daily Usage Tracking
// ============================================================

/// Provider for usage tracking service
final usageTrackingServiceProvider = Provider<UsageTrackingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UsageTrackingService(prefs);
});

/// Daily usage state provider
final dailyUsageProvider = StateNotifierProvider<DailyUsageNotifier, DailyUsage>((ref) {
  final service = ref.watch(usageTrackingServiceProvider);
  return DailyUsageNotifier(service);
});

/// Notifier for managing daily usage state
class DailyUsageNotifier extends StateNotifier<DailyUsage> {
  final UsageTrackingService _service;

  DailyUsageNotifier(this._service) : super(_service.getUsage());

  /// Check if user can view more pointings (premium always can)
  bool canViewPointing(bool isPremium) {
    if (isPremium) return true;
    return !state.limitReached;
  }

  /// Record a pointing view
  Future<void> recordView() async {
    state = await _service.incrementViewCount();
  }

  /// Reset for testing
  Future<void> reset() async {
    await _service.resetUsage();
    state = _service.getUsage();
  }
}

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

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationService(prefs);
});

/// Onboarding state
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.hasCompletedOnboarding;
});

/// Current pointing state
final currentPointingProvider = StateNotifierProvider<CurrentPointingNotifier, Pointing>((ref) {
  return CurrentPointingNotifier();
});

class CurrentPointingNotifier extends StateNotifier<Pointing> {
  CurrentPointingNotifier() : super(getRandomPointing()) {
    // Update widget with initial pointing
    _updateWidget(state);
  }

  void nextPointing({Tradition? tradition, PointingContext? context}) {
    state = getRandomPointing(tradition: tradition, context: context);
    _updateWidget(state);
  }

  void setPointing(Pointing pointing) {
    state = pointing;
    _updateWidget(state);
  }

  /// Update home screen widget with current pointing
  void _updateWidget(Pointing pointing) {
    // Import handled at file level
    WidgetService.updateWidget(pointing);
  }
}

/// Subscription state
enum SubscriptionTier { free, premium }

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SubscriptionNotifier(storage);
});

class SubscriptionState {
  final SubscriptionTier tier;
  final bool isLoading;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.isLoading = false,
  });

  bool get isPremium => tier == SubscriptionTier.premium;

  SubscriptionState copyWith({SubscriptionTier? tier, bool? isLoading}) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final StorageService _storage;

  SubscriptionNotifier(this._storage) : super(const SubscriptionState()) {
    _loadSubscription();
  }

  void _loadSubscription() {
    final tier = _storage.subscriptionTier == 'premium'
        ? SubscriptionTier.premium
        : SubscriptionTier.free;
    state = state.copyWith(tier: tier);
  }

  Future<bool> purchasePremium() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Integrate with RevenueCat
      await _storage.setSubscriptionTier('premium');
      state = state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Integrate with RevenueCat
      final tier = _storage.subscriptionTier;
      if (tier == 'premium') {
        state = state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

/// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesNotifier(storage);
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final StorageService _storage;

  FavoritesNotifier(this._storage) : super(_storage.favorites);

  Future<void> toggle(String pointingId) async {
    if (state.contains(pointingId)) {
      await _storage.removeFavorite(pointingId);
      state = [...state]..remove(pointingId);
    } else {
      await _storage.addFavorite(pointingId);
      state = [...state, pointingId];
    }
  }

  bool isFavorite(String pointingId) => state.contains(pointingId);
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
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
}

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
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(notificationService);
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  final NotificationService _service;

  NotificationSettingsNotifier(this._service) : super(const NotificationSettingsState()) {
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
    final newTimes = state.times.map((t) => t.id == updated.id ? updated : t).toList();
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
