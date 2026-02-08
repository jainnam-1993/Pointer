import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../services/ambient_sound_service.dart';

/// Full-screen branded video splash screen.
///
/// Plays a theme-aware nonduality animation (dark/light variant)
/// then auto-advances to the next screen. Tap anywhere to skip.
/// Respects system reduce-motion accessibility setting.
/// Mutes video audio when the user has set Opening Sound to "None".
class SplashScreen extends ConsumerStatefulWidget {
  /// Where to navigate after splash completes.
  final String destination;

  const SplashScreen({super.key, required this.destination});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Player? _player;
  VideoController? _videoController;
  StreamSubscription<bool>? _completedSub;
  bool _navigated = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    // Defer initialization to after first frame so we have access to theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeVideo();
    });
  }

  void _initializeVideo() {
    // Respect system reduce-motion accessibility setting
    if (MediaQuery.of(context).disableAnimations) {
      _navigateAway();
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = 'asset:///assets/videos/nonduality_${isDark ? 'black' : 'white'}.mp4';

    _player = Player();
    _videoController = VideoController(_player!);

    // Mute video when user has disabled opening sound
    final sound = ref.read(ambientSoundProvider);
    if (sound == AmbientSound.none) {
      _player!.setVolume(0.0);
    }

    // Listen for video completion before opening media
    _completedSub = _player!.stream.completed.listen((completed) {
      if (completed && !_navigated) {
        _navigateAway();
      }
    });

    // open() auto-plays by default
    _player!.open(Media(asset)).catchError((_) {
      // Video failed to load — skip to destination
      _navigateAway();
    });

    setState(() {});
  }

  void _navigateAway() {
    if (_navigated || !mounted) return;
    _navigated = true;

    // Fade out, then navigate
    setState(() => _opacity = 0.0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.go(widget.destination);
    });
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateAway,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: SizedBox.expand(
            child: _videoController != null ? Video(controller: _videoController!, fit: BoxFit.cover, controls: NoVideoControls) : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
