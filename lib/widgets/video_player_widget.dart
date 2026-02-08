import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../theme/app_theme.dart';

/**
 * Video player for video transmissions (premium feature).
 *
 * Shows a placeholder card with a play button overlay. On tap, initializes
 * a media player (lazy, first-tap only) and opens a full-screen video player
 * page. Non-premium users see a lock icon and tapping opens a paywall prompt.
 *
 * Renders nothing when [videoUrl] is null.
 */
class VideoPlayerWidget extends ConsumerStatefulWidget {
  /// Identifier of the pointing this video belongs to.
  final String pointingId;

  /// Network URL of the video file; widget renders empty when null.
  final String? videoUrl;

  /// Whether the user has premium access; controls playback vs lock display.
  final bool isPremium;

  const VideoPlayerWidget({super.key, required this.pointingId, required this.videoUrl, required this.isPremium});

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  Player? _player;
  VideoController? _videoController;
  bool _isInitialized = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _initializeAndPlay() async {
    if (!widget.isPremium) {
      _showPremiumPrompt();
      return;
    }

    if (widget.videoUrl == null) return;

    if (_player == null) {
      _player = Player();
      _videoController = VideoController(_player!);
      await _player!.open(Media(widget.videoUrl!), play: false);
      setState(() => _isInitialized = true);
    }

    // Show fullscreen video
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _FullScreenVideoPlayer(player: _player!, videoController: _videoController!)),
      );
    }
  }

  void _showPremiumPrompt() {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, color: colors.gold, size: 48),
            const SizedBox(height: 16),
            Text('Video Transmissions', style: AppTextStyles.heading(context), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Watch video teachings from realized masters. Premium feature.',
              style: AppTextStyles.bodyText(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Uses GoRouter for redirect handling when kFreeAccessEnabled
                  context.push('/paywall');
                },
                style: FilledButton.styleFrom(backgroundColor: colors.accent, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Upgrade to Premium'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null) return const SizedBox.shrink();

    final colors = context.colors;

    return GestureDetector(
      onTap: _initializeAndPlay,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: colors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video preview or placeholder
            if (_isInitialized && _videoController != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Video(controller: _videoController!, fit: BoxFit.contain, controls: NoVideoControls),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, color: colors.textSecondary, size: 32),
                    const SizedBox(height: 8),
                    Text('Video Transmission', style: AppTextStyles.footerText(context)),
                  ],
                ),
              ),

            // Play button overlay
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isPremium ? colors.accent.withValues(alpha: 0.9) : colors.gold.withValues(alpha: 0.9),
              ),
              child: Icon(widget.isPremium ? Icons.play_arrow : Icons.lock, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen video player page.
///
/// Receives [Player] and [VideoController] from the parent widget — does NOT
/// own or dispose them. Stream subscriptions are cancelled in [dispose].
class _FullScreenVideoPlayer extends StatefulWidget {
  final Player player;
  final VideoController videoController;

  const _FullScreenVideoPlayer({required this.player, required this.videoController});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  @override
  void initState() {
    super.initState();

    _isPlaying = widget.player.state.playing;
    _position = widget.player.state.position;
    _duration = widget.player.state.duration;

    _playingSub = widget.player.stream.playing.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
    _positionSub = widget.player.stream.position.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _durationSub = widget.player.stream.duration.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    widget.player.play();
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _hideControlsAfterDelay();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            Center(child: Video(controller: widget.videoController, controls: NoVideoControls)),

            // Controls overlay
            if (_showControls) ...[
              // Top bar with close button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () {
                    widget.player.pause();
                    Navigator.pop(context);
                  },
                ),
              ),

              // Center play/pause button
              Center(
                child: GestureDetector(
                  onTap: () => widget.player.playOrPause(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.3)),
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 48),
                  ),
                ),
              ),

              // Bottom progress bar
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Text(_formatDuration(_position), style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Slider(
                          value: _duration.inMilliseconds > 0 ? _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()) : 0,
                          max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1,
                          onChanged: (value) {
                            widget.player.seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
