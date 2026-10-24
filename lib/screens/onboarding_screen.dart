import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_ambient.dart';
import '../widgets/glass_card.dart';
import '../widgets/onboarding_animations.dart';
import '../utils/haptics.dart';
import '../theme/app_icons.dart';

/**
 * Contemplative onboarding experience for Pointer app.
 *
 * Four screens that immerse the user in the app's philosophy:
 * 1. The Interruption - immediate pointing question
 * 2. The Contrast - meditation apps vs. direct inquiry
 * 3. The Simplicity - letting go of progress/streaks/becoming
 * 4. Notifications - the entire practice distilled
 */

/**
 * Responsive font size that scales with screen width; [Text] applies the user's text scale.
 * Base sizes scale down on screens < 375px (iPhone SE) for WCAG compliance.
 */
double _responsiveFontSize(BuildContext context, double baseSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  // Scale factor: 1.0 at 375px+, scales down linearly to 0.8 at 320px
  final widthFactor = ((screenWidth - 320) / 55).clamp(0.8, 1.0);
  return baseSize * widthFactor; // Text applies the (root-clamped) text scale once.
}

/**
 * Responsive vertical spacing that compresses on short screens and larger text.
 */
double _responsiveVerticalSpace(BuildContext context, double baseSize) {
  final screenHeight = MediaQuery.of(context).size.height;
  final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.4);
  final heightFactor = (screenHeight / 812).clamp(0.72, 1.0);
  final textCompensation = (1 / textScale).clamp(0.75, 1.0);
  return baseSize * heightFactor * textCompensation;
}

/**
 * Makes onboarding pages vertically scrollable while keeping content centered when space allows.
 */
Widget _buildScrollableCenteredPage({required BuildContext context, required Widget child, double horizontalPadding = 32}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final verticalPadding = _responsiveVerticalSpace(context, 8);
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - (verticalPadding * 2)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              child: Center(child: child),
            ),
          ),
        );
      },
    ),
  );
}

