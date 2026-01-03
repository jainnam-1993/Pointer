import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import 'notification_preview.dart';

/// Animation durations for onboarding - deliberately slower for contemplative feel
class OnboardingDurations {
  static const Duration wordReveal = Duration(milliseconds: 200);
  static const Duration wordFade = Duration(milliseconds: 400);
  static const Duration dissolve = Duration(milliseconds: 800);
  static const Duration strikethrough = Duration(milliseconds: 300);
  static const Duration breathCycle = Duration(seconds: 3);
  static const Duration notificationSlide = Duration(milliseconds: 400);
}

// ============================================================================
// TypewriterText
// ============================================================================

/// Word-by-word text reveal with configurable timing.
///
/// Each word fades in sequentially, creating a contemplative reading experience.
/// Triggers a subtle haptic on the final word.
class TypewriterText extends StatefulWidget {
  /// The text to reveal word by word.
  final String text;

  /// Style for the text. Falls back to theme's textPrimary color.
  final TextStyle? style;

  /// Delay between each word appearing.
  final Duration wordDelay;

  /// Initial delay before the first word appears.
  final Duration startDelay;

  /// Called when all words have been revealed.
  final VoidCallback? onComplete;

  /// Text alignment.
  final TextAlign textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.wordDelay = const Duration(milliseconds: 200),
    this.startDelay = const Duration(seconds: 1),
    this.onComplete,
    this.textAlign = TextAlign.center,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  late List<String> _words;
  int _visibleWordCount = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    // Defer animation start to after first frame (MediaQuery not available in initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAnimation();
    });
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _words = widget.text.split(' ');
      _visibleWordCount = 0;
      _isComplete = false;
      _startAnimation();
    }
  }

  void _startAnimation() {
    // Check if animations are disabled for accessibility
    if (_shouldReduceMotion) {
      setState(() {
        _visibleWordCount = _words.length;
        _isComplete = true;
      });
      widget.onComplete?.call();
      return;
    }

    Future.delayed(widget.startDelay, () {
      if (!mounted) return;
      _revealNextWord();
    });
  }

  void _revealNextWord() {
    if (!mounted || _visibleWordCount >= _words.length) return;

    setState(() {
      _visibleWordCount++;
    });

    if (_visibleWordCount >= _words.length) {
      // Final word - trigger haptic and callback
      HapticFeedback.lightImpact();
      _isComplete = true;
      widget.onComplete?.call();
    } else {
      Future.delayed(widget.wordDelay, _revealNextWord);
    }
  }

  bool get _shouldReduceMotion {
    return MediaQuery.of(context).disableAnimations;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultStyle = widget.style ??
        TextStyle(
          fontSize: 20,
          height: 1.7,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
        );

    // If reduced motion, show all text immediately
    if (_shouldReduceMotion || _isComplete && _visibleWordCount == _words.length) {
      return Text(
        widget.text,
        style: defaultStyle,
        textAlign: widget.textAlign,
      );
    }

    return Wrap(
      alignment: _wrapAlignment,
      children: List.generate(_words.length, (index) {
        final isVisible = index < _visibleWordCount;
        final word = _words[index];
        final isLastWord = index == _words.length - 1;

        return AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: OnboardingDurations.wordFade,
          curve: Curves.easeOut,
          child: Text(
            isLastWord ? word : '$word ',
            style: defaultStyle,
          ),
        );
      }),
    );
  }

  WrapAlignment get _wrapAlignment {
    switch (widget.textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return WrapAlignment.start;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      case TextAlign.center:
      default:
        return WrapAlignment.center;
    }
  }
}

// ============================================================================
// DissolveTransition
// ============================================================================

/// Shows first child, then dissolves/blurs it away as second child emerges.
///
/// Creates an ethereal transition effect where the first child becomes
/// increasingly blurred and faded while the second child materializes.
class DissolveTransition extends StatefulWidget {
  /// The initial widget to show.
  final Widget firstChild;

  /// The widget that emerges as the first dissolves.
  final Widget secondChild;

  /// How long to hold the first child before dissolving.
  final Duration holdDuration;

  /// Duration of the dissolve/emergence animation.
  final Duration dissolveDuration;

  /// Called when the transition completes.
  final VoidCallback? onComplete;

  const DissolveTransition({
    super.key,
    required this.firstChild,
    required this.secondChild,
    this.holdDuration = const Duration(seconds: 2),
    this.dissolveDuration = const Duration(milliseconds: 800),
    this.onComplete,
  });

  @override
  State<DissolveTransition> createState() => _DissolveTransitionState();
}

