import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Full-screen video splash screen.
///
/// Plays the nonduality_black.mp4 video (3.5s enso animation on black),
/// then navigates to the destination. Tap anywhere to skip.
/// Respects system reduce-motion accessibility setting.
///
/// Includes a timeout guard: if video initialization doesn't complete
/// within [_initTimeout], skips directly to destination (prevents hanging
/// on emulators with software H.264 decoders).
class SplashScreen extends StatefulWidget {
  final String destination;

  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _initTimeout = Duration(seconds: 4);

  VideoPlayerController? _controller;
  bool _navigated = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeVideo();
    });
  }

  void _initializeVideo() {
    if (MediaQuery.of(context).disableAnimations) {
      _navigateAway();
      return;
    }

    _controller = VideoPlayerController.asset(
      'assets/videos/nonduality_black.mp4',
    );

    // Guard against initialize() hanging on emulators
    _timeoutTimer = Timer(_initTimeout, () {
      if (!_navigated && mounted) _navigateAway();
    });

    _controller!.initialize().then((_) {
      _timeoutTimer?.cancel();
      if (!mounted || _navigated) return;
      setState(() {});
      _controller!.play();

      // Navigate after video duration (deterministic — doesn't rely on
      // isCompleted callbacks which are unreliable on some decoders)
      final duration = _controller!.value.duration;
      Future.delayed(duration, _navigateAway);
    }).catchError((_) {
      _timeoutTimer?.cancel();
      _navigateAway();
    });
  }

  void _navigateAway() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timeoutTimer?.cancel();
    context.go(widget.destination);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateAway,
        child: SizedBox.expand(
          child: _controller != null && _controller!.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
