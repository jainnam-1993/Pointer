/**
 * Core providers - SharedPreferences, storage, notifications, onboarding.
 *
 * Foundational providers that other domain providers depend on.
 * [sharedPreferencesProvider] must be overridden in the root [ProviderScope]
 * at app startup. [StorageService] and [NotificationService] are derived
 * from it and consumed by settings, content, and subscription providers.
 */
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';

// ============================================================
// SharedPreferences - Root dependency
// ============================================================

/// Root dependency provider for [SharedPreferences].
///
/// **Must be overridden** in the root `ProviderScope` at app startup with an
/// initialized [SharedPreferences] instance. Throws [UnimplementedError] if
/// accessed without override. All persistence flows ultimately depend on this.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ============================================================
// Storage Service
// ============================================================

/// Storage service provider - wraps SharedPreferences with domain-specific methods
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

// ============================================================
// Notification Service
// ============================================================

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationService(prefs);
});

// ============================================================
// Onboarding State
// ============================================================

/// Onboarding completion state
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.hasCompletedOnboarding;
});
