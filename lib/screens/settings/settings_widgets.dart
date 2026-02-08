// Settings shared widgets - section header, settings row, divider
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final textColorSubtitle = colors.textMuted;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColorSubtitle,
                    ),
                  ),
                ],
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
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }
    return Semantics(
      label: label,
      child: content,
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
    );
  }
}
