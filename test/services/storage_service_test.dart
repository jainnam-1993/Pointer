import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer_flutter/services/storage_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late StorageService storageService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    storageService = StorageService(mockPrefs);
  });

  group('AppSettings', () {
    test('default values are correct', () {
      const settings = AppSettings();
      expect(settings.hapticFeedback, true);
      expect(settings.autoAdvance, false);
      expect(settings.autoAdvanceDelay, 30);
      expect(settings.theme, 'dark');
    });

    test('copyWith creates new instance with updated values', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        hapticFeedback: false,
        autoAdvance: true,
        autoAdvanceDelay: 60,
        theme: 'light',
      );

      expect(updated.hapticFeedback, false);
      expect(updated.autoAdvance, true);
      expect(updated.autoAdvanceDelay, 60);
      expect(updated.theme, 'light');
      // Original unchanged
      expect(settings.hapticFeedback, true);
    });

    test('copyWith preserves values when not specified', () {
      final settings = const AppSettings(
        hapticFeedback: false,
        autoAdvance: true,
        autoAdvanceDelay: 45,
        theme: 'cosmic',
      );
      final updated = settings.copyWith(theme: 'midnight');

      expect(updated.hapticFeedback, false);
      expect(updated.autoAdvance, true);
      expect(updated.autoAdvanceDelay, 45);
      expect(updated.theme, 'midnight');
    });

    test('toJson serializes correctly', () {
      const settings = AppSettings(
        hapticFeedback: false,
        autoAdvance: true,
        autoAdvanceDelay: 45,
        theme: 'cosmic',
      );
      final json = settings.toJson();

      expect(json['hapticFeedback'], false);
      expect(json['autoAdvance'], true);
      expect(json['autoAdvanceDelay'], 45);
      expect(json['theme'], 'cosmic');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'hapticFeedback': false,
        'autoAdvance': true,
        'autoAdvanceDelay': 45,
        'theme': 'cosmic',
      };
      final settings = AppSettings.fromJson(json);

      expect(settings.hapticFeedback, false);
      expect(settings.autoAdvance, true);
      expect(settings.autoAdvanceDelay, 45);
      expect(settings.theme, 'cosmic');
    });

    test('fromJson uses defaults for missing values', () {
      final json = <String, dynamic>{};
      final settings = AppSettings.fromJson(json);

      expect(settings.hapticFeedback, true);
      expect(settings.autoAdvance, false);
      expect(settings.autoAdvanceDelay, 30);
      expect(settings.theme, 'dark');
    });
  });

  group('StorageKeys', () {
    test('has correct key values', () {
      expect(StorageKeys.onboardingCompleted, 'pointer_onboarding_completed');
      expect(StorageKeys.favoritePointings, 'pointer_favorites');
      expect(StorageKeys.viewedPointings, 'pointer_viewed');
      expect(StorageKeys.preferredTraditions, 'pointer_preferred_traditions');
      expect(StorageKeys.settings, 'pointer_settings');
      expect(StorageKeys.subscriptionTier, 'pointer_subscription');
    });
  });

  group('StorageService - Onboarding', () {
    test('hasCompletedOnboarding returns false when not set', () {
      when(() => mockPrefs.getBool(StorageKeys.onboardingCompleted))
          .thenReturn(null);
      expect(storageService.hasCompletedOnboarding, false);
    });

    test('hasCompletedOnboarding returns stored value', () {
      when(() => mockPrefs.getBool(StorageKeys.onboardingCompleted))
          .thenReturn(true);
      expect(storageService.hasCompletedOnboarding, true);
    });

    test('setOnboardingCompleted saves value', () async {
      when(() => mockPrefs.setBool(StorageKeys.onboardingCompleted, true))
          .thenAnswer((_) async => true);

      await storageService.setOnboardingCompleted(true);

      verify(() => mockPrefs.setBool(StorageKeys.onboardingCompleted, true))
          .called(1);
    });
  });

  group('StorageService - Favorites', () {
    test('favorites returns empty list when not set', () {
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(null);
      expect(storageService.favorites, isEmpty);
    });

    test('favorites returns stored list', () {
      final stored = jsonEncode(['adv-1', 'zen-1', 'dir-1']);
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(stored);

      final favorites = storageService.favorites;
      expect(favorites, ['adv-1', 'zen-1', 'dir-1']);
    });

    test('addFavorite adds new favorite', () async {
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(jsonEncode(['adv-1']));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.addFavorite('zen-1');

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.favoritePointings, captureAny()),
      ).captured.single as String;
      expect(jsonDecode(captured), ['adv-1', 'zen-1']);
    });

    test('addFavorite does not add duplicate', () async {
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(jsonEncode(['adv-1']));

      await storageService.addFavorite('adv-1');

      verifyNever(() => mockPrefs.setString(any(), any()));
    });

    test('removeFavorite removes existing favorite', () async {
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(jsonEncode(['adv-1', 'zen-1']));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.removeFavorite('adv-1');

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.favoritePointings, captureAny()),
      ).captured.single as String;
      expect(jsonDecode(captured), ['zen-1']);
    });

    test('isFavorite returns true for existing favorite', () {
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(jsonEncode(['adv-1', 'zen-1']));

      expect(storageService.isFavorite('adv-1'), true);
      expect(storageService.isFavorite('adv-99'), false);
    });
  });

  group('StorageService - Viewed Pointings', () {
    test('viewedPointings returns empty list when not set', () {
      when(() => mockPrefs.getString(StorageKeys.viewedPointings))
          .thenReturn(null);
      expect(storageService.viewedPointings, isEmpty);
    });

    test('viewedPointings returns stored list', () {
      final stored = jsonEncode([
        {'id': 'adv-1', 'viewedAt': 1234567890},
        {'id': 'zen-1', 'viewedAt': 1234567891},
      ]);
      when(() => mockPrefs.getString(StorageKeys.viewedPointings))
          .thenReturn(stored);

      final viewed = storageService.viewedPointings;
      expect(viewed.length, 2);
      expect(viewed[0]['id'], 'adv-1');
      expect(viewed[1]['id'], 'zen-1');
    });

    test('markPointingAsViewed adds new viewed pointing at front', () async {
      when(() => mockPrefs.getString(StorageKeys.viewedPointings))
          .thenReturn(jsonEncode([
        {'id': 'adv-1', 'viewedAt': 1234567890},
      ]));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.markPointingAsViewed('zen-1');

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.viewedPointings, captureAny()),
      ).captured.single as String;
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(captured));
      expect(decoded.length, 2);
      expect(decoded[0]['id'], 'zen-1'); // New one at front
      expect(decoded[1]['id'], 'adv-1');
    });

    test('markPointingAsViewed moves existing to front', () async {
      when(() => mockPrefs.getString(StorageKeys.viewedPointings))
          .thenReturn(jsonEncode([
        {'id': 'adv-1', 'viewedAt': 1234567890},
        {'id': 'zen-1', 'viewedAt': 1234567880},
      ]));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.markPointingAsViewed('zen-1');

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.viewedPointings, captureAny()),
      ).captured.single as String;
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(captured));
      expect(decoded.length, 2);
      expect(decoded[0]['id'], 'zen-1'); // Moved to front
      expect(decoded[1]['id'], 'adv-1');
    });

    test('markPointingAsViewed trims to 100 items', () async {
      final existing = List.generate(
        100,
        (i) => {'id': 'p-$i', 'viewedAt': 1234567890 - i},
      );
      when(() => mockPrefs.getString(StorageKeys.viewedPointings))
          .thenReturn(jsonEncode(existing));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.markPointingAsViewed('new-pointing');

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.viewedPointings, captureAny()),
      ).captured.single as String;
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(captured));
      expect(decoded.length, 100);
      expect(decoded[0]['id'], 'new-pointing');
      expect(decoded[99]['id'], 'p-98'); // p-99 was trimmed
    });
  });

  group('StorageService - Preferred Traditions', () {
    test('preferredTraditions returns empty list when not set', () {
      when(() => mockPrefs.getString(StorageKeys.preferredTraditions))
          .thenReturn(null);
      expect(storageService.preferredTraditions, isEmpty);
    });

    test('preferredTraditions returns stored list', () {
      final stored = jsonEncode(['advaita', 'zen']);
      when(() => mockPrefs.getString(StorageKeys.preferredTraditions))
          .thenReturn(stored);

      expect(storageService.preferredTraditions, ['advaita', 'zen']);
    });

    test('setPreferredTraditions saves list', () async {
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.setPreferredTraditions(['advaita', 'zen', 'direct']);

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.preferredTraditions, captureAny()),
      ).captured.single as String;
      expect(jsonDecode(captured), ['advaita', 'zen', 'direct']);
    });
  });

  group('StorageService - Settings', () {
    test('settings returns default when not set', () {
      when(() => mockPrefs.getString(StorageKeys.settings)).thenReturn(null);

      final settings = storageService.settings;
      expect(settings.hapticFeedback, true);
      expect(settings.autoAdvance, false);
      expect(settings.autoAdvanceDelay, 30);
      expect(settings.theme, 'dark');
    });

    test('settings returns stored settings', () {
      final stored = jsonEncode({
        'hapticFeedback': false,
        'autoAdvance': true,
        'autoAdvanceDelay': 60,
        'theme': 'cosmic',
      });
      when(() => mockPrefs.getString(StorageKeys.settings)).thenReturn(stored);

      final settings = storageService.settings;
      expect(settings.hapticFeedback, false);
      expect(settings.autoAdvance, true);
      expect(settings.autoAdvanceDelay, 60);
      expect(settings.theme, 'cosmic');
    });

    test('updateSettings saves settings', () async {
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      const newSettings = AppSettings(
        hapticFeedback: false,
        autoAdvance: true,
        autoAdvanceDelay: 45,
        theme: 'midnight',
      );
      await storageService.updateSettings(newSettings);

      final captured = verify(
        () => mockPrefs.setString(StorageKeys.settings, captureAny()),
      ).captured.single as String;
      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['hapticFeedback'], false);
      expect(decoded['autoAdvance'], true);
      expect(decoded['autoAdvanceDelay'], 45);
      expect(decoded['theme'], 'midnight');
    });
  });

  group('StorageService - Subscription', () {
    test('subscriptionTier returns free when not set', () {
      when(() => mockPrefs.getString(StorageKeys.subscriptionTier))
          .thenReturn(null);
      expect(storageService.subscriptionTier, 'free');
    });

    test('subscriptionTier returns stored value', () {
      when(() => mockPrefs.getString(StorageKeys.subscriptionTier))
          .thenReturn('premium');
      expect(storageService.subscriptionTier, 'premium');
    });

    test('setSubscriptionTier saves value', () async {
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await storageService.setSubscriptionTier('premium');

      verify(() => mockPrefs.setString(StorageKeys.subscriptionTier, 'premium'))
          .called(1);
    });
  });

  group('StorageService - Clear All', () {
    test('clearAll removes all storage keys', () async {
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      await storageService.clearAll();

      verify(() => mockPrefs.remove(StorageKeys.onboardingCompleted)).called(1);
      verify(() => mockPrefs.remove(StorageKeys.favoritePointings)).called(1);
      verify(() => mockPrefs.remove(StorageKeys.viewedPointings)).called(1);
      verify(() => mockPrefs.remove(StorageKeys.preferredTraditions)).called(1);
      verify(() => mockPrefs.remove(StorageKeys.settings)).called(1);
      verify(() => mockPrefs.remove(StorageKeys.subscriptionTier)).called(1);
    });
  });
}
