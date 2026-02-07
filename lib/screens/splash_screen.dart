import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Full-screen branded splash screen using pure Flutter animation.
///
/// Shows app icon with a fade-in + subtle scale animation on black background,
/// then auto-advances to the next screen. Tap anywhere to skip.
/// Respects system reduce-motion accessibility setting.
///
/// Uses Flutter animations instead of video_player to avoid platform-specific
/// video decoder reliability issues (initialize() can hang indefinitely on
/// simulators/emulators with software H.264 decoders).
class SplashScreen extends StatefulWidget {
  /// Where to navigate after splash completes.
  final String destination;

  /// Total splash display duration before auto-advance.
  static const splashDuration = Duration(milliseconds: 3000);

  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  bool _navigated = false;
  double _screenOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade in over first 1.5s
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Subtle scale: 0.8 → 1.0
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Respect reduce-motion accessibility setting
      if (MediaQuery.of(context).disableAnimations) {
        _navigateAway();
        return;
      }

      _controller.forward();

      // Auto-advance after splash duration
      Future.delayed(SplashScreen.splashDuration, _navigateAway);
    });
  }

  void _navigateAway() {
    if (_navigated || !mounted) return;
    _navigated = true;

    // Fade out entire screen, then navigate
    setState(() => _screenOpacity = 0.0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.go(widget.destination);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateAway,
        child: AnimatedOpacity(
          opacity: _screenOpacity,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Enso icon (brand mark)
                    Image.asset(
                      'assets/icons/enso_icon_white.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      'Here Now',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
