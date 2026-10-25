/**
 * Inquiry Player Screen - Guided inquiry session with timed phase transitions.
 * Phases: Setup -> Question -> FollowUp -> Complete.
 */
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/inquiries.dart';
import '../models/inquiry.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_ambient.dart';
import '../widgets/inquiry_phase_content.dart';
import '../utils/haptics.dart';

/**
 * Inquiry Player Screen - Guides users through a timed inquiry session
 *
 * The inquiry flow:
 * 1. Setup phase (3 sec) - Optional context before the question
 * 2. Question phase (inquiry.pauseDuration) - Main contemplation
 * 3. FollowUp phase - Optional follow-up with action buttons
 * 4. Complete phase - If no follow-up, show completion with buttons
 *
 * Respects accessibility settings for reduced motion.
 */
class InquiryPlayerScreen extends ConsumerStatefulWidget {
  const InquiryPlayerScreen({super.key, required this.inquiryId});

  /** ID of the inquiry to play, or 'random' for a random inquiry */
  final String inquiryId;

  /** Duration of the setup phase (8 seconds for proper preparation) */
  static const setupDuration = Duration(seconds: 8);

  /** Duration of the question phase (20 seconds for deep contemplation) */
  static const questionDuration = Duration(seconds: 20);

  /** Disable auto-advance for testing */
  static bool disableAutoAdvance = false;

  @override
  ConsumerState<InquiryPlayerScreen> createState() => _InquiryPlayerScreenState();
}

class _InquiryPlayerScreenState extends ConsumerState<InquiryPlayerScreen> with SingleTickerProviderStateMixin {
  /** The currently loaded [Inquiry] (null until [_loadInquiry] completes). */
  Inquiry? _currentInquiry;

  /** Set when [InquiryPlayerScreen.inquiryId] names no inquiry; shown as an error. */
  String? _missingId;

  /** Current phase in the inquiry flow (setup -> question -> followUp -> complete). */
  InquiryPhase _phase = InquiryPhase.setup;

  /** Timer controlling automatic phase transitions. */
  Timer? _phaseTimer;

  /** The phase wait in flight; completed with `false` when the sequence is cancelled. */
  Completer<bool>? _phaseCompleter;

  /** Whether a timed sequence is currently running. */
  bool _isPlaying = false;

