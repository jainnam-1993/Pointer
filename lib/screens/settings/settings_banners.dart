/** Banners for the settings screen: notification permission alert. */
library;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/**
 * Orange warning banner shown when notification permission is denied at the system level.
 *
 * Prompts the user to open system settings to re-enable notifications.
 * Displayed above the notification settings card when permission is not granted.
 */
class NotificationPermissionBanner extends StatelessWidget {
  /** Callback to request notification permission (shows system prompt, falls back to settings). */
  final VoidCallback onEnable;

  const NotificationPermissionBanner({super.key, required this.onEnable});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off, color: Colors.orange, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications Disabled',
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text('Tap Enable to receive daily pointings', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: onEnable,
            child: Text(
              'Enable',
              style: TextStyle(color: colors.accent, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
