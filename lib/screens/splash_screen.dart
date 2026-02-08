import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Full-screen branded video splash screen.
///
/// Plays a theme-aware nonduality animation (dark/light variant)
/// then auto-advances to the next screen. Tap anywhere to skip.
/// Respects system reduce-motion accessibility setting.
class SplashScreen extends StatefulWidget {
  /// Where to navigate after splash completes.
  final String destination;

  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
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
    final asset = 'assets/videos/nonduality_${isDark ? 'black' : 'white'}.mp4';

    _controller = VideoPlayerController.asset(asset)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {});
            _controller!.play();
            _controller!.addListener(_onVideoProgress);
          })
          .catchError((_) {
            // Video failed to load — skip to destination
            _navigateAway();
          });
  }

  void _onVideoProgress() {
    final controller = _controller;
    if (controller == null || _navigated) return;

    // Auto-advance when video reaches the end
    if (controller.value.isInitialized &&
        controller.value.position >= controller.value.duration &&
        controller.value.duration > Duration.zero) {
      _navigateAway();
    }
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
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
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
      ),
    );
  }
}
