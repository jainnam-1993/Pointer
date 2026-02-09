import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/**
 * Animation duration constants for consistent timing across the app.
 *
 * Used by transition widgets ([CalmPageTransition], [FadeThroughPage],
 * [SharedAxisPage]) and reusable components for uniform motion feel.
 */
class AnimationDurations {
  /** Quick interactions (200ms): toggles, micro-feedback. */
  static const Duration fast = Duration(milliseconds: 200);

  /** Standard transitions (300ms): page switches, content swaps. */
  static const Duration normal = Duration(milliseconds: 300);

  /** Deliberate transitions (450ms): contemplative page navigation. */
  static const Duration slow = Duration(milliseconds: 450);

  /** Per-item stagger offset (50ms) for sequential list animations. */
  static const Duration stagger = Duration(milliseconds: 50);
}

/**
 * Animation curve constants for consistent motion feel across the app.
 *
 * Provides named semantic curves used by [StaggeredFadeIn],
 * [AnimatedTextSwitcher], [ScaleFadeTransition], and other widgets.
 */
class AnimationCurves {
  /** Default ease-in-out cubic for most transitions. */
  static const Curve standard = Curves.easeInOutCubic;

  /** Material Design emphasized curve: fast start, slow finish. */
  static const Curve emphasized = Curves.fastOutSlowIn;

  /** Gradual deceleration for elements coming to rest. */
  static const Curve decelerate = Curves.decelerate;
}

/**
 * Staggered fade-in animation for list items.
 *
 * Each item fades in with a slight upward slide, delayed by [delay] * [index]
 * to create a cascading reveal effect. Commonly used in library grids and
 * settings lists.
 */
class StaggeredFadeIn extends StatefulWidget {
  /** Zero-based position in the list, used to calculate stagger delay. */
  final int index;

  /** The widget to animate in. */
  final Widget child;

  /** Base delay between each item's animation start. */
  final Duration delay;

  /** Duration of the fade + slide animation. */
  final Duration duration;

  /** Easing curve for the animation. */
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

class _StaggeredFadeInState extends State<StaggeredFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/**
 * Animated text switcher with fade and optional slide.
 *
 * Wraps [AnimatedSwitcher] to crossfade between text values with a
 * combined fade + slide transition. The text is keyed by its value
 * so identical strings do not re-animate.
 */
class AnimatedTextSwitcher extends StatelessWidget {
  /** The current text to display; changes trigger crossfade animation. */
  final String text;

  /** Optional text style override. */
  final TextStyle? style;

  /** Alignment for the text widget. */
  final TextAlign textAlign;

  /** Duration of the crossfade transition. */
  final Duration duration;

  /** Starting offset for the incoming text slide (relative to widget size). */
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
        final slideAnimation = Tween<Offset>(begin: slideOffset, end: Offset.zero).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      child: Text(text, key: ValueKey(text), style: style, textAlign: textAlign),
    );
  }
}

/**
 * Scale and fade transition for badges and small elements.
 *
 * Animates the child between visible (full size, full opacity) and hidden
 * (scaled down to 0.8, fully transparent) states. Useful for toggle badges,
 * status indicators, and contextual action buttons.
 */
class ScaleFadeTransition extends StatelessWidget {
  /** The widget to show or hide with the transition. */
  final Widget child;

  /** Whether the child is currently visible. */
  final bool visible;

  /** Duration of the scale + fade animation. */
  final Duration duration;

  const ScaleFadeTransition({super.key, required this.child, this.visible = true, this.duration = const Duration(milliseconds: 200)});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.8,
      duration: duration,
      curve: AnimationCurves.standard,
      child: AnimatedOpacity(opacity: visible ? 1.0 : 0.0, duration: duration, curve: AnimationCurves.standard, child: child),
    );
  }
}

/**
 * Calm-style page transition for [GoRouter].
 *
 * Uses a pure crossfade with no slide movement, creating a contemplative
 * and peaceful navigation experience. Forward transition uses [AnimationDurations.slow];
 * reverse uses [AnimationDurations.normal] for a slightly quicker back-navigation.
 */
class CalmPageTransition extends CustomTransitionPage<void> {
  CalmPageTransition({required super.child, super.name, super.arguments, super.restorationId, super.key})
    : super(
        transitionDuration: AnimationDurations.slow,
        reverseTransitionDuration: AnimationDurations.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Pure fade - calm and unhurried
          final fadeIn = CurvedAnimation(parent: animation, curve: Curves.easeOut);

          final fadeOut = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn));

          return FadeTransition(
            opacity: fadeIn,
            child: FadeTransition(opacity: fadeOut, child: child),
          );
        },
      );
}

