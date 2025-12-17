import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';

class InquirySession {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String level;
  final bool isPremium;

  const InquirySession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.isPremium,
  });
}

const inquirySessions = [
  InquirySession(
    id: '1',
    title: 'Who Am I?',
    description: 'The fundamental inquiry',
    duration: '5 min',
    level: 'Beginner',
    isPremium: false,
  ),
  InquirySession(
    id: '2',
    title: 'Finding the Looker',
    description: 'Turn attention to its source',
    duration: '7 min',
    level: 'Beginner',
    isPremium: false,
  ),
  InquirySession(
    id: '3',
    title: 'The Space of Awareness',
    description: "Recognizing what doesn't change",
    duration: '10 min',
    level: 'Intermediate',
    isPremium: true,
  ),
  InquirySession(
    id: '4',
    title: 'Investigating Thoughts',
    description: 'What are thoughts made of?',
    duration: '8 min',
    level: 'Intermediate',
    isPremium: true,
  ),
  InquirySession(
    id: '5',
    title: 'Resting as Awareness',
    description: 'Beyond the practice',
    duration: '12 min',
    level: 'Advanced',
    isPremium: true,
  ),
];

class InquiryScreen extends ConsumerWidget {
  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                  'Self-Inquiry',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),

                // Intro card
                Builder(
                  builder: (context) {
                    final isDark = context.isDarkMode;
                    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
                    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.6) : AppColorsLight.textSecondary;
                    return GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'These sessions guide you through the ancient practice of self-investigation.',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Each session is 5-15 minutes. No experience required.',
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Section header
                Text(
                  'AVAILABLE SESSIONS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 16),

                // Sessions list
                ...inquirySessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;
                  final isLocked = session.isPremium && !subscription.isPremium;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SessionCard(
                      session: session,
                      index: index,
                      isLocked: isLocked,
                      onTap: () async {
                        final hasVibrator = await Vibration.hasVibrator();
                        if (hasVibrator == true) {
                          Vibration.vibrate(duration: 50, amplitude: 128);
                        }
                        if (isLocked) {
                          if (context.mounted) context.push('/paywall');
                        } else {
                          // TODO: Start session
                        }
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

class _SessionCard extends StatelessWidget {
  final InquirySession session;
  final int index;
  final bool isLocked;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.index,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.6) : AppColorsLight.textSecondary;
    final textColorMuted = isDark ? Colors.white.withValues(alpha: 0.4) : AppColorsLight.textMuted;
    final circleColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppColorsLight.primary.withValues(alpha: 0.1);
    final goldColor = isDark ? AppColors.gold : AppColorsLight.gold;

    return Semantics(
      button: true,
      label: '${session.title}. ${session.description}. ${session.duration}, ${session.level} level${isLocked ? '. Locked, premium required' : ''}',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: isLocked
            ? (isDark ? AppColors.glassBorder : AppColorsLight.glassBorder).withValues(alpha: 0.5)
            : null,
        onTap: onTap,
        child: Opacity(
        opacity: isLocked ? 0.6 : 1,
        child: Row(
          children: [
            // Number or lock
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              child: Center(
                child: isLocked
                    ? Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: textColor.withValues(alpha: 0.5),
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColorsLight.primary,
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
                  Row(
                    children: [
                      Text(
                        session.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isLocked ? textColor.withValues(alpha: 0.5) : textColor,
                        ),
                      ),
                      if (session.isPremium) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: isLocked
                              ? goldColor.withValues(alpha: 0.5)
                              : goldColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLocked ? textColorMuted : textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.duration} • ${session.level}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColorMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
