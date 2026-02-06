import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/services/donation_service.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/services/notification_service.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/donation_button.dart';
import 'package:pointer/widgets/glass_card.dart';

late SharedPreferences prefs;

/// Mock notification service
class MockNotificationService extends Mock implements NotificationService {}

/// Premium subscription state for testing
final _premiumState = SubscriptionState(
  tier: SubscriptionTier.premium,
  isLoading: false,
);

/// Mock donation service for testing
class MockDonationService extends DonationService {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<ProductDetails>> loadProducts() async => [];

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => const Stream.empty();

  @override
  Future<void> purchaseProduct(ProductDetails product) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  void dispose() {}
}

/// Test notifier for donation state
class TestDonationNotifier extends DonationNotifier {
  final DonationState _initialState;

  TestDonationNotifier(this._initialState, DonationService service)
      : super(service);

  @override
  Future<void> initialize() async {
    // Don't initialize - use the provided state
    state = _initialState;
  }

  void setTestState(DonationState newState) {
    state = newState;
  }
}

/// Test subscription notifier that returns fixed state
class _TestSubscriptionNotifier extends SubscriptionNotifier {
  final SubscriptionState _fixedState;

  _TestSubscriptionNotifier(this._fixedState) : super(_MockStorageService());

  @override
  SubscriptionState get state => _fixedState;
}

/// Minimal mock storage service for testing
class _MockStorageService extends StorageService {
  _MockStorageService() : super(prefs);
}

/// Create mock ProductDetails for testing
ProductDetails createMockProduct({
  required String id,
  required String title,
  required String price,
}) {
  return ProductDetails(
    id: id,
    title: title,
    description: 'Test product $id',
    price: price,
    rawPrice: 1.99,
    currencyCode: 'USD',
  );
}

/// Helper to wrap widget with ProviderScope for testing
Widget wrapWithProviderScope(
  Widget child, {
  DonationState? donationState,
  MockNotificationService? notificationService,
}) {
  final mockNotificationService = notificationService ?? MockNotificationService();

  // Setup default mock behavior
  when(() => mockNotificationService.checkPermissions())
      .thenAnswer((_) async => true);
  when(() => mockNotificationService.isNotificationsEnabled).thenReturn(false);
  when(() => mockNotificationService.getSchedule()).thenReturn(
    NotificationSchedule(
      startHour: 8,
      startMinute: 0,
      endHour: 21,
      endMinute: 0,
      frequencyMinutes: 180,
    ),
  );

  // Default donation state with products
  final defaultProducts = [
    createMockProduct(id: 'tip_small', title: 'Small Tip', price: '\$0.99'),
    createMockProduct(id: 'tip_medium', title: 'Medium Tip', price: '\$2.99'),
    createMockProduct(id: 'tip_large', title: 'Large Tip', price: '\$4.99'),
    createMockProduct(id: 'tip_generous', title: 'Generous Tip', price: '\$9.99'),
  ];

  final donation = donationState ??
      DonationState(
        isAvailable: true,
        isLoading: false,
        products: defaultProducts,
      );

  final mockDonationService = MockDonationService();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
      notificationServiceProvider.overrideWithValue(mockNotificationService),
      subscriptionProvider.overrideWith(
        (ref) => _TestSubscriptionNotifier(_premiumState),
      ),
      backgroundShimmerActiveProvider.overrideWith((ref) => false),
      donationServiceProvider.overrideWithValue(mockDonationService),
      donationProvider.overrideWith(
        (ref) => TestDonationNotifier(donation, mockDonationService),
      ),
    ],
    child: child,
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'pointer_onboarding_completed': true,
    });
    prefs = await SharedPreferences.getInstance();

    // Disable animations for tests
    AnimatedGradient.disableAnimations = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
  });

  group('SettingsScreen', () {
    testWidgets('renders Settings title', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders notification section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Daily Pointings'), findsOneWidget);
    });

    testWidgets('renders appearance section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });
  });

  group('SettingsScreen Donation Integration', () {
    // Helper: DonationButton is now inline at bottom of ListView (not floating),
    // so we need to scroll down to bring it into the viewport.
    Future<void> scrollToDonationButton(WidgetTester tester) async {
      final listView = find.byType(ListView);
      // Scroll to the bottom to reveal inline DonationButton
      await tester.drag(listView, const Offset(0, -800));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('shows DonationButton below About section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await scrollToDonationButton(tester);

      // DonationButton should be present after scrolling
      expect(find.byType(DonationButton), findsOneWidget);
    });

    testWidgets('DonationButton is in ListView (inline, not floating)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await scrollToDonationButton(tester);

      // DonationButton should be a descendant of ListView (inline, not floating)
      expect(
        find.ancestor(
          of: find.byType(DonationButton),
          matching: find.byType(ListView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides DonationButton when donations not available', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
          donationState: const DonationState(
            isAvailable: false,
            isLoading: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await scrollToDonationButton(tester);

      // DonationButton should be present but render empty
      expect(find.byType(DonationButton), findsOneWidget);
      // But Support Development text should not be visible
      expect(find.text('Support Development'), findsNothing);
    });

    testWidgets('DonationButton expands when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await scrollToDonationButton(tester);

      // Tap the donation button header
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show expanded content
      expect(
        find.text('Here Now is free forever. If you find value, consider supporting development.'),
        findsOneWidget,
      );
    });

    testWidgets('shows tip options when DonationButton expanded', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await scrollToDonationButton(tester);

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show product options
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Cushion'), findsOneWidget);
      expect(find.text('Incense'), findsOneWidget);
      expect(find.text('Retreat'), findsOneWidget);
    });

    testWidgets('DonationButton uses GlassCard styling', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await scrollToDonationButton(tester);

      // Should have GlassCard within DonationButton
      expect(
        find.descendant(
          of: find.byType(DonationButton),
          matching: find.byType(GlassCard),
        ),
        findsOneWidget,
      );
    });
  });
}
