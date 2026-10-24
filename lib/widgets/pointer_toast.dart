/**
 * A small glass toast: the app's replacement for default Material SnackBars.
 *
 * ```dart
 * PointerToast.show(context, 'Saved to favorites');
 * ```
 * It floats above the nav bar, fades and rises in, holds, then fades out.
 * Screen readers get the message as a polite live-region announcement.
 */
library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/motion.dart';

class PointerToast extends StatefulWidget {
  final String message;

  final IconData? icon;

  final VoidCallback onDismissed;

  final Duration hold;

  const PointerToast({super.key, required this.message, this.icon, required this.onDismissed, this.hold = const Duration(milliseconds: 2400)});

  static OverlayEntry? _current;

  /** Shows [message]; replaces any toast already showing. */
  static void show(BuildContext context, String message, {IconData? icon, Duration hold = const Duration(milliseconds: 2400)}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _current?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => PointerToast(
        message: message,
        icon: icon,
        hold: hold,
        onDismissed: () {
          if (_current == entry) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  @override
  State<PointerToast> createState() => _PointerToastState();
}

class _PointerToastState extends State<PointerToast> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
      _timer = Timer(widget.hold, () {
        if (!mounted) return;
        setState(() => _visible = false);
        _timer = Timer(Motion.standard, widget.onDismissed);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glass = GlassMaterial.of(context);
    final duration = Motion.of(context, Motion.standard);
    final bottom = MediaQuery.paddingOf(context).bottom + AppSpacing.navBarOffset * 0.75;
    return Positioned(
      left: AppSpacing.xl,
      right: AppSpacing.xl,
      bottom: bottom,
      child: IgnorePointer(
        child: Semantics(
          liveRegion: true,
          container: true,
          label: widget.message,
          child: ExcludeSemantics(
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.3),
              duration: duration,
              curve: Motion.enter,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: duration,
                curve: Motion.inOut,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: glass.blurSigma, sigmaY: glass.blurSigma),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg + 2, vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: glass.opaque ? glass.fill : colors.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(color: glass.rimTop, width: glass.rimWidth),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: colors.accent), const SizedBox(width: AppSpacing.sm)],
                            Flexible(
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  widget.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.callout, height: 1.35, color: colors.textPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
