/**
 * Audio pointing playback service — loads and plays audio from URLs.
 *
 * Extends [AudioPlayerService] with URL-based audio loading for
 * guided readings and teachings. Tracks the currently playing
 * pointing ID so UI widgets can show per-pointing playback state.
 *
 * Access via [audioPointingServiceProvider] in the Riverpod graph.
 */
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_player_service.dart';

// Re-export the base class types so consumers get everything from one import
export 'audio_player_service.dart' show AudioPlaybackState;

/** Riverpod provider for the [AudioPointingService]. */
final audioPointingServiceProvider = Provider<AudioPointingService>((ref) {
  final service = AudioPointingService();
  ref.onDispose(() => service.dispose());
  return service;
});

/**
 * Service for playing audio pointings (guided readings, teachings).
 *
 * Uses just_audio via [AudioPlayerService] for cross-platform playback with:
 * - Background playback support
 * - Seek functionality
 * - Progress tracking
 */
class AudioPointingService extends AudioPlayerService {
  String? _currentPointingId;

  /** Currently playing pointing ID */
  String? get currentPointingId => _currentPointingId;

  /** Load and play audio for a pointing from a URL. */
  Future<void> play(String pointingId, String audioUrl) async {
    await ensurePlayer();

    try {
      stateController.add(AudioPlaybackState.loading);
      _currentPointingId = pointingId;

      // Set audio source
      await player!.setUrl(audioUrl);

      // Start playback
      await player!.play();
    } catch (e) {
      debugPrint('AudioPointingService: Error playing - $e');
      stateController.add(AudioPlaybackState.error);
    }
  }

  @override
  Future<void> stop() async {
    _currentPointingId = null;
    await super.stop();
  }
}
