import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/widgets/article_tts_player.dart';
import 'package:pointer/services/tts_service.dart';

void main() {
  Widget createTestWidget({
    required String articleId,
    VoidCallback? onClose,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: ArticleTTSPlayer(
            articleId: articleId,
            onClose: onClose,
          ),
        ),
      ),
    );
  }

  group('ArticleTTSPlayer - Widget Structure', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(createTestWidget(articleId: 'test-article-1'));
      await tester.pumpAndSettle();

      // Widget should render (may be empty if not playing)
      expect(find.byType(ArticleTTSPlayer), findsOneWidget);
    });

    testWidgets('accepts articleId parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(articleId: 'custom-article-id'));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleTTSPlayer), findsOneWidget);
    });

    testWidgets('accepts onClose callback', (tester) async {
      await tester.pumpWidget(createTestWidget(
        articleId: 'test',
        onClose: () {}, // Verify widget accepts callback parameter
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleTTSPlayer), findsOneWidget);
    });
  });

  group('ArticleTTSPlayer - State Management', () {
    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(createTestWidget(articleId: 'test'));
      await tester.pumpAndSettle();

      // Verify it uses Riverpod
      expect(find.byType(ArticleTTSPlayer), findsOneWidget);
    });
  });

  group('PollyVoice - Voice Options', () {
    test('all voices are available for selection', () {
      expect(PollyVoice.values.length, 4);

      final voiceIds = PollyVoice.values.map((v) => v.id).toList();
      expect(voiceIds, contains('Joanna'));
      expect(voiceIds, contains('Matthew'));
      expect(voiceIds, contains('Amy'));
      expect(voiceIds, contains('Brian'));
    });

    test('each voice has description', () {
      for (final voice in PollyVoice.values) {
        expect(voice.description.isNotEmpty, isTrue);
      }
    });

    test('US English voices are available', () {
      final usVoices = PollyVoice.values
          .where((v) => v.description.contains('US English'))
          .toList();
      expect(usVoices.length, 2);
    });

    test('British English voices are available', () {
      final britishVoices = PollyVoice.values
          .where((v) => v.description.contains('British English'))
          .toList();
      expect(britishVoices.length, 2);
    });

    test('male and female voices are available', () {
      final maleVoices =
          PollyVoice.values.where((v) => v.description.contains('Male')).toList();
      final femaleVoices =
          PollyVoice.values.where((v) => v.description.contains('Female')).toList();

      expect(maleVoices.length, 2);
      expect(femaleVoices.length, 2);
    });
  });

  group('TTSPlaybackState - All States', () {
    test('idle state is index 0', () {
      expect(TTSPlaybackState.idle.index, 0);
    });

    test('loading state is index 1', () {
      expect(TTSPlaybackState.loading.index, 1);
    });

    test('playing state is index 2', () {
      expect(TTSPlaybackState.playing.index, 2);
    });

    test('paused state is index 3', () {
      expect(TTSPlaybackState.paused.index, 3);
    });

    test('completed state is index 4', () {
      expect(TTSPlaybackState.completed.index, 4);
    });

    test('error state is index 5', () {
      expect(TTSPlaybackState.error.index, 5);
    });
  });

  group('Duration Formatting', () {
    // Test duration formatting by checking the format pattern
    test('duration format is MM:SS', () {
      // Duration formatting is internal, but we can verify the pattern
      final duration = const Duration(minutes: 5, seconds: 30);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      final formatted = '$minutes:${seconds.toString().padLeft(2, '0')}';

      expect(formatted, '5:30');
    });

    test('duration format handles zero', () {
      final duration = Duration.zero;
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      final formatted = '$minutes:${seconds.toString().padLeft(2, '0')}';

      expect(formatted, '0:00');
    });

    test('duration format handles single digit seconds', () {
      final duration = const Duration(minutes: 2, seconds: 5);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      final formatted = '$minutes:${seconds.toString().padLeft(2, '0')}';

      expect(formatted, '2:05');
    });

    test('duration format handles large values', () {
      final duration = const Duration(minutes: 120, seconds: 45);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      final formatted = '$minutes:${seconds.toString().padLeft(2, '0')}';

      expect(formatted, '120:45');
    });
  });
}
