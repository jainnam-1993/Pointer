import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Audio playback state
enum AudioPlaybackState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Service for playing audio pointings (guided readings, teachings).
///
/// Uses just_audio for cross-platform audio playback with:
/// - Background playback support
/// - Seek functionality
/// - Progress tracking
class AudioPointingService {
  static AudioPointingService? _instance;
  AudioPlayer? _player;

  final _stateController = StreamController<AudioPlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();

  String? _currentPointingId;

  AudioPointingService._();

  static AudioPointingService get instance {
    _instance ??= AudioPointingService._();
    return _instance!;
  }

  /// Stream of playback state changes
  Stream<AudioPlaybackState> get stateStream => _stateController.stream;

  /// Stream of playback position updates
  Stream<Duration> get positionStream => _positionController.stream;

  /// Stream of total duration (once known)
  Stream<Duration?> get durationStream => _durationController.stream;

  /// Currently playing pointing ID
  String? get currentPointingId => _currentPointingId;

  /// Current playback state
  AudioPlaybackState get currentState {
    if (_player == null) return AudioPlaybackState.idle;
    if (_player!.processingState == ProcessingState.loading ||
        _player!.processingState == ProcessingState.buffering) {
      return AudioPlaybackState.loading;
    }
    if (_player!.playing) return AudioPlaybackState.playing;
    if (_player!.processingState == ProcessingState.completed) {
      return AudioPlaybackState.completed;
    }
    return AudioPlaybackState.paused;
  }

  /// Initialize audio player (call once at app start)
  Future<void> initialize() async {
    _player = AudioPlayer();

    // Forward player state changes
    _player!.playerStateStream.listen((state) {
      _stateController.add(currentState);
    });

    // Forward position updates
    _player!.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Forward duration when available
    _player!.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    debugPrint('AudioPointingService: Initialized');
  }

  /// Load and play audio for a pointing
  Future<void> play(String pointingId, String audioUrl) async {
    if (_player == null) await initialize();

    try {
      _stateController.add(AudioPlaybackState.loading);
      _currentPointingId = pointingId;

      // Set audio source
      await _player!.setUrl(audioUrl);

      // Start playback
      await _player!.play();
    } catch (e) {
      debugPrint('AudioPointingService: Error playing - $e');
      _stateController.add(AudioPlaybackState.error);
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _player?.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player?.play();
  }

  /// Stop playback and release resources
  Future<void> stop() async {
    await _player?.stop();
    _currentPointingId = null;
    _stateController.add(AudioPlaybackState.idle);
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  /// Seek forward by seconds
  Future<void> seekForward({int seconds = 10}) async {
    final current = _player?.position ?? Duration.zero;
    final duration = _player?.duration ?? Duration.zero;
    final newPosition = current + Duration(seconds: seconds);
    await seek(newPosition > duration ? duration : newPosition);
  }

  /// Seek backward by seconds
  Future<void> seekBackward({int seconds = 10}) async {
    final current = _player?.position ?? Duration.zero;
    final newPosition = current - Duration(seconds: seconds);
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  /// Get current position
  Duration get position => _player?.position ?? Duration.zero;

  /// Get total duration
  Duration? get duration => _player?.duration;

  /// Is currently playing
  bool get isPlaying => _player?.playing ?? false;

  /// Dispose resources
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _stateController.close();
    _positionController.close();
    _durationController.close();
  }
}
