import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/pointings.dart';
import '../providers/content_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/drag_handle.dart';
import '../widgets/glass_card.dart';
import '../widgets/grouped_section.dart';
import '../widgets/pointer_scaffold.dart';
import '../utils/haptics.dart';
import '../layout/adaptive.dart';

/**
 * Tradition/lineage management screen for filtering which traditions appear.
 *
 * Displays all available [Tradition] values with toggle switches and info buttons.
 * Each [_TraditionCard] shows the tradition icon, name, description, and pointings count.
 * Users can enable/disable traditions (at least one must remain selected).
 * The "Reset" button re-enables all traditions via [PreferredTraditionsNotifier.enableAll].
 */
class LineagesScreen extends ConsumerStatefulWidget {
  const LineagesScreen({super.key});

  @override
  ConsumerState<LineagesScreen> createState() => _LineagesScreenState();
}

class _LineagesScreenState extends ConsumerState<LineagesScreen> {
  /** Tradition shown in the detail pane on a vertical hinge; the first one until the user picks. */
  Tradition? _selected;

  @override
  Widget build(BuildContext context) {
    final isBook = WindowLayout.of(context).posture == Posture.book;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionEntries = traditions.entries.toList();
    final colors = context.colors;
    final preferredTraditions = ref.watch(preferredTraditionsProvider);

    final selected = _selected ?? traditionEntries.first.key;
    final selectedInfo = traditions[selected]!;
    return PointerScaffold(
      // On a vertical hinge the list and the selected tradition's detail sit on either side; nothing under the fold.
      body: HingeSplit(
        childFirst: true,
        companion: _TraditionDetailPane(
          key: ValueKey('lineages-detail-${selected.name}'),
          info: selectedInfo,
          pointingsCount: getPointingsByTradition(selected).length,
        ),
        child: Column(
          children: [
            // Custom AppBar with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Haptics.light();
                      context.pop();
                    },
                    icon: Icon(Icons.arrow_back_ios_new, color: colors.textPrimary, size: 22),
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                  // Reset button
                  TextButton(
                    onPressed: () {
                      Haptics.light();
                      ref.read(preferredTraditionsProvider.notifier).enableAll();
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(color: colors.accent, fontSize: AppType.callout, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xxl + AppSpacing.sm + bottomPadding),
                children: [
                  Text('Manage Lineages', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Text('Select the traditions you want to receive pointings from', style: AppTextStyles.bodyText(context)),
                  const SizedBox(height: 24),

                  // Traditions list with selection
                  // One grouped plate instead of a blurred card per tradition (design 22/24).
                  GroupedSection(
                    itemCount: traditionEntries.length,
                    separatorIndent: 92,
                    itemBuilder: (context, index) {
                      final tradition = traditionEntries[index].key;
                      final info = traditionEntries[index].value;
                      final count = getPointingsByTradition(tradition).length;
                      final isEnabled = preferredTraditions.contains(tradition);

                      return StaggeredFadeIn(
                        index: index,
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: _TraditionCard(
                            tradition: tradition,
                            info: info,
                            pointingsCount: count,
                            isEnabled: isEnabled,
                            onToggle: () {
                              Haptics.selection();
                              ref.read(preferredTraditionsProvider.notifier).toggle(tradition);
                            },
                            onInfoTap: () {
                              Haptics.selection();
                              if (isBook) {
                                setState(() => _selected = tradition);
                                return;
                              }
                              showModalBottomSheet(
                                context: context,
                                anchorPoint: sheetAnchorPoint(context),
                                backgroundColor: Colors.transparent,
                                builder: (context) => _TraditionDetailSheet(tradition: tradition, info: info, pointingsCount: count),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Helper text
                  const SizedBox(height: 8),
                  Text(
                    'At least one tradition must remain selected',
                    style: AppTextStyles.footerText(context).copyWith(color: colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/** Detail pane for one tradition, shown beside the list in book posture. */
class _TraditionDetailPane extends StatelessWidget {
  final TraditionInfo info;
  final int pointingsCount;

  const _TraditionDetailPane({super.key, required this.info, required this.pointingsCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 40),
        children: [
          Row(
            children: [
              Icon(info.lineIcon, size: 35.2, color: colors.textPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.textPrimary)),
                    Text(
                      '$pointingsCount pointings available',
                      style: TextStyle(color: colors.textSecondary, fontSize: AppType.callout),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(info.description, style: AppTextStyles.bodyText(context).copyWith(color: colors.textPrimary)),
        ],
      ),
    );
  }
}

/** Card displaying a [Tradition] with toggle switch, info button, and animated state transitions. */
class _TraditionCard extends StatelessWidget {
  /** The tradition enum value. */
  final Tradition tradition;

  /** Display metadata (name, icon, description) for this tradition. */
  final TraditionInfo info;

  /** Number of pointings available for this tradition. */
  final int pointingsCount;

  /** Whether this tradition is currently enabled for content delivery. */
  final bool isEnabled;

  /** Callback to toggle this tradition's enabled state. */
  final VoidCallback onToggle;

  /** Callback to show the tradition detail bottom sheet. */
  final VoidCallback onInfoTap;

  const _TraditionCard({
    required this.tradition,
    required this.info,
    required this.pointingsCount,
    required this.isEnabled,
    required this.onToggle,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = isEnabled ? colors.textPrimary : colors.textMuted;
    final textColorSecondary = isEnabled ? colors.textSecondary : colors.textMuted;
    final textColorMuted = colors.textMuted;
    final iconBgColor = isEnabled ? colors.primary.withValues(alpha: 0.1) : colors.textMuted.withValues(alpha: 0.1);

    return Semantics(
      button: true,
      toggled: isEnabled,
      label: '${info.name} tradition. ${isEnabled ? "Enabled" : "Disabled"}. $pointingsCount pointings available.',
      child: GroupedRow(
        padding: const EdgeInsets.all(16),
        onTap: onToggle,
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: iconBgColor),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: Icon(info.lineIcon, size: 30.8),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(fontSize: AppType.headline, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: TextStyle(fontSize: AppType.callout, color: textColorSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pointingsCount pointings',
                    style: TextStyle(fontSize: AppType.caption, color: textColorMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Toggle and info button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom toggle
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isEnabled ? colors.accent : colors.textMuted.withValues(alpha: 0.3),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Info button
                GestureDetector(
                  onTap: onInfoTap,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: Icon(Icons.info_outline, color: colors.textMuted, size: 20)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/** Bottom sheet showing tradition details with glass effect */
class _TraditionDetailSheet extends StatelessWidget {
  final Tradition tradition;
  final TraditionInfo info;
  final int pointingsCount;

  const _TraditionDetailSheet({required this.tradition, required this.info, required this.pointingsCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final textColor = context.colors.textPrimary;
    final textColorSecondary = context.colors.textSecondary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomPadding + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  const DragHandle(bottomMargin: 20),
                  Row(
                    children: [
                      Icon(info.lineIcon, size: 35.2),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor)),
                            Text('$pointingsCount pointings available', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(info.description, style: TextStyle(color: textColor, fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          'Close',
                          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
