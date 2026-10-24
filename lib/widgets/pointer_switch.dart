import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/haptics.dart';

/**
 * The app's toggle: an iOS-style switch with the ink accent track, white thumb,
 * and a selection haptic. Used by every settings row.
 *
 * Wrapped to a 48x48 minimum touch target.
 */
class PointerSwitch extends StatelessWidget {
  /** Current toggle state. */
  final bool value;

  /** Callback when the switch is toggled. */
  final ValueChanged<bool> onChanged;

  const PointerSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(
        widthFactor: 1,
        child: Switch.adaptive(
          value: value,
          applyCupertinoTheme: false,
          onChanged: (v) {
            Haptics.selection();
            onChanged(v);
          },
          activeThumbColor: Colors.white,
          activeTrackColor: colors.accent,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: colors.textMuted.withValues(alpha: 0.32),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}

/** Cupertino look regardless of platform, for places that want the iOS switch explicitly. */
class PointerCupertinoSwitch extends StatelessWidget {
  final bool value;

  final ValueChanged<bool> onChanged;

  const PointerCupertinoSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CupertinoSwitch(
      value: value,
      activeTrackColor: colors.accent,
      inactiveTrackColor: colors.textMuted.withValues(alpha: 0.32),
      onChanged: (v) {
        Haptics.selection();
        onChanged(v);
      },
    );
  }
}
