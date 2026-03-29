import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Themed [Switch] that encapsulates the app's dark/light color computation.
///
/// Replaces the 4 duplicated switch-color blocks in settings, appearance,
/// and experience sections. Uses [context.colors] and [context.isDarkMode]
/// to derive consistent thumb, active-track, and inactive-track colors.
class PointerSwitch extends StatelessWidget {
  /// Current toggle state.
  final bool value;

  /// Callback when the switch is toggled.
  final ValueChanged<bool> onChanged;

  const PointerSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.colors;
    final thumbColor = isDark ? Colors.white : colors.primary;
    final activeTrackColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : colors.primary.withValues(alpha: 0.3);
    final inactiveTrackColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.grey.withValues(alpha: 0.3);

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: thumbColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: isDark ? Colors.white : Colors.grey,
      inactiveTrackColor: inactiveTrackColor,
    );
  }
}
