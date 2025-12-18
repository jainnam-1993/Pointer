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
import '../models/mood.dart';
import '../widgets/teacher_sheet.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/commentary_section.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/mini_inquiry_card.dart';
import '../widgets/save_confirmation.dart';
// HIDDEN: MoodSelector import (UI hidden, logic in models/mood.dart)
// import '../widgets/mood_selector.dart';
// Phase 5.11: TraditionBadge no longer imported - using inline badge in card header
// import '../widgets/tradition_badge.dart';
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
    final newValue = !current;
    ref.read(settingsProvider.notifier).setZenMode(newValue);
    if (newValue) {
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

    // Get next pointing based on mood (if set) and track usage
    PointingContext? moodContext;
    final mood = ref.read(currentMoodProvider);
    if (mood != null) {
      final info = moodInfo[mood]!;
      // Pick the first matching context as the primary filter
      final contextStr = info.matchingContexts.first;
      moodContext = PointingContext.values.firstWhere(
        (c) => c.name == contextStr,
        orElse: () => PointingContext.general,
      );
    }
    ref.read(currentPointingProvider.notifier).nextPointing(context: moodContext);
    if (!isPremium) {
      ref.read(dailyUsageProvider.notifier).recordView();
    }

    // Wait for transition animation to complete
    await Future.delayed(300.ms);

    setState(() => _isAnimating = false);

    // Announce new pointing to screen readers and update widget
    final newPointing = ref.read(currentPointingProvider);
    _announcePointingContent(newPointing);
    WidgetService.updateWidget(newPointing);

    // Record in history
    final storage = ref.read(storageServiceProvider);
    await storage.markPointingAsViewed(newPointing.id);
  }

  Future<void> _handlePrevious() async {
    if (_isAnimating) return;

    // Haptic feedback
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    setState(() => _isAnimating = true);

    // Get previous pointing
    ref.read(currentPointingProvider.notifier).previousPointing();

    // Wait for transition animation to complete
    await Future.delayed(300.ms);

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

    final shareText = StringBuffer();
    shareText.writeln('"${pointing.content}"');
    if (pointing.teacher != null) {
      shareText.writeln('\n— ${pointing.teacher}');
    }
    shareText.writeln('\n━━━━━━━━━━━━━━━━━━━━');
    shareText.writeln('Pointer - Daily Awareness Pointings');
    shareText.writeln('Download: https://pointer.app/download');
    shareText.writeln('━━━━━━━━━━━━━━━━━━━━');

    await Share.share(shareText.toString());
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

  /// Inline tradition badge for card header (Phase 5.11)
  Widget _buildInlineTraditionBadge(Tradition tradition, PointerColors colors, {Key? key}) {
    final traditionInfo = traditions[tradition]!;
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(traditionInfo.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            traditionInfo.name,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZenModeView(Pointing pointing) {
    return GestureDetector(
      onTap: _toggleZenMode,
      onVerticalDragEnd: (details) {
        // Swipe up (negative velocity) -> next
        if (details.primaryVelocity! < -200) {
          _handleNext();
        }
        // Swipe down (positive velocity) -> previous
        else if (details.primaryVelocity! > 200) {
          _handlePrevious();
        }
      },
      // B.5: Removed horizontal swipe to allow main_shell tab navigation
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
          // B.4 Fix: GestureDetector wraps entire screen area for full swipe coverage
          GestureDetector(
            behavior: HitTestBehavior.opaque, // Capture gestures on empty space too
            onVerticalDragEnd: (details) {
              // Swipe up (negative velocity) -> next
              if (details.primaryVelocity! < -200) {
                _handleNext();
              }
              // Swipe down (positive velocity) -> previous
              else if (details.primaryVelocity! > 200) {
                _handlePrevious();
              }
            },
            // B.5: Removed horizontal swipe to allow main_shell tab navigation
            child: SafeArea(
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
                  // HIDDEN: Mood selector UI (logic preserved in providers)
                  // TODO: Re-enable when mood feature is ready
                  // const MoodSelector(),
                  // const SizedBox(height: 16),

                  // Phase 5.11: Consolidated pointing card with tradition badge & share inside
                  Flexible(
                    child: GestureDetector(
                      onLongPress: _handleSave,
                      onDoubleTap: _toggleZenMode,
                      child: Semantics(
                          sortKey: const OrdinalSortKey(1.0),
                          label: 'Current pointing: ${pointing.content}${pointing.teacher != null ? ' by ${pointing.teacher}' : ''}',
                          hint: 'Double tap to focus, swipe up or down for actions',
                          customSemanticsActions: {
                            CustomSemanticsAction(label: 'Save to favorites'): _handleSave,
                            CustomSemanticsAction(label: 'Share pointing'): _handleShare,
                          },
                          child: GlassCard(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                            borderRadius: 32,
                            // Enable scrolling for large text / accessibility
                            maxHeight: MediaQuery.of(context).size.height * 0.65,
                            enableScrolling: true,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header row: tradition badge + share icon (Phase 5.11)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Inline tradition badge with animation
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        switchInCurve: Curves.easeInOutCubic,
                                        switchOutCurve: Curves.easeInOutCubic,
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _buildInlineTraditionBadge(
                                          pointing.tradition,
                                          colors,
                                          key: ValueKey('${pointing.id}-badge'),
                                        ),
                                      ),
                                      // Share icon
                                      GestureDetector(
                                        onTap: _handleShare,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: colors.accent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.ios_share,
                                            size: 18,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  switchInCurve: Curves.easeInOutCubic,
                                  switchOutCurve: Curves.easeInOutCubic,
                                  transitionBuilder: (child, animation) {
                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(animation);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: slideAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    pointing.content,
                                    key: ValueKey(pointing.id),
                                    style: AppTextStyles.pointingText(context),
                                    textAlign: TextAlign.center,
                                  ),
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
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    switchInCurve: Curves.easeInOutCubic,
                                    switchOutCurve: Curves.easeInOutCubic,
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: GestureDetector(
                                      key: ValueKey('${pointing.id}-teacher'),
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
                                // Audio player (premium feature)
                                if (pointing.audioUrl != null) ...[
                                  const SizedBox(height: 16),
                                  AudioPlayerWidget(
                                    pointingId: pointing.id,
                                    audioUrl: pointing.audioUrl,
                                    isPremium: ref.watch(subscriptionProvider).isPremium,
                                  ),
                                ],
                                // Video player (premium feature)
                                if (pointing.videoUrl != null) ...[
                                  const SizedBox(height: 16),
                                  VideoPlayerWidget(
                                    pointingId: pointing.id,
                                    videoUrl: pointing.videoUrl,
                                    isPremium: ref.watch(subscriptionProvider).isPremium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Mini-inquiry entry point
                  const MiniInquiryCard(),

                  const SizedBox(height: 24),

                  // Action button - Next only (Share moved to card header in Phase 5.11)
                  Semantics(
                    sortKey: const OrdinalSortKey(2.0),
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

                  const SizedBox(height: 24),

                  // Footer - decorative hint text, excluded from focus order
                  ExcludeSemantics(
                    child: Text(
                      'Swipe for another invitation to look',
                      style: AppTextStyles.footerText(context),
                    ),
                  ),
                ],
                ),
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
