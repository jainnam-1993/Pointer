import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/revenue_cat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('RevenueCatProducts', () {
    test('has correct lifetime product ID', () {
      expect(RevenueCatProducts.lifetimeId, 'pointer_premium_lifetime');
    });
  });

  group('RevenueCatEntitlements', () {
    test('has correct premium entitlement', () {
      expect(RevenueCatEntitlements.premium, 'premium');
    });
  });

  group('SubscriptionProduct', () {
    test('isLifetime returns true for lifetime package type', () {
      // Create a mock to test the model
      final product = _createTestProduct(PackageType.lifetime);
      expect(product.isLifetime, true);
    });

    test('isLifetime returns false for monthly package type', () {
      final product = _createTestProduct(PackageType.monthly);
      expect(product.isLifetime, false);
    });

    test('isLifetime returns false for annual package type', () {
      final product = _createTestProduct(PackageType.annual);
      expect(product.isLifetime, false);
    });

    test('stores all required fields', () {
      final product = _createTestProduct(PackageType.lifetime);
      expect(product.id, 'test_id');
      expect(product.title, 'Test Title');
      expect(product.description, 'Test Description');
      expect(product.price, '\$9.99');
      expect(product.priceValue, 9.99);
      expect(product.packageType, PackageType.lifetime);
    });
  });

  group('SubscriptionStatus', () {
    test('default values are correct', () {
      const status = SubscriptionStatus(isPremium: false);
      expect(status.isPremium, false);
      expect(status.productId, isNull);
      expect(status.expirationDate, isNull);
      expect(status.willRenew, false);
    });

    test('can create premium status', () {
      const status = SubscriptionStatus(
        isPremium: true,
        productId: 'pointer_premium_lifetime',
      );
      expect(status.isPremium, true);
      expect(status.productId, 'pointer_premium_lifetime');
    });

    test('can include expiration date', () {
      final expiration = DateTime(2025, 12, 31);
      final status = SubscriptionStatus(
        isPremium: true,
        productId: 'test_product',
        expirationDate: expiration,
        willRenew: true,
      );
      expect(status.expirationDate, expiration);
      expect(status.willRenew, true);
    });
  });

  group('PurchaseResult', () {
    test('successful purchase has success true', () {
      const result = PurchaseResult(success: true);
      expect(result.success, true);
      expect(result.error, isNull);
      expect(result.isCancelled, false);
    });

    test('failed purchase can have error message', () {
      const result = PurchaseResult(
        success: false,
        error: 'Payment declined',
      );
      expect(result.success, false);
      expect(result.error, 'Payment declined');
      expect(result.isCancelled, false);
    });

    test('cancelled purchase has isCancelled flag', () {
      const result = PurchaseResult(
        success: false,
        error: 'User cancelled',
        isCancelled: true,
      );
      expect(result.success, false);
      expect(result.isCancelled, true);
    });
  });

  group('RestoreResult', () {
    test('successful restore with premium', () {
      const result = RestoreResult(
        success: true,
        hasPremium: true,
      );
      expect(result.success, true);
      expect(result.hasPremium, true);
      expect(result.error, isNull);
    });

    test('successful restore without premium', () {
      const result = RestoreResult(
        success: true,
        hasPremium: false,
      );
      expect(result.success, true);
      expect(result.hasPremium, false);
    });

    test('failed restore has error', () {
      const result = RestoreResult(
        success: false,
        hasPremium: false,
        error: 'Network error',
      );
      expect(result.success, false);
      expect(result.error, 'Network error');
    });
  });

  group('RevenueCatService singleton', () {
    test('instance returns same instance', () {
      final instance1 = RevenueCatService.instance;
      final instance2 = RevenueCatService.instance;
      expect(identical(instance1, instance2), true);
    });
  });

  // Note: The actual SDK methods (initialize, isPremiumActive, getProducts, etc.)
  // cannot be unit tested without mocking the Purchases SDK.
  // These tests focus on the data models and service structure.
  // Integration testing via Maestro flows covers the full purchase flow.
}

/// Helper to create test product without actual Package mock
SubscriptionProduct _createTestProduct(PackageType packageType) {
  // We can't easily mock Package without the real SDK,
  // so we use a workaround with a fake package for testing the model
  return _TestSubscriptionProduct(
    id: 'test_id',
    title: 'Test Title',
    description: 'Test Description',
    price: '\$9.99',
    priceValue: 9.99,
    packageType: packageType,
  );
}

/// Test-only subclass that doesn't require real Package
class _TestSubscriptionProduct extends SubscriptionProduct {
  _TestSubscriptionProduct({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.priceValue,
    required super.packageType,
  }) : super(package: _FakePackage());
}

/// Minimal fake package for testing
class _FakePackage implements Package {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
