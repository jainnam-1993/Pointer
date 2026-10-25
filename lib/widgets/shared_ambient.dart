/**
 * One ambient background for the whole app (design finding 9).
 *
 * [SharedAmbientHost] paints a single [AnimatedGradient] beneath the router and
 * makes route scaffolds transparent, so a page push slides content over one
 * continuous background instead of cross-fading two copies of it. Screens keep
 * using [RouteAmbient] where they used `AnimatedGradient()`: it paints nothing
 * under a host and falls back to its own gradient where there is none (tests,
 * previews, isolated widgets).
 *
 * Render behavior is unchanged: [AnimatedGradient] still drives the shared
 * [AmbientClock], [AmbientRouteObserver] still pauses it under modal sheets and
 * dialogs, and covered page routes still run with tickers off. The one background
 * is never covered by a page, so it never needs that pause itself.
 */
library;

import 'package:flutter/material.dart';

import 'animated_gradient.dart';

/** Marks a subtree that already has the app's shared ambient background. */
class SharedAmbient extends InheritedWidget {
  const SharedAmbient({super.key, required super.child});

  /** True when a [SharedAmbientHost] paints the background above [context]. */
  static bool isActive(BuildContext context) => context.getInheritedWidgetOfExactType<SharedAmbient>() != null;

  @override
  bool updateShouldNotify(SharedAmbient oldWidget) => false;
}

/** Paints the single shared background and hosts the router above it. */
class SharedAmbientHost extends StatelessWidget {
  final Widget child;

  const SharedAmbientHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        const Positioned.fill(child: AnimatedGradient()),
        Positioned.fill(
          child: SharedAmbient(
            child: Theme(
              // Route scaffolds are glass over the one background, never an opaque fill.
              data: theme.copyWith(
                scaffoldBackgroundColor: Colors.transparent,
                pageTransitionsTheme: AmbientPageTransitionsBuilder.themeOver(theme.pageTransitionsTheme),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/** A screen's background slot: empty under a [SharedAmbientHost], its own gradient otherwise. */
class RouteAmbient extends StatelessWidget {
  const RouteAmbient({super.key});

  @override
  Widget build(BuildContext context) => SharedAmbient.isActive(context) ? const SizedBox.shrink() : const AnimatedGradient();
}

/**
 * Wraps the platform's page transition (Cupertino slide with edge-swipe back on
 * iOS) and fades the outgoing page's content as it is covered. The fade is driven
 * by the secondary animation, so it tracks the back gesture; two transparent
 * pages over the shared background never show through each other.
 */
class AmbientPageTransitionsBuilder extends PageTransitionsBuilder {
  final PageTransitionsBuilder base;

  const AmbientPageTransitionsBuilder(this.base);

  /** [theme] with every platform's builder wrapped. */
  static PageTransitionsTheme themeOver(PageTransitionsTheme theme) {
    const fallback = PageTransitionsTheme();
    return PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: AmbientPageTransitionsBuilder(theme.builders[platform] ?? fallback.builders[platform] ?? const FadeForwardsPageTransitionsBuilder()),
      },
    );
  }

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final covered = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    return FadeTransition(opacity: ReverseAnimation(covered), child: base.buildTransitions<T>(route, context, animation, secondaryAnimation, child));
  }
}
