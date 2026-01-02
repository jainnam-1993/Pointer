// Inquiry Player Screen - Guided inquiry session with timed phase transitions
// Phases: Setup -> Question -> FollowUp -> Complete

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/inquiries.dart';
import '../models/inquiry.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/inquiry_phase_content.dart';

/// Inquiry Player Screen - Guides users through a timed inquiry session
///
/// The inquiry flow:
/// 1. Setup phase (3 sec) - Optional context before the question
/// 2. Question phase (inquiry.pauseDuration) - Main contemplation
/// 3. FollowUp phase - Optional follow-up with action buttons
/// 4. Complete phase - If no follow-up, show completion with buttons
///
/// Respects accessibility settings for reduced motion.
class InquiryPlayerScreen extends ConsumerStatefulWidget {
  const InquiryPlayerScreen({
    super.key,
    required this.inquiryId,
  });

  /// ID of the inquiry to play, or 'random' for a random inquiry
  final String inquiryId;

  /// Duration of the setup phase (8 seconds for proper preparation)
  static const setupDuration = Duration(seconds: 8);

  /// Duration of the question phase (20 seconds for deep contemplation)
  static const questionDuration = Duration(seconds: 20);

  /// Disable auto-advance for testing
  static bool disableAutoAdvance = false;

  @override
  ConsumerState<InquiryPlayerScreen> createState() => _InquiryPlayerScreenState();
}

