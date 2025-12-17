import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';

class OnboardingPage {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const OnboardingPage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

const onboardingPages = [
  OnboardingPage(
    id: 'welcome',
    title: 'Welcome to Pointer',
    subtitle: 'Direct invitations to recognize what you already are',
    description:
        'Each pointing is a finger pointing at the moon—not the moon itself. Use these pointers to look, not to think about.',
    icon: Icons.auto_awesome,
  ),
  OnboardingPage(
    id: 'traditions',
    title: 'Multiple Traditions',
    subtitle: 'One truth, many expressions',
    description:
        'Explore pointings from Advaita, Zen, Direct Path, Contemporary, and Original traditions. All point to the same recognition.',
    icon: Icons.self_improvement,
  ),
  OnboardingPage(
    id: 'practice',
    title: 'Daily Pointings',
    subtitle: 'Gentle reminders throughout your day',
    description:
        'Receive notifications that invite you to pause and look. Each pointing is a fresh opportunity to recognize your true nature.',
    icon: Icons.all_inclusive,
  ),
  OnboardingPage(
    id: 'notifications',
    title: 'Stay Connected',
    subtitle: 'Would you like daily reminders?',
    description:
        'Enable notifications to receive gentle pointing reminders throughout your day. You can customize timing later.',
    icon: Icons.notifications_active,
  ),
];

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

  Future<void> _handleNext() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _finishOnboarding(false);
    }
  }

  Future<void> _handleEnableNotifications() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 100, amplitude: 200);
    }
    // TODO: Request notification permissions
    await _finishOnboarding(true);
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
    final isLastPage = _currentPage == onboardingPages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Column(
              children: [
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    itemCount: onboardingPages.length,
                    itemBuilder: (context, index) {
                      final page = onboardingPages[index];
                      return _OnboardingPageView(page: page);
                    },
                  ),
                ),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withValues(alpha:_currentPage == index ? 1 : 0.3),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Padding(
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    bottom: bottomPadding + 20,
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
                        TextButton(
                          onPressed: _handleNext,
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.5),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: _OnboardingButton(
                            label: 'Continue',
                            onPressed: _handleNext,
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

class _OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha:0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha:0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Description card
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha:0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderColor: isPrimary ? AppColors.glassBorderActive : null,
      onTap: onPressed,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
