/**
 * Subscription providers - Simplified (no IAP).
 *
 * All features are free. This file provides stub implementations
 * to maintain API compatibility with the rest of the codebase.
 * [SubscriptionNotifier] always reports premium status, and purchase/restore
 * methods are no-ops.
 *
 * Daily usage tracking via [DailyUsageNotifier] is retained for analytics.
 * To restore IAP functionality: `git checkout v1.0-with-auth`.
 *
 * See also: [kFreeAccessEnabled] flag controlling the free-access mode.
 */
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/widget_service.dart';
import 'core_providers.dart';

// ============================================================
// FREE ACCESS MODE - All Features Free (No IAP)
// ============================================================

/// Master flag enabling free access mode (all features unlocked, no IAP).
///
/// When `true`, RevenueCat initialization is skipped in `main.dart` and
/// [SubscriptionNotifier] always reports premium. Set to `false` to
/// re-enable monetization via RevenueCat lifetime purchases.
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
final dailyUsageProvider = StateNotifierProvider<DailyUsageNotifier, DailyUsage>((ref) {
  final service = ref.watch(usageTrackingServiceProvider);
  return DailyUsageNotifier(service);
});

/**
 * Manages [DailyUsage] state for analytics via [UsageTrackingService].
 *
 * Tracks daily pointing views regardless of subscription tier.
 * Retained for analytics even in free-access mode.
 */
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

/**
 * Immutable subscription state (always premium in free-access mode).
 *
 * In the stub implementation, [isPremium] always returns `true` and
 * [products] is always empty. When IAP is restored, this class will
 * hold real tier, product, and error state from RevenueCat.
 */
class SubscriptionState {
  /// Current subscription tier (always [SubscriptionTier.premium] in free mode).
  final SubscriptionTier tier;

  /// Whether a subscription operation (load, purchase, restore) is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, or `null` if none.
  final String? error;

  const SubscriptionState({this.tier = SubscriptionTier.premium, this.isLoading = false, this.error});

  /// Always `true` in free-access mode. Checked by premium-gated features.
  bool get isPremium => true; // Always premium

  /// Available purchase products (empty in free-access mode).
  List<SubscriptionProduct> get products => const []; // No products

  /// Creates a copy with selectively overridden fields.
  SubscriptionState copyWith({SubscriptionTier? tier, bool? isLoading, String? error}) {
    return SubscriptionState(tier: tier ?? this.tier, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

/**
 * Stub product class for API compatibility when IAP is disabled.
 *
 * Represents a purchasable subscription product (lifetime purchase).
 * When IAP is restored, [package] will hold a RevenueCat Package instance.
 */
class SubscriptionProduct {
  /// RevenueCat product identifier (e.g., `pointer_lifetime`).
  final String identifier;

  /// User-facing product title.
  final String title;

  /// Formatted price string (e.g., "$9.99").
  final String price;

  /// RevenueCat Package instance (typed as `dynamic` to avoid hard dependency).
  final dynamic package; // RevenueCat Package type

  const SubscriptionProduct({required this.identifier, required this.title, required this.price, this.package});
}

/**
 * Result of a purchase attempt (stub - always succeeds in free mode).
 *
 * When IAP is restored, this carries real success/failure/cancellation state.
 */
class PurchaseResult {
  /// Whether the purchase completed successfully.
  final bool success;

  /// Whether the user explicitly cancelled the purchase flow.
  final bool isCancelled;

  /// Error message if the purchase failed, or `null` on success.
  final String? error;

  const PurchaseResult({this.success = true, this.isCancelled = false, this.error});
}

/**
 * Result of a restore-purchases attempt (stub - always succeeds in free mode).
 *
 * When IAP is restored, this carries real restoration state from RevenueCat.
 */
class RestoreResult {
  /// Whether the restore operation completed without errors.
  final bool success;

  /// Whether premium entitlement was found in restored purchases.
  final bool hasPremium;

  /// Error message if restoration failed, or `null` on success.
  final String? error;

  const RestoreResult({this.success = true, this.hasPremium = true, this.error});
}

/// Subscription provider (always premium)
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SubscriptionNotifier(storage);
});

/**
 * Stub [SubscriptionNotifier] that always reports premium status.
 *
 * Initializes by setting [WidgetService] premium flag to `true` so the
 * home widget renders premium content. All purchase and restore methods
 * are no-ops returning successful results.
 *
 * When IAP is re-enabled, this class will integrate with RevenueCat for
 * real purchase flow, entitlement checks, and cross-device sync.
 */
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(StorageService storage) : super(const SubscriptionState()) {
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
