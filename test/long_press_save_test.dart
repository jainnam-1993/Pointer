import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/home_screen.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/widgets/save_confirmation.dart';

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
    // Return true for hasEverSaved so tests don't trigger first-save celebration
    when(() => mockPrefs.getBool(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments.first as String;
      if (key == 'pointer_has_ever_saved') return true;
      return null;
    });
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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget createHomeScreen({Pointing? initialPointing}) {
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

  group('Long Press to Save', () {
    testWidgets('long press on pointing card triggers save', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'What is aware of this moment?',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;
      expect(pointingCardGesture, findsOneWidget);

      // Perform long press
      await tester.longPress(pointingCardGesture);
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      // Verify favorite was saved
      verify(() => mockPrefs.setString(
            StorageKeys.favoritePointings,
            any(that: contains('test-1')),
          )).called(1);
    });

    testWidgets('long press triggers haptic feedback', (tester) async {
      const testPointing = Pointing(
        id: 'test-haptic',
        content: 'Test haptic feedback',
        tradition: Tradition.zen,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;

      // Perform long press
      await tester.longPress(pointingCardGesture);
      await tester.pump();

      // Verify haptic feedback was triggered
      expect(
        hapticCalls.where((call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.mediumImpact'),
        isNotEmpty,
      );
    });

    testWidgets('long press shows save confirmation overlay', (tester) async {
      const testPointing = Pointing(
        id: 'test-confirmation',
        content: 'Test confirmation overlay',
        tradition: Tradition.direct,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;

      // Perform long press
      await tester.longPress(pointingCardGesture);
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      // Verify save confirmation is shown
      expect(find.byType(SaveConfirmation), findsOneWidget);
    });

    testWidgets('save confirmation widget auto-dismiss behavior', (tester) async {
      // Test the SaveConfirmation widget in isolation with auto-dismiss enabled
      SaveConfirmation.disableAutoDismiss = false;
      bool wasDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SaveConfirmation(
              autoDismissDuration: const Duration(milliseconds: 100),
              onDismiss: () => wasDismissed = true,
            ),
          ),
        ),
      );

      // Initially visible
      expect(find.byType(SaveConfirmation), findsOneWidget);

      // Wait for auto-dismiss
      await tester.pump(const Duration(milliseconds: 200));
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      expect(wasDismissed, isTrue);

      // Reset for other tests
      SaveConfirmation.disableAutoDismiss = true;
    });

    testWidgets('long press does not add duplicate favorites', (tester) async {
      const testPointing = Pointing(
        id: 'already-fav',
        content: 'Already a favorite',
        tradition: Tradition.original,
        contexts: [PointingContext.general],
      );

      // Setup: pointing already in favorites
      when(() => mockPrefs.getString(StorageKeys.favoritePointings))
          .thenReturn(jsonEncode(['already-fav']));

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;

      // Perform long press
      await tester.longPress(pointingCardGesture);
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      // Should not call setString since it's already a favorite
      verifyNever(() => mockPrefs.setString(
            StorageKeys.favoritePointings,
            any(),
          ));
    });

    testWidgets('confirmation shows heart icon', (tester) async {
      const testPointing = Pointing(
        id: 'test-heart',
        content: 'Test heart icon',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;

      // Perform long press
      await tester.longPress(pointingCardGesture);
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      // Verify heart icon is shown
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('confirmation shows "Saved" text', (tester) async {
      const testPointing = Pointing(
        id: 'test-saved-text',
        content: 'Test saved text',
        tradition: Tradition.zen,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;

      // Perform long press
      await tester.longPress(pointingCardGesture);
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      // Verify "Saved" text is shown
      expect(find.text('Saved'), findsOneWidget);
    });
  });

  group('SaveConfirmation Widget', () {
    testWidgets('renders with heart icon and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SaveConfirmation(),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('has animated scale effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SaveConfirmation(),
          ),
        ),
      );

      // Find the AnimatedScale or ScaleTransition
      expect(
        find.byType(AnimatedScale).evaluate().isNotEmpty ||
            find.byType(ScaleTransition).evaluate().isNotEmpty ||
            find.byType(TweenAnimationBuilder<double>).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('calls onDismiss callback when provided', (tester) async {
      // Test with auto-dismiss enabled for this specific test
      SaveConfirmation.disableAutoDismiss = false;
      bool wasDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaveConfirmation(
              autoDismissDuration: const Duration(milliseconds: 100),
              onDismiss: () => wasDismissed = true,
            ),
          ),
        ),
      );

      // Wait for auto-dismiss
      await tester.pump(const Duration(milliseconds: 200));
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      expect(wasDismissed, isTrue);

      // Reset for other tests
      SaveConfirmation.disableAutoDismiss = true;
    });
  });

  group('Favorites Provider Integration', () {
    testWidgets('long press updates favorites provider state', (tester) async {
      const testPointing = Pointing(
        id: 'provider-test',
        content: 'Test provider integration',
        tradition: Tradition.direct,
        contexts: [PointingContext.general],
      );

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

      // Initially not a favorite
      expect(capturedRef.read(favoritesProvider).contains('provider-test'), isFalse);

      // Find the GlassCard containing the pointing text
      final glassCardFinder = find.ancestor(
        of: find.text(testPointing.content),
        matching: find.byType(GlassCard),
      ).first;

      // Find the GestureDetector wrapping this specific card
      final pointingCardGesture = find.ancestor(
        of: glassCardFinder,
        matching: find.byType(GestureDetector),
      ).first;

      // Perform long press
      await tester.longPress(pointingCardGesture);
      // Use pump(Duration) instead of pumpAndSettle due to confetti animation
      await tester.pump(const Duration(seconds: 2));

      // Should now be a favorite
      expect(capturedRef.read(favoritesProvider).contains('provider-test'), isTrue);
    });
  });
}
