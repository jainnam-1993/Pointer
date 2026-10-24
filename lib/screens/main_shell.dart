import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import '../widgets/liquid_glass_nav.dart';
import '../theme/app_icons.dart';
import '../layout/adaptive.dart';

/**
 * Root shell widget providing bottom navigation and tab management.
 *
 * Wraps the [StatefulNavigationShell] from GoRouter with horizontal swipe
 * gestures for tab switching (dust motes now come from the ambient shader), and a
 * glassmorphic [_BottomNavBar]. Hides the nav bar in zen mode.
 *
 * The [navigationShell] must NOT be wrapped in [AnimatedSwitcher] or
 * [KeyedSubtree] as it contains internal GlobalKeys that conflict
 * when the widget tree changes.
 */
class MainShell extends ConsumerStatefulWidget {
  /** The GoRouter navigation shell managing tab state and branch navigation. */
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  /** The bar minimizes on scroll down in lists (never on Home) and restores on scroll up, at the top, or on a tap. */
  bool _minimized = false;
  double _scrollRun = 0;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical || n.depth > 2) return false;
    if (widget.navigationShell.currentIndex == 0) return false;
    if (n is ScrollUpdateNotification && n.scrollDelta != null) {
      final d = n.scrollDelta!;
      _scrollRun = (d > 0) == (_scrollRun > 0) ? _scrollRun + d : d;
      final atTop = n.metrics.pixels <= n.metrics.minScrollExtent;
      if (!_minimized && _scrollRun > LiquidGlass.minimizeAfter && !atTop) {
        setState(() => _minimized = true);
      } else if (_minimized && (atTop || _scrollRun < -LiquidGlass.restoreAfter)) {
        setState(() => _minimized = false);
      }
    }
    return false;
  }

  void _goBranch(int index, int currentIndex) {
    if (_minimized) setState(() => _minimized = false);
    _scrollRun = 0;
    widget.navigationShell.goBranch(index, initialLocation: index == currentIndex);
  }

  bool _currentBranchCanPop() {
    final key = widget.navigationShell.shellRouteContext.navigatorKey;
    return key.currentState?.canPop() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isZenMode = ref.watch(zenModeProvider);
    final currentIndex = widget.navigationShell.currentIndex;
    final branchCanPop = _currentBranchCanPop();
    final shouldInterceptBack = currentIndex != 0 && !branchCanPop;

    // Wrap content with horizontal swipe gesture and pure fade transition
    // Pure fade creates contemplative, peaceful experience (no slides)
    final content = GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left (negative velocity) -> next tab
        if (details.primaryVelocity! < -200 && currentIndex < 3) {
          widget.navigationShell.goBranch(currentIndex + 1);
        }
        // Swipe right (positive velocity) -> previous tab
        else if (details.primaryVelocity! > 200 && currentIndex > 0) {
          widget.navigationShell.goBranch(currentIndex - 1);
        }
      },
      // Don't wrap navigationShell in AnimatedSwitcher/KeyedSubtree - it has
      // internal GlobalKeys that conflict when the widget tree changes.
      // The shell handles its own tab state; transitions happen at content level.
      child: NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.navigationShell),
    );

    // In zen mode, hide bottom nav bar
    if (isZenMode) {
      return PopScope(
        canPop: !shouldInterceptBack,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          widget.navigationShell.goBranch(0);
        },
        child: Scaffold(body: Stack(children: [content]), extendBody: true),
      );
    }

    // BackdropGroup lets the tab bar share one backdrop read with any other
    // grouped blur in the shell (BackdropFilter.grouped).
    return PopScope(
      canPop: !shouldInterceptBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        widget.navigationShell.goBranch(0);
      },
      child: BackdropGroup(
        child: WindowLayout.of(context).navigationType == NavigationType.rail
            ? _buildWithRail(context, content, currentIndex)
            : Scaffold(
                body: Stack(children: [content]),
                extendBody: true,
                bottomNavigationBar: _BottomNavBar(
                  currentIndex: currentIndex,
                  minimized: _minimized && currentIndex != 0,
                  onTap: (index) => _goBranch(index, currentIndex),
                ),
              ),
      ),
    );
  }

  /**
   * Medium and expanded windows: a glass side rail replaces the bottom bar.
   * Content keeps the full window (so the ambient, frost and hinge bounds stay
   * in window coordinates) and gets the rail as extra left padding instead.
   */
  Widget _buildWithRail(BuildContext context, Widget content, int currentIndex) {
    final media = MediaQuery.of(context);
    final layout = WindowLayout.fromMediaQuery(media);
    final railTop = layout.posture == Posture.tabletop ? layout.hinge!.bounds.bottom : 0.0;
    return Scaffold(
      body: Stack(
        children: [
          MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(left: media.padding.left + kRailWidth),
              viewPadding: media.viewPadding.copyWith(left: media.viewPadding.left + kRailWidth),
            ),
            child: content,
          ),
          Positioned(
            left: 0,
            top: railTop,
            bottom: 0,
            width: kRailWidth + media.padding.left,
            child: SafeArea(
              right: false,
              top: railTop == 0,
              child: _SideRail(currentIndex: currentIndex, onTap: (index) => _goBranch(index, currentIndex)),
            ),
          ),
        ],
      ),
    );
  }
}

