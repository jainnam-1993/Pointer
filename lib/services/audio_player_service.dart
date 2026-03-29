/**
 * Base audio player service with common stream controllers and transport controls.
 *
 * Provides the shared infrastructure for any audio playback service:
 * - Broadcast streams for playback state, position, and duration
 * - Transport controls (pause, resume, stop, seek, seekForward, seekBackward)
 * - Player lifecycle management (initialization, disposal)
 *
 * Subclasses implement [play] to load audio from their specific source
 * (URL, asset, file, etc.).
 */
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/** Lifecycle state of the audio player. */
enum AudioPlaybackState {
  /** No audio loaded or player reset. */
  idle,

  /** Audio source is being loaded or buffered. */
  loading,

  /** Audio is actively playing. */
  playing,

  /** Playback is paused by the user. */
  paused,

  /** Playback reached the end of the audio. */
  completed,

  /** An error occurred during loading or playback. */
  error,
}

/**
 * Abstract base class for audio playback services.
 *
 * Manages an [AudioPlayer] instance, forwards its events to typed broadcast
 * streams, and provides transport controls. Subclasses override [play] to
 * load audio from their specific source type.
 */
abstract class AudioPlayerService {
  AudioPlayer? _player;

  final _stateController = StreamController<AudioPlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();

  /** Stream of playback state changes */
  Stream<AudioPlaybackState> get stateStream => _stateController.stream;

  /** Stream of playback position updates */
  Stream<Duration> get positionStream => _positionController.stream;

  /** Stream of total duration (once known) */
  Stream<Duration?> get durationStream => _durationController.stream;

  /** Current playback state derived from the underlying player. */
  AudioPlaybackState get currentState {
    if (_player == null) return AudioPlaybackState.idle;
    if (_player!.processingState == ProcessingState.loading || _player!.processingState == ProcessingState.buffering) {
      return AudioPlaybackState.loading;
    }
    if (_player!.playing) return AudioPlaybackState.playing;
    if (_player!.processingState == ProcessingState.completed) {
      return AudioPlaybackState.completed;
    }
    return AudioPlaybackState.paused;
  }

  /** The underlying [AudioPlayer], lazily initialized via [ensurePlayer]. */
  @protected
  AudioPlayer? get player => _player;

  /** The broadcast [StreamController] for playback state — used by subclasses to emit loading/error. */
  @protected
  StreamController<AudioPlaybackState> get stateController => _stateController;

  /** Initialize the audio player and wire up stream forwarding. */
  @mustCallSuper
  Future<void> ensurePlayer() async {
    if (_player != null) return;

    _player = AudioPlayer();

    _player!.playerStateStream.listen((state) {
      _stateController.add(currentState);
    });

    _player!.positionStream.listen((position) {
      _positionController.add(position);
    });

    _player!.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    debugPrint('$runtimeType: Player initialized');
  }

  /** Pause playback */
  Future<void> pause() async {
    await _player?.pause();
  }

  /** Resume playback */
  Future<void> resume() async {
    await _player?.play();
  }

  /** Stop playback and reset state */
  Future<void> stop() async {
    await _player?.stop();
    _stateController.add(AudioPlaybackState.idle);
  }

  /** Seek to an absolute position */
  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  /** Seek forward by [seconds] (default 10) */
  Future<void> seekForward({int seconds = 10}) async {
    final current = _player?.position ?? Duration.zero;
    final dur = _player?.duration ?? Duration.zero;
    final newPosition = current + Duration(seconds: seconds);
    await seek(newPosition > dur ? dur : newPosition);
  }

  /** Seek backward by [seconds] (default 10) */
  Future<void> seekBackward({int seconds = 10}) async {
    final current = _player?.position ?? Duration.zero;
    final newPosition = current - Duration(seconds: seconds);
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  /** Get current position */
  Duration get position => _player?.position ?? Duration.zero;

  /** Get total duration */
  Duration? get duration => _player?.duration;

  /** Is currently playing */
  bool get isPlaying => _player?.playing ?? false;

  /** Dispose the player and close all streams. */
  @mustCallSuper
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _stateController.close();
    _positionController.close();
    _durationController.close();
  }
}
