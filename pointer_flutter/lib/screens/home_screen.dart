import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';
import '../widgets/tradition_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isAnimating = false;

  Future<void> _handleNext() async {
    if (_isAnimating) return;

    // Haptic feedback
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    setState(() => _isAnimating = true);

    // Wait for fade out
    await Future.delayed(150.ms);

    // Get next pointing
    ref.read(currentPointingProvider.notifier).nextPointing();

    setState(() => _isAnimating = false);
  }

  Future<void> _handleShare() async {
    final pointing = ref.read(currentPointingProvider);
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    String shareText = '"${pointing.content}"';
    if (pointing.teacher != null) {
      shareText += '\n\n- ${pointing.teacher}';
    }
    shareText += '\n\nShared from Pointer';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final pointing = ref.watch(currentPointingProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(child: AnimatedGradient()),
          const Positioned.fill(child: FloatingParticles()),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 100 + bottomPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tradition badge
                  TraditionBadge(tradition: pointing.tradition)
                      .animate(target: _isAnimating ? 0 : 1)
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 16),

                  // Pointing card with Dynamic Type support
                  Flexible(
                    child: AnimatedOpacity(
                      opacity: _isAnimating ? 0 : 1,
                      duration: 150.ms,
                      child: Semantics(
                        label: 'Current pointing: ${pointing.content}${pointing.teacher != null ? ' by ${pointing.teacher}' : ''}',
                        child: GlassCard(
                          padding: const EdgeInsets.all(32),
                          borderRadius: 32,
                          // Enable scrolling for large text / accessibility
                          maxHeight: MediaQuery.of(context).size.height * 0.55,
                          enableScrolling: true,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                pointing.content,
                                style: AppTextStyles.pointingText(context),
                                textAlign: TextAlign.center,
                              ),
                              if (pointing.instruction != null) ...[
                                const SizedBox(height: 24),
                                Text(
                                  pointing.instruction!,
                                  style: AppTextStyles.instructionText(context),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              if (pointing.teacher != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  '- ${pointing.teacher}',
                                  style: AppTextStyles.teacherText(context),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Share button
                      Semantics(
                        button: true,
                        label: 'Share this pointing',
                        child: GlassButton(
                          label: 'Share',
                          onPressed: _handleShare,
                          isPrimary: false,
                          icon: Icon(
                            Icons.share_outlined,
                            color: colors.iconColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Next button
                      Semantics(
                        button: true,
                        label: 'Show next pointing',
                        child: GlassButton(
                          label: 'Next',
                          onPressed: _handleNext,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: colors.iconColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    'Tap for another invitation to look',
                    style: AppTextStyles.footerText(context),
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
