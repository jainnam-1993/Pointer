import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_pointing_service.dart';
import '../theme/app_theme.dart';

/// Compact audio player for pointing audio (guided readings, teachings).
///
/// Features:
/// - Play/pause control
/// - Seek slider with position/duration
/// - Skip forward/backward buttons
/// - Premium gating (audio is premium feature)
class AudioPlayerWidget extends ConsumerStatefulWidget {
  final String pointingId;
  final String? audioUrl;
  final bool isPremium;

  const AudioPlayerWidget({
    super.key,
    required this.pointingId,
    required this.audioUrl,
    required this.isPremium,
  });

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  final _audioService = AudioPointingService.instance;
  AudioPlaybackState _state = AudioPlaybackState.idle;
  Duration _position = Duration.zero;
  Duration? _duration;

  bool get _isCurrentPointing =>
      _audioService.currentPointingId == widget.pointingId;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _audioService.stateStream.listen((state) {
      if (mounted && _isCurrentPointing) {
        setState(() => _state = state);
      }
    });

    _audioService.positionStream.listen((position) {
      if (mounted && _isCurrentPointing) {
        setState(() => _position = position);
      }
    });

    _audioService.durationStream.listen((duration) {
      if (mounted && _isCurrentPointing) {
        setState(() => _duration = duration);
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (!widget.isPremium) {
      _showPremiumPrompt();
      return;
    }

    if (widget.audioUrl == null) return;

    if (_state == AudioPlaybackState.playing) {
      await _audioService.pause();
    } else if (_state == AudioPlaybackState.paused ||
        _state == AudioPlaybackState.completed) {
      await _audioService.resume();
    } else {
      await _audioService.play(widget.pointingId, widget.audioUrl!);
    }
  }

  void _showPremiumPrompt() {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.headphones, color: colors.gold, size: 48),
            const SizedBox(height: 16),
            Text(
              'Audio Pointings',
              style: AppTextStyles.heading(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Listen to guided readings and teachings from masters. Premium feature.',
              style: AppTextStyles.bodyText(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/paywall');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon for non-premium
              if (!widget.isPremium)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.lock_outline, color: colors.gold, size: 18),
                ),

              // Skip backward
              IconButton(
                icon: Icon(Icons.replay_10, color: colors.iconColor, size: 24),
                onPressed:
                    widget.isPremium ? () => _audioService.seekBackward() : null,
              ),

              // Play/Pause button
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isPremium ? colors.accent : colors.gold,
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),

              // Skip forward
              IconButton(
                icon: Icon(Icons.forward_10, color: colors.iconColor, size: 24),
                onPressed:
                    widget.isPremium ? () => _audioService.seekForward() : null,
              ),
            ],
          ),

          // Progress slider (only for premium)
          if (widget.isPremium && _duration != null) ...[
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
                  Text(
                    _formatDuration(_position),
                    style: AppTextStyles.footerText(context),
                  ),
                  Text(
                    _formatDuration(_duration!),
                    style: AppTextStyles.footerText(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
