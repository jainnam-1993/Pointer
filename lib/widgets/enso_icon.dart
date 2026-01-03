import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ensō (円相) icon - Zen circle representing enlightenment, the void, and the beauty of imperfection
///
/// The ensō is a sacred symbol in Zen Buddhism, drawn in one or two brushstrokes
/// to express the moment when the mind is free to let the body create.
///
/// Uses SVG for crisp rendering at any size with color tinting support.
class EnsoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const EnsoIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color ?? Colors.white;

    return SvgPicture.asset(
      'assets/enso.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
