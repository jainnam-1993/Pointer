import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/inquiry_sessions.dart';
import '../data/pointings.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

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
              padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 120 + bottomPadding),
              children: [
                Text('Self-Inquiry', style: Theme.of(context).textTheme.displayLarge),
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
                const SizedBox(height: 24),

                // Section header
                Text('AVAILABLE SESSIONS', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 16),

                // Sessions list with staggered animation
                ...inquirySessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;

                  return StaggeredFadeIn(
                    index: index + 1, // Offset by 1 for intro card
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(width: 16),

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
