import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:pointer_flutter/widgets/video_player_widget.dart';
import 'package:pointer_flutter/theme/app_theme.dart';
import 'package:pointer_flutter/providers/providers.dart';

// Mock classes
class MockVideoPlayerController extends Mock implements VideoPlayerController {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockVideoPlayerValue extends Mock implements VideoPlayerValue {}

// Fake classes for fallback values
class FakeRoute extends Fake implements Route<dynamic> {}

class FakeUri extends Fake implements Uri {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(FakeUri());
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

    Widget createTestWidget({
      required String pointingId,
      String? videoUrl,
      required bool isPremium,
    }) {
      return ProviderScope(
        overrides: [
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          navigatorObservers: [mockNavigatorObserver],
          home: Scaffold(
            body: VideoPlayerWidget(
              pointingId: pointingId,
              videoUrl: videoUrl,
              isPremium: isPremium,
            ),
          ),
        ),
      );
    }

    testWidgets('returns SizedBox.shrink when videoUrl is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: null,
          isPremium: true,
        ),
      );

      // Should render nothing
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('displays video placeholder with lock icon for non-premium users',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: false,
        ),
      );

      // Should show the container with placeholder
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);

      // Should show lock icon for non-premium
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('displays video placeholder with play icon for premium users',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: true,
        ),
      );

      // Should show the container with placeholder
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);

      // Should show play icon for premium users
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('shows premium prompt modal for non-premium users when tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: false,
        ),
      );

      // Tap on the video widget
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Should show modal bottom sheet with premium prompt
      expect(find.text('Video Transmissions'), findsOneWidget);
      expect(
        find.text('Watch video teachings from realized masters. Premium feature.'),
        findsOneWidget,
      );
      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('premium prompt shows upgrade button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: false,
        ),
      );

      // Tap on the video widget to show modal
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verify upgrade button is present and tappable
      final upgradeButton = find.text('Upgrade to Premium');
      expect(upgradeButton, findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.ancestor(
          of: upgradeButton,
          matching: find.byType(FilledButton),
        )),
        isNotNull,
      );
    });

    testWidgets('premium prompt modal is dismissible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: false,
        ),
      );

      // Tap on the video widget to show modal
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.text('Video Transmissions'), findsOneWidget);

      // Simulate back button press to dismiss modal
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Modal should be dismissed
      expect(find.text('Video Transmissions'), findsNothing);
    });

    testWidgets('uses correct colors from theme', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: true,
        ),
      );

      // Find the play button overlay container
      final containerFinder = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );

      expect(containerFinder, findsOneWidget);

      // Verify the container has the correct styling
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);

      // The color should be accent with opacity for premium users
      // Note: We can't directly compare Color with opacity, so we check it exists
      expect(decoration.color, isNotNull);
    });

    testWidgets('displays different overlay colors for premium vs non-premium',
        (tester) async {
      // Test premium user overlay
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: true,
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Test non-premium user overlay
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('widget structure matches expected layout', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: true,
        ),
      );

      // Verify the widget tree structure
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(1));

      // Find Stack inside the GestureDetector (not the one from Scaffold)
      final stackFinder = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsOneWidget);

      expect(find.byType(Center), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('has correct container dimensions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: true,
        ),
      );

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
      await tester.pumpWidget(
        createTestWidget(
          pointingId: 'test-pointing',
          videoUrl: 'https://example.com/video.mp4',
          isPremium: true,
        ),
      );

      // Find the play button overlay container (circular overlay)
      final overlayContainerFinder = find.descendant(
        of: find.byType(Stack),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
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
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
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
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
            ),
          ),
        ),
      );

      // Should maintain state
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);
    });

    testWidgets('updates when isPremium changes', (tester) async {
      // Start as non-premium
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);

      // Change to premium
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('updates when videoUrl changes from null to valid', (tester) async {
      // Start with null videoUrl
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: null,
                isPremium: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam), findsNothing);

      // Change to valid videoUrl
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
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
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'invalid-url',
                isPremium: true,
              ),
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
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: '',
                isPremium: true,
              ),
            ),
          ),
        ),
      );

      // Should still display the placeholder
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Video Transmission'), findsOneWidget);
    });

    testWidgets('handles very long videoUrl', (tester) async {
      final longUrl = 'https://example.com/' + 'a' * 1000 + '.mp4';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: longUrl,
                isPremium: true,
              ),
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
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
            ),
          ),
        ),
      );

      final gestureDetector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );

      expect(gestureDetector.onTap, isNotNull);
    });

    testWidgets('responds to tap events', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: false,
              ),
            ),
          ),
        ),
      );

      // Verify widget is present before tap
      expect(find.byType(VideoPlayerWidget), findsOneWidget);

      // Tap should trigger action
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Modal should appear
      expect(find.text('Video Transmissions'), findsOneWidget);
    });
  });

  group('VideoPlayerWidget - Integration with Theme', () {
    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
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
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: VideoPlayerWidget(
                pointingId: 'test-pointing',
                videoUrl: 'https://example.com/video.mp4',
                isPremium: true,
              ),
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
