import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

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

  const WindowLayout({required this.size, required this.sizeClass, this.hinge, this.hasVerticalFold = false});

  factory WindowLayout.fromMediaQuery(MediaQueryData data) {
    return WindowLayout(
      size: data.size,
      sizeClass: WindowSizeClass.fromWidth(data.size.width),
      hinge: separatingFeature(data.displayFeatures),
      hasVerticalFold: data.displayFeatures.any(_isVerticalFold),
    );
  }

  static bool _isVerticalFold(DisplayFeature f) =>
      (f.type == DisplayFeatureType.fold || f.type == DisplayFeatureType.hinge) && f.bounds.height > 0 && f.bounds.height >= f.bounds.width;

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

  /**
   * True when a vertical fold runs top to bottom through the window in any
   * state, flat included. Unlike [hinge], a flat fold does not separate
   * content, but it says the window is an unfolded foldable's inner screen.
   */
  final bool hasVerticalFold;

  /** Narrowest window that gets two panes because of its shape rather than its width. */
  static const double foldableTwoPaneMinWidth = 720;

  /** Widest long-to-short side ratio still counted as a near-square, unfolded inner screen. */
  static const double foldableMaxAspect = 1.25;

  /**
   * Two panes on expanded windows, whenever a vertical hinge splits the window,
   * and on an unfolded foldable's near-square inner screen. The last case
   * matters when the user raises display size: the vivo V2330 at a 432 dpi display size
   * setting is about 815 dp wide, under [WindowSizeClass.expandedMinWidth],
   * yet it is the same device that gets two panes at the default density.
   */
  int get paneCount {
    if (sizeClass == WindowSizeClass.expanded || posture == Posture.book) return 2;
    if (sizeClass == WindowSizeClass.medium && (hasVerticalFold || _isNearSquareInnerScreen)) return 2;
    return 1;
  }

  bool get _isNearSquareInnerScreen {
    if (size.shortestSide < foldableTwoPaneMinWidth) return false;
    return size.longestSide / size.shortestSide < foldableMaxAspect;
  }

  bool get isTwoPane => paneCount == 2;

  /**
   * An unfolded foldable's inner screen: a vertical fold in any state, book
   * posture, or the near-square shape. These windows keep the layouts tuned on
   * the Fold; the tablet rules below ([railAlignment], [railContentInset],
   * [heroComposition]) apply only to the other regular windows.
   */
  bool get isFoldableInnerScreen => hasVerticalFold || posture == Posture.book || _isNearSquareInnerScreen;

  /**
   * Rail rule. Material 3 puts rail destinations at the top of their own
   * margin column, and the iPadOS sidebar starts at the top too. On tablets the
   * glass capsule sits top-left, clear of Today's centered card. The Fold and
   * tabletop keep the centered capsule they had.
   */
  Alignment get railAlignment => isFoldableInnerScreen || posture == Posture.tabletop ? Alignment.centerLeft : Alignment.topLeft;

  /**
   * Left padding the shell gives content beside the rail. Tablets also get
   * [kRailGutter], so the rail has its own margin column and never touches
   * content. The Fold keeps [kRailWidth] alone, because its 815 dp two panes
   * need the width.
   */
  double get railContentInset => kRailWidth + (isFoldableInnerScreen ? 0 : kRailGutter);

  /** How Today composes the hero card with its context. See [HeroComposition]. */
  HeroComposition get heroComposition {
    if (sizeClass == WindowSizeClass.compact || posture != Posture.flat || isFoldableInnerScreen) {
      return isTwoPane ? HeroComposition.sideBySide : HeroComposition.single;
    }
    if (size.height > size.width * kTallWindowAspect) return HeroComposition.stacked;
    return isTwoPane ? HeroComposition.sideBySide : HeroComposition.single;
  }
}

/**
 * Today's hero composition. [single]: the card alone, as on phones.
 * [sideBySide]: the card with context in a second pane (Fold, landscape
 * tablets). [stacked]: one composed column on tall tablets, with the card at
 * [kHeroCardMaxWidth], the actions below it, and the context beneath them. The
 * group sits a little above center, so a portrait iPad has no empty band above
 * a floating card.
 */
enum HeroComposition { single, sideBySide, stacked }

/** Height-to-width ratio past which a regular window counts as a tall (portrait) tablet. */
const double kTallWindowAspect = 1.15;

/** Extra gap between the rail column and content on tablets. */
const double kRailGutter = 16;

/** Top inset of a top-aligned rail, matching the large-title row of the screens beside it. */
const double kRailTopInset = 20;

