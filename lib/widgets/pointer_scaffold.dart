import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_gradient.dart';
import 'shared_ambient.dart';

/// Standardized scaffold that layers [AnimatedGradient] behind content.
///
/// Eliminates the repeated `Scaffold > Stack > [Positioned.fill(AnimatedGradient()),
/// SafeArea > ...]` boilerplate used across every screen. Wraps the [body] in a
/// [SafeArea] by default (disable via [useSafeArea] for screens needing custom
/// safe-area handling).
class PointerScaffold extends StatelessWidget {
  /// The primary content displayed above the animated gradient.
  final Widget body;

  /// Optional bottom navigation bar (passed through to [Scaffold]).
  final Widget? bottomNavigationBar;

  /// Whether the body extends behind the bottom navigation bar.
  final bool extendBody;

  /// Whether the body extends behind the app bar.
  final bool extendBodyBehindAppBar;

  /// Whether to wrap [body] in a [SafeArea]. Defaults to true.
  final bool useSafeArea;

  const PointerScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          const Positioned.fill(child: RouteAmbient()),
          // The bottom stays open so lists scroll under the floating tab bar and the home indicator; each list ends
          // [scrollEndInset] above the bottom instead.
          if (useSafeArea) SafeArea(bottom: false, child: body) else body,
        ],
      ),
    );
  }
}

/// Bottom padding for the end of a [PointerScaffold] list: the bottom inset (the floating tab bar inside the shell,
/// the safe area elsewhere, nothing beside the rail) plus one spacing step, so the last item scrolls fully clear.
double scrollEndInset(BuildContext context) => MediaQuery.paddingOf(context).bottom + AppSpacing.lg;
