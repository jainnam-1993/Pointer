/// Subscription providers - Premium status, daily usage limits, freemium model
///
/// Manages subscription state via RevenueCat and enforces daily pointing limits
/// for free users.
///
/// Freemium Model v2:
/// - FREE: Unlimited quotes/pointings
/// - PREMIUM: Full library, audio (TTS), notifications, widget
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/revenue_cat_service.dart';
import '../services/storage_service.dart';
import '../services/usage_tracking_service.dart';
import '../services/widget_service.dart';
import 'core_providers.dart';

// ============================================================
// TESTING FLAG - Force premium during development
// ============================================================

/// Set to true to force premium tier during testing
const bool kForcePremiumForTesting = true;

// ============================================================
// Freemium - Daily Usage Tracking
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
///
/// NOTE: Daily limits are now disabled - quotes/pointings are FREE for all users.
/// Premium features are: Full Library, Audio (TTS), Notifications, Widget.
class DailyUsageNotifier extends StateNotifier<DailyUsage> {
  final UsageTrackingService _service;

  DailyUsageNotifier(this._service) : super(_service.getUsage());

  /// Check if user can view more pointings
  ///
  /// Always returns true - quotes/pointings are free for all users.
  /// Premium gating is now only for: full library, audio, notifications, widget.
  bool canViewPointing(bool isPremium) {
    // Quotes are FREE for all users (freemium model v2)
    return true;
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
// Subscription State & Tier
// ============================================================

/// Subscription tier enum
enum SubscriptionTier { free, premium }

/// Subscription state
class SubscriptionState {
  final SubscriptionTier tier;
  final bool isLoading;
  final List<SubscriptionProduct> products;
  final String? error;
  final DateTime? expirationDate;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.expirationDate,
  });

  bool get isPremium => tier == SubscriptionTier.premium;

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    bool? isLoading,
    List<SubscriptionProduct>? products,
    String? error,
    DateTime? expirationDate,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }
}

/// Subscription provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SubscriptionNotifier(storage);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final StorageService _storage;
  final RevenueCatService _revenueCat = RevenueCatService.instance;

  SubscriptionNotifier(this._storage) : super(const SubscriptionState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    // Force premium for testing/development
    if (kForcePremiumForTesting) {
      state = state.copyWith(
        tier: SubscriptionTier.premium,
        isLoading: false,
      );
      // Sync widget with premium status
      await WidgetService.setPremiumStatus(true);
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      // Initialize RevenueCat SDK
      await _revenueCat.initialize();

      // Check if still mounted after async operation
      if (!mounted) return;

      // Check current subscription status
      final status = await _revenueCat.getSubscriptionStatus();
      final tier =
          status.isPremium ? SubscriptionTier.premium : SubscriptionTier.free;

      // Cache status locally for offline access
      await _storage.setSubscriptionTier(status.isPremium ? 'premium' : 'free');

      // Sync widget with premium status (widget is premium-only feature)
      await WidgetService.setPremiumStatus(status.isPremium);

      // Check if still mounted after async operations
      if (!mounted) return;

      // Load available products
      final products = await _revenueCat.getProducts();

      // Final mounted check before setting state
      if (!mounted) return;

      state = state.copyWith(
        tier: tier,
        isLoading: false,
        products: products,
        expirationDate: status.expirationDate,
      );
    } catch (e) {
      // Fallback to cached subscription status (only if still mounted)
      if (!mounted) return;
      final cachedTier = _storage.subscriptionTier == 'premium'
          ? SubscriptionTier.premium
          : SubscriptionTier.free;
      state = state.copyWith(tier: cachedTier, isLoading: false);

      // Sync widget with cached status
      await WidgetService.setPremiumStatus(cachedTier == SubscriptionTier.premium);
    }
  }

  /// Purchase a subscription package
  Future<PurchaseResult> purchasePackage(SubscriptionProduct product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _revenueCat.purchasePackage(product.package);

      if (result.success) {
        await _storage.setSubscriptionTier('premium');
        // Sync widget - now premium features (widget, notifications) are unlocked
        await WidgetService.setPremiumStatus(true);
        state = state.copyWith(
          tier: SubscriptionTier.premium,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.isCancelled ? null : result.error,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return PurchaseResult(success: false, error: e.toString());
    }
  }

  /// Restore previous purchases
  Future<RestoreResult> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _revenueCat.restorePurchases();

      if (result.hasPremium) {
        await _storage.setSubscriptionTier('premium');
        // Sync widget - premium features restored
        await WidgetService.setPremiumStatus(true);
        state =
            state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return RestoreResult(
          success: false, hasPremium: false, error: e.toString());
    }
  }

  /// Refresh subscription status from server
  Future<void> refreshStatus() async {
    try {
      final status = await _revenueCat.getSubscriptionStatus();
      final tier =
          status.isPremium ? SubscriptionTier.premium : SubscriptionTier.free;
      await _storage.setSubscriptionTier(status.isPremium ? 'premium' : 'free');
      state = state.copyWith(
        tier: tier,
        expirationDate: status.expirationDate,
      );
    } catch (e) {
      // Ignore errors during refresh
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
