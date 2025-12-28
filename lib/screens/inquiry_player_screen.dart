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

  /// Duration of the setup phase
  static const setupDuration = Duration(seconds: 3);

  /// Disable auto-advance for testing
  static bool disableAutoAdvance = false;

  @override
  ConsumerState<InquiryPlayerScreen> createState() => _InquiryPlayerScreenState();
}

class _InquiryPlayerScreenState extends ConsumerState<InquiryPlayerScreen> {
  Inquiry? _currentInquiry;
  InquiryPhase _phase = InquiryPhase.setup;
  Timer? _phaseTimer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadInquiry();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
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

    // Setup phase - if inquiry has setup text, show it for 3 seconds
    if (_currentInquiry!.setup != null) {
      await _waitForDuration(InquiryPlayerScreen.setupDuration);
      if (!mounted) return;
    }

    // Question phase
    setState(() => _phase = InquiryPhase.question);

    // Haptic feedback at question start
    _triggerHaptic();

    // Wait for the inquiry's pause duration
    await _waitForDuration(_currentInquiry!.pauseDuration);
    if (!mounted) return;

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
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Row(
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
