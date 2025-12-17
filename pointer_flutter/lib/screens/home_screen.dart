import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
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

                  // Pointing card
                  Flexible(
                    child: AnimatedOpacity(
                      opacity: _isAnimating ? 0 : 1,
                      duration: 150.ms,
                      child: Semantics(
                        label: 'Current pointing: ${pointing.content}${pointing.teacher != null ? ' by ${pointing.teacher}' : ''}',
                        child: GlassCard(
                          padding: const EdgeInsets.all(32),
                          borderRadius: 32,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                pointing.content,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              if (pointing.instruction != null) ...[
                                const SizedBox(height: 24),
                                Text(
                                  pointing.instruction!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha:0.6),
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              if (pointing.teacher != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  '- ${pointing.teacher}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha:0.4),
                                    fontSize: 14,
                                  ),
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
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
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
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
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
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.3),
                      fontSize: 12,
                    ),
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
