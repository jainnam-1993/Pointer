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
    test('default values are correct (always premium in free mode)', () {
      const state = SubscriptionState();
      expect(state.tier, SubscriptionTier.premium); // Default is premium now
      expect(state.isLoading, false);
      expect(state.products, isEmpty); // Empty list - no IAP
      expect(state.error, isNull);
    });

    test('isPremium always returns true (all features free)', () {
      const state = SubscriptionState(tier: SubscriptionTier.premium);
      expect(state.isPremium, true);
    });

    test('isPremium returns true even for free tier (override)', () {
      // In the simplified model, isPremium always returns true
      const state = SubscriptionState(tier: SubscriptionTier.free);
      expect(state.isPremium, true); // Always true now
    });

    test('copyWith creates modified copy', () {
      const original = SubscriptionState(
        tier: SubscriptionTier.free,
        isLoading: false,
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
    });

    test('copyWith preserves unmodified fields', () {
      const original = SubscriptionState(
        tier: SubscriptionTier.premium,
        isLoading: false,
        error: 'test error',
      );

      final modified = original.copyWith(isLoading: true);

      expect(modified.tier, SubscriptionTier.premium); // preserved
      expect(modified.isLoading, true); // changed
      expect(modified.error, isNull); // copyWith clears nullable fields if not provided
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

    test('canViewPointing always returns true (freemium v2 model)', () {
      // Under freemium v2 model, all pointings are free regardless of view count
      final usage = DailyUsage(
        viewCount: 2, // At limit, but still returns true
        lastResetDate: _todayString(),
      );
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);
      // Quotes are free for all users now
      expect(notifier.canViewPointing(false), true);
      expect(notifier.state.limitReached, true); // State still tracks limit
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

  group('kFreeAccessEnabled', () {
    test('is set to true for free release', () {
      // IMPORTANT: Set to true for free app release (all features free, no IAP)
      expect(kFreeAccessEnabled, true);
    });

    test('is a compile-time constant', () {
      // Verify it's a const (can be used in const expressions)
      const value = kFreeAccessEnabled;
      expect(value, isA<bool>());
    });
  });
}

String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
