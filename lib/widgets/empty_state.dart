/**
 * Designed empty state: a small unfinished enso in ink, one line in the app's voice,
 * and an optional single text action (design finding 21).
 */
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';

/**
 * Calm empty state used by Library, History and filtered lists.
 *
 * [icon] is kept for call-site compatibility but the visual is always the unfinished
 * enso, so every empty state in the app reads as one family.
 */
class EmptyStateWidget extends StatelessWidget {
  /** Legacy icon parameter; ignored by the enso visual. */
  final IconData? icon;

  /** The single in-voice line, set in the reading serif. */
  final String title;

  /** Optional quieter second line explaining how to fill the space. */
  final String? subtitle;

  /** Diameter of the enso mark. */
  final double iconSize;

  /** Label for the single call to action, shown only with [onAction]. */
  final String? actionLabel;

  /** Callback for the call to action. */
  final VoidCallback? onAction;

  const EmptyStateWidget({super.key, this.icon, required this.title, this.subtitle, this.iconSize = 56, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: CustomPaint(
                  size: Size.square(iconSize),
                  painter: _UnfinishedEnsoPainter(color: colors.textMuted),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                style: TextStyle(fontFamily: AppFonts.serif, color: colors.textPrimary, fontSize: AppType.headline, height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppType.callout, height: 1.45),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.accent,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  ),
                  onPressed: () {
                    Haptics.light();
                    onAction!();
                  },
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(fontSize: AppType.body, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/** An open brush circle: about 300 degrees, thicker at the start, tapering out. */
class _UnfinishedEnsoPainter extends CustomPainter {
  final Color color;

  const _UnfinishedEnsoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(size.shortestSide * 0.08);
    const start = -math.pi / 2 + 0.5;
    const sweep = math.pi * 1.68;
    const segments = 24;
    for (var i = 0; i < segments; i++) {
      final t = i / segments;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.85 - t * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * (0.07 - t * 0.04);
      canvas.drawArc(inset, start + sweep * t, sweep / segments + 0.01, false, paint);
    }
  }

  @override
  bool shouldRepaint(_UnfinishedEnsoPainter oldDelegate) => oldDelegate.color != color;
}
