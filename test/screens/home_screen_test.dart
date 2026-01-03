import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/home_screen.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/widgets/animated_gradient.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    // Disable animations to prevent timer issues in tests
    AnimatedGradient.disableAnimations = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    // Setup default mock returns
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  Widget createHomeScreen({Pointing? initialPointing}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
        if (initialPointing != null)
          currentPointingProvider.overrideWith((ref) {
            final storage = ref.watch(storageServiceProvider);
            final notifier = CurrentPointingNotifier(storage);
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

  // Helper for tests with animations - uses runAsync to avoid timer issues
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

  // PLACEHOLDER_TO_REMOVE
  Future<void> OLD_pumpHomeScreen(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(widget);
    });
    await tester.pump();
  }

  group('HomeScreen', () {
    testWidgets('renders without errors', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows a pointing content', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'What is aware of this moment?',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      expect(find.text('What is aware of this moment?'), findsOneWidget);
    });

    testWidgets('shows tradition badge', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Test content',
        tradition: Tradition.zen,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      // Phase 5.11: TraditionBadge moved inline inside card
      expect(find.text('Zen Buddhism'), findsOneWidget);
    });

    testWidgets('shows instruction when present', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Test content',
        instruction: 'Just look.',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      expect(find.text('Just look.'), findsOneWidget);
    });

    testWidgets('shows teacher when present', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Test content',
        teacher: 'Ramana Maharshi',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      expect(find.textContaining('Ramana Maharshi'), findsOneWidget);
    });

    testWidgets('has Next button', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('has Share icon in card header', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Phase 5.11: Share moved to icon in card header
      expect(find.byIcon(Icons.ios_share), findsOneWidget);
    });

    testWidgets('shows GlassCard for pointing content', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Two GlassCards: one for pointing content, one for mini-inquiry
      expect(find.byType(GlassCard), findsNWidgets(2));
    });

    testWidgets('shows one GlassButton (Next)', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Phase 5.11: Only Next button is GlassButton, Share is icon in card header
      expect(find.byType(GlassButton), findsOneWidget);
    });

    testWidgets('has animated gradient background', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      expect(find.byType(AnimatedGradient), findsOneWidget);
    });

    testWidgets('has proper layout structure', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Should have Stack for layered background
      expect(find.byType(Stack), findsWidgets);

      // Should have SafeArea for device safe areas
      expect(find.byType(SafeArea), findsOneWidget);

      // Should have Column(s) for vertical layout
      expect(
        find.descendant(
          of: find.byType(SafeArea),
          matching: find.byType(Column),
        ),
        findsWidgets,
      );
    });

    testWidgets('Next button has arrow icon', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('Share icon exists in card header', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Phase 5.11: Share icon is in card header, not a button
      expect(find.byIcon(Icons.ios_share), findsOneWidget);
    });

    testWidgets('pointing card is flexible height', (tester) async {
      // Use moderate length content that wraps but doesn't overflow test screen
      const mediumPointing = Pointing(
        id: 'test-medium',
        content:
            'This pointing content wraps across multiple lines to test flexible height.',
        tradition: Tradition.original,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: mediumPointing));

      // Content should render and wrap properly
      expect(find.textContaining('wraps across'), findsOneWidget);
    });

    testWidgets('handles pointing without instruction', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Simple pointing without instruction',
        tradition: Tradition.zen,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      expect(find.text('Simple pointing without instruction'), findsOneWidget);
      // Two GlassCards: pointing card + mini-inquiry card
      expect(find.byType(GlassCard), findsNWidgets(2));
    });

    testWidgets('handles pointing without teacher', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Pointing without attribution',
        tradition: Tradition.original,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      expect(find.text('Pointing without attribution'), findsOneWidget);
      // Should not find any dash teacher attribution
      expect(find.textContaining('- '), findsNothing);
    });

    testWidgets('handles pointing with all fields', (tester) async {
      const fullPointing = Pointing(
        id: 'test-full',
        content: 'Main pointing content',
        instruction: 'Instruction text',
        tradition: Tradition.direct,
        contexts: [PointingContext.morning, PointingContext.general],
        teacher: 'Test Teacher',
        source: 'Test Source',
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: fullPointing));

      expect(find.text('Main pointing content'), findsOneWidget);
      expect(find.text('Instruction text'), findsOneWidget);
      expect(find.text('Direct Path'), findsOneWidget);
      expect(find.textContaining('Test Teacher'), findsOneWidget);
    });
  });

  group('HomeScreen Interactions', () {
    testWidgets('Next button is tappable', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      final button = find.text('Next');
      expect(button, findsOneWidget);

      // Tapping should not throw - pumpAndSettle to clear all animation timers
      await tester.tap(button);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    });

    testWidgets('Share icon is tappable', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Phase 5.11: Share is now an icon in card header
      final icon = find.byIcon(Icons.ios_share);
      expect(icon, findsOneWidget);

      // Tapping should not throw (share dialog won't open in tests)
      await tester.tap(icon);
      await tester.pump(const Duration(milliseconds: 200)); // Clear timers
    });

    testWidgets('tapping Next button triggers animation', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Should have AnimatedSwitcher for quote change animation
      // Note: AnimatedOpacity is only shown in zen mode
      expect(find.byType(AnimatedSwitcher), findsWidgets);

      // Tap next - this triggers animations
      await tester.tap(find.text('Next'));

      // Clear all animation timers (300ms + buffer)
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    });
  });

  group('HomeScreen Provider Integration', () {
    testWidgets('uses currentPointingProvider', (tester) async {
      final testPointing = pointings.first;

      await pumpHomeScreen(
        tester,
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            currentPointingProvider.overrideWith((ref) {
              final storage = ref.watch(storageServiceProvider);
              final notifier = CurrentPointingNotifier(storage);
              notifier.setPointing(testPointing);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text(testPointing.content), findsOneWidget);
    });

    testWidgets('displays pointing content from provider', (tester) async {
      // Test that the HomeScreen displays the pointing from the provider
      const testPointing = Pointing(
        id: 'provider-test-2',
        content: 'Provider test pointing content',
        instruction: 'Look closely',
        tradition: Tradition.zen,
        contexts: [PointingContext.general],
        teacher: 'Provider Teacher',
      );

      await pumpHomeScreen(
        tester,
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
            currentPointingProvider.overrideWith((ref) {
              final storage = ref.watch(storageServiceProvider);
              final notifier = CurrentPointingNotifier(storage);
              notifier.setPointing(testPointing);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const HomeScreen(),
          ),
        ),
      );

      // Verify all pointing fields are displayed
      expect(find.text('Provider test pointing content'), findsOneWidget);
      expect(find.text('Look closely'), findsOneWidget);
      expect(find.text('Zen Buddhism'), findsOneWidget);
      expect(find.textContaining('Provider Teacher'), findsOneWidget);
    });
  });

  group('HomeScreen Layout', () {
    testWidgets('uses Scaffold', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('content is centered', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // HomeScreen uses Expanded with Center to center the card content
      final expandedFinder = find.descendant(
        of: find.byType(SafeArea),
        matching: find.byType(Expanded),
      );
      expect(expandedFinder, findsOneWidget);

      // Center widget inside Expanded provides centering
      final centerFinder = find.descendant(
        of: expandedFinder,
        matching: find.byType(Center),
      );
      // Multiple Center widgets may exist, verify at least one is present
      expect(centerFinder, findsWidgets);
    });

    testWidgets('has proper spacing between elements', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // SizedBox widgets provide spacing
      expect(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(SizedBox),
        ),
        findsWidgets,
      );
    });

    testWidgets('has Row for action buttons', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Should have Row containing the Share and Next buttons
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('HomeScreen Accessibility', () {
    testWidgets('all text is visible', (tester) async {
      const testPointing = Pointing(
        id: 'test-a11y',
        content: 'Accessibility test content',
        instruction: 'Instruction for screen reader',
        teacher: 'Teacher Name',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await pumpHomeScreen(tester, createHomeScreen(initialPointing: testPointing));

      expect(find.text('Accessibility test content'), findsOneWidget);
      expect(find.text('Instruction for screen reader'), findsOneWidget);
      expect(find.textContaining('Teacher Name'), findsOneWidget);
    });

    testWidgets('buttons are accessible', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // Phase 5.11: Only Next button is GlassButton
      final buttons = find.byType(GlassButton);
      expect(buttons, findsOneWidget);

      // Share icon should be tappable
      await tester.tap(find.byIcon(Icons.ios_share));
      await tester.pump(const Duration(milliseconds: 200)); // Clear timers

      // Verify Next button exists and is tappable
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('has semantics for screen readers', (tester) async {
      await pumpHomeScreen(tester, createHomeScreen());

      // The pointing card has Semantics wrapper
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