/**
 * Four-page contemplative onboarding experience.
 *
 * Guides first-time users through the app's philosophy using animated pages:
 * 1. [_InterruptionPage] - word-by-word question reveal
 * 2. [_ContrastPage] - dissolve transition between meditation concept and inquiry
 * 3. [_SimplicityPage] - strike-through animation for concepts being let go
 * 4. [_NotificationsPage] - simulated notification with explanation
 *
 * Supports horizontal swiping between pages and handles notification permission
 * request on the final page. Marks onboarding complete in [StorageService].
 */
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

  /** Animates to the specified page with haptic feedback. No-ops if [page] > 3. */
  void _advanceToPage(int page) {
    if (!mounted || page > 3) return;
    Haptics.light();
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
  }

  /** Advances to the next page or finishes onboarding on the last page. */
  Future<void> _handleContinue() async {
    Haptics.success();
    if (_currentPage < 3) {
      _advanceToPage(_currentPage + 1);
    } else {
      await _finishOnboarding(false);
    }
  }

  /**
   * Shows a short rationale, then the system permission prompt. Granting
   * enables and schedules notifications; either answer finishes onboarding.
   * Dismissing the rationale stays on the page.
   */
  Future<void> _handleEnableNotifications() async {
    Haptics.light();
    final proceed = await showDialog<bool>(context: context, builder: (context) => const _PermissionRationaleDialog());
    if (proceed != true || !mounted) return;
    final notificationService = ref.read(notificationServiceProvider);
    final granted = await notificationService.requestPermissions();
    await _finishOnboarding(granted);
  }

  /** Marks onboarding complete, enables notifications when granted, and navigates home. */
  Future<void> _finishOnboarding(bool notificationsEnabled) async {
    if (notificationsEnabled) {
      await ref.read(notificationServiceProvider).setNotificationsEnabled(true);
    }
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    ref.invalidate(onboardingCompletedProvider);
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
          const Positioned.fill(child: RouteAmbient()),
          SafeArea(
            child: Column(
              children: [
                // Page view - allows swiping
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      Haptics.light();
                      setState(() => _currentPage = page);
                    },
                    children: const [_InterruptionPage(), _ContrastPage(), _SimplicityPage(), _NotificationsPage()],
                  ),
                ),

                // Page indicators
                _PageIndicators(currentPage: _currentPage, pageCount: 4),

                SizedBox(height: isLandscape ? 16 : 32),

                // Buttons
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, bottom: bottomPadding + (isLandscape ? 8 : 20)),
                  child: Column(
                    children: [
                      if (isLastPage) ...[
                        SizedBox(
                          width: double.infinity,
                          child: _OnboardingButton(label: 'Enable Notifications', onPressed: _handleEnableNotifications, isPrimary: true),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final textColor = context.colors.textMuted;
                            return TextButton(
                              onPressed: () => _finishOnboarding(false),
                              child: Text(
                                'Maybe Later',
                                style: TextStyle(color: textColor, fontSize: _responsiveFontSize(context, 16)),
                              ),
                            );
                          },
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: _OnboardingButton(label: 'Continue', onPressed: _handleContinue, isPrimary: true),
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

/**
 * Screen starts empty, then reveals question word-by-word.
 * "What is looking through your eyes right now?"
 * Followed by "Don't answer. Just look."
 */
class _InterruptionPage extends StatefulWidget {
  const _InterruptionPage();

  @override
  State<_InterruptionPage> createState() => _InterruptionPageState();
}

class _InterruptionPageState extends State<_InterruptionPage> {
  bool _showSubtext = false;
  bool _showIcon = false;

  /** Pending reveal step; cancelled on dispose so no timer outlives the page. */
  Timer? _revealTimer;

  void _revealAfterPause(VoidCallback reveal) {
    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(reveal);
    });
  }

  void _onMainTextComplete() {
    if (mounted) _revealAfterPause(() => _showSubtext = true);
  }

  void _onSubtextComplete() {
    if (mounted) _revealAfterPause(() => _showIcon = true);
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final spaceLarge = _responsiveVerticalSpace(context, 60);
    final spaceMedium = _responsiveVerticalSpace(context, 40);

    return _buildScrollableCenteredPage(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            wordDelay: const Duration(milliseconds: 110),
            startDelay: const Duration(milliseconds: 300),
            onComplete: reduceMotion ? null : _onMainTextComplete,
          ),

          SizedBox(height: spaceMedium),

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
              wordDelay: const Duration(milliseconds: 90),
              startDelay: Duration.zero,
              onComplete: reduceMotion ? null : _onSubtextComplete,
            ),
          ),

          SizedBox(height: spaceLarge),

          // Subtle eye icon - fades in last
          AnimatedOpacity(
            opacity: reduceMotion || _showIcon ? 0.4 : 0.0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            child: BreathingGlow(
              glowColor: colors.accent,
              maxBlur: 15,
              maxSpread: 3,
              child: Icon(Icons.visibility_outlined, size: 32, color: colors.textMuted),
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

/** Shows meditation app concept, dissolves it away, reveals the question. */
class _ContrastPage extends StatelessWidget {
  const _ContrastPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cardPadding = _responsiveVerticalSpace(context, 32).clamp(20.0, 32.0);
    final betweenIconAndCopy = _responsiveVerticalSpace(context, 24);

    return _buildScrollableCenteredPage(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DissolveTransition(
            holdDuration: const Duration(seconds: 3),
            dissolveDuration: const Duration(milliseconds: 1200),
            firstChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.timer, size: 48, color: colors.textMuted),
                SizedBox(height: betweenIconAndCopy),
                Text(
                  'Meditation apps teach you to become a better meditator.',
                  style: TextStyle(fontSize: _responsiveFontSize(context, 22), height: 1.5, fontWeight: FontWeight.w400, color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            secondChild: GlassCard(
              padding: EdgeInsets.all(cardPadding),
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
                  SizedBox(height: _responsiveVerticalSpace(context, 12)),
                  Text(
                    'Who is meditating?',
                    style: TextStyle(fontSize: _responsiveFontSize(context, 28), height: 1.4, fontWeight: FontWeight.w300, color: colors.textPrimary),
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

/** Strike-through animation for concepts being let go. */
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
    final betweenPrimaryAndSecondary = _responsiveVerticalSpace(context, 24);

    return _buildScrollableCenteredPage(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Strike-through sequence
          if (!_showRemains)
            StrikeThroughReveal(
              items: const ['Progress', 'Streaks', 'Becoming'],
              itemDelay: const Duration(milliseconds: 400),
              strikeDelay: const Duration(milliseconds: 600),
              style: TextStyle(fontSize: _responsiveFontSize(context, 32), fontWeight: FontWeight.w400, color: colors.textSecondary, height: 1.4),
              onComplete: reduceMotion ? () => setState(() => _showRemains = true) : _onStrikeComplete,
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
                    style: TextStyle(fontSize: _responsiveFontSize(context, 32), fontWeight: FontWeight.w300, color: colors.textPrimary, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: betweenPrimaryAndSecondary),
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

/** Simulates a notification banner, then explains the practice. */
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
    final topSpace = _responsiveVerticalSpace(context, 16);
    final betweenNotificationAndText = _responsiveVerticalSpace(context, 40);
    final betweenTextAndConclusion = _responsiveVerticalSpace(context, 28);

    return _buildScrollableCenteredPage(
      context: context,
      horizontalPadding: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topSpace),

          // Simulated notification (matches actual notification UI)
          NotificationSimulation(
            message: 'Notice: You are not the voice in your head.',
            attribution: 'Direct Path',
            delay: const Duration(seconds: 1),
            onComplete: reduceMotion ? null : _onNotificationComplete,
          ),

          SizedBox(height: betweenNotificationAndText),

          // Centered explanation and conclusion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedOpacity(
              opacity: reduceMotion || _showExplanation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: Text(
                'A notification arrives.\nYou pause. You look.',
                style: TextStyle(fontSize: _responsiveFontSize(context, 20), height: 1.6, fontWeight: FontWeight.w400, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: betweenTextAndConclusion),

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
                  style: TextStyle(fontSize: _responsiveFontSize(context, 18), height: 1.5, fontWeight: FontWeight.w500, color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Components
// =============================================================================

/**
 * Animated dot indicators showing current page position.
 *
 * The active dot expands to 24px width; inactive dots are 8px circles at 30% opacity.
 */
class _PageIndicators extends StatelessWidget {
  /** Zero-based index of the current page. */
  final int currentPage;

  /** Total number of pages to display dots for. */
  final int pageCount;

  const _PageIndicators({required this.currentPage, required this.pageCount});

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

/** Rationale shown before the system notification permission prompt. */
class _PermissionRationaleDialog extends StatelessWidget {
  const _PermissionRationaleDialog();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A few quiet pointings a day',
              style: TextStyle(fontSize: _responsiveFontSize(context, 20), fontWeight: FontWeight.w500, color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Only inside the hours you choose, never during quiet hours. Your phone asks for permission next. You can change times or turn them off in Settings.',
              style: TextStyle(fontSize: _responsiveFontSize(context, 15), height: 1.5, color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _OnboardingButton(label: 'Continue', onPressed: () => Navigator.of(context).pop(true), isPrimary: true),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not now',
                style: TextStyle(color: colors.textMuted, fontSize: _responsiveFontSize(context, 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/** Glass-styled button used on onboarding pages with optional primary highlight. */
class _OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _OnboardingButton({required this.label, required this.onPressed, this.isPrimary = false});

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
          style: TextStyle(color: textColor, fontSize: _responsiveFontSize(context, 16), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
