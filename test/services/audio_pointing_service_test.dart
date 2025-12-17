import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_flutter/services/audio_pointing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlaybackState', () {
    test('enum has all expected values', () {
      expect(AudioPlaybackState.values, [
        AudioPlaybackState.idle,
        AudioPlaybackState.loading,
        AudioPlaybackState.playing,
        AudioPlaybackState.paused,
        AudioPlaybackState.completed,
        AudioPlaybackState.error,
      ]);
    });

    test('enum values have correct index', () {
      expect(AudioPlaybackState.idle.index, 0);
      expect(AudioPlaybackState.loading.index, 1);
      expect(AudioPlaybackState.playing.index, 2);
      expect(AudioPlaybackState.paused.index, 3);
      expect(AudioPlaybackState.completed.index, 4);
      expect(AudioPlaybackState.error.index, 5);
    });
  });

  group('AudioPointingService - Singleton', () {
    test('instance returns same instance', () {
      final instance1 = AudioPointingService.instance;
      final instance2 = AudioPointingService.instance;
      expect(identical(instance1, instance2), true);
    });

    test('instance is not null', () {
      expect(AudioPointingService.instance, isNotNull);
    });
  });

  group('AudioPointingService - Initial State', () {
    late AudioPointingService service;

    setUp(() {
      service = AudioPointingService.instance;
    });

    test('currentState is idle initially', () {
      expect(service.currentState, AudioPlaybackState.idle);
    });

    test('currentPointingId is null initially', () {
      expect(service.currentPointingId, null);
    });

    test('isPlaying is false initially', () {
      expect(service.isPlaying, false);
    });

    test('position is zero initially', () {
      expect(service.position, Duration.zero);
    });

    test('duration is null initially', () {
      expect(service.duration, null);
    });
  });

  group('AudioPointingService - Streams', () {
    late AudioPointingService service;

    setUp(() {
      service = AudioPointingService.instance;
    });

    test('stateStream is broadcast stream', () {
      expect(service.stateStream, isA<Stream<AudioPlaybackState>>());
      expect(service.stateStream.isBroadcast, true);
    });

    test('positionStream is broadcast stream', () {
      expect(service.positionStream, isA<Stream<Duration>>());
      expect(service.positionStream.isBroadcast, true);
    });

    test('durationStream is broadcast stream', () {
      expect(service.durationStream, isA<Stream<Duration?>>());
      expect(service.durationStream.isBroadcast, true);
    });

    test('multiple listeners can subscribe to stateStream', () {
      final subscription1 = service.stateStream.listen((_) {});
      final subscription2 = service.stateStream.listen((_) {});

      // Should not throw for broadcast streams
      expect(subscription1, isNotNull);
      expect(subscription2, isNotNull);

      subscription1.cancel();
      subscription2.cancel();
    });
  });

  group('AudioPointingService - Playback Control (null safety)', () {
    late AudioPointingService service;

    setUp(() {
      service = AudioPointingService.instance;
    });

    test('pause does nothing when player is null', () async {
      await service.pause();
      // Should not throw
      expect(service.currentState, AudioPlaybackState.idle);
    });

    test('resume does nothing when player is null', () async {
      await service.resume();
      // Should not throw
      expect(service.currentState, AudioPlaybackState.idle);
    });

    test('stop does nothing when player is null', () async {
      await service.stop();
      // Should not throw
      expect(service.currentPointingId, null);
      expect(service.currentState, AudioPlaybackState.idle);
    });

    test('seek does nothing when player is null', () async {
      await service.seek(Duration(seconds: 60));
      // Should not throw
      expect(service.position, Duration.zero);
    });

    test('seekForward does nothing when player is null', () async {
      await service.seekForward();
      // Should not throw
      expect(service.position, Duration.zero);
    });

    test('seekBackward does nothing when player is null', () async {
      await service.seekBackward();
      // Should not throw
      expect(service.position, Duration.zero);
    });
  });

  group('AudioPointingService - Seek Calculation', () {
    test('seekForward with custom seconds parameter', () async {
      final service = AudioPointingService.instance;

      // Test with default parameter (should accept seconds: 10)
      await service.seekForward(seconds: 10);
      expect(service.position, Duration.zero); // Player null, so zero
    });

    test('seekBackward with custom seconds parameter', () async {
      final service = AudioPointingService.instance;

      // Test with default parameter (should accept seconds: 10)
      await service.seekBackward(seconds: 10);
      expect(service.position, Duration.zero); // Player null, so zero
    });
  });

  group('AudioPointingService - State Stream Broadcasting', () {
    late AudioPointingService service;

    setUp(() {
      service = AudioPointingService.instance;
    });

    test('stop broadcasts idle state', () async {
      final states = <AudioPlaybackState>[];
      final subscription = service.stateStream.listen(states.add);

      await service.stop();

      // Give it time to emit
      await Future.delayed(Duration(milliseconds: 50));

      expect(states, contains(AudioPlaybackState.idle));

      await subscription.cancel();
    });
  });
}
