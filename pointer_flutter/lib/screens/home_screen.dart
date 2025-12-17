import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../data/pointings.dart';
import '../data/teachers.dart';
import '../widgets/teacher_sheet.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/commentary_section.dart';
import '../widgets/glass_card.dart';
import '../widgets/save_confirmation.dart';
import '../widgets/tradition_badge.dart';
import '../services/widget_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isAnimating = false;
  bool _showSaveConfirmation = false;

  void _toggleZenMode() {
    final current = ref.read(zenModeProvider);
    ref.read(zenModeProvider.notifier).state = !current;
    if (!current) {
      // Entering zen mode - haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  @override
  void initState() {
    super.initState();
    // Schedule initial announcement and widget update after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pointing = ref.read(currentPointingProvider);
      _announcePointingContent(pointing);
      WidgetService.updateWidget(pointing);
    });
  }

  /// Announces pointing content to screen readers
  void _announcePointingContent(Pointing pointing) {
    final traditionInfo = traditions[pointing.tradition]!;
    final announcement = StringBuffer();
    announcement.write('New pointing from ${traditionInfo.name}. ');
    announcement.write(pointing.content);
    if (pointing.teacher != null) {
      announcement.write('. By ${pointing.teacher}');
    }
    // ignore: deprecated_member_use
    SemanticsService.announce(announcement.toString(), TextDirection.ltr);
  }

  Future<void> _handleNext() async {
    if (_isAnimating) return;

    // Check freemium limit
    final subscription = ref.read(subscriptionProvider);
    final isPremium = subscription.isPremium;
    final dailyUsage = ref.read(dailyUsageProvider);

    if (!isPremium && dailyUsage.limitReached) {
      // Show paywall when limit reached
      if (mounted) {
        context.push('/paywall');
      }
      return;
    }

    // Haptic feedback
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    setState(() => _isAnimating = true);

    // Wait for fade out
    await Future.delayed(150.ms);

    // Get next pointing and track usage
    ref.read(currentPointingProvider.notifier).nextPointing();
    if (!isPremium) {
      ref.read(dailyUsageProvider.notifier).recordView();
    }

    setState(() => _isAnimating = false);

    // Announce new pointing to screen readers and update widget
    final newPointing = ref.read(currentPointingProvider);
    _announcePointingContent(newPointing);
    WidgetService.updateWidget(newPointing);
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

  Future<void> _handleSave() async {
    final pointing = ref.read(currentPointingProvider);
    final favorites = ref.read(favoritesProvider);

    // Don't save if already a favorite
    if (favorites.contains(pointing.id)) {
      return;
    }

    // Haptic feedback using HapticFeedback from flutter/services.dart
    HapticFeedback.mediumImpact();

    // Save to favorites
    await ref.read(favoritesProvider.notifier).toggle(pointing.id);

    // Show confirmation
    setState(() => _showSaveConfirmation = true);
  }

  void _hideSaveConfirmation() {
    if (mounted) {
      setState(() => _showSaveConfirmation = false);
    }
  }

  Widget _buildZenModeView(Pointing pointing) {
    return GestureDetector(
      onTap: _toggleZenMode,
      behavior: HitTestBehavior.opaque,
      child: Center(
        key: const ValueKey('zen-mode'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Text(
              pointing.content,
              style: AppTextStyles.pointingText(context),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointing = ref.watch(currentPointingProvider);
    final isZenMode = ref.watch(zenModeProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(child: AnimatedGradient()),
          const Positioned.fill(child: FloatingParticles()),

          // Content - switches between zen mode and full view
          if (isZenMode)
            SafeArea(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: _buildZenModeView(pointing),
              ),
            )
          else
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
                  // Tradition badge - first in focus order
                  Semantics(
                    sortKey: const OrdinalSortKey(1.0),
                    child: TraditionBadge(tradition: pointing.tradition)
                        .animate(target: _isAnimating ? 0 : 1)
                        .fadeIn(duration: 300.ms),
                  ),

                  const SizedBox(height: 16),

                  // Pointing card with Dynamic Type support, long press to save, double-tap for zen mode
                  Flexible(
                    child: GestureDetector(
                      onLongPress: _handleSave,
                      onDoubleTap: _toggleZenMode,
                      child: AnimatedOpacity(
                        opacity: _isAnimating ? 0 : 1,
                        duration: 150.ms,
                        child: Semantics(
                          sortKey: const OrdinalSortKey(2.0),
                          label: 'Current pointing: ${pointing.content}${pointing.teacher != null ? ' by ${pointing.teacher}' : ''}',
                          hint: 'Double tap to focus, swipe up or down for actions',
                          customSemanticsActions: {
                            CustomSemanticsAction(label: 'Save to favorites'): _handleSave,
                            CustomSemanticsAction(label: 'Share pointing'): _handleShare,
                          },
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
                                  GestureDetector(
                                    onTap: () {
                                      final teacher = getTeacher(pointing.teacher);
                                      if (teacher != null) {
                                        showTeacherSheet(context, teacher);
                                      }
                                    },
                                    child: Text(
                                      '- ${pointing.teacher}',
                                      style: AppTextStyles.teacherText(context).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppTextStyles.teacherText(context).color?.withValues(alpha: 0.5),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                                // Extended commentary (premium feature)
                                if (pointing.commentary != null) ...[
                                  const SizedBox(height: 16),
                                  CommentarySection(
                                    commentary: pointing.commentary,
                                    pointingId: pointing.id,
                                  ),
                                ],
                              ],
                            ),
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
                        sortKey: const OrdinalSortKey(3.0),
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
                        sortKey: const OrdinalSortKey(4.0),
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

                  // Footer - decorative hint text, excluded from focus order
                  ExcludeSemantics(
                    child: Text(
                      'Tap for another invitation to look',
                      style: AppTextStyles.footerText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Save confirmation overlay
          if (_showSaveConfirmation)
            Positioned.fill(
              child: SaveConfirmation(
                onDismiss: _hideSaveConfirmation,
              ),
            ),
        ],
      ),
    );
  }
}
