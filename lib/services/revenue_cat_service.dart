import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat API keys
class _RevenueCatKeys {
  static const iosApiKey = 'test_wXZuGwQRPBNGSUglyDrlTGAxLEV';
  static const androidApiKey = 'test_wXZuGwQRPBNGSUglyDrlTGAxLEV';
}

/// Product identifiers configured in RevenueCat dashboard
class RevenueCatProducts {
  static const lifetimeId = 'pointer_premium_lifetime';
}

/// Entitlement identifiers
class RevenueCatEntitlements {
  static const premium = 'premium';
}

/// Service for managing in-app purchases via RevenueCat.
///
/// Handles:
/// - SDK initialization
/// - Fetching available products
/// - Processing purchases
/// - Checking subscription status
/// - Restoring purchases
class RevenueCatService {
  static RevenueCatService? _instance;
  bool _isInitialized = false;

  RevenueCatService._();

  static RevenueCatService get instance {
    _instance ??= RevenueCatService._();
    return _instance!;
  }

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Enable debug logs in debug mode
    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(
      Platform.isIOS ? _RevenueCatKeys.iosApiKey : _RevenueCatKeys.androidApiKey,
    );

    await Purchases.configure(configuration);
    _isInitialized = true;
    print('[RevenueCat] Initialized with ${Platform.isIOS ? "iOS" : "Android"} key');
  }

  /// Check if user has premium entitlement
  Future<bool> isPremiumActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(RevenueCatEntitlements.premium);
    } catch (e) {
      return false;
    }
  }

  /// Get subscription status details
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.active[RevenueCatEntitlements.premium];

      if (entitlement != null) {
        return SubscriptionStatus(
          isPremium: true,
          productId: entitlement.productIdentifier,
          expirationDate: entitlement.expirationDate != null
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
          willRenew: entitlement.willRenew,
        );
      }

      return const SubscriptionStatus(isPremium: false);
    } catch (e) {
      return const SubscriptionStatus(isPremium: false);
    }
  }

  /// Get available products (offerings)
  Future<List<SubscriptionProduct>> getProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      print('[RevenueCat] Offerings fetched: ${offerings.all.keys.toList()}');
      final current = offerings.current;

      if (current == null) {
        print('[RevenueCat] No current offering set');
        return [];
      }

      print('[RevenueCat] Current offering: ${current.identifier}, packages: ${current.availablePackages.length}');

      final products = <SubscriptionProduct>[];

      for (final package in current.availablePackages) {
        print('[RevenueCat] Package: ${package.packageType}, product: ${package.storeProduct.identifier}, price: ${package.storeProduct.priceString}');
        products.add(SubscriptionProduct(
          id: package.storeProduct.identifier,
          title: package.storeProduct.title,
          description: package.storeProduct.description,
          price: package.storeProduct.priceString,
          priceValue: package.storeProduct.price,
          packageType: package.packageType,
          package: package,
        ));
      }

      return products;
    } catch (e) {
      print('[RevenueCat] Error fetching products: $e');
      return [];
    }
  }

  /// Purchase a subscription package
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isPremium = customerInfo.entitlements.active.containsKey(
        RevenueCatEntitlements.premium,
      );

      return PurchaseResult(
        success: isPremium,
        error: isPremium ? null : 'Purchase completed but entitlement not found',
      );
    } on PurchasesErrorCode catch (e) {
      return PurchaseResult(
        success: false,
        error: _getErrorMessage(e),
        isCancelled: e == PurchasesErrorCode.purchaseCancelledError,
      );
    } catch (e) {
      return PurchaseResult(success: false, error: e.toString());
    }
  }

  /// Restore previous purchases
  Future<RestoreResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.active.containsKey(
        RevenueCatEntitlements.premium,
      );

      return RestoreResult(
        success: true,
        hasPremium: isPremium,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        hasPremium: false,
        error: e.toString(),
      );
    }
  }

  /// Listen to customer info updates
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  String _getErrorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Purchase was cancelled';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases not allowed on this device';
      case PurchasesErrorCode.paymentPendingError:
        return 'Payment is pending';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Product not available';
      default:
        return 'An error occurred during purchase';
    }
  }
}

/// Subscription product model
class SubscriptionProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final double priceValue;
  final PackageType packageType;
  final Package package;

  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceValue,
    required this.packageType,
    required this.package,
  });

  bool get isLifetime => packageType == PackageType.lifetime;
}

/// Current subscription status
class SubscriptionStatus {
  final bool isPremium;
  final String? productId;
  final DateTime? expirationDate;
  final bool willRenew;

  const SubscriptionStatus({
    required this.isPremium,
    this.productId,
    this.expirationDate,
    this.willRenew = false,
  });
}

/// Purchase result
class PurchaseResult {
  final bool success;
  final String? error;
  final bool isCancelled;

  const PurchaseResult({
    required this.success,
    this.error,
    this.isCancelled = false,
  });
}

/// Restore result
class RestoreResult {
  final bool success;
  final bool hasPremium;
  final String? error;

  const RestoreResult({
    required this.success,
    required this.hasPremium,
    this.error,
  });
}
