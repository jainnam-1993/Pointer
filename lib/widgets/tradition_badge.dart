import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/pointings.dart';
import '../theme/app_theme.dart';

/**
 * Pill-shaped badge displaying the [Tradition] of a pointing.
 *
 * Renders the tradition icon and name inside a frosted-glass pill with
 * backdrop blur. Includes a semantic label for screen reader accessibility
 * (e.g., "Tradition: Advaita Vedanta").
 *
 * Uses [PointerColors] from `context.colors` for theming.
 */
class TraditionBadge extends StatelessWidget {
  /** The tradition to display (determines icon and label text). */
  final Tradition tradition;

  const TraditionBadge({super.key, required this.tradition});

  @override
  Widget build(BuildContext context) {
    final info = traditions[tradition]!;
    final bgColor = context.colors.glassBackground;
    final borderColor = context.colors.glassBorder;
    final textColor = context.colors.textPrimary;

    return Semantics(
      label: 'Tradition: ${info.name}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(info.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  info.name,
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
