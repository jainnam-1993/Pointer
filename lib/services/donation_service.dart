import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/**
 * App Store / Play Store product identifiers for tip jar consumable purchases.
 *
 * Each tier corresponds to a different donation amount configured in
 * App Store Connect and Google Play Console.
 */
class DonationProductIds {
  /// Smallest donation tier (e.g. "Buy me a tea").
  static const tipSmall = 'com.dailypointer.tip_small';

  /// Medium donation tier (e.g. "Buy me a cushion").
  static const tipMedium = 'com.dailypointer.tip_medium';

  /// Large donation tier (e.g. "Buy me incense").
  static const tipLarge = 'com.dailypointer.tip_large';

  /// Largest donation tier (e.g. "Fund a retreat").
  static const tipGenerous = 'com.dailypointer.tip_generous';

  /// Set of all product IDs, passed to [InAppPurchase.queryProductDetails].
  static const all = {tipSmall, tipMedium, tipLarge, tipGenerous};
}

/// Service for handling tip jar donations via in-app purchases
///
/// All donations are consumable products - they can be purchased multiple times.
/// CRITICAL: completePurchase() must be called after successful purchase
/// to acknowledge receipt with the store.
class DonationService {
  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  DonationService([InAppPurchase? iap]) : _iap = iap ?? InAppPurchase.instance;

  /// Stream of purchase updates from the store
  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  /// Check if in-app purchases are available on this device
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (e) {
      // Graceful degradation - return false on errors
      return false;
    }
  }

  /// Load donation products from the store
  ///
  /// Returns empty list if products unavailable or on error.
  Future<List<ProductDetails>> loadProducts() async {
    try {
      final available = await isAvailable();
      if (!available) return [];

      final response = await _iap.queryProductDetails(DonationProductIds.all);

      if (response.notFoundIDs.isNotEmpty) {
        // Some products not found - log but continue with available ones
        // In production, these would be configured in App Store Connect / Play Console
      }

      // Sort by price (assuming small < medium < large < generous)
      final products = response.productDetails.toList()..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

      return products;
    } catch (e) {
      // Graceful degradation - return empty on errors
      return [];
    }
  }

  /// Initiate a donation purchase
  ///
  /// The purchase result will be delivered via [purchaseUpdates] stream.
  Future<void> purchaseProduct(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      // Donations are consumable - can be purchased multiple times
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Purchase initiation failed - error will surface through stream
      rethrow;
    }
  }

  /// Complete a purchase to acknowledge receipt with the store
  ///
  /// CRITICAL: Must be called for consumable products after successful purchase.
  /// Failure to call this will result in the store refunding the purchase.
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /// Listen to purchase updates and handle completion
  ///
  /// Returns a subscription that should be cancelled when no longer needed.
  StreamSubscription<List<PurchaseDetails>> listenToPurchases(void Function(PurchaseDetails) onPurchase) {
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        onPurchase(purchase);
      }
    });
    return _subscription!;
  }

  /// Clean up resources
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