class _InquiryPlayerScreenState extends ConsumerState<InquiryPlayerScreen>
    with SingleTickerProviderStateMixin {
  Inquiry? _currentInquiry;
  InquiryPhase _phase = InquiryPhase.setup;
  Timer? _phaseTimer;
  bool _isPlaying = false;

  // Timer animation state
  AnimationController? _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this);
    _loadInquiry();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _timerController?.dispose();
    super.dispose();
  }

  /// Start the visual timer animation for a phase
  void _startVisualTimer(Duration duration) {
    _timerController?.duration = duration;
    _timerController?.forward(from: 0.0);
  }

  /// Stop the visual timer
  void _stopVisualTimer() {
    _timerController?.stop();
    _timerController?.reset();
  }

  void _loadInquiry() {
    // Check if ID is a valid inquiry ID or if we should get a random one
    final inquiry = widget.inquiryId == 'random'
        ? getRandomInquiry()
        : getInquiryById(widget.inquiryId);

    // Fall back to random if ID not found
    _currentInquiry = inquiry ?? getRandomInquiry();

    // Start the sequence
    if (mounted) {
      _startSequence();
    }
  }

  void _startSequence() async {
    if (_isPlaying || _currentInquiry == null) return;
    _isPlaying = true;

    // Reset to setup phase
    if (mounted) {
      setState(() => _phase = InquiryPhase.setup);
    }

    // Skip auto-advance in test mode
    if (InquiryPlayerScreen.disableAutoAdvance) {
      _isPlaying = false;
      return;
    }

    // Setup phase - if inquiry has setup text, show it with visual timer
    if (_currentInquiry!.setup != null) {
      _startVisualTimer(InquiryPlayerScreen.setupDuration);
      await _waitForDuration(InquiryPlayerScreen.setupDuration);
      if (!mounted) return;
    }

    // Question phase
    setState(() => _phase = InquiryPhase.question);

    // Haptic feedback at question start
    _triggerHaptic();

    // Start visual timer for question phase (20 seconds for deep contemplation)
    _startVisualTimer(InquiryPlayerScreen.questionDuration);

    // Wait for the question duration
    await _waitForDuration(InquiryPlayerScreen.questionDuration);
    if (!mounted) return;

    // Stop visual timer
    _stopVisualTimer();

    // Haptic feedback at phase transition
    _triggerHaptic();

    // Follow-up phase if available, otherwise complete
    if (_currentInquiry!.followUp != null) {
      setState(() => _phase = InquiryPhase.followUp);
    } else {
      setState(() => _phase = InquiryPhase.complete);
    }

    _isPlaying = false;
  }

  Future<void> _waitForDuration(Duration duration) async {
    final completer = Completer<void>();
    _phaseTimer = Timer(duration, () {
      if (mounted) {
        completer.complete();
      }
    });
    return completer.future;
  }

  void _triggerHaptic() async {
    HapticFeedback.lightImpact();
  }

  void _onAnother() {
    _phaseTimer?.cancel();
    _isPlaying = false;

    // Load a new random inquiry
    setState(() {
      _currentInquiry = getRandomInquiry();
      _phase = InquiryPhase.setup;
    });

    // Haptic feedback
    _triggerHaptic();

    // Start the new sequence
    _startSequence();
  }

  void _onDone() {
    _phaseTimer?.cancel();
    _triggerHaptic();
    context.pop();
  }

  /// Manually advance to the next phase (for testing or user skip)
  void advancePhase() {
    _phaseTimer?.cancel();

    setState(() {
      switch (_phase) {
        case InquiryPhase.setup:
          _phase = InquiryPhase.question;
        case InquiryPhase.question:
          if (_currentInquiry?.followUp != null) {
            _phase = InquiryPhase.followUp;
          } else {
            _phase = InquiryPhase.complete;
          }
        case InquiryPhase.followUp:
          _phase = InquiryPhase.complete;
        case InquiryPhase.complete:
          // Already at end
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_currentInquiry == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const Positioned.fill(child: AnimatedGradient()),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with close button
                _buildTopBar(context, colors),

                // Phase content
                Expanded(
                  child: Center(
                    child: InquiryPhaseContent(
                      inquiry: _currentInquiry!,
                      phase: _phase,
                      onAnother: _onAnother,
                      onDone: _onDone,
                    ),
                  ),
                ),

                // Phase indicator
                _buildPhaseIndicator(context, colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PointerColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          Semantics(
            button: true,
            label: 'Close inquiry',
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: colors.textMuted,
              ),
              onPressed: _onDone,
            ),
          ),

          // Tradition badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.glassBorder),
            ),
            child: Text(
              _getTraditionLabel(_currentInquiry!.tradition),
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Skip button removed for cleaner experience (per Phase 5.4)
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(BuildContext context, PointerColors colors) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final showTimer = _phase == InquiryPhase.setup || _phase == InquiryPhase.question;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Breathing progress indicator (only during timed phases)
          if (showTimer && _timerController != null)
            AnimatedBuilder(
              animation: _timerController!,
              builder: (context, child) {
                return _BreathingProgressRing(
                  progress: _timerController!.value,
                  colors: colors,
                );
              },
            ),
          if (showTimer) const SizedBox(height: 16),
          // Phase dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhaseIndicatorDot(
                isActive: _phase == InquiryPhase.setup,
                isPast: _phase.index > InquiryPhase.setup.index,
                colors: colors,
              ),
              const SizedBox(width: 8),
              _PhaseIndicatorDot(
                isActive: _phase == InquiryPhase.question,
                isPast: _phase.index > InquiryPhase.question.index,
                colors: colors,
              ),
              const SizedBox(width: 8),
              _PhaseIndicatorDot(
                isActive: _phase == InquiryPhase.followUp || _phase == InquiryPhase.complete,
                isPast: false,
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTraditionLabel(dynamic tradition) {
    final name = tradition.toString().split('.').last;
    switch (name) {
      case 'advaita':
        return 'Advaita';
      case 'zen':
        return 'Zen';
      case 'direct':
        return 'Direct Path';
      case 'contemporary':
        return 'Contemporary';
      default:
        return name;
    }
  }
}

class _PhaseIndicatorDot extends StatelessWidget {
  const _PhaseIndicatorDot({
    required this.isActive,
    required this.isPast,
    required this.colors,
  });

  final bool isActive;
  final bool isPast;
  final PointerColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive || isPast
            ? colors.accent.withValues(alpha: isActive ? 0.8 : 0.4)
            : colors.glassBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Subtle breathing progress ring that fills as time passes
/// Creates a gentle visual cue without being distracting
/// Matches the liquid glass design system
class _BreathingProgressRing extends StatelessWidget {
  const _BreathingProgressRing({
    required this.progress,
    required this.colors,
  });

  /// Progress from 0.0 to 1.0
  final double progress;
  final PointerColors colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Subtle breathing effect - gentle scale pulse synced with progress
    final breathingScale = 1.0 + (0.015 * (1 - (progress * 2 - 1).abs()));

    // Theme-consistent colors matching liquid glass style
    final ringColor = isDark
        ? colors.accent.withValues(alpha: 0.5)
        : colors.primary.withValues(alpha: 0.4);
    final bgColor = isDark
        ? colors.glassBorder.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.06);

    return Transform.scale(
      scale: breathingScale,
      child: SizedBox(
        width: 44,
        height: 44,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            progress: progress,
            color: ringColor,
            backgroundColor: bgColor,
            strokeWidth: isDark ? 2.5 : 2.0,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the progress ring
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 2.5,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const pi = 3.14159265359;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