class _DissolveTransitionState extends State<DissolveTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dissolveAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _emergeAnimation;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.dissolveDuration,
      vsync: this,
    );

    // First child fades out (1.0 -> 0.0)
    _dissolveAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // First child blurs (0.0 -> 10.0)
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Second child fades in (0.0 -> 1.0)
    _emergeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _scheduleTransition();
  }

  void _scheduleTransition() {
    // Check for reduced motion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_shouldReduceMotion) {
        // Skip animation, show second child immediately
        _controller.value = 1.0;
        widget.onComplete?.call();
        return;
      }

      Future.delayed(widget.holdDuration, () {
        if (!mounted) return;
        HapticFeedback.lightImpact();
        _hasStarted = true;
        _controller.forward();
      });
    });
  }

  bool get _shouldReduceMotion {
    return MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Immediate switch for reduced motion
    if (_shouldReduceMotion) {
      return widget.secondChild;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // First child with dissolve effect
            if (_dissolveAnimation.value > 0)
              Opacity(
                opacity: _dissolveAnimation.value,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: widget.firstChild,
                ),
              ),
            // Second child emerging
            if (_emergeAnimation.value > 0 || _hasStarted)
              Opacity(
                opacity: _emergeAnimation.value,
                child: widget.secondChild,
              ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// StrikeThroughReveal
// ============================================================================

/// Text that appears then gets struck through and fades.
///
/// Used to show concepts that are being "let go of" or transcended,
/// such as "Progress", "Streaks", "Becoming".
class StrikeThroughReveal extends StatefulWidget {
  /// List of items to show and strike through sequentially.
  final List<String> items;

  /// Delay before showing the next item after the previous fades.
  final Duration itemDelay;

  /// Delay after item appears before strike-through begins.
  final Duration strikeDelay;

  /// Style for the text.
  final TextStyle? style;

  /// Called when all items have been shown and struck through.
  final VoidCallback? onComplete;

  const StrikeThroughReveal({
    super.key,
    required this.items,
    this.itemDelay = const Duration(milliseconds: 600),
    this.strikeDelay = const Duration(milliseconds: 400),
    this.style,
    this.onComplete,
  });

  @override
  State<StrikeThroughReveal> createState() => _StrikeThroughRevealState();
}

class _StrikeThroughRevealState extends State<StrikeThroughReveal>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  _StrikePhase _phase = _StrikePhase.hidden;
  late AnimationController _fadeController;
  late AnimationController _strikeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _strikeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: OnboardingDurations.wordFade,
      vsync: this,
    );

    _strikeController = AnimationController(
      duration: OnboardingDurations.strikethrough,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _strikeAnimation = CurvedAnimation(
      parent: _strikeController,
      curve: Curves.easeInOut,
    );

    _startSequence();
  }

  void _startSequence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_shouldReduceMotion) {
        // Show all items at once in reduced motion mode
        setState(() {
          _currentIndex = widget.items.length - 1;
          _phase = _StrikePhase.complete;
        });
        widget.onComplete?.call();
        return;
      }

      _showNextItem();
    });
  }

  void _showNextItem() {
    if (!mounted || _currentIndex >= widget.items.length) {
      widget.onComplete?.call();
      return;
    }

    setState(() {
      _phase = _StrikePhase.appearing;
    });

    _fadeController.forward(from: 0).then((_) {
      if (!mounted) return;

      // Wait then start strike-through
      Future.delayed(widget.strikeDelay, () {
        if (!mounted) return;

        HapticFeedback.lightImpact();
        setState(() {
          _phase = _StrikePhase.striking;
        });

        _strikeController.forward(from: 0).then((_) {
          if (!mounted) return;

          // Fade out
          setState(() {
            _phase = _StrikePhase.fading;
          });

          _fadeController.reverse().then((_) {
            if (!mounted) return;

            // Move to next item
            Future.delayed(widget.itemDelay, () {
              if (!mounted) return;

              setState(() {
                _currentIndex++;
                _phase = _StrikePhase.hidden;
              });

              _showNextItem();
            });
          });
        });
      });
    });
  }

  bool get _shouldReduceMotion {
    return MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _strikeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.items.length) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final defaultStyle = widget.style ??
        TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
          height: 1.4,
        );

    final currentItem = widget.items[_currentIndex];

    // Reduced motion: show all items as a column
    if (_shouldReduceMotion) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.items
            .map((item) => Text(
                  item,
                  style: defaultStyle.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: colors.textMuted,
                  ),
                ))
            .toList(),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _strikeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: CustomPaint(
            painter: _phase == _StrikePhase.striking || _phase == _StrikePhase.fading
                ? _StrikeThroughPainter(
                    progress: _strikeAnimation.value,
                    color: colors.textMuted,
                    strokeWidth: 2.0,
                  )
                : null,
            child: Text(
              currentItem,
              style: defaultStyle,
            ),
          ),
        );
      },
    );
  }
}

