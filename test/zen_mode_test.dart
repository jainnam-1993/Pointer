import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/home_screen.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/save_confirmation.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/widgets/tradition_badge.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late List<MethodCall> hapticCalls;

  setUpAll(() {
    // Disable animations to prevent timer issues in tests
    AnimatedGradient.disableAnimations = true;
    SaveConfirmation.disableAutoDismiss = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
    SaveConfirmation.disableAutoDismiss = false;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    hapticCalls = [];

    // Setup default mock returns
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

    // Mock haptic feedback channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'HapticFeedback.vibrate') {
          hapticCalls.add(methodCall);
        }
        return null;
      },
    );

    // Mock home_widget channel to prevent MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (MethodCall methodCall) async {
        // Return success for all home_widget method calls
        if (methodCall.method == 'saveWidgetData') {
          return true;
        } else if (methodCall.method == 'updateWidget') {
          return true;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
  });

  Widget createHomeScreen({
    Pointing? initialPointing,
    bool initialZenMode = false,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
        if (initialPointing != null)
          currentPointingProvider.overrideWith((ref) {
            final notifier = CurrentPointingNotifier();
            notifier.setPointing(initialPointing);
            return notifier;
          }),
        zenModeProvider.overrideWith((ref) => initialZenMode),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const HomeScreen(),
      ),
    );
  }

  Future<void> pumpHomeScreen(
    WidgetTester tester,
    Widget widget,
  ) async {
    // Use a phone-sized surface to avoid overflow in tests
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(widget);
    });
    await tester.pump();
  }

  group('Zen Mode Provider', () {
    testWidgets('zenModeProvider starts as false by default', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return Container();
            },
          ),
        ),
      );

      // Verify initial state is false
      expect(capturedRef.read(zenModeProvider), isFalse);
    });

    testWidgets('toggling zenModeProvider updates state from false to true',
        (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return Container();
            },
          ),
        ),
      );

      // Initial state
      expect(capturedRef.read(zenModeProvider), isFalse);

      // Toggle to true
      capturedRef.read(zenModeProvider.notifier).state = true;
      await tester.pump();

      // Verify state changed
      expect(capturedRef.read(zenModeProvider), isTrue);
    });

    testWidgets('toggling zenModeProvider updates state from true to false',
        (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            zenModeProvider.overrideWith((ref) => true),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return Container();
            },
          ),
        ),
      );

      // Initial state (overridden)
      expect(capturedRef.read(zenModeProvider), isTrue);

      // Toggle to false
      capturedRef.read(zenModeProvider.notifier).state = false;
      await tester.pump();

      // Verify state changed
      expect(capturedRef.read(zenModeProvider), isFalse);
    });
  });

  group('Home Screen - Zen Mode UI', () {
    const testPointing = Pointing(
      id: 'zen-test-1',
      content: 'What is aware of this moment?',
      instruction: 'Look directly without effort',
      teacher: 'Test Teacher',
      tradition: Tradition.advaita,
      contexts: [PointingContext.general],
    );

    testWidgets('shows full UI when zen mode is off', (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: false,
        ),
      );

      // Verify full UI elements are present
      expect(find.byType(TraditionBadge), findsOneWidget);
      expect(find.byType(GlassCard), findsNWidgets(2)); // Pointing card + mini-inquiry card
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Verify content is visible
      expect(find.text(testPointing.content), findsOneWidget);
      expect(find.text(testPointing.instruction!), findsOneWidget);
      expect(find.text('- ${testPointing.teacher}'), findsOneWidget);

      // Verify zen mode view is not present
      expect(find.byKey(const ValueKey('zen-mode')), findsNothing);
    });

    testWidgets('hides non-essential UI when zen mode is on', (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: true,
        ),
      );

      // Verify non-essential UI elements are hidden
      expect(find.byType(TraditionBadge), findsNothing);
      expect(find.byType(GlassCard), findsNothing);
      expect(find.text('Share'), findsNothing);
      expect(find.text('Next'), findsNothing);
      expect(
        find.text('Tap for another invitation to look'),
        findsNothing,
      );

      // Verify only pointing content is visible
      expect(find.text(testPointing.content), findsOneWidget);

      // Verify instruction and teacher are hidden in zen mode
      expect(find.text(testPointing.instruction!), findsNothing);
      expect(find.text('- ${testPointing.teacher}'), findsNothing);

      // Verify zen mode view is present
      expect(find.byKey(const ValueKey('zen-mode')), findsOneWidget);
    });

    testWidgets('zen mode view is centered', (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: true,
        ),
      );

      // Find the Center widget that contains zen mode view
      final centerFinder = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Center),
      );

      expect(centerFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('zen mode content is scrollable for long text', (tester) async {
      const longPointing = Pointing(
        id: 'zen-long-text',
        content:
            'This is a very long pointing text that would normally overflow the screen. '
            'It contains multiple sentences to test scrolling behavior. '
            'In zen mode, this content should be scrollable so users can read everything. '
            'The SingleChildScrollView should handle this gracefully. '
            'Additional text to make it even longer and test the scrolling more thoroughly.',
        tradition: Tradition.zen,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: longPointing,
          initialZenMode: true,
        ),
      );

      // Verify SingleChildScrollView is present
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('zen-mode')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    });
  });

  group('Zen Mode Gestures', () {
    const testPointing = Pointing(
      id: 'gesture-test',
      content: 'Test gesture interaction',
      tradition: Tradition.direct,
      contexts: [PointingContext.general],
    );

    testWidgets('double-tap on pointing card toggles zen mode on',
        (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            currentPointingProvider.overrideWith((ref) {
              final notifier = CurrentPointingNotifier();
              notifier.setPointing(testPointing);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const HomeScreen();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Initially zen mode is off
      expect(capturedRef.read(zenModeProvider), isFalse);
      expect(find.byType(TraditionBadge), findsOneWidget);

      // Find the pointing card (the GlassCard with the pointing content) and double-tap it
      final pointingCard = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      );
      expect(pointingCard, findsOneWidget);

      // Perform double-tap using the pointing card finder
      await tester.tap(pointingCard);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(pointingCard);
      await tester.pumpAndSettle();

      // Verify zen mode is now on
      expect(capturedRef.read(zenModeProvider), isTrue);
      expect(find.byKey(const ValueKey('zen-mode')), findsOneWidget);
      expect(find.byType(TraditionBadge), findsNothing);
    });

    testWidgets('tap on zen mode view toggles zen mode off', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            currentPointingProvider.overrideWith((ref) {
              final notifier = CurrentPointingNotifier();
              notifier.setPointing(testPointing);
              return notifier;
            }),
            zenModeProvider.overrideWith((ref) => true),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const HomeScreen();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Initially zen mode is on
      expect(capturedRef.read(zenModeProvider), isTrue);
      expect(find.byKey(const ValueKey('zen-mode')), findsOneWidget);

      // Tap on zen mode view to exit
      await tester.tap(find.byKey(const ValueKey('zen-mode')));
      await tester.pumpAndSettle();

      // Verify zen mode is now off
      expect(capturedRef.read(zenModeProvider), isFalse);
      expect(find.byKey(const ValueKey('zen-mode')), findsNothing);
      expect(find.byType(TraditionBadge), findsOneWidget);
    });

    testWidgets('entering zen mode triggers haptic feedback', (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: false,
        ),
      );

      hapticCalls.clear();

      // Find the pointing card (the GlassCard with the pointing content)
      final pointingCard = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      );

      // Double-tap to enter zen mode
      await tester.tap(pointingCard);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(pointingCard);
      await tester.pumpAndSettle();

      // Verify haptic feedback was triggered
      expect(
        hapticCalls.where((call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.lightImpact'),
        isNotEmpty,
      );
    });

    testWidgets('exiting zen mode does not trigger haptic feedback',
        (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: true,
        ),
      );

      hapticCalls.clear();

      // Tap to exit zen mode
      await tester.tap(find.byKey(const ValueKey('zen-mode')));
      await tester.pumpAndSettle();

      // Verify no haptic feedback when exiting
      expect(
        hapticCalls.where((call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.lightImpact'),
        isEmpty,
      );
    });
  });

  group('Zen Mode Animation', () {
    const testPointing = Pointing(
      id: 'animation-test',
      content: 'Test animation behavior',
      tradition: Tradition.zen,
      contexts: [PointingContext.general],
    );

    testWidgets('zen mode view has fade-in animation', (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: true,
        ),
      );

      // Find AnimatedOpacity wrapping zen mode view
      final animatedOpacityFinder = find.ancestor(
        of: find.byKey(const ValueKey('zen-mode')),
        matching: find.byType(AnimatedOpacity),
      );

      expect(animatedOpacityFinder, findsOneWidget);

      // Verify opacity is set to 1.0 (fully visible)
      final animatedOpacity =
          tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(animatedOpacity.opacity, 1.0);
    });

    testWidgets('animation duration is 500ms', (tester) async {
      await pumpHomeScreen(
        tester,
        createHomeScreen(
          initialPointing: testPointing,
          initialZenMode: true,
        ),
      );

      // Find AnimatedOpacity
      final animatedOpacityFinder = find.ancestor(
        of: find.byKey(const ValueKey('zen-mode')),
        matching: find.byType(AnimatedOpacity),
      );

      final animatedOpacity =
          tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(
        animatedOpacity.duration,
        const Duration(milliseconds: 500),
      );
    });
  });

  group('Zen Mode Integration', () {
    const testPointing = Pointing(
      id: 'integration-test',
      content: 'Test full integration',
      tradition: Tradition.original,
      contexts: [PointingContext.general],
    );

    testWidgets('zen mode persists across rebuilds', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            currentPointingProvider.overrideWith((ref) {
              final notifier = CurrentPointingNotifier();
              notifier.setPointing(testPointing);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const HomeScreen();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Enter zen mode
      capturedRef.read(zenModeProvider.notifier).state = true;
      await tester.pumpAndSettle();

      expect(capturedRef.read(zenModeProvider), isTrue);
      expect(find.byKey(const ValueKey('zen-mode')), findsOneWidget);

      // Trigger rebuild
      await tester.pump();

      // Verify zen mode is still active
      expect(capturedRef.read(zenModeProvider), isTrue);
      expect(find.byKey(const ValueKey('zen-mode')), findsOneWidget);
    });

    testWidgets('can toggle between zen and normal mode multiple times',
        (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            currentPointingProvider.overrideWith((ref) {
              final notifier = CurrentPointingNotifier();
              notifier.setPointing(testPointing);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const HomeScreen();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Toggle on
      capturedRef.read(zenModeProvider.notifier).state = true;
      await tester.pumpAndSettle();
      expect(capturedRef.read(zenModeProvider), isTrue);

      // Toggle off
      capturedRef.read(zenModeProvider.notifier).state = false;
      await tester.pumpAndSettle();
      expect(capturedRef.read(zenModeProvider), isFalse);

      // Toggle on again
      capturedRef.read(zenModeProvider.notifier).state = true;
      await tester.pumpAndSettle();
      expect(capturedRef.read(zenModeProvider), isTrue);

      // Toggle off again
      capturedRef.read(zenModeProvider.notifier).state = false;
      await tester.pumpAndSettle();
      expect(capturedRef.read(zenModeProvider), isFalse);
    });
  });
}
