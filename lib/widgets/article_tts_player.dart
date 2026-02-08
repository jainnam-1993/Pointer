import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Mini TTS player widget for article reader.
///
/// Shows playback controls and progress when TTS is active.
class ArticleTTSPlayer extends ConsumerStatefulWidget {
  final String articleId;
  final VoidCallback? onClose;

  const ArticleTTSPlayer({
    super.key,
    required this.articleId,
    this.onClose,
  });

  @override
  ConsumerState<ArticleTTSPlayer> createState() => _ArticleTTSPlayerState();
}

class _ArticleTTSPlayerState extends ConsumerState<ArticleTTSPlayer> {
  final TTSService _ttsService = TTSService.instance;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return StreamBuilder<TTSPlaybackState>(
      stream: _ttsService.stateStream,
      initialData: _ttsService.currentState,
      builder: (context, stateSnapshot) {
        final state = stateSnapshot.data ?? TTSPlaybackState.idle;

        // Don't show if not playing this article
        if (_ttsService.currentArticleId != widget.articleId &&
            state == TTSPlaybackState.idle) {
          return const SizedBox.shrink();
        }

        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              StreamBuilder<Duration>(
                stream: _ttsService.positionStream,
                builder: (context, positionSnapshot) {
                  return StreamBuilder<Duration?>(
                    stream: _ttsService.durationStream,
                    builder: (context, durationSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final duration =
                          durationSnapshot.data ?? const Duration(seconds: 1);

                      final progress = duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0;

                      return Column(
                        children: [
                          // Seek slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: colors.accent,
                              inactiveTrackColor:
                                  colors.accent.withValues(alpha: 0.2),
                              thumbColor: colors.accent,
                              overlayColor: colors.accent.withValues(alpha: 0.1),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (value * duration.inMilliseconds).round(),
                                );
                                _ttsService.seek(newPosition);
                              },
                            ),
                          ),

                          // Time labels
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 4),

              // Playback controls - wrapped in LayoutBuilder + FittedBox for reliable scaling
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
                          // Close button
                          IconButton(
                            icon: Icon(Icons.close, color: colors.textMuted, size: 20),
                            onPressed: () {
                              _ttsService.stop();
                              widget.onClose?.call();
                            },
                            tooltip: 'Close',
                          ),

                          const SizedBox(width: 4),

                          // Seek backward
                          IconButton(
                            icon: Icon(Icons.replay_10,
                                color: colors.textPrimary, size: 24),
                            onPressed: () => _ttsService.seekBackward(seconds: 10),
                            tooltip: 'Back 10s',
                          ),

                          const SizedBox(width: 4),

                          // Play/Pause button
                          _PlayPauseButton(
                            state: state,
                            onPlay: () => _ttsService.resume(),
                            onPause: () => _ttsService.pause(),
                          ),

                          const SizedBox(width: 4),

                          // Seek forward
                          IconButton(
                            icon: Icon(Icons.forward_10,
                                color: colors.textPrimary, size: 24),
                            onPressed: () => _ttsService.seekForward(seconds: 10),
                            tooltip: 'Forward 10s',
                          ),

                          const SizedBox(width: 4),

                          // Voice selection (placeholder)
                          IconButton(
                            icon: Icon(Icons.record_voice_over,
                                color: colors.textMuted, size: 20),
                            onPressed: () => _showVoiceSelector(context),
                            tooltip: 'Voice',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Error message
              StreamBuilder<String>(
                stream: _ttsService.errorStream,
                builder: (context, errorSnapshot) {
                  if (errorSnapshot.hasData && state == TTSPlaybackState.error) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        errorSnapshot.data!,
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showVoiceSelector(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...PollyVoice.values.map((voice) {
              final isSelected = _ttsService.selectedVoice == voice;
              return ListTile(
                leading: Icon(
                  Icons.record_voice_over,
                  color: isSelected ? colors.accent : colors.textMuted,
                ),
                title: Text(
                  voice.id,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  voice.description,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: colors.accent)
                    : null,
                onTap: () {
                  _ttsService.setVoice(voice);
                  Navigator.pop(context);
                },
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final TTSPlaybackState state;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const _PlayPauseButton({
    required this.state,
    required this.onPlay,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (state == TTSPlaybackState.loading) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(colors.accent),
          ),
        ),
      );
    }

    final isPlaying = state == TTSPlaybackState.playing;

    return Material(
      color: colors.accent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isPlaying ? onPause : onPlay,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
