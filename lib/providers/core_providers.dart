/// Core providers - SharedPreferences, storage, notifications, onboarding
///
/// These are foundational providers that other domain providers depend on.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';

// ============================================================
// SharedPreferences - Root dependency
// ============================================================

/// SharedPreferences provider - must be overridden in ProviderScope
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