/** Widest a multi-column screen (Saved) gets; past this, tiles stop adding columns and center. */
const double kWideContentMaxWidth = 1240;

/** Featured readings in Library's detail pane: six fill a regular grid of two or three columns. */
const int kFeaturedOverviewCount = 6;

/** Narrowest a Saved tile gets before the grid drops a column. */
const double kTileMinWidth = 300;

/** Columns of [minTileWidth]-wide tiles, separated by [gap], that fit in [width]. Never below one. */
int tileColumns(double width, {double minTileWidth = kTileMinWidth, double gap = 12}) =>
    ((width + gap) / (minTileWidth + gap)).floor().clamp(1, 1 << 20);

/**
 * Columns for a grid of [count] equal cards when at most [fit] fit: the most
 * columns that leave every row full. Three cards in two columns would leave a
 * ragged last row, so they go in three columns or one. Never above [count].
 */
int balancedColumns(int fit, int count) {
  if (count <= 1) return 1;
  final cap = fit.clamp(1, count);
  for (var c = cap; c > 1; c--) {
    if (count % c == 0) return c;
  }
  return 1;
}

/**
 * The Saved tiles: a [SliverList] on one column, and on wider windows a
 * masonry of [tileColumns] columns: each column is as tall as its own items.
 * Items fill round-robin, so the reading order runs left to right, then top
 * to bottom. Items bring their own bottom spacing, as in the list.
 */
class SliverTileGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minTileWidth;
  final double gap;

  const SliverTileGrid({super.key, required this.itemCount, required this.itemBuilder, this.minTileWidth = kTileMinWidth, this.gap = 12});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final cols = WindowLayout.of(context).sizeClass == WindowSizeClass.compact
            ? 1
            : tileColumns(constraints.crossAxisExtent, minTileWidth: minTileWidth, gap: gap).clamp(1, itemCount < 1 ? 1 : itemCount);
        if (cols == 1) return SliverList(delegate: SliverChildBuilderDelegate(itemBuilder, childCount: itemCount));
        return SliverToBoxAdapter(
          child: Row(
            key: const ValueKey('tile-grid'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < cols; c++) ...[
                if (c > 0) SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (var i = c; i < itemCount; i += cols) Builder(builder: (context) => itemBuilder(context, i))],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/**
 * The [HeroComposition.stacked] column: [hero] over [below], capped at
 * [kHeroCardMaxWidth] and placed a little above center. [hero] shrinks
 * before [below] when the window is short.
 */
class HeroStack extends StatelessWidget {
  final Widget hero;
  final Widget below;

  const HeroStack({super.key, required this.hero, required this.below});

  @override
  Widget build(BuildContext context) {
    return Align(
      key: const ValueKey('hero-stack'),
      alignment: const Alignment(0, -0.3),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kHeroCardMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: hero),
            below,
          ],
        ),
      ),
    );
  }
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

  /**
   * Narrowest the primary pane gets when the flex split would make it
   * narrower, so a list keeps at least a phone's width. Capped at
   * [kPrimaryPaneMaxShare] of the width so the secondary pane stays usable.
   */
  final double primaryMinWidth;

  const TwoPane({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    this.gap = 0,
    this.primaryMinWidth = 0,
  });

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - gap;
        final flexWidth = available * primaryFlex / (primaryFlex + secondaryFlex);
        final floor = primaryMinWidth.clamp(0.0, available * kPrimaryPaneMaxShare);
        final primaryWidth = flexWidth < floor ? floor : flexWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: primaryWidth, child: left),
            if (gap > 0) SizedBox(width: gap),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

/** Largest share of a [TwoPane]'s width that [TwoPane.primaryMinWidth] may claim. */
const double kPrimaryPaneMaxShare = 0.55;

/** Narrowest a list pane gets beside its detail: a compact phone's list width. */
const double kListPaneMinWidth = 360;

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

/**
 * Keeps a single-column screen off a vertical hinge.
 *
 * In book posture the window splits at the hinge through [TwoPane]: [child]
 * takes one pane and [companion] (a title, a detail, or a calm empty pane) the
 * other, so no content sits under the fold. Everywhere else it builds [child]
 * alone, so phone, tablet and tabletop layouts are unchanged. [childFirst]
 * puts [child] in the left pane; otherwise [companion] leads, like a book's
 * facing page.
 */
class HingeSplit extends StatelessWidget {
  final Widget child;
  final Widget companion;
  final bool childFirst;

  const HingeSplit({super.key, required this.child, required this.companion, this.childFirst = false});

