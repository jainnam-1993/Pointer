import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/core_providers.dart';

/** Ambient sound option played once on cold start to set a contemplative tone. */
enum AmbientSound {
  /** No sound on app open. */
  none('None', null),

  /** Single meditation bell strike. */
  bell('Bell', 'assets/sounds/bell.wav');
  // Future: singingBowl('Singing Bowl', 'assets/sounds/singing_bowl.wav'),
  // Future: softChime('Soft Chime', 'assets/sounds/soft_chime.wav');

  const AmbientSound(this.displayName, this.assetPath);

  /** Human-readable name shown in the settings picker. */
  final String displayName;

  /** Asset bundle path to the audio file, or `null` for [none]. */
  final String? assetPath;
}

/** Riverpod provider for the user's persisted [AmbientSound] preference. */
final ambientSoundProvider = StateNotifierProvider<AmbientSoundNotifier, AmbientSound>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AmbientSoundNotifier(prefs);
});

/**
 * Manages the user's selected [AmbientSound], persisting it to [SharedPreferences].
 */
class AmbientSoundNotifier extends StateNotifier<AmbientSound> {
  final SharedPreferences _prefs;
  static const _storageKey = 'ambient_sound';

  AmbientSoundNotifier(this._prefs) : super(AmbientSound.none) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = _prefs.getString(_storageKey);
    if (saved != null) {
      state = AmbientSound.values.firstWhere((s) => s.name == saved, orElse: () => AmbientSound.none);
    }
  }

  /** Update the selected sound and persist the choice. */
  void setSound(AmbientSound sound) {
    state = sound;
    _prefs.setString(_storageKey, sound.name);
  }
}

/** Riverpod provider exposing the [AmbientSoundService]. */
final ambientSoundServiceProvider = Provider<AmbientSoundService>((ref) {
  final service = AmbientSoundService();
  ref.onDispose(service.dispose);
  return service;
});

/**
 * Service for playing an ambient sound once on app cold start.
 *
 * Instance-based with provider-managed lifecycle. The playback guard
 * ([_isPlayingSound]) prevents duplicate plays within one instance's
 * lifetime. Access via [ambientSoundServiceProvider].
 */
class AmbientSoundService {
  AmbientSoundService();

  /** Audio player for opening sound playback. */
  AudioPlayer? _player;

  /** Guard flag preventing duplicate playback. */
  bool _isPlayingSound = false;

  /** Subscription to the player state stream, cancelled on cleanup. */
  StreamSubscription<PlayerState>? _playerStateSubscription;

  /** Play the opening sound (only on cold start) */
  Future<void> playOpeningSound(AmbientSound sound) async {
    if (sound == AmbientSound.none) {
      debugPrint('AmbientSound: Sound is none, skipping');
      return;
    }

    // Guard against double-plays
    if (_isPlayingSound) {
      debugPrint('AmbientSound: Already playing, skipping duplicate call');
      return;
    }
    _isPlayingSound = true;

    try {
      debugPrint('AmbientSound: Playing ${sound.assetPath}');

      // Dispose previous player/subscription if exists (cleanup)
      await _cleanup();

      _player = AudioPlayer();

      // Load the asset
      final duration = await _player!.setAsset(sound.assetPath!);
      debugPrint('AmbientSound: Asset loaded, duration: $duration');

      // Play the sound
      await _player!.play();
      debugPrint('AmbientSound: Play started successfully');

      // Wait for playback to complete (store subscription for cleanup)
      _playerStateSubscription = _player!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          debugPrint('AmbientSound: Playback completed');
          _cleanup();
        }
      });
    } catch (e, stack) {
      debugPrint('AmbientSound: Error playing sound: $e');
      debugPrint('AmbientSound: Stack trace: $stack');
      await _cleanup();
    }
  }

  /** Clean up resources and reset state */
  Future<void> _cleanup() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _player?.dispose();
    _player = null;
    _isPlayingSound = false;
  }

  /** Dispose resources */
  void dispose() {
    _cleanup();
  }
}
