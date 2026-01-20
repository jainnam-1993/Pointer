
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/services/ambient_sound_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('AmbientSound enum', () {
    test('none has null assetPath', () {
      expect(AmbientSound.none.assetPath, isNull);
      expect(AmbientSound.none.displayName, 'None');
    });

    test('bell has correct assetPath', () {
      expect(AmbientSound.bell.assetPath, 'assets/sounds/bell.wav');
      expect(AmbientSound.bell.displayName, 'Bell');
    });

    test('all values have displayName', () {
      for (final sound in AmbientSound.values) {
        expect(sound.displayName, isNotEmpty);
      }
    });
  });

  group('AmbientSoundNotifier', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
    });

    test('defaults to none when no saved value', () {
      when(() => mockPrefs.getString('ambient_sound')).thenReturn(null);

      final notifier = AmbientSoundNotifier(mockPrefs);

      expect(notifier.state, AmbientSound.none);
    });

    test('loads saved sound from storage', () {
      when(() => mockPrefs.getString('ambient_sound')).thenReturn('bell');

      final notifier = AmbientSoundNotifier(mockPrefs);

      expect(notifier.state, AmbientSound.bell);
    });

    test('defaults to none for invalid stored value', () {
      when(() => mockPrefs.getString('ambient_sound'))
          .thenReturn('invalid_sound');

      final notifier = AmbientSoundNotifier(mockPrefs);

      expect(notifier.state, AmbientSound.none);
    });

    test('setSound updates state and persists', () {
      when(() => mockPrefs.getString('ambient_sound')).thenReturn(null);
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);

      final notifier = AmbientSoundNotifier(mockPrefs);
      expect(notifier.state, AmbientSound.none);

      notifier.setSound(AmbientSound.bell);

      expect(notifier.state, AmbientSound.bell);
      verify(() => mockPrefs.setString('ambient_sound', 'bell')).called(1);
    });
  });

  group('AmbientSoundService', () {
    test('singleton instance returns same object', () {
      final instance1 = AmbientSoundService.instance;
      final instance2 = AmbientSoundService.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('playOpeningSound skips when sound is none', () async {
      final service = AmbientSoundService.instance;

      // Should return immediately without error
      await service.playOpeningSound(AmbientSound.none);

      // Test passes if no exception thrown
    });

    // Note: Tests involving AudioPlayer are skipped in unit tests
    // because they require platform plugins. Integration tests
    // should verify actual audio playback.
  });

  group('AmbientSoundService edge cases', () {
    test('handles AmbientSound.none gracefully', () async {
      final service = AmbientSoundService.instance;

      // Should return early and not attempt playback
      await service.playOpeningSound(AmbientSound.none);

      // Verify by checking logs would show "Sound is none, skipping"
      // In unit tests, we just verify no exception thrown
    });
  });
}
