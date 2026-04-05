import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_initializer.dart';
import '../widgets/enso_icon.dart';

/**
 * Full-screen branded splash built entirely in Flutter.
 *
 * Uses a layered vector animation instead of video so the first branded frame
 * appears immediately and stays crisp on every device density.
 */
class SplashScreen extends StatefulWidget {
  /** Where to navigate after splash completes. */
  final String destination;

  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _minimumDisplayDuration = Duration(milliseconds: 1500);
  static const _fadeDuration = Duration(milliseconds: 420);

  late final AnimationController _controller;

  bool _startupReady = false;
  bool _minimumDurationElapsed = false;
  bool _navigated = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 9200))..repeat();

    _startupReady = AppInitializer.isCriticalContentReady;
    unawaited(
      AppInitializer.criticalContentReady
          .then((_) {
            if (!mounted) return;
            _startupReady = true;
            _maybeNavigateAway();
          })
          .catchError((error, stackTrace) {
            if (!mounted) return;
            debugPrint('[SplashScreen] Critical startup failed: $error');
            _startupReady = true;
            _maybeNavigateAway();
          }),
    );

    Future<void>.delayed(_minimumDisplayDuration, () {
      if (!mounted) return;
      _minimumDurationElapsed = true;
      _maybeNavigateAway();
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
    _maybeNavigateAway();
  }

  void _maybeNavigateAway() {
    if (_navigated || !mounted || !_startupReady || !_minimumDurationElapsed) return;
    _navigated = true;

    setState(() => _opacity = 0.0);
    Future<void>.delayed(_fadeDuration, () {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animationsEnabled = !MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050505) : const Color(0xFFF7F4EE),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _requestLeave,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: _fadeDuration,
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = animationsEnabled ? _controller.value : 0.18;
              return _SplashArtwork(progress: progress, isDark: isDark);
            },
          ),
        ),
      ),
    );
  }
}

class _SplashArtwork extends StatelessWidget {
  final double progress;
  final bool isDark;

  const _SplashArtwork({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFFF5F3EE) : const Color(0xFF111111);
    final haloColor = isDark ? const Color(0xFF9DA7A4) : const Color(0xFFB8A789);
    final accentColor = isDark ? const Color(0xFFD9C9AE) : const Color(0xFF8D6E52);

    final driftX = math.sin(progress * math.pi * 2) * 26;
    final driftY = math.cos(progress * math.pi * 2 * 0.7) * 24;
    final breathe = 1.0 + (math.sin(progress * math.pi * 2 * 1.5) * 0.035);
    final rotate = progress * math.pi * 2 * 0.72;
    final shimmer = (math.sin(progress * math.pi * 2 * 1.2) + 1) / 2;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF050505), Color(0xFF11100F), Color(0xFF060606)]
                  : const [Color(0xFFF8F4EC), Color(0xFFF1E9DE), Color(0xFFFBF9F4)],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(driftX, driftY),
          child: Align(
            alignment: isDark ? const Alignment(-0.55, -0.38) : const Alignment(-0.45, -0.35),
            child: _SoftOrb(diameter: 300, color: haloColor.withValues(alpha: isDark ? 0.12 : 0.16)),
          ),
        ),
        Transform.translate(
          offset: Offset(-driftX * 0.75, -driftY * 0.55),
          child: Align(
            alignment: isDark ? const Alignment(0.62, 0.48) : const Alignment(0.55, 0.42),
            child: _SoftOrb(diameter: 250, color: accentColor.withValues(alpha: isDark ? 0.10 : 0.14)),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size.square(260),
                        painter: _SplashFieldPainter(
                          progress: progress,
                          ringColor: baseColor.withValues(alpha: isDark ? 0.15 : 0.12),
                          accentColor: accentColor.withValues(alpha: isDark ? 0.40 : 0.28),
                        ),
                      ),
                      Transform.scale(
                        scale: 1.18 + shimmer * 0.03,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Opacity(
                            opacity: isDark ? 0.28 : 0.18,
                            child: Transform.rotate(
                              angle: -rotate * 0.45,
                              child: EnsoIcon(size: 162, color: accentColor),
                            ),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: breathe,
                        child: Opacity(
                          opacity: 0.18,
                          child: Transform.rotate(
                            angle: rotate * 0.22,
                            child: EnsoIcon(size: 166, color: haloColor),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: breathe,
                        child: ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (bounds) {
                            return SweepGradient(
                              colors: [
                                baseColor.withValues(alpha: 0.84),
                                baseColor,
                                accentColor.withValues(alpha: 0.92),
                                baseColor,
                                baseColor.withValues(alpha: 0.84),
                              ],
                              stops: const [0.0, 0.26, 0.56, 0.82, 1.0],
                              transform: GradientRotation(rotate * 0.8),
                            ).createShader(bounds);
                          },
                          child: Transform.rotate(
                            angle: rotate,
                            child: EnsoIcon(size: 172, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Here Now',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300, letterSpacing: 2.4, color: baseColor.withValues(alpha: 0.96)),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to continue',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.8,
                  color: baseColor.withValues(alpha: isDark ? 0.48 : 0.42),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double diameter;
  final Color color;

  const _SoftOrb({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: color.a * 0.55),
                Colors.transparent,
              ],
              stops: const [0.0, 0.36, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashFieldPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color accentColor;

  const _SplashFieldPainter({required this.progress, required this.ringColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.33;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = ringColor;

    canvas.drawCircle(center, radius + 26, ringPaint);

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8
      ..color = accentColor;

    final arcRect = Rect.fromCircle(center: center, radius: radius + 10);
    canvas.drawArc(arcRect, -math.pi / 2 + progress * math.pi * 2 * 0.55, 0.72, false, accentPaint);

    canvas.drawArc(arcRect.inflate(12), math.pi / 5 - progress * math.pi * 2 * 0.32, 0.42, false, accentPaint..strokeWidth = 1.6);
  }

  @override
  bool shouldRepaint(covariant _SplashFieldPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.ringColor != ringColor || oldDelegate.accentColor != accentColor;
  }
}
