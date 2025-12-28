import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Banner shown when notification permission is denied
/// Prompts user to enable notifications in system settings
class PermissionBanner extends ConsumerWidget {
  final VoidCallback? onDismiss;

  const PermissionBanner({
    super.key,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = context.colors.textPrimary;
    final textColorSecondary = context.colors.textSecondary;

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: context.isDarkMode ? Colors.amber.withValues(alpha: 0.3) : Colors.amber,
        child: Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: Colors.amber,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Notifications Disabled',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enable in system settings to receive daily pointings',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: textColorSecondary,
                  size: 20,
                ),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
