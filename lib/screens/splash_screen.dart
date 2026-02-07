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
/// The video controller is explicitly paused and disposed BEFORE navigation
/// to ensure the system media codec process shuts down immediately.
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

    _timeoutTimer = Timer(_initTimeout, () {
      if (!_navigated && mounted) _navigateAway();
    });

    _controller!.initialize().then((_) {
      _timeoutTimer?.cancel();
      if (!mounted || _navigated) return;
      setState(() {});
      _controller!.play();

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

    // Kill the video codec BEFORE navigating — pause stops decoding,
    // dispose releases the system media codec process immediately.
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.pause();
      controller.dispose();
    }

    context.go(widget.destination);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    // Controller already disposed in _navigateAway, but guard against
    // widget being removed without navigation (e.g. hot reload).
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
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
