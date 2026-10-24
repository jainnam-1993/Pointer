/**
 * Grouped list section: one glass plate holding many rows separated by hairlines,
 * instead of a blurred card per row (design findings 22 and 24). One plate means one
 * backdrop filter for the whole group, and the list reads as one calm surface.
 */
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/** A single [GlassCard] that lays out [itemCount] rows with hairline separators. */
class GroupedSection extends StatelessWidget {
  /** Number of rows. */
  final int itemCount;

  /** Builds row [index]; rows should be [GroupedRow]s or similarly padded content. */
  final IndexedWidgetBuilder itemBuilder;

  /** Leading inset of the separator, so it aligns with the row text rather than the icon. */
  final double separatorIndent;

  const GroupedSection({super.key, required this.itemCount, required this.itemBuilder, this.separatorIndent = 16});

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    final colors = context.colors;
    return GlassCard(
      padding: EdgeInsets.zero,
      enableScrolling: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            itemBuilder(context, i),
            if (i < itemCount - 1) Divider(height: 1, thickness: 0.5, indent: separatorIndent, color: colors.glassBorder),
          ],
        ],
      ),
    );
  }
}

/** A tappable row inside a [GroupedSection]: no surface of its own, 48 pt minimum height. */
class GroupedRow extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GroupedRow({super.key, required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14), this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return content;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
