import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/pointings.dart';
import '../providers/providers.dart';
import '../providers/subscription_providers.dart' show kFreeAccessEnabled;
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

class InquirySession {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String level;
  final bool isPremium;
  final Tradition tradition;

  const InquirySession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.isPremium,
    required this.tradition,
  });

  /// Get the accent color for this session's tradition
  Color get accentColor {
    switch (tradition) {
      case Tradition.advaita:
        return TraditionAccentColors.advaita;
      case Tradition.zen:
        return TraditionAccentColors.zen;
      case Tradition.direct:
        return TraditionAccentColors.direct;
      case Tradition.contemporary:
        return TraditionAccentColors.contemporary;
      case Tradition.original:
        return TraditionAccentColors.original;
    }
  }
}

const inquirySessions = [
  InquirySession(
    id: '1',
    title: 'Who Am I?',
    description: 'The fundamental inquiry',
    duration: '5 min',
    level: 'Beginner',
    isPremium: false,
    tradition: Tradition.advaita,
  ),
  InquirySession(
    id: '2',
    title: 'Finding the Looker',
    description: 'Turn attention to its source',
    duration: '7 min',
    level: 'Beginner',
    isPremium: false,
    tradition: Tradition.direct,
  ),
  InquirySession(
    id: '3',
    title: 'The Space of Awareness',
    description: "Recognizing what doesn't change",
    duration: '10 min',
    level: 'Intermediate',
    isPremium: true,
    tradition: Tradition.direct,
  ),
  InquirySession(
    id: '4',
    title: 'Investigating Thoughts',
    description: 'What are thoughts made of?',
    duration: '8 min',
    level: 'Intermediate',
    isPremium: true,
    tradition: Tradition.zen,
  ),
  InquirySession(
    id: '5',
    title: 'Resting as Awareness',
    description: 'Beyond the practice',
    duration: '12 min',
    level: 'Advanced',
    isPremium: true,
    tradition: Tradition.contemporary,
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

                // Intro card with fade-in
                StaggeredFadeIn(
                  index: 0,
                  child: Builder(
                    builder: (context) {
                      final colors = context.colors;
                      final textColor = colors.textPrimary;
                      final textColorSecondary = colors.textSecondary;
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
                ),
                const SizedBox(height: 24),

                // Section header
                Text(
                  'AVAILABLE SESSIONS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 16),

                // Sessions list with staggered animation
                ...inquirySessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;
                    // When kFreeAccessEnabled, all sessions are unlocked
                  final isLocked = !kFreeAccessEnabled && session.isPremium && !subscription.isPremium;

                  return StaggeredFadeIn(
                    index: index + 1, // Offset by 1 for intro card
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SessionCard(
                        session: session,
                        index: index,
                        isLocked: isLocked,
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          if (isLocked) {
                            if (context.mounted) context.push('/paywall');
                          } else {
                            // Navigate to inquiry session
                            if (context.mounted) {
                              context.push('/inquiry/${session.id}');
                            }
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
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final textColorSecondary = colors.textSecondary;
    final textColorMuted = colors.textMuted;
    // Use tradition-specific accent color for the circle
    final traditionAccent = session.accentColor;
    final circleColor = traditionAccent.withValues(alpha: 0.15);
    final goldColor = colors.gold;

    return Semantics(
      button: true,
      label: '${session.title}. ${session.description}. ${session.duration}, ${session.level} level. ${traditions[session.tradition]!.name} tradition${isLocked ? '. Locked, premium required' : ''}',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: isLocked
            ? context.colors.glassBorder.withValues(alpha: 0.5)
            : null,
        onTap: onTap,
        child: Opacity(
        opacity: isLocked ? 0.6 : 1,
        child: Row(
          children: [
            // Number or lock with tradition-specific accent color
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
                          color: traditionAccent,
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
                      // Hide premium badge when kFreeAccessEnabled (all content free)
                      if (!kFreeAccessEnabled && session.isPremium) ...[
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
