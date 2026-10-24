/**
 * Motion tokens and the single reduce-motion check.
 *
 * Every animation picks a duration and curve (or spring) from [Motion], and
 * asks [Motion.reduce] once whether to animate at all. [Motion.reduce] honors
 * the system setting and the app's Animations toggle: the app root folds the
 * toggle into [MediaQueryData.disableAnimations], and widgets built outside
 * that root (tests, overlays) fall back to [reduceMotionOverrideProvider].
 */
library;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart' show reduceMotionOverrideProvider;

class Motion {
  const Motion._();

  /** 120 ms: press feedback, toggles. */
  static const Duration instant = Duration(milliseconds: 120);

  /** 200 ms: small state changes (fades, color). */
  static const Duration quick = Duration(milliseconds: 200);

  /** 320 ms: component transitions (sheets, toasts, expanding cards). */
  static const Duration standard = Duration(milliseconds: 320);

  /** 600 ms: screen-level reveals. */
  static const Duration slow = Duration(milliseconds: 600);

  /** 1200 ms: contemplative reveals (pointing text, enso draw). */
  static const Duration calm = Duration(milliseconds: 1200);

  /** 4 s: one breath; ambient loops. */
  static const Duration breath = Duration(seconds: 4);

  /** Default easing for entering content. */
  static const Curve enter = Curves.easeOutCubic;

  /** Default easing for leaving content. */
  static const Curve exit = Curves.easeInCubic;

  /** Symmetric easing for state changes. */
  static const Curve inOut = Curves.easeInOutCubic;

  /** Critically damped spring: settles without bounce (sheets, drags). */
  static final SpringDescription settle = SpringDescription.withDampingRatio(mass: 1, stiffness: 300, ratio: 1.0);

  /** Gentle spring with a hint of life (press release, toggles). */
  static final SpringDescription gentle = SpringDescription.withDampingRatio(mass: 1, stiffness: 420, ratio: 0.82);

  /**
   * Liquid spring for the tab selection pill: one small overshoot (about 3 px), because the pill moves with the finger
   * like a liquid. Everything else settles without bounce.
   */
  static final SpringDescription liquid = SpringDescription.withDampingRatio(mass: 1, stiffness: 280, ratio: 0.78);

  /** Press-scale target for tappable surfaces. */
  static const double pressScale = 0.97;

  /** Whether motion should be reduced here: system setting or the app's Animations toggle. */
  static bool reduce(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return true;
    try {
      return ProviderScope.containerOf(context, listen: false).read(reduceMotionOverrideProvider) == true;
    } catch (_) {
      return false; // No ProviderScope above (isolated widget tests).
    }
  }

  /** [d], or zero when motion is reduced. */
  static Duration of(BuildContext context, Duration d) => reduce(context) ? Duration.zero : d;
}

/**
 * A [Curve] that follows a spring from 0 to 1 over [duration], for implicit animations (AnimatedContainer and friends)
 * that should move like a spring rather than along an easing curve. The spring should settle within [duration].
 */
class SpringCurve extends Curve {
  final SpringDescription spring;

  final Duration duration;

  const SpringCurve(this.spring, this.duration);

  @override
  double transformInternal(double t) {
    final seconds = t * duration.inMicroseconds / Duration.microsecondsPerSecond;
    return SpringSimulation(spring, 0, 1, 0).x(seconds);
  }
}
