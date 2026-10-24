/**
 * The inline thank-you shown after a tip: an enso draws itself once, then
 * "Thank you. This keeps Here Now free." settles in below it.
 *
 * Styled on the shared type scale (serif quote) and fires [Haptics.success]
 * once when shown. Under reduce motion the enso appears fully drawn.
 */
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';

class DonationThankYou extends StatefulWidget {
  /** The thank-you line; the default is the product copy. */
  final String message;

  /** Enso diameter. */
  final double size;

  const DonationThankYou({super.key, this.message = 'Thank you. This keeps Here Now free.', this.size = 56});

  @override
  State<DonationThankYou> createState() => _DonationThankYouState();
}

class _DonationThankYouState extends State<DonationThankYou> with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(vsync: this, duration: Motion.calm);

  @override
  void initState() {
    super.initState();
    Haptics.success();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduce(context)) {
      _draw.value = 1;
    } else if (!_draw.isAnimating && _draw.value == 0) {
      _draw.forward();
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      label: widget.message,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _draw,
              builder: (context, _) => CustomPaint(
                size: Size.square(widget.size),
                painter: EnsoStrokePainter(progress: Motion.enter.transform(_draw.value), color: colors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _draw,
                curve: const Interval(0.45, 1, curve: Curves.easeOut),
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.quoteText(context).copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/** A single brush-like enso stroke drawn to [progress] (0..1), open at the top right. */
class EnsoStrokePainter extends CustomPainter {
  final double progress;

  final Color color;

  const EnsoStrokePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final stroke = size.shortestSide * 0.07;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2 - stroke);
    const start = -math.pi / 3;
    const sweep = math.pi * 2 * 0.9;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, start, sweep * progress, false, paint);
  }

  @override
  bool shouldRepaint(EnsoStrokePainter old) => old.progress != progress || old.color != color;
}
