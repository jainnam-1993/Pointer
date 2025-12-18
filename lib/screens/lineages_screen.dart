import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../data/pointings.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

class LineagesScreen extends StatelessWidget {
  const LineagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionEntries = traditions.entries.toList();
    final isDark = context.isDarkMode;
    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.6) : AppColorsLight.textSecondary;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 120 + bottomPadding,
              ),
              children: [
                Text(
                  'Lineages',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a tradition that resonates with you',
                  style: TextStyle(
                    color: textColorSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // Traditions list with staggered animation
                ...traditionEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tradition = entry.value.key;
                  final info = entry.value.value;
                  final count = getPointingsByTradition(tradition).length;

                  return StaggeredFadeIn(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TraditionCard(
                        tradition: tradition,
                        info: info,
                        pointingsCount: count,
                        onTap: () async {
                          final hasVibrator = await Vibration.hasVibrator();
                          if (hasVibrator == true) {
                            Vibration.vibrate(duration: 50, amplitude: 128);
                          }
                          // Show tradition detail sheet with information
                          if (context.mounted) {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _TraditionDetailSheet(
                                tradition: tradition,
                                info: info,
                                pointingsCount: count,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }),
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
  final VoidCallback onTap;

  const _TraditionCard({
    required this.tradition,
    required this.info,
    required this.pointingsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.6) : AppColorsLight.textSecondary;
    final textColorMuted = isDark ? Colors.white.withValues(alpha: 0.4) : AppColorsLight.textMuted;
    final iconBgColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppColorsLight.primary.withValues(alpha: 0.1);

    return Semantics(
      button: true,
      label: '${info.name} tradition. ${info.description}. $pointingsCount pointings available.',
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        onTap: onTap,
        child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: iconBgColor,
            ),
            child: Center(
              child: Text(
                info.icon,
                style: const TextStyle(fontSize: 28),
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

          Icon(
            Icons.chevron_right,
            color: textColorMuted,
            size: 24,
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
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.7) : AppColorsLight.textSecondary;

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
