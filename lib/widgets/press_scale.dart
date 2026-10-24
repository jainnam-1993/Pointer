/**
 * Press feedback for glass surfaces: a gentle scale-down instead of an ink ripple.
 */
library;

import 'package:flutter/widgets.dart';

import '../utils/haptics.dart';
import '../utils/motion.dart';

/** Scales [child] to [Motion.pressScale] while pressed and calls [onTap] on release. */
class PressScale extends StatefulWidget {
  final Widget child;

  final VoidCallback? onTap;

  /** Fire [Haptics.light] on tap. */
  final bool haptic;

  /** Accessibility label; when set the child is merged into one button node. */
  final String? semanticLabel;

  const PressScale({super.key, required this.child, this.onTap, this.haptic = true, this.semanticLabel});

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (widget.onTap == null || _pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final reduce = Motion.reduce(context);
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: enabled
            ? () {
                if (widget.haptic) Haptics.light();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed && !reduce ? Motion.pressScale : 1.0,
          duration: reduce ? Duration.zero : Motion.instant,
          curve: Motion.enter,
          child: AnimatedOpacity(opacity: _pressed && reduce ? 0.7 : 1.0, duration: Motion.instant, child: widget.child),
        ),
      ),
    );
  }
}
