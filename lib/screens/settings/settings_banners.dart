/** Banners for the settings screen: notification permission and premium feature alerts. */
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
  /// Callback to open the system notification settings.
  final VoidCallback onOpenSettings;

  const NotificationPermissionBanner({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications Disabled',
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text('Enable in system settings to receive daily pointings', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOpenSettings,
            child: Text(
              'Open Settings',
              style: TextStyle(color: colors.accent, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner showing a premium feature is locked
class PremiumFeatureBanner extends StatelessWidget {
  final String feature;
  final VoidCallback onUpgrade;

  const PremiumFeatureBanner({super.key, required this.feature, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final goldColor = colors.gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: goldColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$feature is a Premium Feature',
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text('Upgrade to unlock $feature and more', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onUpgrade,
            child: Text(
              'Upgrade',
              style: TextStyle(color: goldColor, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
