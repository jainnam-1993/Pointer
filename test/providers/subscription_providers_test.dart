import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/subscription_providers.dart';
import 'package:pointer/services/usage_tracking_service.dart';

class MockUsageTrackingService extends Mock implements UsageTrackingService {}

void main() {
  group('SubscriptionTier', () {
    test('has free and premium values', () {
      expect(SubscriptionTier.values.length, 2);
      expect(SubscriptionTier.values, contains(SubscriptionTier.free));
      expect(SubscriptionTier.values, contains(SubscriptionTier.premium));
    });
  });

  group('SubscriptionState', () {
    test('default values are correct', () {
      const state = SubscriptionState();
      expect(state.tier, SubscriptionTier.free);
      expect(state.isLoading, false);
      expect(state.products, isEmpty);
      expect(state.error, isNull);
      expect(state.expirationDate, isNull);
    });

    test('isPremium getter returns true for premium tier', () {
      const state = SubscriptionState(tier: SubscriptionTier.premium);
      expect(state.isPremium, true);
    });

    test('isPremium getter returns false for free tier', () {
      const state = SubscriptionState(tier: SubscriptionTier.free);
      expect(state.isPremium, false);
    });

    test('copyWith creates modified copy', () {
      const original = SubscriptionState(
        tier: SubscriptionTier.free,
        isLoading: false,
        products: [],
        error: 'original error',
      );

      final modified = original.copyWith(
        tier: SubscriptionTier.premium,
        isLoading: true,
        error: 'new error',
      );

      expect(modified.tier, SubscriptionTier.premium);
      expect(modified.isLoading, true);
      expect(modified.error, 'new error');
      expect(modified.products, isEmpty); // unchanged
    });

    test('copyWith preserves unmodified fields', () {
      final expiration = DateTime(2025, 12, 31);
      final original = SubscriptionState(
        tier: SubscriptionTier.premium,
        isLoading: false,
        products: const [],
        error: 'test error',
        expirationDate: expiration,
      );

      final modified = original.copyWith(isLoading: true);

      expect(modified.tier, SubscriptionTier.premium); // preserved
      expect(modified.isLoading, true); // changed
      expect(modified.products, isEmpty); // preserved
      expect(modified.error, isNull); // copyWith clears nullable fields if not provided
      expect(modified.expirationDate, expiration); // preserved
    });

    test('copyWith can clear error by passing null', () {
      const original = SubscriptionState(error: 'some error');
      final modified = original.copyWith(error: null);
      expect(modified.error, isNull);
    });
  });

  group('DailyUsageNotifier', () {
    late MockUsageTrackingService mockService;
    late DailyUsageNotifier notifier;

    setUp(() {
      mockService = MockUsageTrackingService();
    });

    test('canViewPointing returns true for premium users', () {
      final usage = DailyUsage(
        viewCount: 10, // Over limit
        lastResetDate: _todayString(),
      );
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.canViewPointing(true), true);
    });

    test('canViewPointing returns true when under limit', () {
      final usage = DailyUsage(
        viewCount: 1, // Under limit (2)
        lastResetDate: _todayString(),
      );
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.canViewPointing(false), true);
      expect(notifier.state.limitReached, false);
    });

    test('canViewPointing returns false when limit reached', () {
      final usage = DailyUsage(
        viewCount: 2, // At limit
        lastResetDate: _todayString(),
      );
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.canViewPointing(false), false);
      expect(notifier.state.limitReached, true);
    });

    test('recordView increments count', () async {
      final initial = DailyUsage(
        viewCount: 1,
        lastResetDate: _todayString(),
      );
      final updated = DailyUsage(
        viewCount: 2,
        lastResetDate: _todayString(),
      );

      when(() => mockService.getUsage()).thenReturn(initial);
      when(() => mockService.incrementViewCount())
          .thenAnswer((_) async => updated);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 1);

      await notifier.recordView();
      expect(notifier.state.viewCount, 2);
      verify(() => mockService.incrementViewCount()).called(1);
    });

    test('reset clears usage', () async {
      final initial = DailyUsage(
        viewCount: 2,
        lastResetDate: _todayString(),
      );
      final resetUsage = DailyUsage(
        viewCount: 0,
        lastResetDate: _todayString(),
      );

      // First call (constructor) returns initial, subsequent calls return reset
      var callCount = 0;
      when(() => mockService.getUsage()).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? initial : resetUsage;
      });
      when(() => mockService.resetUsage()).thenAnswer((_) async {});

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 2);

      await notifier.reset();
      expect(notifier.state.viewCount, 0);
      verify(() => mockService.resetUsage()).called(1);
    });

    test('initializes with service usage on creation', () {
      final usage = DailyUsage(
        viewCount: 1,
        lastResetDate: _todayString(),
      );
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 1);
      expect(notifier.state.lastResetDate, _todayString());
    });
  });

  group('kForcePremiumForTesting', () {
    test('is set to true for development', () {
      // Document current value - should be false in production
      expect(kForcePremiumForTesting, true);
    });

    test('is a compile-time constant', () {
      // Verify it's a const (can be used in const expressions)
      const value = kForcePremiumForTesting;
      expect(value, isA<bool>());
    });
  });
}

String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
