import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/pointings.dart';
import 'share_preview_screen.dart';
import '../data/teachers.dart';
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
// Phase 5.11: TraditionBadge no longer imported - using inline badge in card header
// import '../widgets/tradition_badge.dart';
import '../services/widget_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  /// Static flag to disable auto-advance in tests
  /// Set to true in test setUp to prevent timer issues
  static bool disableAutoAdvanceForTesting = false;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isAnimating = false;
  bool _showSaveConfirmation = false;
  bool _isFirstSave = false;

  // Swipe-up blur animation state
  double _swipeOffset = 0.0;
  bool _isSwipeInProgress = false;

  // Auto-advance timer
  Timer? _autoAdvanceTimer;

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
    // Schedule initial announcement, widget update, and auto-advance timer after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pointing = ref.read(currentPointingProvider);
      _announcePointingContent(context, pointing);
      WidgetService.updateWidget(pointing);
      _startAutoAdvanceTimer();
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  /// Starts or restarts the auto-advance timer based on settings
  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();

    // Skip in tests to prevent timer issues
    if (HomeScreen.disableAutoAdvanceForTesting) return;

    final isEnabled = ref.read(autoAdvanceProvider);
    if (!isEnabled) return;

    final delaySeconds = ref.read(autoAdvanceDelayProvider);
    _autoAdvanceTimer = Timer.periodic(
      Duration(seconds: delaySeconds),
      (_) => _handleAutoAdvance(),
    );
  }

  /// Handles automatic advancement to next pointing
  Future<void> _handleAutoAdvance() async {
    // Skip if currently animating or swiping
    if (_isAnimating || _isSwipeInProgress) return;

    // Skip if save confirmation is showing
    if (_showSaveConfirmation) return;

    // Check if auto-advance is still enabled (user might have toggled it)
    final isEnabled = ref.read(autoAdvanceProvider);
    if (!isEnabled) {
      _autoAdvanceTimer?.cancel();
      return;
    }

    // Use the existing _handleNext logic but without haptic feedback
    // to distinguish from manual interaction
    final subscription = ref.read(subscriptionProvider);
    final isPremium = subscription.isPremium;
    final dailyUsage = ref.read(dailyUsageProvider);

    // Don't auto-advance if limit reached (let user see paywall on manual tap)
    if (!isPremium && dailyUsage.limitReached) return;

    setState(() => _isAnimating = true);

    ref.read(currentPointingProvider.notifier).nextPointing();
    if (!isPremium) {
      ref.read(dailyUsageProvider.notifier).recordView();
    }

    await Future.delayed(300.ms);

    if (!mounted) return;
    setState(() => _isAnimating = false);

    final newPointing = ref.read(currentPointingProvider);
    _announcePointingContent(context, newPointing);
    WidgetService.updateWidget(newPointing);

    final storage = ref.read(storageServiceProvider);
    await storage.markPointingAsViewed(newPointing.id);

    // Track tradition affinity for personalization
    final affinity = ref.read(affinityServiceProvider);
    await affinity.recordView(newPointing.tradition);

    // Restart timer for the new pointing (gives full 60s with new content)
    _startAutoAdvanceTimer();
  }

  /// Announces pointing content to screen readers
  void _announcePointingContent(BuildContext context, Pointing pointing) {
    final traditionInfo = traditions[pointing.tradition]!;
    final announcement = StringBuffer();
    announcement.write('New pointing from ${traditionInfo.name}. ');
    announcement.write(pointing.content);
    if (pointing.teacher != null) {
      announcement.write('. By ${pointing.teacher}');
    }
    SemanticsService.sendAnnouncement(
      View.of(context),
      announcement.toString(),
      TextDirection.ltr,
    );
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
    HapticFeedback.mediumImpact();

    setState(() => _isAnimating = true);

    // Get next pointing
    ref.read(currentPointingProvider.notifier).nextPointing();
    if (!isPremium) {
      ref.read(dailyUsageProvider.notifier).recordView();
    }

    // Wait for transition animation to complete
    await Future.delayed(300.ms);

    setState(() => _isAnimating = false);

    // Announce new pointing to screen readers and update widget
    final newPointing = ref.read(currentPointingProvider);
    _announcePointingContent(context, newPointing);
    WidgetService.updateWidget(newPointing);

    // Record in history
    final storage = ref.read(storageServiceProvider);
    await storage.markPointingAsViewed(newPointing.id);

    // Track tradition affinity for personalization
    final affinity = ref.read(affinityServiceProvider);
    await affinity.recordView(newPointing.tradition);

    // Restart timer for the new pointing (gives full 60s with new content)
    _startAutoAdvanceTimer();
  }

  Future<void> _handlePrevious() async {
    if (_isAnimating) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() => _isAnimating = true);

    // Get previous pointing
    ref.read(currentPointingProvider.notifier).previousPointing();

    // Wait for transition animation to complete
    await Future.delayed(300.ms);

    setState(() => _isAnimating = false);

    // Announce new pointing to screen readers and update widget
    final newPointing = ref.read(currentPointingProvider);
    _announcePointingContent(context, newPointing);
    WidgetService.updateWidget(newPointing);

    // Restart timer for the new pointing (gives full 60s with new content)
    _startAutoAdvanceTimer();
  }

  Future<void> _handleShare() async {
    final pointing = ref.read(currentPointingProvider);
    HapticFeedback.mediumImpact();

    // Show share preview screen with template/format options
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SharePreviewScreen(pointing: pointing),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final pointing = ref.read(currentPointingProvider);
    final favorites = ref.read(favoritesProvider);
    final storage = ref.read(storageServiceProvider);

    // Don't save if already a favorite
    if (favorites.contains(pointing.id)) {
      return;
    }

    // Check if this is the user's first-ever save (before toggling)
    final isFirstSave = !storage.hasEverSaved;

    // Haptic feedback - stronger for first save celebration
    if (isFirstSave) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    // Save to favorites
    await ref.read(favoritesProvider.notifier).toggle(pointing.id);

    // Mark first save milestone completed (if applicable)
    if (isFirstSave) {
      await storage.markFirstSaveCompleted();
    }

    // Update widget with new favorites data
    await WidgetService.updateFavorites({...favorites, pointing.id});

    // Track tradition affinity (saves weighted 3x in affinity algorithm)
    final affinity = ref.read(affinityServiceProvider);
    await affinity.recordSave(pointing.tradition);

    // Show confirmation with celebration state
    setState(() {
      _isFirstSave = isFirstSave;
      _showSaveConfirmation = true;
    });
  }

  void _hideSaveConfirmation() {
    if (mounted) {
      setState(() {
        _showSaveConfirmation = false;
        _isFirstSave = false;
      });
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = context.colors;

    // Detect foldable/tablet with square-ish aspect ratio (< 1.3)
    final aspectRatio = screenHeight / screenWidth;
    final isSquareAspect = aspectRatio < 1.3;

    // Responsive bottom padding: accounts for nav bar (~72px) + margin
    // For square-aspect foldables, reduce padding since content has more vertical room
    final navBarSpace = isSquareAspect
        ? 80.0  // Minimal space for foldables
        : (screenHeight * 0.08).clamp(80.0, 120.0);

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
            onVerticalDragStart: (_) {
              setState(() {
                _isSwipeInProgress = true;
                _swipeOffset = 0.0;
              });
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                // Accumulate the delta, negative = swipe up, positive = swipe down
                _swipeOffset += details.delta.dy;
              });
            },
            onVerticalDragEnd: (details) {
              final wasSwipingUp = _swipeOffset < -50;
              final wasSwipingDown = _swipeOffset > 50;

              // Reset swipe state with animation
              setState(() {
                _isSwipeInProgress = false;
                _swipeOffset = 0.0;
              });

              // Swipe up (negative velocity) -> next
              if (details.primaryVelocity! < -200 || wasSwipingUp) {
                _handleNext();
              }
              // Swipe down (positive velocity) -> previous
              else if (details.primaryVelocity! > 200 || wasSwipingDown) {
                _handlePrevious();
              }
            },
            // B.5: Removed horizontal swipe to allow main_shell tab navigation
            child: SafeArea(
              // SafeArea already handles system UI padding (taskbar, etc.)
              // We only need to add space for our custom nav bar
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: navBarSpace, // Just nav bar space, SafeArea handles system padding
                ),
                child: Column(
                  // Fixed layout: card area expands, bottom buttons stay anchored
                  children: [
                  // Expanded card area - card centered within, bottom stays fixed
                  Expanded(
                    child: Center(
                      // Swipe blur effect: blur entire card during vertical drag
                      child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: (_swipeOffset.abs() / 50).clamp(0.0, 8.0),
                            sigmaY: (_swipeOffset.abs() / 50).clamp(0.0, 8.0),
                          ),
                          child: AnimatedOpacity(
                            duration: _isSwipeInProgress
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            opacity: 1.0 - (_swipeOffset.abs() / 200).clamp(0.0, 0.4),
                            child: GestureDetector(
                      onLongPress: _handleSave,
                      onDoubleTap: _toggleZenMode,
                      child: Semantics(
                          sortKey: const OrdinalSortKey(1.0),
                          label: 'Current pointing: ${pointing.content}${pointing.teacher != null ? ' by ${pointing.teacher}' : ''}',
                          hint: 'Double tap to focus. Swipe up for next pointing, down for previous',
                          customSemanticsActions: {
                            CustomSemanticsAction(label: 'Save to favorites'): _handleSave,
                            CustomSemanticsAction(label: 'Share pointing'): _handleShare,
                          },
                          child: GlassCard(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                            borderRadius: 32,
                            // Enable scrolling for large text / accessibility
                            // On foldables (square aspect), enforce minimum height to use more space
                            // Otherwise, let card size dynamically based on content
                            minHeight: isSquareAspect ? screenHeight * 0.25 : screenHeight * 0.15,
                            maxHeight: isSquareAspect
                                ? screenHeight * 0.40
                                : screenHeight * 0.55,
                            enableScrolling: true,
                            // Subtle breathing animation syncs with "Ethereal Liquid Glass" design
                            enableBreathingAnimation: true,
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
                                      // Share icon - separate focusable element
                                      Semantics(
                                        button: true,
                                        label: 'Share this pointing',
                                        focusable: true,
                                        child: GestureDetector(
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
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, animation) {
                                    // Pure fade - calm and unhurried
                                    return FadeTransition(
                                      opacity: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      ),
                                      child: child,
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
                      ),  // Close GestureDetector
                    ),  // Close AnimatedOpacity
                  ),  // Close ImageFiltered
                ),  // Close Center
              ),  // Close Expanded

                  SizedBox(height: isSquareAspect ? 12 : 20),

                  // Mini-inquiry entry point (hide in landscape to save space)
                  if (!isSquareAspect) ...[
                    const MiniInquiryCard(),
                    const SizedBox(height: 24),
                  ],

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

                  // Footer - decorative hint text (hide in landscape)
                  if (!isSquareAspect) ...[
                    const SizedBox(height: 24),
                    ExcludeSemantics(
                      child: Text(
                        'Swipe for another invitation to look',
                        style: AppTextStyles.footerText(context),
                      ),
                    ),
                  ],
                ],
                ),
              ),
            ),
          ),

          // Save confirmation overlay with first-save celebration
          if (_showSaveConfirmation)
            Positioned.fill(
              child: SaveConfirmation(
                onDismiss: _hideSaveConfirmation,
                isFirstSave: _isFirstSave,
              ),
            ),
        ],
      ),
    );
  }
}