/** The four tabs, shared by the bottom bar and the side rail. */
const _tabs = <LiquidTab>[
  (AppIcons.home, AppIcons.homeActive, 'Home'),
  (AppIcons.inquiry, AppIcons.inquiryActive, 'Inquiry'),
  (AppIcons.library, AppIcons.libraryActive, 'Library'),
  (AppIcons.settings, AppIcons.settingsActive, 'Settings'),
];

/**
 * Liquid Glass side rail for medium and expanded windows: a vertical capsule centred on the left edge, sharing the
 * shell's [BackdropGroup] (one live blur).
 */
class _SideRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SideRail({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('side-rail'),
      child: Padding(
        padding: const EdgeInsets.only(left: LiquidGlass.railInset),
        child: Align(
          alignment: Alignment.centerLeft,
          child: LiquidGlassNav(tabs: _tabs, currentIndex: currentIndex, onTap: onTap, axis: Axis.vertical),
        ),
      ),
    );
  }
}

/**
 * Liquid Glass tab bar for compact windows: a floating 64 px capsule, [LiquidGlass.edgeMargin] from the screen edges and
 * at most [LiquidGlass.barMaxWidth] wide. It minimizes to an icon-only 48 px capsule while a list scrolls down.
 */
class _BottomNavBar extends StatelessWidget {
  /** Index of the currently selected tab (0-3). */
  final int currentIndex;

  /** Callback when a tab is tapped. */
  final ValueChanged<int> onTap;

  final bool minimized;

  const _BottomNavBar({required this.currentIndex, required this.onTap, this.minimized = false});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final full = math.min(media.size.width - 2 * LiquidGlass.edgeMargin, LiquidGlass.barMaxWidth);
    final bottom = math.max(media.padding.bottom + LiquidGlass.safeGap, LiquidGlass.edgeMargin);
    final reduce = Motion.reduce(context);
    return Padding(
      key: const ValueKey('liquid-tab-bar'),
      padding: EdgeInsets.fromLTRB(LiquidGlass.edgeMargin, AppSpacing.sm, LiquidGlass.edgeMargin, bottom),
      child: Center(
        heightFactor: 1,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : Motion.standard,
          curve: SpringCurve(Motion.settle, Motion.standard),
          width: minimized ? LiquidGlassNav.minimizedWidth(_tabs.length) : full,
          height: minimized ? LiquidGlass.barMinimizedHeight : LiquidGlass.barHeight,
          child: LiquidGlassNav(tabs: _tabs, currentIndex: currentIndex, onTap: onTap, axis: Axis.horizontal, minimized: minimized),
        ),
      ),
    );
  }
}