enum _StrikePhase { hidden, appearing, striking, fading, complete }

class _StrikeThroughPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _StrikeThroughPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    final endX = size.width * progress;

    canvas.drawLine(
      Offset(0, y),
      Offset(endX, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(_StrikeThroughPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// ============================================================================
// NotificationSimulation
// ============================================================================

/// Simulates a notification banner sliding down from the top.
///
/// Creates an iOS/Android-style notification appearance matching the actual
/// Pointer notification UI with Ensō icon, title, tradition badge, and actions.
class NotificationSimulation extends StatefulWidget {
  /// App name shown in the notification header.
  final String appName;

  /// The notification message body (the pointing content).
  final String message;

  /// Title shown above the message (defaults to "Today's Pointing").
  final String title;

  /// Tradition and teacher attribution (e.g., "Advaita Vedanta — Nisargadatta").
  final String? attribution;

  /// Whether to show action buttons (Save, Another).
  final bool showActions;

  /// Delay before the notification appears.
  final Duration delay;

  /// Called when the notification has fully appeared.
  final VoidCallback? onComplete;

  const NotificationSimulation({
    super.key,
    this.appName = 'Pointer',
    required this.message,
    this.title = "Today's Pointing",
    this.attribution,
    this.showActions = true,
    this.delay = const Duration(seconds: 1),
    this.onComplete,
  });

  @override
  State<NotificationSimulation> createState() => _NotificationSimulationState();
}

class _NotificationSimulationState extends State<NotificationSimulation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: OnboardingDurations.notificationSlide,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _scheduleAppearance();
  }

  void _scheduleAppearance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_shouldReduceMotion) {
        setState(() => _isVisible = true);
        _controller.value = 1.0;
        widget.onComplete?.call();
        return;
      }

      Future.delayed(widget.delay, () {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        setState(() => _isVisible = true);
        _controller.forward();
      });
    });
  }

  bool get _shouldReduceMotion {
    return MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible && !_shouldReduceMotion) {
      return const SizedBox.shrink();
    }

    // Delegate to the reusable NotificationPreview widget
    // This ensures consistency with any other notification preview in the app
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: NotificationPreview(
            title: widget.title,
            body: widget.message,
            attribution: widget.attribution,
            showActions: widget.showActions,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BreathingGlow
// ============================================================================

/// Subtle pulsing glow effect for containers.
///
/// Wraps a child widget with an animated glow that pulses gently,
/// like breathing. Uses a smooth sine-wave animation for natural feel.
class BreathingGlow extends StatefulWidget {
  /// The widget to wrap with the breathing glow effect.
  final Widget child;

  /// Color of the glow. Defaults to theme accent color.
  final Color? glowColor;

  /// Duration of one full breath cycle (inhale + exhale).
  final Duration cycleDuration;

  /// Maximum blur radius of the glow.
  final double maxBlur;

  /// Maximum spread radius of the glow.
  final double maxSpread;

  const BreathingGlow({
    super.key,
    required this.child,
    this.glowColor,
    this.cycleDuration = const Duration(seconds: 3),
    this.maxBlur = 20.0,
    this.maxSpread = 5.0,
  });

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.cycleDuration,
      vsync: this,
    );

    // Start animation after frame is built (to check reduced motion)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_shouldReduceMotion) {
        _controller.repeat();
      }
    });
  }

  bool get _shouldReduceMotion {
    return MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No glow effect for reduced motion
    if (_shouldReduceMotion) {
      return widget.child;
    }

    final colors = context.colors;
    final glowColor = widget.glowColor ?? colors.accent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use sine wave for smooth breathing effect
        // Value oscillates between 0.3 and 1.0
        final breathValue = 0.3 + (0.7 * ((math.sin(_controller.value * 2 * math.pi) + 1) / 2));

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.3 * breathValue),
                blurRadius: widget.maxBlur * breathValue,
                spreadRadius: widget.maxSpread * breathValue,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ============================================================================
// Utility Extensions
// ============================================================================

/// Extension to add onboarding-specific animations using flutter_animate
extension OnboardingAnimateExtensions on Widget {
  /// Applies a contemplative fade-in with subtle upward drift.
  Widget contemplativeFadeIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: duration,
          curve: Curves.easeOut,
        );
  }

  /// Applies a gentle scale-in effect for emphasis.
  Widget gentleScaleIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return animate(delay: delay)
        .scaleXY(
          begin: 0.95,
          end: 1.0,
          duration: duration,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: duration, curve: Curves.easeOut);
  }

  /// Applies a soft blur-in effect (from blurred to clear).
  Widget blurIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return animate(delay: delay)
        .blur(
          begin: const Offset(10, 10),
          end: Offset.zero,
          duration: duration,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: duration, curve: Curves.easeOut);
  }
}
