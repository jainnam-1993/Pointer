import 'dart:async';

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
 * Provides named semantic curves used by [StaggeredFadeIn] and other widgets.
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
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Stagger the animation start based on index
    _startTimer = Timer(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
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
