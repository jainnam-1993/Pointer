import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_pointing_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatting.dart';

/**
 * Compact audio player for pointing audio (guided readings, teachings).
 *
 * Features:
 * - Play/pause control with loading indicator
 * - Seek slider with position/duration labels
 * - Skip forward/backward (10s) buttons
 *
 * Integrates with [AudioPointingService] via [audioPointingServiceProvider]
 * for playback state management. Renders nothing when [audioUrl] is null.
 */
class AudioPlayerWidget extends ConsumerStatefulWidget {
  /** Identifier of the pointing this player is associated with. */
  final String pointingId;

  /** Network URL of the audio file; widget renders empty when null. */
  final String? audioUrl;

  const AudioPlayerWidget({super.key, required this.pointingId, required this.audioUrl});

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  AudioPlaybackState _state = AudioPlaybackState.idle;
  Duration _position = Duration.zero;
  Duration? _duration;

  // Stream subscriptions - must be cancelled in dispose()
  StreamSubscription<AudioPlaybackState>? _stateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  AudioPointingService get _audioService => ref.read(audioPointingServiceProvider);

  bool get _isCurrentPointing => _audioService.currentPointingId == widget.pointingId;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    final audioService = _audioService;
    _stateSubscription = audioService.stateStream.listen((state) {
      if (mounted && _isCurrentPointing) {
        setState(() => _state = state);
      }
    });

    _positionSubscription = audioService.positionStream.listen((position) {
      if (mounted && _isCurrentPointing) {
        setState(() => _position = position);
      }
    });

    _durationSubscription = audioService.durationStream.listen((duration) {
      if (mounted && _isCurrentPointing) {
        setState(() => _duration = duration);
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (widget.audioUrl == null) return;

    final audioService = _audioService;
    if (_state == AudioPlaybackState.playing) {
      await audioService.pause();
    } else if (_state == AudioPlaybackState.paused || _state == AudioPlaybackState.completed) {
      await audioService.resume();
    } else {
      await audioService.play(widget.pointingId, widget.audioUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null) return const SizedBox.shrink();

    final colors = context.colors;
    final isPlaying = _state == AudioPlaybackState.playing;
    final isLoading = _state == AudioPlaybackState.loading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Controls row - wrapped in LayoutBuilder + FittedBox for reliable scaling on small screens
          LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip backward
                      IconButton(
                        icon: Icon(Icons.replay_10, color: colors.iconColor, size: 24),
                        onPressed: () => _audioService.seekBackward(),
                      ),

                      // Play/Pause button
                      GestureDetector(
                        onTap: _togglePlayback,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: colors.accent),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                        ),
                      ),

                      // Skip forward
                      IconButton(
                        icon: Icon(Icons.forward_10, color: colors.iconColor, size: 24),
                        onPressed: () => _audioService.seekForward(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Progress slider
          if (_duration != null) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: colors.accent,
                inactiveTrackColor: colors.glassBorder,
                thumbColor: colors.accent,
                overlayColor: colors.accent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _position.inMilliseconds.toDouble(),
                max: _duration!.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _audioService.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            // Time labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(_position), style: AppTextStyles.footerText(context)),
                  Text(formatDuration(_duration!), style: AppTextStyles.footerText(context)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
