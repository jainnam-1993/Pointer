import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';
import '../widgets/onboarding_animations.dart';

/// Contemplative onboarding experience for Pointer app.
///
/// Four screens that immerse the user in the app's philosophy:
/// 1. The Interruption - immediate pointing question
/// 2. The Contrast - meditation apps vs. direct inquiry
/// 3. The Simplicity - letting go of progress/streaks/becoming
/// 4. Notifications - the entire practice distilled

/// Responsive font size that scales with screen width and respects text scaling.
/// Base sizes scale down on screens < 375px (iPhone SE) for WCAG compliance.
double _responsiveFontSize(BuildContext context, double baseSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final textScaler = MediaQuery.textScalerOf(context);
  // Scale factor: 1.0 at 375px+, scales down linearly to 0.8 at 320px
  final widthFactor = ((screenWidth - 320) / 55).clamp(0.8, 1.0);
  return textScaler.scale(baseSize * widthFactor);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _advanceToPage(int page) {
    if (!mounted || page > 3) return;
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _handleContinue() async {
    HapticFeedback.lightImpact();
    if (_currentPage < 3) {
      _advanceToPage(_currentPage + 1);
    } else {
      await _finishOnboarding(false);
    }
  }

  Future<void> _handleEnableNotifications() async {
    HapticFeedback.mediumImpact();
    final granted =
        await ref.read(notificationServiceProvider).requestPermissions();
    await _finishOnboarding(granted);
  }

  Future<void> _finishOnboarding(bool notificationsEnabled) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    ref.read(onboardingCompletedProvider.notifier).state = true;
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLastPage = _currentPage == 3;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Detect landscape/foldable mode
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Column(
              children: [
                // Page view - allows swiping
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      HapticFeedback.lightImpact();
                      setState(() => _currentPage = page);
                    },
                    children: const [
                      _InterruptionPage(),
                      _ContrastPage(),
                      _SimplicityPage(),
                      _NotificationsPage(),
                    ],
                  ),
                ),

                // Page indicators
                _PageIndicators(
                  currentPage: _currentPage,
                  pageCount: 4,
                ),

                SizedBox(height: isLandscape ? 16 : 32),

                // Buttons
                Padding(
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    bottom: bottomPadding + (isLandscape ? 8 : 20),
                  ),
                  child: Column(
                    children: [
                      if (isLastPage) ...[
                        SizedBox(
                          width: double.infinity,
                          child: _OnboardingButton(
                            label: 'Enable Notifications',
                            onPressed: _handleEnableNotifications,
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final textColor = context.colors.textMuted;
                            return TextButton(
                              onPressed: () => _finishOnboarding(false),
                              child: Text(
                                'Maybe Later',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: _responsiveFontSize(context, 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: _OnboardingButton(
                            label: 'Continue',
                            onPressed: _handleContinue,
                            isPrimary: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Screen 1: The Interruption
// =============================================================================

/// Screen starts empty, then reveals question word-by-word.
/// "What is looking through your eyes right now?"
/// Followed by "Don't answer. Just look."
class _InterruptionPage extends StatefulWidget {
  const _InterruptionPage();

  @override
  State<_InterruptionPage> createState() => _InterruptionPageState();
}

class _InterruptionPageState extends State<_InterruptionPage> {
  bool _showSubtext = false;
  bool _showIcon = false;

  void _onMainTextComplete() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showSubtext = true);
    });
  }

  void _onSubtextComplete() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showIcon = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main question - word by word reveal
          TypewriterText(
            text: 'What is looking through your eyes right now?',
            style: TextStyle(
              fontSize: _responsiveFontSize(context, 28),
              height: 1.5,
              fontWeight: FontWeight.w300,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
            wordDelay: const Duration(milliseconds: 250),
            startDelay: const Duration(milliseconds: 1500),
            onComplete: reduceMotion ? null : _onMainTextComplete,
          ),

          const SizedBox(height: 40),

          // Subtext - appears after main question
          AnimatedOpacity(
            opacity: reduceMotion || _showSubtext ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            child: TypewriterText(
              key: ValueKey('subtext_$_showSubtext'),
              text: "Don't answer. Just look.",
              style: TextStyle(
                fontSize: _responsiveFontSize(context, 18),
                height: 1.6,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary,
              ),
              wordDelay: const Duration(milliseconds: 200),
              startDelay: Duration.zero,
              onComplete: reduceMotion ? null : _onSubtextComplete,
            ),
          ),

          const SizedBox(height: 60),

          // Subtle eye icon - fades in last
          AnimatedOpacity(
            opacity: reduceMotion || _showIcon ? 0.4 : 0.0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            child: BreathingGlow(
              glowColor: colors.accent,
              maxBlur: 15,
              maxSpread: 3,
              child: Icon(
                Icons.visibility_outlined,
                size: 32,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Screen 2: The Contrast
// =============================================================================

/// Shows meditation app concept, dissolves it away, reveals the question.
class _ContrastPage extends StatelessWidget {
  const _ContrastPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DissolveTransition(
            holdDuration: const Duration(seconds: 3),
            dissolveDuration: const Duration(milliseconds: 1200),
            firstChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement_outlined,
                  size: 48,
                  color: colors.textMuted,
                ),
                const SizedBox(height: 24),
                Text(
                  'Meditation apps teach you to become a better meditator.',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(context, 22),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            secondChild: GlassCard(
              padding: const EdgeInsets.all(32),
              intensity: GlassIntensity.light,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Here Now asks:',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Who is meditating?',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(context, 28),
                      height: 1.4,
                      fontWeight: FontWeight.w300,
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Screen 3: The Simplicity
// =============================================================================

/// Strike-through animation for concepts being let go.
class _SimplicityPage extends StatefulWidget {
  const _SimplicityPage();

  @override
  State<_SimplicityPage> createState() => _SimplicityPageState();
}

class _SimplicityPageState extends State<_SimplicityPage> {
  bool _showRemains = false;

  void _onStrikeComplete() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showRemains = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Strike-through sequence
          if (!_showRemains)
            StrikeThroughReveal(
              items: const ['Progress', 'Streaks', 'Becoming'],
              itemDelay: const Duration(milliseconds: 400),
              strikeDelay: const Duration(milliseconds: 600),
              style: TextStyle(
                fontSize: _responsiveFontSize(context, 32),
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.4,
              ),
              onComplete: reduceMotion
                  ? () => setState(() => _showRemains = true)
                  : _onStrikeComplete,
            ),

          // What remains
          AnimatedOpacity(
            opacity: _showRemains ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _showRemains ? Offset.zero : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Just recognition.',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(context, 32),
                      fontWeight: FontWeight.w300,
                      color: colors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Invitations to see what you already are.',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(context, 16),
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Screen 4: Notifications
// =============================================================================

/// Simulates a notification banner, then explains the practice.
class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  bool _showExplanation = false;
  bool _showConclusion = false;

  void _onNotificationComplete() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showExplanation = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showConclusion = true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Push notification toward upper portion of screen
          SizedBox(height: screenHeight * 0.05),

          // Simulated notification (matches actual notification UI)
          NotificationSimulation(
            message: 'Notice: You are not the voice in your head.',
            attribution: 'Direct Path',
            delay: const Duration(seconds: 1),
            onComplete: reduceMotion ? null : _onNotificationComplete,
          ),

          // Flexible space between notification and centered content
          const Spacer(),

          // Centered explanation and conclusion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedOpacity(
              opacity: reduceMotion || _showExplanation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: Text(
                'A notification arrives.\nYou pause. You look.',
                style: TextStyle(
                  fontSize: _responsiveFontSize(context, 20),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Conclusion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedOpacity(
              opacity: reduceMotion || _showConclusion ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                intensity: GlassIntensity.light,
                child: Text(
                  "That's the entire practice.",
                  style: TextStyle(
                    fontSize: _responsiveFontSize(context, 18),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Equal spacer below to center the text content
          const Spacer(),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Components
// =============================================================================

class _PageIndicators extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _PageIndicators({
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = context.colors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: dotColor.withValues(alpha: currentPage == index ? 1 : 0.3),
          ),
        ),
      ),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _OnboardingButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.colors.textPrimary;
    final borderColor = isPrimary ? context.colors.glassBorderActive : null;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderColor: borderColor,
      onTap: onPressed,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: _responsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
