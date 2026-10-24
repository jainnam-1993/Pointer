/**
 * A capsule choice chip for glass sheets: a tinted fill instead of an outline, a check mark when selected, a 44 pt
 * minimum hit size, a selection haptic and a selected state that VoiceOver and TalkBack announce.
 */
library;

import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';
import 'press_scale.dart';

/** One option in a mutually exclusive group of chips. */
class SelectableChip extends StatelessWidget {
  final String label;

  final bool selected;

  final VoidCallback onSelected;

  /** Spoken label when the visible [label] is an abbreviation (for example "3h"). */
  final String? semanticLabel;

  const SelectableChip({super.key, required this.label, required this.selected, required this.onSelected, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduce = Motion.reduce(context);
    final fill = selected
        ? colors.accent.withValues(alpha: isDark ? SelectionTint.selectedDark : SelectionTint.selectedLight)
        : colors.textPrimary.withValues(alpha: SelectionTint.resting);
    final textColor = selected ? colors.textPrimary : colors.textSecondary;

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        label: semanticLabel,
        child: PressScale(
          haptic: false,
          onTap: () {
            if (selected) return;
            Haptics.selection();
            onSelected();
          },
          child: AnimatedContainer(
            duration: reduce ? Duration.zero : Motion.quick,
            curve: Motion.inOut,
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget, minWidth: AppSpacing.minTouchTarget),
            padding: AppSpacing.chip,
            decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[Icon(AppIcons.check, size: AppType.callout, color: colors.accent), const SizedBox(width: AppSpacing.xs)],
                ExcludeSemantics(
                  excluding: semanticLabel != null,
                  child: Text(
                    label,
                    style: TextStyle(color: textColor, fontSize: AppType.callout, fontWeight: selected ? FontWeight.w600 : FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
