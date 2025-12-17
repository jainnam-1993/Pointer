// Mini-Inquiry Card - Entry point to inquiry experience from home screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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

    return Semantics(
      button: true,
      label: 'Take a moment - start guided inquiry',
      hint: 'Double tap to begin',
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderRadius: 20,
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/inquiry/random');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Diamond icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '◇',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text only - no question preview for cleaner look
            Text(
              'Take a moment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.accent,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms);
  }
}
