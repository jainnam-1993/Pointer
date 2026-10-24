import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart' show InAppPurchasePlatformAddition;

/// Fake store behind the real [InAppPurchase] API, so tests drive
/// `DonationService`, `TipPurchaseListener` and `DonationNotifier` through
/// their production code paths.
class FakeInAppPurchase implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> _controller = StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  List<ProductDetails> products = [];
  bool buyResult = true;
  Object? buyError;
  Object? completeError;
  BillingResponse consumeResponse = BillingResponse.ok;
  List<PurchaseDetails> restorable = [];

  bool? lastAutoConsume;
  int buyCalls = 0;
  int restoreCalls = 0;
  final List<PurchaseDetails> completed = [];
  final List<PurchaseDetails> consumed = [];

  late final FakeAndroidAddition _addition = FakeAndroidAddition(this);

  /// Deliver a batch of purchase updates, as the platform would.
  void emit(List<PurchaseDetails> purchases) => _controller.add(purchases);

  /// Deliver a stream-level error.
  void emitError(Object error) => _controller.addError(error);

  Future<void> close() => _controller.close();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async =>
      ProductDetailsResponse(productDetails: products.where((p) => identifiers.contains(p.id)).toList(), notFoundIDs: const []);

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) async {
    buyCalls++;
    lastAutoConsume = autoConsume;
    if (buyError != null) throw buyError!;
    return buyResult;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (completeError != null) throw completeError!;
    completed.add(purchase);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreCalls++;
    if (restorable.isNotEmpty) _controller.add(restorable);
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() => _addition as T;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAndroidAddition implements InAppPurchaseAndroidPlatformAddition {
  final FakeInAppPurchase _iap;

  FakeAndroidAddition(this._iap);

  @override
  Future<BillingResultWrapper> consumePurchase(PurchaseDetails purchase) async {
    _iap.consumed.add(purchase);
    return BillingResultWrapper(responseCode: _iap.consumeResponse);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProductDetails tipProduct(String id, {double price = 0.99}) =>
    ProductDetails(id: id, title: id, description: 'Tip $id', price: '\$$price', rawPrice: price, currencyCode: 'USD');

/// A store-neutral purchase update (StoreKit-shaped).
PurchaseDetails purchaseUpdate(String productId, PurchaseStatus status, {bool pendingComplete = true, String? errorMessage}) {
  final details = PurchaseDetails(
    purchaseID: 'order-$productId',
    productID: productId,
    verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: 'token-$productId', source: 'test'),
    transactionDate: '0',
    status: status,
  )..pendingCompletePurchase = pendingComplete;
  if (errorMessage != null) details.error = IAPError(source: 'test', code: 'error', message: errorMessage);
  return details;
}

/// A Play purchase as `restorePurchases` reports it at startup.
GooglePlayPurchaseDetails playPurchase(
  String productId, {
  PurchaseStatus status = PurchaseStatus.restored,
  PurchaseStateWrapper state = PurchaseStateWrapper.purchased,
}) {
  final wrapper = PurchaseWrapper(
    orderId: 'order-$productId',
    packageName: 'com.dailypointer.app',
    purchaseTime: 0,
    purchaseToken: 'token-$productId',
    signature: 'sig',
    products: [productId],
    isAutoRenewing: false,
    originalJson: '{}',
    isAcknowledged: false,
    purchaseState: state,
  );
  return GooglePlayPurchaseDetails.fromPurchase(wrapper).first..status = status;
}
