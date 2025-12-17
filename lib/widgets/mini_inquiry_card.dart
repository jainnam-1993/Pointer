// Mini-Inquiry Card - Entry point to inquiry experience from home screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../data/inquiries.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Compact card that invites users to try a guided self-inquiry session
///
/// Displays a preview of a random inquiry question and navigates to
/// the inquiry player when tapped.
class MiniInquiryCard extends StatelessWidget {
  const MiniInquiryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inquiry = getRandomInquiry();

    return Semantics(
      button: true,
      label: 'Start guided inquiry: ${inquiry.question}',
      hint: 'Double tap to begin',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/inquiry/random');
        },
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '◇',
                  style: TextStyle(
                    fontSize: 20,
                    color: colors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take a moment',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inquiry.question,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: colors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms);
  }
}
