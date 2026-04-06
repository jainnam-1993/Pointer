import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_initializer.dart';

/**
 * Full-screen branded splash recreated in Flutter from the original video art.
 *
 * Uses the extracted brushstroke from the shipped MP4, then animates it with
 * the same core motion language: slow rotation, slight scale drift, and a
 * soft blur-out exit.
 */
class SplashScreen extends StatefulWidget {
  final String destination;

  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _minimumDisplayDuration = Duration(milliseconds: 1500);
  static const _loopDuration = Duration(milliseconds: 4267);
  static const _exitDuration = Duration(milliseconds: 880);

  late final AnimationController _loopController;
  late final AnimationController _exitController;

  bool _startupReady = false;
  bool _minimumDurationElapsed = false;
  bool _exitStarted = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(vsync: this, duration: _loopDuration)..repeat();
    _exitController = AnimationController(vsync: this, duration: _exitDuration);

    _startupReady = AppInitializer.isCriticalContentReady;
    unawaited(
      AppInitializer.criticalContentReady
          .then((_) {
            if (!mounted) return;
            _startupReady = true;
            _beginExitIfReady();
          })
          .catchError((error, stackTrace) {
            if (!mounted) return;
            debugPrint('[SplashScreen] Critical startup failed: $error');
            _startupReady = true;
            _beginExitIfReady();
          }),
    );

    Future<void>.delayed(_minimumDisplayDuration, () {
      if (!mounted) return;
      _minimumDurationElapsed = true;
      _beginExitIfReady();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        unawaited(AppInitializer.startBackgroundInitialization());
      });
    });
  }

  void _requestLeave() {
    _minimumDurationElapsed = true;
    _beginExitIfReady();
  }

  void _beginExitIfReady() {
    if (_exitStarted || !_startupReady || !_minimumDurationElapsed || !mounted) return;
    _exitStarted = true;
    _exitController.forward().whenComplete(() {
      if (!mounted || _navigated) return;
      _navigated = true;
      context.go(widget.destination);
    });
  }

  @override
  void dispose() {
    _loopController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animationsEnabled = !MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _requestLeave,
        child: AnimatedBuilder(
          animation: Listenable.merge([_loopController, _exitController]),
          builder: (context, _) {
            final loopProgress = animationsEnabled ? _loopController.value : 0.22;
            final exitProgress = animationsEnabled ? _exitController.value : (_exitStarted ? 1.0 : 0.0);
            return _SplashVideoMatch(isDark: isDark, loopProgress: loopProgress, exitProgress: exitProgress);
          },
        ),
      ),
    );
  }
}

class _SplashVideoMatch extends StatelessWidget {
  final bool isDark;
  final double loopProgress;
  final double exitProgress;

  const _SplashVideoMatch({required this.isDark, required this.loopProgress, required this.exitProgress});

  @override
  Widget build(BuildContext context) {
    final rotation = loopProgress * math.pi * 2 * 0.56;
    final baseScale = 1.0 - (loopProgress * 0.055) + (math.sin(loopProgress * math.pi * 2 * 0.9) * 0.012);
    final baseYOffset = 8 - (loopProgress * 22);

    final exitCurve = Curves.easeInOutCubic.transform(exitProgress);
    final blurSigma = lerpDouble(0, 16, exitCurve)!;
    final opacity = lerpDouble(1, 0.18, exitCurve)!;
    final finalScale = baseScale * lerpDouble(1, 0.72, exitCurve)!;
    final finalYOffset = baseYOffset + lerpDouble(0, 18, exitCurve)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ensoSize = constraints.biggest.shortestSide * 0.39;
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: isDark ? Colors.black : Colors.white),
            Align(
              alignment: const Alignment(0, 0.12),
              child: Transform.translate(
                offset: Offset(0, finalYOffset),
                child: Opacity(
                  opacity: opacity,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: finalScale,
                        child: Image.asset(
                          'assets/images/enso_splash.png',
                          width: ensoSize,
                          height: ensoSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                          color: isDark ? Colors.white : Colors.black,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
