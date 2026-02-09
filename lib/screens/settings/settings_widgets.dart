/** Shared widgets for settings screen layout: SettingsSectionHeader, SettingsRow, SettingsDivider. */
library;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Uppercase label header for a settings section (e.g., "NOTIFICATIONS", "APPEARANCE").
class SettingsSectionHeader extends StatelessWidget {
  /// The section title text, typically in uppercase.
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.labelSmall);
  }
}

/**
 * A single row in a settings card with title, optional subtitle, leading/trailing widgets.
 *
 * When [onTap] is provided, the row is wrapped in an [InkWell] and marked as a
 * semantic button. The leading widget (e.g., lock icon) appears before the title.
 */
class SettingsRow extends StatelessWidget {
  /// Primary label for the setting.
  final String title;

  /// Optional secondary text below the title (e.g., current value or status).
  final String? subtitle;

  /// Optional widget before the title (e.g., icon).
  final Widget? leading;

  /// Optional widget after the title (e.g., switch, chevron, or value text).
  final Widget? trailing;

  /// Tap callback; when provided, the row becomes tappable.
  final VoidCallback? onTap;

  const SettingsRow({super.key, required this.title, this.subtitle, this.leading, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final textColorSubtitle = colors.textMuted;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: textColor)),
                if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: TextStyle(fontSize: 14, color: textColorSubtitle))],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    final label = '$title${subtitle != null ? ', $subtitle' : ''}';

    if (onTap != null) {
      return Semantics(
        button: true,
        label: label,
        child: InkWell(onTap: onTap, child: content),
      );
    }
    return Semantics(label: label, child: content);
  }
}

/// Thin horizontal divider between [SettingsRow] items within a [GlassCard].
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
    );
  }
}
