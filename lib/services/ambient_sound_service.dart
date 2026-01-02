import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/core_providers.dart';

/// Available ambient sounds for app opening
enum AmbientSound {
  none('None', null),
  bell('Bell', 'assets/sounds/bell.wav');
  // Future: singingBowl('Singing Bowl', 'assets/sounds/singing_bowl.wav'),
  // Future: softChime('Soft Chime', 'assets/sounds/soft_chime.wav');

  const AmbientSound(this.displayName, this.assetPath);
  final String displayName;
  final String? assetPath;
}

/// Provider for ambient sound selection (persisted)
final ambientSoundProvider = StateNotifierProvider<AmbientSoundNotifier, AmbientSound>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AmbientSoundNotifier(prefs);
});

class AmbientSoundNotifier extends StateNotifier<AmbientSound> {
  final SharedPreferences _prefs;
  static const _storageKey = 'ambient_sound';

  AmbientSoundNotifier(this._prefs) : super(AmbientSound.none) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = _prefs.getString(_storageKey);
    if (saved != null) {
      state = AmbientSound.values.firstWhere(
        (s) => s.name == saved,
        orElse: () => AmbientSound.none,
      );
    }
  }

  void setSound(AmbientSound sound) {
    state = sound;
    _prefs.setString(_storageKey, sound.name);
  }
}

/// Provider for ambient sound service
final ambientSoundServiceProvider = Provider<AmbientSoundService>((ref) {
  return AmbientSoundService();
});

/// Service for playing ambient sounds on app open
class AmbientSoundService {
  AudioPlayer? _player;
  bool _hasPlayedThisSession = false;

  /// Play the opening sound (only on cold start, not resume)
  Future<void> playOpeningSound(AmbientSound sound) async {
    debugPrint('AmbientSound: playOpeningSound called with ${sound.name}');

    // Skip if already played this session or no sound selected
    if (_hasPlayedThisSession) {
      debugPrint('AmbientSound: Already played this session, skipping');
      return;
    }

    if (sound == AmbientSound.none) {
      debugPrint('AmbientSound: Sound is none, skipping');
      return;
    }

    _hasPlayedThisSession = true;

    try {
      debugPrint('AmbientSound: Playing ${sound.assetPath}');

      // Create fresh player for each play to avoid state issues
      _player?.dispose();
      _player = AudioPlayer();

      // Load the asset - this returns the duration if successful
      final duration = await _player!.setAsset(sound.assetPath!);
      debugPrint('AmbientSound: Asset loaded, duration: $duration');

      // Play the sound
      await _player!.play();
      debugPrint('AmbientSound: Play started successfully');

      // Wait for playback to complete, then dispose
      _player!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          debugPrint('AmbientSound: Playback completed');
          _player?.dispose();
          _player = null;
        }
      });
    } catch (e, stack) {
      debugPrint('AmbientSound: Error playing sound: $e');
      debugPrint('AmbientSound: Stack trace: $stack');
      // Reset flag so user can retry on next launch if error occurred
      _hasPlayedThisSession = false;
    }
  }

  /// Dispose resources
  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