  /** Animation controller driving the [_PhaseTimeBar] during timed phases. */
  AnimationController? _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this);
    _loadInquiry();
  }

  @override
  void dispose() {
    _cancelSequence();
    _timerController?.dispose();
    super.dispose();
  }

  /** Start the visual timer animation for a phase */
  void _startVisualTimer(Duration duration) {
    _timerController?.duration = duration;
    _timerController?.forward(from: 0.0);
  }

  /** Stop the visual timer */
  void _stopVisualTimer() {
    _timerController?.stop();
    _timerController?.reset();
  }

  /** Loads the inquiry by ID (or random if 'random') and starts the timed sequence. */
  void _loadInquiry() {
    // Check if ID is a valid inquiry ID or if we should get a random one
    final inquiry = widget.inquiryId == 'random' ? getRandomInquiry() : getInquiryById(widget.inquiryId);

    // An unknown id is a bug in the caller (a session or link pointing at an
    // inquiry that doesn't exist); fail loudly instead of playing another one.
    if (inquiry == null) {
      debugPrint('InquiryPlayerScreen: no inquiry with id ${widget.inquiryId}');
      if (mounted) setState(() => _missingId = widget.inquiryId);
      return;
    }
    _currentInquiry = inquiry;

    // Start the sequence
    if (mounted) {
      _startSequence();
    }
  }

  /** Runs the timed inquiry sequence: setup -> question -> followUp/complete. */
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
      if (!await _waitForDuration(InquiryPlayerScreen.setupDuration) || !mounted) return;
    }

    // Question phase
    setState(() => _phase = InquiryPhase.question);

    // Haptic feedback at question start
    _triggerHaptic();

    // Start visual timer for question phase (20 seconds for deep contemplation)
    _startVisualTimer(InquiryPlayerScreen.questionDuration);

    // Wait for the question duration
    if (!await _waitForDuration(InquiryPlayerScreen.questionDuration) || !mounted) return;

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

  /**
   * Waits for [duration]. Resolves `true` when the time elapsed, or `false` when
   * [_cancelSequence] ended the sequence first, so the awaiting caller stops instead of hanging.
   */
  Future<bool> _waitForDuration(Duration duration) {
    final completer = Completer<bool>();
    _phaseCompleter = completer;
    _phaseTimer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete(true);
    });
    return completer.future;
  }

  /** Cancels the running sequence: its phase timer, its pending wait, and its countdown ring. */
  void _cancelSequence() {
    _phaseTimer?.cancel();
    final pending = _phaseCompleter;
    if (pending != null && !pending.isCompleted) pending.complete(false);
    _phaseCompleter = null;
    _isPlaying = false;
  }

  void _triggerHaptic() async {
    Haptics.success();
  }

  /** Loads a new random inquiry and restarts the sequence. */
  void _onAnother() {
    _cancelSequence();
    _stopVisualTimer();

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

  /** Cancels the current sequence and pops back to the inquiry list. */
  void _onDone() {
    _cancelSequence();
    _triggerHaptic();
    context.pop();
  }

  /** Manually advance to the next phase (for testing or user skip) */
  void advancePhase() {
    // Skipping hands control to the user: the timed sequence and its countdown end here.
    _cancelSequence();
    _stopVisualTimer();

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

    if (_missingId != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No inquiry "$_missingId".',
            key: const ValueKey('inquiry-missing'),
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }
    if (_currentInquiry == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const Positioned.fill(child: RouteAmbient()),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with close button
                _buildTopBar(context, colors),

                // Phase content
                Expanded(
                  child: Center(
                    child: InquiryPhaseContent(inquiry: _currentInquiry!, phase: _phase, onAnother: _onAnother, onDone: _onDone),
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

  /** Builds the top bar with close button and tradition badge. */
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
              icon: Icon(Icons.close, color: colors.textMuted),
              onPressed: _onDone,
            ),
          ),

          // Tradition badge: callout type in the primary text color on a solid accent tint, so it reads at store size in both themes.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: Color.alphaBlend(colors.accent.withValues(alpha: 0.34), colors.surface),
              border: Border.all(color: colors.accent.withValues(alpha: 0.45), width: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              _getTraditionLabel(_currentInquiry!.tradition),
              style: TextStyle(color: colors.textPrimary, fontSize: AppType.callout, fontWeight: FontWeight.w600, letterSpacing: 0.2),
            ),
          ),

          // Skip button removed for cleaner experience (per Phase 5.4)
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /** Builds the bottom phase indicator with time bar and phase dots. */
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
                return _PhaseTimeBar(progress: _timerController!.value, colors: colors);
              },
            ),
          if (showTimer) const SizedBox(height: 16),
          // Phase dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhaseIndicatorDot(isActive: _phase == InquiryPhase.setup, isPast: _phase.index > InquiryPhase.setup.index, colors: colors),
              const SizedBox(width: 8),
              _PhaseIndicatorDot(isActive: _phase == InquiryPhase.question, isPast: _phase.index > InquiryPhase.question.index, colors: colors),
              const SizedBox(width: 8),
              _PhaseIndicatorDot(isActive: _phase == InquiryPhase.followUp || _phase == InquiryPhase.complete, isPast: false, colors: colors),
            ],
          ),
        ],
      ),
    );
  }

  /** Converts a tradition enum value to its display label. */
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

/** Animated dot indicating an inquiry phase state (active, past, or upcoming). */
class _PhaseIndicatorDot extends StatelessWidget {
  const _PhaseIndicatorDot({required this.isActive, required this.isPast, required this.colors});

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
        color: isActive || isPast ? colors.accent.withValues(alpha: isActive ? 0.8 : 0.4) : colors.textMuted.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/**
 * Time left in the phase as a hairline bar that fills left to right. A ring was
 * read as a loading spinner in a still frame (panel item 11); a bar is not.
 * Subtle breathing progress that fills as time passes
 * Creates a gentle visual cue without being distracting
 * Matches the liquid glass design system
 */
class _PhaseTimeBar extends StatelessWidget {
  const _PhaseTimeBar({required this.progress, required this.colors});

  /** Progress from 0.0 to 1.0 */
  final double progress;
  final PointerColors colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Subtle breathing effect - gentle scale pulse synced with progress
    final breathingScale = 1.0 + (0.015 * (1 - (progress * 2 - 1).abs()));

    // Theme-consistent colors matching liquid glass style
    final ringColor = colors.accent.withValues(alpha: isDark ? 0.8 : 0.9);
    final bgColor = colors.textMuted.withValues(alpha: 0.3);

    return Semantics(
      label: 'Time in this phase',
      value: '${(progress * 100).round()} percent',
      child: Transform.scale(
        scale: breathingScale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: 120,
            height: 4,
            child: LinearProgressIndicator(value: progress, color: ringColor, backgroundColor: bgColor, minHeight: 4),
          ),
        ),
      ),
    );
  }
}
