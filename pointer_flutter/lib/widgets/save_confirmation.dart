import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A subtle heart animation overlay shown when a pointing is saved to favorites.
///
/// Features:
/// - Heart icon with scale-in animation
/// - "Saved" text below the heart
/// - Auto-dismisses after 2 seconds
/// - Semi-transparent glass background
class SaveConfirmation extends StatefulWidget {
  /// Callback when the confirmation is dismissed (auto or manual).
  final VoidCallback? onDismiss;

  /// Duration before auto-dismiss.
  final Duration autoDismissDuration;

  /// Set to true in tests to disable auto-dismiss timers.
  static bool disableAutoDismiss = false;

  const SaveConfirmation({
    super.key,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 2),
  });

  @override
  State<SaveConfirmation> createState() => _SaveConfirmationState();
}

class _SaveConfirmationState extends State<SaveConfirmation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _controller.forward();

    // Auto-dismiss after duration (skip in test mode)
    if (!SaveConfirmation.disableAutoDismiss) {
      Future.delayed(widget.autoDismissDuration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: colors.glassBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Saved',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
