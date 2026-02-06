import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/subscription_providers.dart';

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

}
