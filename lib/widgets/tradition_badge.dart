import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/pointings.dart';
import '../theme/app_theme.dart';

/// Badge showing the tradition of a pointing
///
/// Includes semantic label for screen reader accessibility.
class TraditionBadge extends StatelessWidget {
  final Tradition tradition;

  const TraditionBadge({
    super.key,
    required this.tradition,
  });

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
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info.icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                info.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
