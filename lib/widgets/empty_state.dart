import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardized empty state placeholder with icon, title, and optional subtitle.
///
/// Replaces ad-hoc empty-state widgets in [HistoryScreen], [LibraryScreen],
/// and teaching detail screens. Uses [PointerColors] from the current theme.
class EmptyStateWidget extends StatelessWidget {
  /// The icon displayed prominently above the title.
  final IconData icon;

  /// Primary empty-state message.
  final String title;

  /// Optional secondary message with additional context.
  final String? subtitle;

  /// Icon size. Defaults to 64.
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: colors.textSecondary, fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
