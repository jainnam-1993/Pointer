// Inquiry Phase Content - Display widget for each inquiry phase
// Handles setup, question, followUp, and complete phases

import 'package:flutter/material.dart';
import '../models/inquiry.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'inquiry_visual.dart';

/// Phases of an inquiry session
enum InquiryPhase {
  setup,
  question,
  followUp,
  complete,
}

/// Content widget for each phase of an inquiry
///
/// Displays the appropriate content based on the current phase:
/// - setup: Optional context before the main question
/// - question: The main inquiry question with visual element
/// - followUp: Optional follow-up after contemplation
/// - complete: Completion state with action buttons
class InquiryPhaseContent extends StatelessWidget {
  const InquiryPhaseContent({
    super.key,
    required this.inquiry,
    required this.phase,
    this.onAnother,
    this.onDone,
  });

  /// The current inquiry being displayed
  final Inquiry inquiry;

  /// The current phase of the inquiry
  final InquiryPhase phase;

  /// Callback when user wants another inquiry
  final VoidCallback? onAnother;

  /// Callback when user is done
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildPhaseContent(context, colors),
    );
  }

  Widget _buildPhaseContent(BuildContext context, PointerColors colors) {
    switch (phase) {
      case InquiryPhase.setup:
        return _buildSetupPhase(context, colors);
      case InquiryPhase.question:
        return _buildQuestionPhase(context, colors);
      case InquiryPhase.followUp:
        return _buildFollowUpPhase(context, colors);
      case InquiryPhase.complete:
        return _buildCompletePhase(context, colors);
    }
  }

  Widget _buildSetupPhase(BuildContext context, PointerColors colors) {
    if (inquiry.setup == null) {
      return const SizedBox.shrink(key: ValueKey('empty-setup'));
    }

    return Padding(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            inquiry.setup!,
            style: AppTextStyles.pointingText(context).copyWith(
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPhase(BuildContext context, PointerColors colors) {
    return Padding(
      key: const ValueKey('question'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual element if the inquiry has one
          if (inquiry.hasVisualElement) ...[
            const InquiryVisual(size: 140),
            const SizedBox(height: 48),
          ],

          // Main question in glass card
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              children: [
                Text(
                  inquiry.question,
                  style: AppTextStyles.pointingText(context).copyWith(
                    fontSize: 22,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (inquiry.teacher != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    '- ${inquiry.teacher}',
                    style: AppTextStyles.teacherText(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          // Visual element below if no visual above
          if (!inquiry.hasVisualElement) ...[
            const SizedBox(height: 48),
            const InquiryVisual(size: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowUpPhase(BuildContext context, PointerColors colors) {
    if (inquiry.followUp == null) {
      return const SizedBox.shrink(key: ValueKey('empty-followup'));
    }

    return Padding(
      key: const ValueKey('followUp'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            inquiry.followUp!,
            style: AppTextStyles.pointingText(context).copyWith(
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildActionButtons(context, colors),
        ],
      ),
    );
  }

  Widget _buildCompletePhase(BuildContext context, PointerColors colors) {
    return Padding(
      key: const ValueKey('complete'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Small visual element
          const InquiryVisual(size: 80),
          const SizedBox(height: 32),

          // Completion message
          Text(
            'Rest here.',
            style: AppTextStyles.pointingText(context).copyWith(
              color: colors.textMuted,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildActionButtons(context, colors),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PointerColors colors) {
    final isDark = context.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Another button
        _ActionButton(
          label: 'Another',
          onTap: onAnother,
          isPrimary: false,
          isDark: isDark,
          colors: colors,
        ),
        const SizedBox(width: 16),
        // Done button
        _ActionButton(
          label: 'Done',
          onTap: onDone,
          isPrimary: true,
          isDark: isDark,
          colors: colors,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.isDark,
    required this.colors,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isDark;
  final PointerColors colors;

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary
        ? colors.accent.withValues(alpha: isDark ? 0.2 : 0.15)
        : colors.glassBackground;

    final borderColor = isPrimary
        ? colors.accent.withValues(alpha: isDark ? 0.4 : 0.3)
        : colors.glassBorder;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? colors.accent : colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
