/**
 * Tab-to-tab transition for the shell (liquid-glass-spec.md section 4, "Tab switch: content").
 *
 * Every branch stays mounted in one full-size Stack over the single shared ambient background (SharedAmbientHost), so a
 * switch never rebuilds the background, never flashes, and never shifts layout. The incoming tab fades in over
 * [Motion.quick] while rising from a 0.98 scale; the outgoing tab fades out underneath. Under Reduce Motion the scale is
 * dropped and only the fade remains. Hidden tabs are offstage, ignore pointers, are excluded from semantics and have
 * their tickers muted.
 */
library;

import 'package:flutter/widgets.dart';

import '../utils/motion.dart';

class TabCrossFadeContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const TabCrossFadeContainer({super.key, required this.currentIndex, required this.children});

  /** Scale the incoming tab rises from. */
  static const double enterScale = 0.98;

  @override
  State<TabCrossFadeContainer> createState() => _TabCrossFadeContainerState();
}

class _TabCrossFadeContainerState extends State<TabCrossFadeContainer> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: Motion.quick, value: 1);
  int? _previous;

  @override
  void didUpdateWidget(TabCrossFadeContainer old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _previous = old.currentIndex;
      _t.forward(from: 0).whenCompleteOrCancel(() {
        if (mounted) setState(() => _previous = null);
      });
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = Motion.reduce(context);
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = Motion.enter.transform(_t.value);
        return Stack(fit: StackFit.expand, children: [for (var i = 0; i < widget.children.length; i++) _tab(i, t, reduce)]);
      },
    );
  }

  Widget _tab(int i, double t, bool reduce) {
    final current = i == widget.currentIndex;
    final leaving = i == _previous;
    final visible = current || leaving;
    Widget child = widget.children[i];
    if (current && t < 1) {
      child = Opacity(
        opacity: t,
        child: reduce ? child : Transform.scale(scale: TabCrossFadeContainer.enterScale + (1 - TabCrossFadeContainer.enterScale) * t, child: child),
      );
    } else if (leaving) {
      child = Opacity(opacity: 1 - t, child: child);
    }
    return Offstage(
      key: ValueKey('tab-$i'),
      offstage: !visible,
      child: TickerMode(
        enabled: current,
        child: IgnorePointer(
          ignoring: !current,
          child: ExcludeSemantics(excluding: !current, child: child),
        ),
      ),
    );
  }
}
