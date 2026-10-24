/**
 * Core providers - SharedPreferences, storage, notifications, widget, onboarding.
 *
 * Foundational providers that other domain providers depend on.
 * [sharedPreferencesProvider] must be overridden in the root [ProviderScope]
 * at app startup. [StorageService], [NotificationService], and [WidgetService]
 * are derived from it and consumed by settings, content, and subscription providers.
 */
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';

// ============================================================
// SharedPreferences - Root dependency
// ============================================================

/**
 * Root dependency provider for [SharedPreferences].
 *
 * **Must be overridden** in the root `ProviderScope` at app startup with an
 * initialized [SharedPreferences] instance. Throws [UnimplementedError] if
 * accessed without override. All persistence flows ultimately depend on this.
 */
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ============================================================
// Storage Service
// ============================================================

/** Storage service provider - wraps SharedPreferences with domain-specific methods */
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

// ============================================================
// Notification Service
// ============================================================

/** Notification service provider */
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationService(prefs);
});

// ============================================================
// Widget Service
// ============================================================

/** Widget service provider - manages home screen widget data and updates */
final widgetServiceProvider = Provider<WidgetService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WidgetService(prefs);
});

// ============================================================
// Onboarding State
// ============================================================

/** Onboarding completion state — read-only, derived from storage. */
final onboardingCompletedProvider = Provider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.hasCompletedOnboarding;
});

// ============================================================
// App version
// ============================================================

/**
 * Installed app version and build number from the platform package info.
 *
 * Errors (no platform channel, as in widget tests) surface as an error state;
 * callers read `valueOrNull` and omit the version rather than show a stale one.
 */
final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());
