import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Animated gradient background using flutter_animate
class AnimatedGradient extends StatelessWidget {
  const AnimatedGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0A3A),
            Color(0xFF0F0524),
            Color(0xFF150A2E),
          ],
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          duration: 3000.ms,
          color: AppColors.primary.withValues(alpha:0.1),
        );
  }
}

/// Floating particles effect
class FloatingParticles extends StatelessWidget {
  const FloatingParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(6, (index) {
          return Positioned(
            left: (index * 60.0) + 20,
            top: (index * 80.0) + 50,
            child: Container(
              width: 4 + (index % 3) * 2.0,
              height: 4 + (index % 3) * 2.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:0.1 + (index % 3) * 0.05),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: -20 - index * 5.0,
                  duration: (3000 + index * 500).ms,
                  curve: Curves.easeInOut,
                )
                .fadeIn(
                  duration: 1000.ms,
                ),
          );
        }),
      ),
    );
  }
}
