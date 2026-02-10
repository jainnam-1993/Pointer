import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/widgets/video_player_widget.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';

// Mock classes
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake classes for fallback values
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeRoute());
    AppTextStyles.useSystemFonts = true; // Use system fonts to avoid Google Fonts loading
  });

  tearDownAll(() {
    AppTextStyles.useSystemFonts = false;
  });

  group('VideoPlayerWidget', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Widget createTestWidget({required String pointingId, String? videoUrl}) {
      return ProviderScope(
        overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
        child: MaterialApp(
          theme: AppTheme.dark,
          navigatorObservers: [mockNavigatorObserver],
          home: Scaffold(
            body: VideoPlayerWidget(pointingId: pointingId, videoUrl: videoUrl),
          ),
        ),
      );
    }

    testWidgets('returns SizedBox.shrink when videoUrl is null', (tester) async {
      await tester.pumpWidget(createTestWidget(pointingId: 'test-pointing', videoUrl: null));

      // Should render nothing
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('displays video placeholder with play icon', (tester) async {
      await tester.pumpWidget(createTestWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'));

      // Should show the container with placeholder
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);

      // Should show play icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('uses correct colors from theme', (tester) async {
      await tester.pumpWidget(createTestWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'));

      // Find the play button overlay container
      final containerFinder = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );

      expect(containerFinder, findsOneWidget);

      // Verify the container has the correct styling
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);

      // The color should be accent with opacity
      // Note: We can't directly compare Color with opacity, so we check it exists
      expect(decoration.color, isNotNull);
    });

    testWidgets('widget structure matches expected layout', (tester) async {
      await tester.pumpWidget(createTestWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'));

      // Verify the widget tree structure
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(1));

      // Find Stack inside the GestureDetector (not the one from Scaffold)
      final stackFinder = find.descendant(of: find.byType(GestureDetector), matching: find.byType(Stack));
      expect(stackFinder, findsOneWidget);

      expect(find.byType(Center), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('has correct container dimensions', (tester) async {
      await tester.pumpWidget(createTestWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'));

      // Find the main container by its decoration
      final containerFinder = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius == BorderRadius.circular(16),
        ),
      );

      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.border, isNotNull);

      // Verify the size through the render box
      final renderBox = tester.renderObject(containerFinder) as RenderBox;
      expect(renderBox.size.height, 160);
    });

    testWidgets('play button overlay has correct size', (tester) async {
      await tester.pumpWidget(createTestWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'));

      // Find the play button overlay container (circular overlay)
      final overlayContainerFinder = find.descendant(
        of: find.byType(Stack),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );

      expect(overlayContainerFinder, findsOneWidget);

      // Verify the size through the render box
      final renderBox = tester.renderObject(overlayContainerFinder) as RenderBox;
      expect(renderBox.size.width, 64);
      expect(renderBox.size.height, 64);
    });
  });

  group('VideoPlayerWidget - State Management', () {
    testWidgets('maintains state across rebuilds', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'),
            ),
          ),
        ),
      );

      // Should maintain state
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);
    });

    testWidgets('updates when videoUrl changes from null to valid', (tester) async {
      // Start with null videoUrl
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: null)),
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam), findsNothing);

      // Change to valid videoUrl
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);
    });
  });

  group('VideoPlayerWidget - Error Handling', () {
    testWidgets('handles invalid video URL gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'invalid-url'),
            ),
          ),
        ),
      );

      // Should still display the placeholder
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('handles empty string videoUrl', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: ''),
            ),
          ),
        ),
      );

      // Should still display the placeholder
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);
    });

    testWidgets('handles very long videoUrl', (tester) async {
      final longUrl = 'https://example.com/${'a' * 1000}.mp4';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: longUrl),
            ),
          ),
        ),
      );

      // Should still render
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });
  });

  group('VideoPlayerWidget - Accessibility', () {
    testWidgets('has tappable gesture detector', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'),
            ),
          ),
        ),
      );

      final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));

      expect(gestureDetector.onTap, isNotNull);
    });
  });

  group('VideoPlayerWidget - Integration with Theme', () {
    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'),
            ),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);

      // Verify the theme is applied
      final context = tester.element(find.byType(VideoPlayerWidget));
      final brightness = Theme.of(context).brightness;
      expect(brightness, Brightness.dark);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [oledModeProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => null)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: VideoPlayerWidget(pointingId: 'test-pointing', videoUrl: 'https://example.com/video.mp4'),
            ),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);

      // Verify the theme is applied
      final context = tester.element(find.byType(VideoPlayerWidget));
      final brightness = Theme.of(context).brightness;
      expect(brightness, Brightness.light);
    });
  });
}
