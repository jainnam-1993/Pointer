import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A subtle heart animation overlay shown when a pointing is saved to favorites.
///
/// Features:
/// - Heart icon with scale-in animation
/// - "Saved" text below the heart
/// - Auto-dismisses after 2 seconds
/// - Semi-transparent glass background
/// - Confetti celebration on first-ever save
class SaveConfirmation extends StatefulWidget {
  /// Callback when the confirmation is dismissed (auto or manual).
  final VoidCallback? onDismiss;

  /// Duration before auto-dismiss.
  final Duration autoDismissDuration;

  /// Whether this is the user's first-ever save (triggers celebration).
  final bool isFirstSave;

  /// Set to true in tests to disable auto-dismiss timers.
  static bool disableAutoDismiss = false;

  const SaveConfirmation({
    super.key,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 2),
    this.isFirstSave = false,
  });

  @override
  State<SaveConfirmation> createState() => _SaveConfirmationState();
}

class _SaveConfirmationState extends State<SaveConfirmation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late ConfettiController _confettiController;

  // Ethereal colors matching the app's theme
  static const _confettiColors = [
    Color(0xFF8B5CF6), // Violet (primary accent)
    Color(0xFFA78BFA), // Light violet
    Color(0xFF06B6D4), // Teal
    Color(0xFF7DD3FC), // Light blue
    Color(0xFFF0ABFC), // Pink
    Color(0xFFFFFFFF), // White
  ];

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

    // Initialize confetti controller (longer duration for first save)
    _confettiController = ConfettiController(
      duration: widget.isFirstSave
          ? const Duration(milliseconds: 1500)
          : const Duration(milliseconds: 500),
    );

    // Start animation
    _controller.forward();

    // Trigger confetti for first save
    if (widget.isFirstSave) {
      _confettiController.play();
    }

    // Auto-dismiss after duration (skip in test mode)
    // Longer duration for first save to let confetti finish
    final dismissDuration = widget.isFirstSave
        ? const Duration(seconds: 3)
        : widget.autoDismissDuration;

    if (!SaveConfirmation.disableAutoDismiss) {
      Future.delayed(dismissDuration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  /// Custom confetti path for softer, rounder particles
  Path _drawCircle(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        // Confetti layer (behind the card)
        if (widget.isFirstSave)
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.1,
              particleDrag: 0.05,
              colors: _confettiColors,
              createParticlePath: _drawCircle,
              minimumSize: const Size(5, 5),
              maximumSize: const Size(12, 12),
            ),
          ),

        // Main confirmation card
        Center(
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
                  color: widget.isFirstSave
                      ? colors.accent.withValues(alpha: 0.5)
                      : colors.glassBorder,
                  width: widget.isFirstSave ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isFirstSave
                        ? colors.accent.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: widget.isFirstSave ? 30 : 20,
                    spreadRadius: widget.isFirstSave ? 8 : 5,
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
                      color: widget.isFirstSave
                          ? colors.accent
                          : Theme.of(context).colorScheme.primary,
                      size: widget.isFirstSave ? 56 : 48,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isFirstSave ? 'First Save!' : 'Saved',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: widget.isFirstSave ? 18 : 16,
                      fontWeight: widget.isFirstSave
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (widget.isFirstSave) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Find your saved pointings in Library',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
