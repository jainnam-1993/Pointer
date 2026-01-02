import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Animation constants for consistent timing across the app
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration stagger = Duration(milliseconds: 50);
}

/// Animation curves for consistent feel
class AnimationCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.fastOutSlowIn;
  static const Curve decelerate = Curves.decelerate;
}

/// Staggered fade-in animation for list items
class StaggeredFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Stagger the animation start based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated text switcher with fade and optional slide
class AnimatedTextSwitcher extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration duration;
  final Offset slideOffset;

  const AnimatedTextSwitcher({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.duration = const Duration(milliseconds: 300),
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AnimationCurves.standard,
      switchOutCurve: AnimationCurves.standard,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: slideOffset,
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

/// Scale and fade transition for badges and small elements
class ScaleFadeTransition extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration duration;

  const ScaleFadeTransition({
    super.key,
    required this.child,
    this.visible = true,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.8,
      duration: duration,
      curve: AnimationCurves.standard,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: duration,
        curve: AnimationCurves.standard,
        child: child,
      ),
    );
  }
}

/// Calm-style page transition for GoRouter
/// Uses pure fade - no slides for a contemplative, peaceful experience
class CalmPageTransition extends CustomTransitionPage<void> {
  CalmPageTransition({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AnimationDurations.slow,
          reverseTransitionDuration: AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Pure fade - calm and unhurried
            final fadeIn = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            final fadeOut = Tween<double>(begin: 1, end: 0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeIn,
              ),
            );

            return FadeTransition(
              opacity: fadeIn,
              child: FadeTransition(
                opacity: fadeOut,
                child: child,
              ),
            );
          },
        );
}

/// Hero-compatible morphing card wrapper
class MorphingCard extends StatelessWidget {
  final String heroTag;
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const MorphingCard({
    super.key,
    required this.heroTag,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }
}

/// Container transform animation using animations package
/// Opens a card into a full-screen page with material motion
class OpenContainerCard extends StatelessWidget {
  final Widget closedBuilder;
  final Widget Function(BuildContext, VoidCallback) openBuilder;
  final Color? closedColor;
  final Color? openColor;
  final BorderRadius closedBorderRadius;
  final double closedElevation;
  final ContainerTransitionType transitionType;

  const OpenContainerCard({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.closedColor,
    this.openColor,
    this.closedBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.closedElevation = 0,
    this.transitionType = ContainerTransitionType.fadeThrough,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: transitionType,
      transitionDuration: AnimationDurations.slow,
      openBuilder: (context, action) => openBuilder(context, action),
      closedBuilder: (context, action) => InkWell(
        onTap: action,
        borderRadius: closedBorderRadius,
        child: closedBuilder,
      ),
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? Theme.of(context).scaffoldBackgroundColor,
      closedShape: RoundedRectangleBorder(borderRadius: closedBorderRadius),
      closedElevation: closedElevation,
    );
  }
}

/// Fade through transition for switching between unrelated content
class FadeThroughSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeThroughSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Shared axis transition for navigating between related content
class SharedAxisSwitcher extends StatelessWidget {
  final Widget child;
  final SharedAxisTransitionType transitionType;
  final Duration duration;

  const SharedAxisSwitcher({
    super.key,
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// GoRouter page with fade through transition
class FadeThroughPage extends CustomTransitionPage<void> {
  FadeThroughPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AnimationDurations.normal,
          reverseTransitionDuration: AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

/// GoRouter page with shared axis transition
class SharedAxisPage extends CustomTransitionPage<void> {
  SharedAxisPage({
    required super.child,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AnimationDurations.normal,
          reverseTransitionDuration: AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );
}

/// Pulse animation for subtle attention-drawing
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 1.0,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
