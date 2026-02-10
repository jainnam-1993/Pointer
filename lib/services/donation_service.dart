import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Enable test products for IAP testing
///
/// When true:
/// - Android: Uses Google's static test ID ('android.test.purchased')
/// - iOS: Uses real product IDs with StoreKit Configuration file
///
/// Pass via dart-define: --dart-define=USE_DONATION_TEST_PRODUCTS=true
/// Defaults to true in debug builds.
const kUseDonationTestProducts = bool.fromEnvironment(
  'USE_DONATION_TEST_PRODUCTS',
  defaultValue: kDebugMode,
);

/// Product IDs for tip jar donations (consumable)
class DonationProductIds {
  static const tipSmall = 'com.dailypointer.tip_small';
  static const tipMedium = 'com.dailypointer.tip_medium';
  static const tipLarge = 'com.dailypointer.tip_large';
  static const tipGenerous = 'com.dailypointer.tip_generous';

  /// Google's static test product ID for Android
  /// Always returns a successful purchase without store configuration.
  static const androidTestPurchased = 'android.test.purchased';

  /// Production product IDs
  static const productionIds = {tipSmall, tipMedium, tipLarge, tipGenerous};

  /// Get the appropriate product IDs based on test mode and platform
  static Set<String> get all {
    if (kUseDonationTestProducts && Platform.isAndroid) {
      // Android: Use Google's static test product for immediate testing
      return {androidTestPurchased};
    }
    // iOS (and production): Use real product IDs
    // iOS uses StoreKit Configuration file for local testing
    return productionIds;
  }
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
      final products = response.productDetails.toList()
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

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
  StreamSubscription<List<PurchaseDetails>> listenToPurchases(
    void Function(PurchaseDetails) onPurchase,
  ) {
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