  @override
  Widget build(BuildContext context) {
    if (WindowLayout.of(context).posture != Posture.book) return child;
    return childFirst ? TwoPane(primary: child, secondary: companion) : TwoPane(primary: companion, secondary: child);
  }
}

/**
 * Anchor for a modal route so it opens on the right side of a hinge.
 *
 * Flutter's modal routes place themselves in one [DisplayFeatureSubScreen];
 * without an anchor that is the top-left one, which in tabletop posture puts a
 * bottom sheet in the upper half. Sheets belong with the controls below the
 * fold, so in tabletop this returns the bottom center of the window. Elsewhere
 * it returns null and the default placement holds.
 */
Offset? sheetAnchorPoint(BuildContext context) {
  // Read the whole window, not the nearest MediaQuery: a sheet opened from
  // inside another sheet only sees its own sub-screen.
  final layout = WindowLayout.fromMediaQuery(MediaQueryData.fromView(View.of(context)));
  if (layout.posture != Posture.tabletop) return null;
  return Offset(layout.size.width / 2, layout.size.height);
}

/**
 * Height cap for a modal sheet in a window of [windowHeight]: 70 percent on
 * normal windows, nearly all of it on short ones (the lower half of a tabletop
 * fold, a phone in landscape) where 70 percent would leave too little room.
 */
double sheetMaxHeight(double windowHeight) => windowHeight * (windowHeight < kShortWindowHeight ? 0.94 : 0.7);

/** Windows shorter than this get a taller sheet cap; see [sheetMaxHeight]. */
const double kShortWindowHeight = 520;

/** Widest a centered form-sheet panel gets on medium and expanded windows, like an iPad form sheet. */
const double kFormSheetMaxWidth = 580;

/** Tallest a centered form-sheet panel gets. */
const double kFormSheetMaxHeight = 760;

/** Widest a dialog's card gets; past this a dialog's lines run too long to read. */
const double kDialogMaxWidth = 480;

/** Widest the hero pointing card gets on medium and expanded windows (compact keeps [kContentMaxWidth]). */
const double kHeroCardMaxWidth = 680;

/**
 * Whether modal sheets present as centered form-sheet panels: on medium and
 * expanded windows, except tabletop posture, whose sheets belong below the
 * fold. Compact windows (phones, an iPad Split View third) keep bottom sheets.
 * Reads the whole window, like [sheetAnchorPoint].
 */
bool presentsFormSheets(BuildContext context) {
  final layout = WindowLayout.fromMediaQuery(MediaQueryData.fromView(View.of(context)));
  return layout.sizeClass != WindowSizeClass.compact && layout.posture != Posture.tabletop;
}

/**
 * Shows [builder] as a bottom sheet on compact windows and as a centered
 * [FormSheetPanel] on medium and expanded ones, so a sheet never stretches
 * along the bottom of an iPad or an unfolded phone. Both routes close on
 * Escape, a barrier tap and the system back gesture.
 */
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool useRootNavigator = false,
  Offset? anchorPoint,
}) {
  if (!presentsFormSheets(context)) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      anchorPoint: anchorPoint,
      backgroundColor: Colors.transparent,
    );
  }
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    anchorPoint: anchorPoint,
    builder: (context) => FormSheetPanel(child: builder(context)),
  );
}

/**
 * A sheet's content as a centered panel, at most [kFormSheetMaxWidth] by
 * [kFormSheetMaxHeight], inside the window's safe area and above the keyboard.
 * The panel clips the content's corners, so a sheet drawn with rounded top
 * corners reads as a rounded card.
 */
class FormSheetPanel extends StatelessWidget {
  final Widget child;

  const FormSheetPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: media.padding + media.viewInsets + const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          key: const ValueKey('form-sheet-panel'),
          constraints: const BoxConstraints(maxWidth: kFormSheetMaxWidth, maxHeight: kFormSheetMaxHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              type: MaterialType.transparency,
              child: MediaQuery.removePadding(context: context, removeTop: true, removeBottom: true, removeLeft: true, removeRight: true, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * Caps a [Dialog] at [kDialogMaxWidth] of card plus the dialog's own inset, so
 * its text keeps a readable measure on wide windows. Wrap the dialog widget a
 * dialog builder returns.
 */
class DialogWidth extends StatelessWidget {
  final Widget child;

  /** Horizontal inset the wrapped dialog adds on each side (Dialog's default is 40). */
  final double inset;

  const DialogWidth({super.key, required this.child, this.inset = 40});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        key: const ValueKey('dialog-width'),
        constraints: BoxConstraints(maxWidth: kDialogMaxWidth + 2 * inset),
        child: child,
      ),
    );
  }
}
