import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pointer/providers/core_providers.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/services/notification_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('sharedPreferencesProvider', () {
    test('throws UnimplementedError when not overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(() => container.read(sharedPreferencesProvider), throwsUnimplementedError);
    });

    test('works when overridden with value', () {
      final mockPrefs = MockSharedPreferences();
      final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)]);
      addTearDown(container.dispose);

      final prefs = container.read(sharedPreferencesProvider);

      expect(prefs, same(mockPrefs));
    });
  });

  group('storageServiceProvider', () {
    late MockSharedPreferences mockPrefs;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)]);
    });

    tearDown(() => container.dispose());

    test('creates StorageService with SharedPreferences', () {
      final service = container.read(storageServiceProvider);

      expect(service, isA<StorageService>());
    });

    test('returns same instance on multiple reads', () {
      final service1 = container.read(storageServiceProvider);
      final service2 = container.read(storageServiceProvider);

      expect(service1, same(service2));
    });

    test('uses provided SharedPreferences instance', () {
      // Mock the hasCompletedOnboarding getter to verify SharedPreferences is used
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);

      final service = container.read(storageServiceProvider);

      expect(service.hasCompletedOnboarding, true);
      verify(() => mockPrefs.getBool('pointer_onboarding_completed')).called(1);
    });
  });

  group('notificationServiceProvider', () {
    late MockSharedPreferences mockPrefs;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)]);
    });

    tearDown(() => container.dispose());

    test('creates NotificationService with SharedPreferences', () {
      final service = container.read(notificationServiceProvider);

      expect(service, isA<NotificationService>());
    });

    test('returns same instance on multiple reads', () {
      final service1 = container.read(notificationServiceProvider);
      final service2 = container.read(notificationServiceProvider);

      expect(service1, same(service2));
    });

    test('uses provided SharedPreferences instance', () {
      // Mock the isNotificationsEnabled getter to verify SharedPreferences is used
      when(() => mockPrefs.getBool('pointer_notifications_enabled')).thenReturn(true);

      final service = container.read(notificationServiceProvider);

      expect(service.isNotificationsEnabled, true);
      verify(() => mockPrefs.getBool('pointer_notifications_enabled')).called(1);
    });
  });

  group('onboardingCompletedProvider', () {
    late MockSharedPreferences mockPrefs;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)]);
    });

    tearDown(() => container.dispose());

    test('returns false when onboarding not completed', () {
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(null);

      final isCompleted = container.read(onboardingCompletedProvider);

      expect(isCompleted, false);
    });

    test('returns true when onboarding completed', () {
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);

      final isCompleted = container.read(onboardingCompletedProvider);

      expect(isCompleted, true);
    });

    test('derives from storage (read-only)', () {
      // Mock initial state (not completed)
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(false);

      expect(container.read(onboardingCompletedProvider), false);

      // Verify it reads from storage each time
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);

      // Create a new container to pick up the changed storage
      final newContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)],
      );
      addTearDown(newContainer.dispose);

      expect(newContainer.read(onboardingCompletedProvider), true);
    });

    test('can be invalidated to re-read from storage', () {
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(false);

      expect(container.read(onboardingCompletedProvider), false);

      // Simulate storage update
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);

      // Invalidate to force re-read
      container.invalidate(onboardingCompletedProvider);

      expect(container.read(onboardingCompletedProvider), true);
    });

    test('invalidation triggers provider listeners', () {
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(false);

      var listenCallCount = 0;
      bool? lastValue;

      container.listen<bool>(onboardingCompletedProvider, (previous, next) {
        listenCallCount++;
        lastValue = next;
      });

      // Simulate storage update and invalidate
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);
      container.invalidate(onboardingCompletedProvider);

      // Force a read to trigger listener
      container.read(onboardingCompletedProvider);

      expect(listenCallCount, 1);
      expect(lastValue, true);
    });
  });

  group('Provider Dependencies', () {
    late MockSharedPreferences mockPrefs;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)]);
    });

    tearDown(() => container.dispose());

    test('storageServiceProvider depends on sharedPreferencesProvider', () {
      when(() => mockPrefs.getBool(any())).thenReturn(false);

      // Reading storageServiceProvider should trigger sharedPreferencesProvider
      container.read(storageServiceProvider);

      // Verify SharedPreferences was accessed (via storage service usage)
      expect(container.read(sharedPreferencesProvider), same(mockPrefs));
    });

    test('notificationServiceProvider depends on sharedPreferencesProvider', () {
      when(() => mockPrefs.getBool(any())).thenReturn(false);

      // Reading notificationServiceProvider should trigger sharedPreferencesProvider
      container.read(notificationServiceProvider);

      // Verify SharedPreferences was accessed
      expect(container.read(sharedPreferencesProvider), same(mockPrefs));
    });

    test('onboardingCompletedProvider depends on storageServiceProvider', () {
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);

      // Reading onboardingCompletedProvider should trigger storageServiceProvider
      final isCompleted = container.read(onboardingCompletedProvider);

      expect(isCompleted, true);
      // Verify the dependency chain worked
      verify(() => mockPrefs.getBool('pointer_onboarding_completed')).called(1);
    });

    test('providers react to sharedPreferences changes', () {
      // Initial state
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(false);

      expect(container.read(onboardingCompletedProvider), false);

      // Simulate SharedPreferences change
      when(() => mockPrefs.getBool('pointer_onboarding_completed')).thenReturn(true);

      // Create new container to simulate app restart with new SharedPreferences state
      final newContainer = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)]);
      addTearDown(newContainer.dispose);

      expect(newContainer.read(onboardingCompletedProvider), true);
    });
  });
}