/**
 * Hero-compatible morphing card wrapper.
 *
 * Wraps a child widget in a [Hero] with a transparent [Material] background,
 * enabling smooth hero transitions between list items and detail screens.
 * Includes an optional [InkWell] tap handler with custom border radius.
 */
class MorphingCard extends StatelessWidget {
  /** Unique hero tag for matching source and destination widgets. */
  final String heroTag;

  /** The card content widget. */
  final Widget child;

  /** Optional tap callback; wraps child in [InkWell] when provided. */
  final VoidCallback? onTap;

  /** Corner radius for the ink splash bounds. */
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
        child: InkWell(onTap: onTap, borderRadius: borderRadius, child: child),
      ),
    );
  }
}

/**
 * Container transform animation using the `animations` package.
 *
 * Opens a card into a full-screen page with Material Design container
 * transform motion. The closed state renders [closedBuilder] as a tappable
 * card; tapping triggers the container expand into [openBuilder].
 *
 * Transition duration defaults to [AnimationDurations.slow].
 */
class OpenContainerCard extends StatelessWidget {
  /** Widget displayed in the closed (card) state. */
  final Widget closedBuilder;

  /** Builder for the open (full-screen) state; receives a close action callback. */
  final Widget Function(BuildContext, VoidCallback) openBuilder;

  /** Background color of the closed card; defaults to transparent. */
  final Color? closedColor;

  /** Background color of the open page; defaults to scaffold background. */
  final Color? openColor;

  /** Corner radius of the closed card. */
  final BorderRadius closedBorderRadius;

  /** Elevation of the closed card. */
  final double closedElevation;

  /** The container transform type (fade through or fade). */
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
      closedBuilder: (context, action) => InkWell(onTap: action, borderRadius: closedBorderRadius, child: closedBuilder),
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? Theme.of(context).scaffoldBackgroundColor,
      closedShape: RoundedRectangleBorder(borderRadius: closedBorderRadius),
      closedElevation: closedElevation,
    );
  }
}

/**
 * Fade-through transition for switching between unrelated content.
 *
 * Uses Material Design fade-through motion where the outgoing child fades
 * out completely before the incoming child fades in. Suitable for tab switches
 * and content that has no spatial relationship.
 */
class FadeThroughSwitcher extends StatelessWidget {
  /** The current child widget; changes trigger the fade-through animation. */
  final Widget child;

  /** Duration of the complete fade-out + fade-in cycle. */
  final Duration duration;

  const FadeThroughSwitcher({super.key, required this.child, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(animation: primaryAnimation, secondaryAnimation: secondaryAnimation, child: child);
      },
      child: child,
    );
  }
}

/**
 * Shared-axis transition for navigating between related content.
 *
 * Uses Material Design shared-axis motion where outgoing and incoming
 * children move along the same axis (horizontal, vertical, or scaled).
 * Suitable for sequential content like onboarding steps or pagination.
 */
class SharedAxisSwitcher extends StatelessWidget {
  /** The current child widget; changes trigger the shared-axis animation. */
  final Widget child;

  /** The axis along which the transition occurs. */
  final SharedAxisTransitionType transitionType;

  /** Duration of the transition. */
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

/** [GoRouter] page with Material Design fade-through transition. */
class FadeThroughPage extends CustomTransitionPage<void> {
  FadeThroughPage({required super.child, super.name, super.arguments, super.restorationId, super.key})
    : super(
        transitionDuration: AnimationDurations.normal,
        reverseTransitionDuration: AnimationDurations.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
        },
      );
}

/** [GoRouter] page with Material Design shared-axis transition. */
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
           return SharedAxisTransition(animation: animation, secondaryAnimation: secondaryAnimation, transitionType: transitionType, child: child);
         },
       );
}

/**
 * Pulse animation for subtle attention-drawing.
 *
 * Continuously scales the child between [minScale] and [maxScale] when
 * [enabled] is true. Stops and resets when disabled. Useful for drawing
 * attention to interactive elements or indicating ongoing activity.
 */
class PulseAnimation extends StatefulWidget {
  /** The widget to pulse. */
  final Widget child;

  /** Whether the pulse animation is currently active. */
  final bool enabled;

  /** Duration of one complete pulse cycle (scale up + scale down). */
  final Duration duration;

  /** Scale factor at the smallest point of the pulse. */
  final double minScale;

  /** Scale factor at the largest point of the pulse. */
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

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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

    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
