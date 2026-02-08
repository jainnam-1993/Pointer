/**
 * Donation providers - Tip jar via in-app purchases.
 *
 * Provides state management for the donation/tip jar feature via
 * [DonationNotifier]. All donations are consumable products (can be
 * purchased multiple times) using the `in_app_purchase` package directly
 * (not RevenueCat). Four tiers: Tea, Cushion, Incense, and Retreat.
 *
 * [DonationState] tracks product availability, loading state, and
 * purchase results. [DonationService] handles platform IAP communication.
 */
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/donation_service.dart';

/// Result of a donation purchase attempt
enum DonationResult {
  /// Purchase completed successfully
  success,

  /// User cancelled the purchase
  cancelled,

  /// Purchase failed due to error
  error,
}

/**
 * Immutable state for the donation/tip jar feature.
 *
 * Tracks IAP availability, loading state during product fetch or purchase,
 * available [ProductDetails] sorted by price, and the result of the last
 * purchase attempt for UI feedback (success toast, cancellation, or error).
 */
class DonationState {
  /// Whether in-app purchases are available on this device
  final bool isAvailable;

  /// Whether we're loading products or processing a purchase
  final bool isLoading;

  /// Available donation products (sorted by price)
  final List<ProductDetails> products;

  /// Error message if something went wrong
  final String? error;

  /// Result of the last purchase attempt (null if no attempt yet)
  final DonationResult? lastResult;

  const DonationState({this.isAvailable = false, this.isLoading = true, this.products = const [], this.error, this.lastResult});

  /// Creates a copy with selectively overridden fields.
  ///
  /// Use [clearError] to explicitly set [error] to `null`, and [clearResult]
  /// to reset [lastResult] to `null` (since passing `null` preserves the current value).
  DonationState copyWith({
    bool? isAvailable,
    bool? isLoading,
    List<ProductDetails>? products,
    String? error,
    DonationResult? lastResult,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return DonationState(
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: clearError ? null : (error ?? this.error),
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
    );
  }
}

/// Provider for the donation service
final donationServiceProvider = Provider<DonationService>((ref) {
  final service = DonationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for donation state and actions
final donationProvider = StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  final service = ref.watch(donationServiceProvider);
  return DonationNotifier(service);
});

/**
 * Manages [DonationState] and coordinates with [DonationService] for IAP.
 *
 * On construction, subscribes to the platform purchase update stream and
 * calls [initialize] to check availability and load products. Purchase
 * results flow through the stream listener and update state reactively.
 *
 * Consumable purchases must be explicitly completed via
 * [DonationService.completePurchase] to acknowledge receipt with the store.
 */
class DonationNotifier extends StateNotifier<DonationState> {
  final DonationService _service;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  DonationNotifier(this._service) : super(const DonationState()) {
    _listenToPurchases();
    initialize();
  }

  /// Initialize the donation system
  ///
  /// Checks availability and loads products.
  Future<void> initialize() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final available = await _service.isAvailable();

      if (!mounted) return;

      if (!available) {
        state = state.copyWith(isAvailable: false, isLoading: false, products: []);
        return;
      }

      final products = await _service.loadProducts();

      if (!mounted) return;

      state = state.copyWith(isAvailable: true, isLoading: false, products: products);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isAvailable: false, isLoading: false, error: 'Failed to load donation options: $e');
    }
  }

  /// Purchase a tip/donation
  Future<void> purchaseTip(ProductDetails product) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);

    try {
      await _service.purchaseProduct(product);
      // Result will come through the purchase stream
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: 'Failed to initiate purchase: $e', lastResult: DonationResult.error);
    }
  }

  /// Clear the last purchase result
  void clearResult() {
    if (!mounted) return;
    state = state.copyWith(clearResult: true);
  }

  /// Clear any error state
  void clearError() {
    if (!mounted) return;
    state = state.copyWith(clearError: true);
  }

  /// Subscribes to the platform IAP purchase update stream.
  void _listenToPurchases() {
    _purchaseSubscription = _service.purchaseUpdates.listen(_handlePurchase);
  }

  /// Processes each [PurchaseDetails] in a batch of purchase updates.
  Future<void> _handlePurchase(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _processPurchase(purchase);
    }
  }

  /// Handles a single purchase update based on its [PurchaseStatus].
  ///
  /// Completed purchases are acknowledged via [DonationService.completePurchase]
  /// (critical for consumable products). Cancelled and error states update
  /// [DonationState.lastResult] for UI feedback.
  Future<void> _processPurchase(PurchaseDetails purchase) async {
    if (!mounted) return;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Still processing - keep loading state
        state = state.copyWith(isLoading: true);
        break;

      case PurchaseStatus.purchased:
        // CRITICAL: Complete the purchase to acknowledge receipt
        await _service.completePurchase(purchase);
        if (!mounted) return;
        state = state.copyWith(isLoading: false, lastResult: DonationResult.success);
        break;

      case PurchaseStatus.restored:
        // Consumables don't restore, but handle anyway
        await _service.completePurchase(purchase);
        if (!mounted) return;
        state = state.copyWith(isLoading: false);
        break;

      case PurchaseStatus.error:
        if (!mounted) return;
        state = state.copyWith(isLoading: false, error: purchase.error?.message ?? 'Purchase failed', lastResult: DonationResult.error);
        break;

      case PurchaseStatus.canceled:
        if (!mounted) return;
        state = state.copyWith(isLoading: false, lastResult: DonationResult.cancelled);
        break;
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
