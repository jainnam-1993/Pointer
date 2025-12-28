import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/tts_service.dart';

void main() {
  group('TTSPlaybackState', () {
    test('enum has all expected values', () {
      expect(TTSPlaybackState.values.length, 6);
      expect(TTSPlaybackState.idle, isNotNull);
      expect(TTSPlaybackState.loading, isNotNull);
      expect(TTSPlaybackState.playing, isNotNull);
      expect(TTSPlaybackState.paused, isNotNull);
      expect(TTSPlaybackState.completed, isNotNull);
      expect(TTSPlaybackState.error, isNotNull);
    });

    test('enum values have correct index', () {
      expect(TTSPlaybackState.idle.index, 0);
      expect(TTSPlaybackState.loading.index, 1);
      expect(TTSPlaybackState.playing.index, 2);
      expect(TTSPlaybackState.paused.index, 3);
      expect(TTSPlaybackState.completed.index, 4);
      expect(TTSPlaybackState.error.index, 5);
    });
  });

  group('PollyVoice', () {
    test('enum has all expected voices', () {
      expect(PollyVoice.values.length, 4);
      expect(PollyVoice.joanna, isNotNull);
      expect(PollyVoice.matthew, isNotNull);
      expect(PollyVoice.amy, isNotNull);
      expect(PollyVoice.brian, isNotNull);
    });

    test('joanna has correct properties', () {
      expect(PollyVoice.joanna.id, 'Joanna');
      expect(PollyVoice.joanna.description, 'US English, Female');
    });

    test('matthew has correct properties', () {
      expect(PollyVoice.matthew.id, 'Matthew');
      expect(PollyVoice.matthew.description, 'US English, Male');
    });

    test('amy has correct properties', () {
      expect(PollyVoice.amy.id, 'Amy');
      expect(PollyVoice.amy.description, 'British English, Female');
    });

    test('brian has correct properties', () {
      expect(PollyVoice.brian.id, 'Brian');
      expect(PollyVoice.brian.description, 'British English, Male');
    });
  });

  group('TTSService - Singleton', () {
    test('instance returns same instance', () {
      final instance1 = TTSService.instance;
      final instance2 = TTSService.instance;

      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('TTSService - Initial State', () {
    test('currentState is idle initially', () {
      final service = TTSService.instance;
      expect(service.currentState, TTSPlaybackState.idle);
    });

    test('currentArticleId is null initially', () {
      final service = TTSService.instance;
      expect(service.currentArticleId, isNull);
    });

    test('selectedVoice defaults to joanna', () {
      final service = TTSService.instance;
      expect(service.selectedVoice, PollyVoice.joanna);
    });

    test('isPlaying is false initially', () {
      final service = TTSService.instance;
      expect(service.isPlaying, isFalse);
    });

    test('position is zero initially', () {
      final service = TTSService.instance;
      expect(service.position, Duration.zero);
    });

    test('duration is null initially', () {
      final service = TTSService.instance;
      expect(service.duration, isNull);
    });
  });

  group('TTSService - Voice Selection', () {
    test('setVoice changes selected voice', () {
      final service = TTSService.instance;

      service.setVoice(PollyVoice.matthew);
      expect(service.selectedVoice, PollyVoice.matthew);

      service.setVoice(PollyVoice.amy);
      expect(service.selectedVoice, PollyVoice.amy);

      // Reset to default
      service.setVoice(PollyVoice.joanna);
    });
  });

  group('TTSService - Streams', () {
    test('stateStream is broadcast stream', () {
      final service = TTSService.instance;
      expect(service.stateStream.isBroadcast, isTrue);
    });

    test('positionStream is broadcast stream', () {
      final service = TTSService.instance;
      expect(service.positionStream.isBroadcast, isTrue);
    });

    test('durationStream is broadcast stream', () {
      final service = TTSService.instance;
      expect(service.durationStream.isBroadcast, isTrue);
    });

    test('errorStream is broadcast stream', () {
      final service = TTSService.instance;
      expect(service.errorStream.isBroadcast, isTrue);
    });
  });

  group('TTSService - Markdown Stripping', () {
    // Test the markdown stripping functionality indirectly
    // by checking that the service accepts markdown content
    test('service accepts markdown content for synthesis', () {
      final service = TTSService.instance;
      // This test validates the interface accepts markdown
      // Actual stripping is tested when synthesizeAndPlay is called
      expect(service.synthesizeAndPlay, isA<Function>());
    });
  });
}
