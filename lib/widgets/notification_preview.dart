import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'enso_icon.dart';

/// A preview of the Pointer notification that matches the actual Android notification.
///
/// This widget renders a notification card identical to what users see in their
/// notification shade. Use this for:
/// - Onboarding notification preview
/// - Settings notification preview
/// - Any in-app notification representation
///
/// The layout matches Android's BigTextStyleInformation notification:
/// - Header: Ensō icon + app name + timestamp
/// - Title: Bold "Today's Pointing"
/// - Body: The pointing content (expandable)
/// - Attribution: Tradition — Teacher
/// - Actions: Save and Another buttons (left-aligned)
class NotificationPreview extends StatelessWidget {
  /// The notification title (defaults to "Today's Pointing").
  final String title;

  /// The notification body text (the pointing content).
  final String body;

  /// Attribution line (e.g., "Advaita Vedanta — Nisargadatta Maharaj").
  final String? attribution;

  /// Whether to show action buttons.
  final bool showActions;

  /// Timestamp text (defaults to "now").
  final String timestamp;

  /// Optional callback when Save is tapped.
  final VoidCallback? onSave;

  /// Optional callback when Another is tapped.
  final VoidCallback? onAnother;

  const NotificationPreview({
    super.key,
    this.title = "Today's Pointing",
    required this.body,
    this.attribution,
    this.showActions = true,
    this.timestamp = 'now',
    this.onSave,
    this.onAnother,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Match actual Android notification colors
    final notificationBg = isDark
        ? const Color(0xFF1E1E1E) // Dark notification background
        : const Color(0xFFF0F0F0); // Light notification background
    final headerColor = isDark
        ? const Color(0xFF9E9E9E) // Muted header text
        : const Color(0xFF757575);
    final titleColor = isDark ? Colors.white : Colors.black;
    final bodyColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF424242);
    final actionColor = isDark
        ? const Color(0xFF8AB4F8) // Google blue for dark mode
        : const Color(0xFF1A73E8); // Google blue for light mode

    return Container(
      decoration: BoxDecoration(
        color: notificationBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Ensō icon + "Pointer" + "now"
            Row(
              children: [
                EnsoIcon(
                  size: 16,
                  color: headerColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pointer',
                  style: TextStyle(
                    color: headerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '•',
                  style: TextStyle(
                    color: headerColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  timestamp,
                  style: TextStyle(
                    color: headerColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Title: Bold "Today's Pointing"
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),

            // Body: The pointing content
            Text(
              body,
              style: TextStyle(
                color: bodyColor,
                fontSize: 14,
                height: 1.3,
              ),
            ),

            // Attribution: Tradition — Teacher
            if (attribution != null) ...[
              const SizedBox(height: 2),
              Text(
                attribution!,
                style: TextStyle(
                  color: headerColor,
                  fontSize: 12,
                ),
              ),
            ],

            // Action buttons: Save and Another (left-aligned, pill style)
            if (showActions) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _ActionButton(
                    label: 'Save',
                    color: actionColor,
                    onTap: onSave,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    label: 'Another',
                    color: actionColor,
                    onTap: onAnother,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Android notification action button (pill style).
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
