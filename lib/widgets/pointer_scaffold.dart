import 'package:flutter/material.dart';
import 'animated_gradient.dart';

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
          const Positioned.fill(child: AnimatedGradient()),
          if (useSafeArea) SafeArea(child: body) else body,
        ],
      ),
    );
  }
}
