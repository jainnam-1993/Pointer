import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../data/pointings.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
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

                // Traditions list
                ...traditionEntries.map((entry) {
                  final tradition = entry.key;
                  final info = entry.value;
                  final count = getPointingsByTradition(tradition).length;

                  return Padding(
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
                        // TODO: Navigate to tradition detail
                      },
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
