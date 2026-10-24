import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/widgets.dart';

/**
 * Window size classes and foldable posture helpers.
 *
 * Follows the Android window size class breakpoints on window width (dp):
 * compact under 600, medium 600 to 839, expanded 840 and up. Everything here
 * reads the window from [MediaQuery], never a device model, so it stays right
 * across fold, unfold and multi-window resizes.
 */
enum WindowSizeClass {
  compact,
  medium,
  expanded;

  /** Lower bound of [medium], in logical pixels. */
  static const double mediumMinWidth = 600;

  /** Lower bound of [expanded], in logical pixels. */
  static const double expandedMinWidth = 840;

  static WindowSizeClass fromWidth(double width) {
    if (width >= expandedMinWidth) return expanded;
    if (width >= mediumMinWidth) return medium;
    return compact;
  }
}

/** Primary navigation chrome for a window. */
enum NavigationType { bottomBar, rail }

/** Device posture derived from a separating fold or hinge. */
enum Posture {
  /** No separating display feature: a flat phone, tablet, or a fully open fold. */
  flat,

  /** A vertical separating hinge: content goes on either side, like an open book. */
  book,

  /** A horizontal separating hinge, half opened: top half shows, bottom half controls. */
  tabletop,
}

/** Width of the glass side rail, including its outer margin. */
const double kRailWidth = 96;

/** Readable cap for single-column content on medium and larger windows. */
const double kContentMaxWidth = 600;

/**
 * A snapshot of the window: size class, navigation type and the separating
 * hinge, if any. Hinge bounds are in window coordinates.
 */
@immutable
class WindowLayout {
  final Size size;
  final WindowSizeClass sizeClass;

  /** The separating fold or hinge, or null when nothing splits the window. */
  final DisplayFeature? hinge;

  const WindowLayout({required this.size, required this.sizeClass, this.hinge});

  factory WindowLayout.fromMediaQuery(MediaQueryData data) {
    return WindowLayout(size: data.size, sizeClass: WindowSizeClass.fromWidth(data.size.width), hinge: separatingFeature(data.displayFeatures));
  }

  static WindowLayout of(BuildContext context) => WindowLayout.fromMediaQuery(MediaQuery.of(context));

  /**
   * The first fold or hinge that separates content, matching Android's
   * FoldingFeature.isSeparating: a hinge with real width occludes, and a fold
   * separates once half opened. A flat fold is ignored.
   */
  static DisplayFeature? separatingFeature(List<DisplayFeature> features) {
    for (final f in features) {
      if (f.type == DisplayFeatureType.cutout || f.type == DisplayFeatureType.unknown) continue;
      final occluding = f.bounds.width > 0 && f.bounds.height > 0;
      if (occluding || f.state == DisplayFeatureState.postureHalfOpened || f.type == DisplayFeatureType.hinge) return f;
    }
    return null;
  }

  /** Whether the hinge has area that content must not sit under. */
  bool get isOccluding => hinge != null && hinge!.bounds.width > 0 && hinge!.bounds.height > 0;

  bool get isHalfOpened => hinge?.state == DisplayFeatureState.postureHalfOpened;

  /** True when the hinge runs top to bottom (it is taller than wide). */
  bool get hasVerticalHinge => hinge != null && hinge!.bounds.height >= hinge!.bounds.width && hinge!.bounds.height > 0;

  bool get hasHorizontalHinge => hinge != null && !hasVerticalHinge;

  Posture get posture {
    if (hasVerticalHinge) return Posture.book;
    if (hasHorizontalHinge && (isHalfOpened || isOccluding)) return Posture.tabletop;
    return Posture.flat;
  }

  NavigationType get navigationType => sizeClass == WindowSizeClass.compact ? NavigationType.bottomBar : NavigationType.rail;

  /** Two panes on expanded windows and whenever a vertical hinge splits the window. */
  int get paneCount => (sizeClass == WindowSizeClass.expanded || posture == Posture.book) ? 2 : 1;

  bool get isTwoPane => paneCount == 2;
}

/**
 * Caps a single column at [maxWidth] and centers it. On compact windows it is
 * a no-op, so phone layouts stay unchanged.
 */
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = kContentMaxWidth});

  @override
  Widget build(BuildContext context) {
    if (WindowLayout.of(context).sizeClass == WindowSizeClass.compact) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/**
 * Two side-by-side panes that never put content under a vertical hinge.
 *
 * Contract: the widget is right-anchored to the window (insets such as the
 * side rail or a safe area only on its left), so its window x origin is the
 * window width minus its own width and hinge bounds map into it. With a
 * vertical hinge the panes split exactly at it; otherwise [primaryFlex] and
 * [secondaryFlex] share the width. Each pane gets a [MediaQuery] whose inner
 * edge padding is removed, so a [SafeArea] inside only pads the outer edges.
 * Builds [primary] alone when the window is single pane.
 */
class TwoPane extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;

  /** Gap between the panes when no hinge sets it. */
  final double gap;

  const TwoPane({super.key, required this.primary, required this.secondary, this.primaryFlex = 1, this.secondaryFlex = 1, this.gap = 0});

  @override
  Widget build(BuildContext context) {
    final layout = WindowLayout.of(context);
    if (!layout.isTwoPane) return primary;
    final left = MediaQuery.removePadding(
      context: context,
      removeRight: true,
      child: KeyedSubtree(key: const ValueKey('pane-primary'), child: primary),
    );
    final right = MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      child: KeyedSubtree(key: const ValueKey('pane-secondary'), child: secondary),
    );
    if (layout.posture == Posture.book) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Right-anchored: any inset (rail, safe area) sits on the left edge.
          final originX = layout.size.width - constraints.maxWidth;
          final bounds = layout.hinge!.bounds;
          final leftWidth = (bounds.left - originX).clamp(0.0, constraints.maxWidth);
          final hingeWidth = bounds.width.clamp(0.0, constraints.maxWidth - leftWidth);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: leftWidth, child: left),
              SizedBox(key: const ValueKey('pane-hinge'), width: hingeWidth),
              Expanded(child: right),
            ],
          );
        },
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: primaryFlex, child: left),
        if (gap > 0) SizedBox(width: gap),
        Expanded(flex: secondaryFlex, child: right),
      ],
    );
  }
}

/**
 * Tabletop split: [top] fills the area above the horizontal hinge and
 * [bottom] the area below it. Spans the full window height from y = 0.
 * Builds [fallback] when the window is not in tabletop posture.
 */
class TabletopSplit extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final Widget fallback;

  const TabletopSplit({super.key, required this.top, required this.bottom, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final layout = WindowLayout.of(context);
    if (layout.posture != Posture.tabletop) return fallback;
    final bounds = layout.hinge!.bounds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: const ValueKey('tabletop-top'),
          height: bounds.top,
          child: MediaQuery.removePadding(context: context, removeBottom: true, child: top),
        ),
        SizedBox(height: bounds.height),
        Expanded(
          key: const ValueKey('tabletop-bottom'),
          child: MediaQuery.removePadding(context: context, removeTop: true, child: bottom),
        ),
      ],
    );
  }
}
