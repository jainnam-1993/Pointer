import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/pointings.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

/**
 * Data model for a guided self-inquiry session.
 *
 * Each session belongs to a [Tradition] and has a difficulty level.
 */
class InquirySession {
  /** Unique identifier for the session. */
  final String id;

  /** Display title (e.g., "Who Am I?"). */
  final String title;

  /** Short description of the inquiry approach. */
  final String description;

  /** Human-readable duration string (e.g., "5 min"). */
  final String duration;

  /** Difficulty level: Beginner, Intermediate, or Advanced. */
  final String level;

  /** The spiritual tradition this inquiry belongs to. */
  final Tradition tradition;

  const InquirySession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.tradition,
  });

  /** Get the accent color for this session's tradition */
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

/** All available inquiry sessions, ordered from beginner to advanced. */
const inquirySessions = [
  InquirySession(
    id: '1',
    title: 'Who Am I?',
    description: 'The fundamental inquiry',
    duration: '5 min',
    level: 'Beginner',
    tradition: Tradition.advaita,
  ),
  InquirySession(
    id: '2',
    title: 'Finding the Looker',
    description: 'Turn attention to its source',
    duration: '7 min',
    level: 'Beginner',
    tradition: Tradition.direct,
  ),
  InquirySession(
    id: '3',
    title: 'The Space of Awareness',
    description: "Recognizing what doesn't change",
    duration: '10 min',
    level: 'Intermediate',
    tradition: Tradition.direct,
  ),
  InquirySession(
    id: '4',
    title: 'Investigating Thoughts',
    description: 'What are thoughts made of?',
    duration: '8 min',
    level: 'Intermediate',
    tradition: Tradition.zen,
  ),
  InquirySession(
    id: '5',
    title: 'Resting as Awareness',
    description: 'Beyond the practice',
    duration: '12 min',
    level: 'Advanced',
    tradition: Tradition.contemporary,
  ),
];

/**
 * Self-inquiry session selection screen.
 *
 * Displays an intro card explaining the practice followed by [_SessionCard] items
 * for each [InquirySession]. Uses [StaggeredFadeIn] for entry animations.
 */
class InquiryScreen extends StatelessWidget {
  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: 20, bottom: AppSpacing.navBarOffset + bottomPadding),
              children: [
                Text('Self-Inquiry', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: AppSpacing.lg),

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
                              style: TextStyle(color: textColor, fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text('Each session is 5-15 minutes. No experience required.', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Section header
                Text('AVAILABLE SESSIONS', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: AppSpacing.lg),

                // Sessions list with staggered animation
                ...inquirySessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;

                  return StaggeredFadeIn(
                    index: index + 1, // Offset by 1 for intro card
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _SessionCard(
                        session: session,
                        index: index,
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          if (context.mounted) {
                            context.push('/inquiry/${session.id}');
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

/** Card displaying an [InquirySession] with tradition-colored circle and session details. */
class _SessionCard extends StatelessWidget {
  /** The inquiry session to display. */
  final InquirySession session;

  /** Zero-based index (shown as session number in the circle). */
  final int index;

  /** Callback when the card is tapped (navigates to player). */
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final textColorSecondary = colors.textSecondary;
    final textColorMuted = colors.textMuted;
    // Use tradition-specific accent color for the circle
    final traditionAccent = session.accentColor;
    final circleColor = traditionAccent.withValues(alpha: 0.15);
    return Semantics(
      button: true,
      label:
          '${session.title}. ${session.description}. ${session.duration}, ${session.level} level. ${traditions[session.tradition]!.name} tradition',
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: onTap,
        child: Row(
          children: [
            // Number with tradition-specific accent color
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: traditionAccent),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(session.description, style: TextStyle(fontSize: 14, color: textColorSecondary)),
                  const SizedBox(height: 4),
                  Text('${session.duration} • ${session.level}', style: TextStyle(fontSize: 12, color: textColorMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
