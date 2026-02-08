import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/pointings.dart';
import '../providers/content_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

class LineagesScreen extends ConsumerWidget {
  const LineagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionEntries = traditions.entries.toList();
    final colors = context.colors;
    final preferredTraditions = ref.watch(preferredTraditionsProvider);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar with back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: colors.textPrimary,
                          size: 22,
                        ),
                        tooltip: 'Back',
                      ),
                      const Spacer(),
                      // Reset button
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(preferredTraditionsProvider.notifier).enableAll();
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: colors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 40 + bottomPadding,
                    ),
                    children: [
                      Text(
                        'Manage Lineages',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the traditions you want to receive pointings from',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Traditions list with selection
                      ...traditionEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tradition = entry.value.key;
                        final info = entry.value.value;
                        final count = getPointingsByTradition(tradition).length;
                        final isEnabled = preferredTraditions.contains(tradition);

                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TraditionCard(
                              tradition: tradition,
                              info: info,
                              pointingsCount: count,
                              isEnabled: isEnabled,
                              onToggle: () {
                                HapticFeedback.mediumImpact();
                                ref.read(preferredTraditionsProvider.notifier).toggle(tradition);
                              },
                              onInfoTap: () {
                                HapticFeedback.lightImpact();
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => _TraditionDetailSheet(
                                    tradition: tradition,
                                    info: info,
                                    pointingsCount: count,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),

                      // Helper text
                      const SizedBox(height: 8),
                      Text(
                        'At least one tradition must remain selected',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TraditionCard extends StatelessWidget {
  final Tradition tradition;
  final TraditionInfo info;
  final int pointingsCount;
  final bool isEnabled;
  final VoidCallback onToggle;
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
    final iconBgColor = isEnabled
        ? colors.primary.withValues(alpha: 0.1)
        : colors.textMuted.withValues(alpha: 0.1);

    return Semantics(
      button: true,
      toggled: isEnabled,
      label: '${info.name} tradition. ${isEnabled ? "Enabled" : "Disabled"}. $pointingsCount pointings available.',
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        onTap: onToggle,
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: iconBgColor,
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: Text(
                    info.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColorSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pointingsCount pointings',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColorMuted,
                    ),
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
                      color: isEnabled
                          ? colors.accent
                          : colors.textMuted.withValues(alpha: 0.3),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Info button
                GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(
                    Icons.info_outline,
                    color: colors.textMuted,
                    size: 20,
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

/// Bottom sheet showing tradition details with glass effect
class _TraditionDetailSheet extends StatelessWidget {
  final Tradition tradition;
  final TraditionInfo info;
  final int pointingsCount;

  const _TraditionDetailSheet({
    required this.tradition,
    required this.info,
    required this.pointingsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final textColor = context.colors.textPrimary;
    final textColorSecondary = context.colors.textSecondary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: bottomPadding + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: textColorSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        info.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: textColor,
                                  ),
                            ),
                            Text(
                              '$pointingsCount pointings available',
                              style: TextStyle(
                                color: textColorSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    info.description,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
