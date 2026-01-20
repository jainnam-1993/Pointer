/// Subscription providers - Simplified (no IAP)
///
/// All features are free. This file provides stub implementations
/// to maintain API compatibility with the rest of the codebase.
///
/// To restore IAP functionality: git checkout v1.0-with-auth
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/widget_service.dart';
import 'core_providers.dart';

// ============================================================
// FREE ACCESS MODE - All Features Free (No IAP)
// ============================================================

/// All features are free - no IAP
/// To restore IAP: git checkout v1.0-with-auth
const bool kFreeAccessEnabled = true;

// ============================================================
// Freemium - Daily Usage Tracking (Kept for analytics)
// ============================================================

/// Provider for usage tracking service
final usageTrackingServiceProvider = Provider<UsageTrackingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UsageTrackingService(prefs);
});

/// Daily usage state provider
final dailyUsageProvider =
    StateNotifierProvider<DailyUsageNotifier, DailyUsage>((ref) {
  final service = ref.watch(usageTrackingServiceProvider);
  return DailyUsageNotifier(service);
});

/// Notifier for managing daily usage state
class DailyUsageNotifier extends StateNotifier<DailyUsage> {
  final UsageTrackingService _service;

  DailyUsageNotifier(this._service) : super(_service.getUsage());

  /// Always returns true - all content is free
  bool canViewPointing(bool isPremium) => true;

  /// Record a pointing view (for analytics)
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
// Subscription State (Stub - Always Premium)
// ============================================================

/// Subscription tier enum (kept for API compatibility)
enum SubscriptionTier { free, premium }

/// Subscription state (always premium)
class SubscriptionState {
  final SubscriptionTier tier;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.tier = SubscriptionTier.premium,
    this.isLoading = false,
    this.error,
  });

  bool get isPremium => true; // Always premium
  List<SubscriptionProduct> get products => const []; // No products

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Stub product class (API compatibility)
class SubscriptionProduct {
  final String identifier;
  final String title;
  final String price;
  final dynamic package; // RevenueCat Package type

  const SubscriptionProduct({
    required this.identifier,
    required this.title,
    required this.price,
    this.package,
  });
}

/// Stub purchase result (API compatibility)
class PurchaseResult {
  final bool success;
  final bool isCancelled;
  final String? error;

  const PurchaseResult({
    this.success = true,
    this.isCancelled = false,
    this.error,
  });
}

/// Stub restore result (API compatibility)
class RestoreResult {
  final bool success;
  final bool hasPremium;
  final String? error;

  const RestoreResult({
    this.success = true,
    this.hasPremium = true,
    this.error,
  });
}

/// Subscription provider (always premium)
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SubscriptionNotifier(storage);
});

/// Subscription notifier (stub - all features free)
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(StorageService storage)
      : super(const SubscriptionState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // All features free - mark as premium, sync widget
    await WidgetService.setPremiumStatus(true);
    if (mounted) {
      state = state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
    }
  }

  /// No-op: IAP disabled
  Future<PurchaseResult> purchasePackage(SubscriptionProduct product) async {
    return const PurchaseResult(success: true);
  }

  /// No-op: Always premium
  Future<RestoreResult> restorePurchases() async {
    return const RestoreResult(success: true, hasPremium: true);
  }

  /// No-op: Always premium
  Future<void> refreshStatus() async {}

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
