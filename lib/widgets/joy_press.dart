/**
 * Press, release and hover for interactive glass surfaces (joy-motion spec 4.1 and the iPad pointer note).
 *
 * - Press: scale to [Motion.pressScale] on [Motion.press]; release on [Motion.settle], no overshoot. Springs always
 *   start from the current value and velocity, so quick taps retarget smoothly.
 * - A soft radial highlight follows the finger (and the iPad pointer) on [Motion.lift], clamped inside the surface and
 *   painted under the child's content.
 * - Hover (trackpad or mouse): a gentle highlight and a slight lift, never a pointer-shape change.
 * - Moving more than 10 pt after down cancels the press without firing.
 * - Reduce Motion: no scale and no travel; press dims to 0.85 opacity and release restores it.
 *
 * It wraps any child, so GlassButton and GlassCard stay untouched (glass_card.dart is under phonefix's bisect).
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../utils/haptics.dart';
import '../utils/motion.dart';

class JoyPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /** Scale at full press; use [Motion.pressScaleLarge] for cards. */
  final double pressedScale;

  /** Corner radius of the highlight's clip (match the surface). */
  final BorderRadius borderRadius;

  /** Haptic on commit: light by default; pass null for none. */
  final Future<void> Function()? haptic;

  final String? semanticLabel;

  const JoyPress({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = Motion.pressScale,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.haptic = Haptics.light,
    this.semanticLabel,
  });

  /** Movement after down that cancels the press. */
  static const double cancelSlop = 10;

  /** Hover lift (scale) and highlight strength relative to a press. */
  static const double hoverScale = 1.015;
  static const double hoverHighlight = 0.55;

  /** Peak highlight alpha at full press. */
  static const double highlightAlpha = 0.14;

  @override
  State<JoyPress> createState() => JoyPressState();
}

@visibleForTesting
class JoyPressState extends State<JoyPress> with TickerProviderStateMixin {
  /** Press amount, 0 rest to 1 fully pressed. */
  late final AnimationController press = AnimationController.unbounded(vsync: this);

  /** Hover amount, 0 to 1. */
  late final AnimationController hover = AnimationController.unbounded(vsync: this);

  /** Highlight position (local), smoothed toward the pointer. */
  late final AnimationController _hx = AnimationController.unbounded(vsync: this);
  late final AnimationController _hy = AnimationController.unbounded(vsync: this);

  Offset? _down;
  bool _cancelled = false;

  bool get _reduce => Motion.reduce(context);

  void _spring(AnimationController c, SpringDescription s, double to) {
    if (_reduce) {
      c.value = to;
      return;
    }
    c.animateWith(SpringSimulation(s, c.value, to, c.velocity));
  }

  void _follow(Offset p) {
    if (_reduce) {
      _hx.value = p.dx;
      _hy.value = p.dy;
      return;
    }
    _hx.animateWith(SpringSimulation(Motion.lift, _hx.value, p.dx, _hx.velocity));
    _hy.animateWith(SpringSimulation(Motion.lift, _hy.value, p.dy, _hy.velocity));
  }

  @override
  void dispose() {
    press.dispose();
    hover.dispose();
    _hx.dispose();
    _hy.dispose();
    super.dispose();
  }

  void _onDown(PointerDownEvent e) {
    if (widget.onTap == null) return;
    _down = e.localPosition;
    _cancelled = false;
    if (hover.value == 0) {
      _hx.value = e.localPosition.dx;
      _hy.value = e.localPosition.dy;
    }
    _follow(e.localPosition);
    _spring(press, Motion.press, 1);
  }

  void _onMove(PointerMoveEvent e) {
    if (_down == null) return;
    _follow(e.localPosition);
    if ((e.localPosition - _down!).distance > JoyPress.cancelSlop) _cancelled = true;
  }

  void _onUp(PointerUpEvent e) {
    if (_down == null) return;
    final commit = !_cancelled;
    _down = null;
    _spring(press, Motion.settle, 0);
    if (commit) {
      widget.haptic?.call();
      widget.onTap?.call();
    }
  }

  void _onCancel(PointerCancelEvent e) {
    _down = null;
    _spring(press, Motion.settle, 0);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = _reduce;
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (e) {
          _hx.value = e.localPosition.dx;
          _hy.value = e.localPosition.dy;
          _spring(hover, Motion.lift, 1);
        },
        onHover: (e) => _follow(e.localPosition),
        onExit: (_) => _spring(hover, Motion.lift, 0),
        child: Listener(
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: _onUp,
          onPointerCancel: _onCancel,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: Listenable.merge([press, hover]),
            builder: (context, child) {
              final p = press.value.clamp(0.0, 1.0);
              final h = hover.value.clamp(0.0, 1.0);
              if (reduce) {
                return Opacity(opacity: 1 - 0.15 * p, child: child);
              }
              final scale = (1 - (1 - widget.pressedScale) * p) * (1 + (JoyPress.hoverScale - 1) * h * (1 - p));
              return Transform.scale(scale: scale, child: child);
            },
            child: RepaintBoundary(
              child: Stack(
                children: [
                  widget.child,
                  if (!reduce)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: widget.borderRadius,
                          child: CustomPaint(painter: _HighlightPainter(this)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final JoyPressState s;

  _HighlightPainter(this.s) : super(repaint: Listenable.merge([s.press, s.hover, s._hx, s._hy]));

  @override
  void paint(Canvas canvas, Size size) {
    final strength = (s.press.value.clamp(0.0, 1.0) + JoyPress.hoverHighlight * s.hover.value.clamp(0.0, 1.0)).clamp(0.0, 1.0);
    if (strength <= 0.001) return;
    final c = Offset(s._hx.value.clamp(0.0, size.width), s._hy.value.clamp(0.0, size.height));
    final r = size.shortestSide * 0.6;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: JoyPress.highlightAlpha * strength),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, paint);
  }

  @override
  bool shouldRepaint(_HighlightPainter old) => old.s != s;
}
