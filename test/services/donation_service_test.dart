import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/services/donation_service.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class MockProductDetails extends Mock implements ProductDetails {}

class MockPurchaseDetails extends Mock implements PurchaseDetails {}

class FakeProductDetails extends Fake implements ProductDetails {}

class FakePurchaseParam extends Fake implements PurchaseParam {}

class FakePurchaseDetails extends Fake implements PurchaseDetails {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeProductDetails());
    registerFallbackValue(FakePurchaseParam());
    registerFallbackValue(FakePurchaseDetails());
  });

  group('DonationProductIds', () {
    test('has correct product IDs', () {
      expect(DonationProductIds.tipSmall, 'com.dailypointer.tip_small');
      expect(DonationProductIds.tipMedium, 'com.dailypointer.tip_medium');
      expect(DonationProductIds.tipLarge, 'com.dailypointer.tip_large');
      expect(DonationProductIds.tipGenerous, 'com.dailypointer.tip_generous');
    });

    test('all contains all product IDs', () {
      expect(DonationProductIds.all, hasLength(4));
      expect(DonationProductIds.all, contains(DonationProductIds.tipSmall));
      expect(DonationProductIds.all, contains(DonationProductIds.tipMedium));
      expect(DonationProductIds.all, contains(DonationProductIds.tipLarge));
      expect(DonationProductIds.all, contains(DonationProductIds.tipGenerous));
    });
  });

  group('DonationService - isAvailable', () {
    late MockInAppPurchase mockIap;
    late DonationService donationService;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
      donationService = DonationService(mockIap);
    });

    tearDown(() {
      purchaseController.close();
      donationService.dispose();
    });

    test('returns true when IAP is available', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => true);

      final result = await donationService.isAvailable();

      expect(result, true);
      verify(() => mockIap.isAvailable()).called(1);
    });

    test('returns false when IAP is not available', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => false);

      final result = await donationService.isAvailable();

      expect(result, false);
    });

    test('returns false on error (graceful degradation)', () async {
      when(() => mockIap.isAvailable()).thenThrow(Exception('IAP error'));

      final result = await donationService.isAvailable();

      expect(result, false);
    });
  });

  group('DonationService - loadProducts', () {
    late MockInAppPurchase mockIap;
    late DonationService donationService;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
      donationService = DonationService(mockIap);
    });

    tearDown(() {
      purchaseController.close();
      donationService.dispose();
    });

    test('returns empty list when IAP unavailable', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => false);

      final products = await donationService.loadProducts();

      expect(products, isEmpty);
      verifyNever(() => mockIap.queryProductDetails(any()));
    });

    test('returns products sorted by price', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => true);

      final expensiveProduct = _createMockProduct('tip_large', 9.99);
      final cheapProduct = _createMockProduct('tip_small', 0.99);
      final mediumProduct = _createMockProduct('tip_medium', 4.99);

      final response = ProductDetailsResponse(
        productDetails: [expensiveProduct, cheapProduct, mediumProduct],
        notFoundIDs: [],
      );

      when(() => mockIap.queryProductDetails(any())).thenAnswer((_) async => response);

      final products = await donationService.loadProducts();

      expect(products, hasLength(3));
      expect(products[0].rawPrice, 0.99); // Cheapest first
      expect(products[1].rawPrice, 4.99);
      expect(products[2].rawPrice, 9.99); // Most expensive last
    });

    test('handles partial product availability', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => true);

      final product = _createMockProduct('tip_small', 0.99);
      final response = ProductDetailsResponse(
        productDetails: [product],
        notFoundIDs: ['tip_medium', 'tip_large', 'tip_generous'],
      );

      when(() => mockIap.queryProductDetails(any())).thenAnswer((_) async => response);

      final products = await donationService.loadProducts();

      expect(products, hasLength(1));
      expect(products[0].id, 'tip_small');
    });

    test('returns empty list on error (graceful degradation)', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => true);
      when(() => mockIap.queryProductDetails(any())).thenThrow(Exception('Query failed'));

      final products = await donationService.loadProducts();

      expect(products, isEmpty);
    });
  });

  group('DonationService - purchaseProduct', () {
    late MockInAppPurchase mockIap;
    late DonationService donationService;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
      donationService = DonationService(mockIap);
    });

    tearDown(() {
      purchaseController.close();
      donationService.dispose();
    });

    test('initiates consumable purchase', () async {
      final product = _createMockProduct('tip_small', 0.99);

      when(() => mockIap.buyConsumable(purchaseParam: any(named: 'purchaseParam'))).thenAnswer((_) async => true);

      await donationService.purchaseProduct(product);

      verify(() => mockIap.buyConsumable(purchaseParam: any(named: 'purchaseParam'))).called(1);
    });

    test('rethrows error on purchase failure', () async {
      final product = _createMockProduct('tip_small', 0.99);

      when(
        () => mockIap.buyConsumable(purchaseParam: any(named: 'purchaseParam')),
      ).thenThrow(Exception('Purchase failed'));

      expect(() => donationService.purchaseProduct(product), throwsException);
    });
  });

  group('DonationService - completePurchase', () {
    late MockInAppPurchase mockIap;
    late DonationService donationService;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
      donationService = DonationService(mockIap);
    });

    tearDown(() {
      purchaseController.close();
      donationService.dispose();
    });

    test('completes purchase when pending', () async {
      final purchase = MockPurchaseDetails();
      when(() => purchase.pendingCompletePurchase).thenReturn(true);
      when(() => mockIap.completePurchase(purchase)).thenAnswer((_) async {});

      await donationService.completePurchase(purchase);

      verify(() => mockIap.completePurchase(purchase)).called(1);
    });

    test('does not complete purchase when not pending', () async {
      final purchase = MockPurchaseDetails();
      when(() => purchase.pendingCompletePurchase).thenReturn(false);

      await donationService.completePurchase(purchase);

      verifyNever(() => mockIap.completePurchase(any()));
    });
  });

  group('DonationService - purchaseUpdates', () {
    late MockInAppPurchase mockIap;
    late DonationService donationService;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
      donationService = DonationService(mockIap);
    });

    tearDown(() {
      purchaseController.close();
      donationService.dispose();
    });

    test('exposes purchase stream from IAP', () {
      expect(donationService.purchaseUpdates, isA<Stream<List<PurchaseDetails>>>());
    });

    test('listenToPurchases receives purchase updates', () async {
      final purchases = <PurchaseDetails>[];
      final purchase = MockPurchaseDetails();

      donationService.listenToPurchases((p) => purchases.add(p));

      purchaseController.add([purchase]);
      await Future.delayed(Duration.zero);

      expect(purchases, hasLength(1));
      expect(purchases[0], purchase);
    });

    test('listenToPurchases handles multiple purchases in batch', () async {
      final purchases = <PurchaseDetails>[];
      final purchase1 = MockPurchaseDetails();
      final purchase2 = MockPurchaseDetails();

      donationService.listenToPurchases((p) => purchases.add(p));

      purchaseController.add([purchase1, purchase2]);
      await Future.delayed(Duration.zero);

      expect(purchases, hasLength(2));
    });
  });

  group('DonationService - dispose', () {
    late MockInAppPurchase mockIap;
    late DonationService donationService;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream).thenAnswer((_) => purchaseController.stream);
      donationService = DonationService(mockIap);
    });

    tearDown(() {
      purchaseController.close();
    });

    test('cancels subscription on dispose', () async {
      final purchases = <PurchaseDetails>[];
      final purchase = MockPurchaseDetails();

      donationService.listenToPurchases((p) => purchases.add(p));

      donationService.dispose();

      // Adding after dispose should not trigger callback
      purchaseController.add([purchase]);
      await Future.delayed(Duration.zero);

      expect(purchases, isEmpty);
    });
  });
}

ProductDetails _createMockProduct(String id, double price) {
  final product = MockProductDetails();
  when(() => product.id).thenReturn(id);
  when(() => product.rawPrice).thenReturn(price);
  when(() => product.title).thenReturn(id);
  when(() => product.description).thenReturn('Test product');
  when(() => product.price).thenReturn('\$$price');
  when(() => product.currencyCode).thenReturn('USD');
  when(() => product.currencySymbol).thenReturn('\$');
  return product;
}
