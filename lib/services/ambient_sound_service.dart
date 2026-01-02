import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'storage_service.dart';

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
  final storage = ref.watch(storageServiceProvider);
  return AmbientSoundNotifier(storage);
});

class AmbientSoundNotifier extends StateNotifier<AmbientSound> {
  final StorageService _storage;
  static const _storageKey = 'ambient_sound';

  AmbientSoundNotifier(this._storage) : super(AmbientSound.none) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = _storage.prefs.getString(_storageKey);
    if (saved != null) {
      state = AmbientSound.values.firstWhere(
        (s) => s.name == saved,
        orElse: () => AmbientSound.none,
      );
    }
  }

  void setSound(AmbientSound sound) {
    state = sound;
    _storage.prefs.setString(_storageKey, sound.name);
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
    // Skip if already played this session or no sound selected
    if (_hasPlayedThisSession || sound == AmbientSound.none) {
      return;
    }

    _hasPlayedThisSession = true;

    try {
      _player ??= AudioPlayer();
      await _player!.setAsset(sound.assetPath!);
      await _player!.play();
    } catch (e) {
      // Silently fail - ambient sound is not critical
    }
  }

  /// Dispose resources
  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
