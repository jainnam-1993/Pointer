import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/adaptive.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_ambient.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_scale.dart';
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
    if (_currentPage < onboardingPages.length - 1) {
      _advanceToPage(_currentPage + 1);
    } else {
      await _finishOnboarding();
    }
  }

  /**
   * Marks onboarding complete and goes to Today. It no longer asks for
   * notifications; the first Save does (NotificationAskPolicy, P11).
   */
  Future<void> _finishOnboarding() async {
    await ref.read(notificationAskProvider).onOnboardingFinished();
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
    final isLastPage = _currentPage == onboardingPages.length - 1;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Detect landscape/foldable mode
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: RouteAmbient()),
          // On a vertical hinge the pages and buttons take one pane and the other stays a calm, empty field.
          HingeSplit(
            companion: const SizedBox.expand(key: ValueKey('onboarding-calm-pane')),
            child: SafeArea(
              child: ContentWidth(
                child: Column(
                  children: [
                    // Skip: every page but the last leaves onboarding at once (P11).
                    Align(
                      alignment: Alignment.centerRight,
                      child: Visibility(
                        visible: true,
                        child: TextButton(
                          key: const ValueKey('onboarding-skip'),
                          onPressed: _finishOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(color: context.colors.textMuted, fontSize: _responsiveFontSize(context, 16)),
                          ),
                        ),
                      ),
                    ),
                    // Page view - allows swiping
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (page) {
                          Haptics.light();
                          setState(() => _currentPage = page);
                        },
                        children: onboardingPages,
                      ),
                    ),

                    // Page indicators
                    _PageIndicators(currentPage: _currentPage, pageCount: onboardingPages.length),

                    SizedBox(height: isLandscape ? 16 : 32),

                    // Buttons
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32, bottom: bottomPadding + (isLandscape ? 8 : 20)),
                      child: Column(
                        children: [
                          if (isLastPage)
                            SizedBox(
                              width: double.infinity,
                              child: _OnboardingButton(label: 'Begin', onPressed: _finishOnboarding, isPrimary: true),
                            )
                          else
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
              fontFamily: AppFonts.serif,
              fontSize: _responsiveFontSize(context, 28),
              height: 1.4,
              fontWeight: FontWeight.w400,
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
            // A quiet glass circle: the glow follows the circle, never a square box.
            child: Container(
              key: const ValueKey('onboarding-eye'),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.glassBackground,
                border: Border.all(color: colors.glassBorder),
                boxShadow: [BoxShadow(color: colors.accent.withValues(alpha: 0.25), blurRadius: 24, spreadRadius: 1)],
              ),
              child: Icon(Icons.visibility_outlined, size: 28, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Screens 2 and 3: what a pointing is, what inquiry is (one screen each, P4)
// =============================================================================

/** One idea per screen: an icon, a short title and two plain sentences. */
class _ExplainPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _ExplainPage({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _buildScrollableCenteredPage(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colors.textMuted),
          SizedBox(height: _responsiveVerticalSpace(context, 24)),
          Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(fontSize: _responsiveFontSize(context, 28), height: 1.3, fontWeight: FontWeight.w300, color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: _responsiveVerticalSpace(context, 16)),
          Text(
            body,
            style: TextStyle(fontSize: _responsiveFontSize(context, 18), height: 1.5, color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/** The three onboarding pages, in order. */
const onboardingPages = <Widget>[
  _InterruptionPage(),
  _ExplainPage(
    icon: AppIcons.teacher,
    title: 'A pointing',
    body: 'A short line from a teacher. Read it, then look at what it points to, instead of thinking about it.',
  ),
  _ExplainPage(
    icon: AppIcons.inquiry,
    title: 'An inquiry',
    body: 'A question you hold for about a minute, such as "Who am I?". Tap Inquire on Today when you want one.',
  ),
];

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
    final glass = GlassMaterial.of(context);
    if (isPrimary && glass.primaryFill != null) {
      // Light theme (sage and sand): the primary action is a filled sage capsule with white text.
      return PressScale(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: glass.buttonFill(primary: true), borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: glass.onPrimary, fontSize: _responsiveFontSize(context, 16), fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

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
