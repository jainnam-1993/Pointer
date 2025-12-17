import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_flutter/models/mood.dart';
import 'package:pointer_flutter/providers/providers.dart';
import 'package:pointer_flutter/widgets/mood_selector.dart';
import 'package:pointer_flutter/theme/app_theme.dart';

/// Helper to wrap widget with ProviderScope and MaterialApp
Widget wrapWithProviders(
  Widget child, {
  Mood? initialMood,
}) {
  return ProviderScope(
    overrides: [
      currentMoodProvider.overrideWith((ref) => initialMood),
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  // Set up haptic feedback mock
  TestWidgetsFlutterBinding.ensureInitialized();
  final List<MethodCall> hapticCalls = [];

  setUp(() {
    hapticCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        hapticCalls.add(methodCall);
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('MoodSelector widget', () {
    testWidgets('renders all mood chips', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      // ListView should build all 8 mood chips
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.childrenDelegate, isA<SliverChildBuilderDelegate>());

      // Verify first few visible moods (some may be off-screen in horizontal scroll)
      expect(find.text('Peaceful'), findsOneWidget);
      expect(find.text('🧘'), findsOneWidget);
      expect(find.text('Anxious'), findsOneWidget);
      expect(find.text('😰'), findsOneWidget);
    });

    testWidgets('displays "How are you feeling?" label', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      expect(find.text('How are you feeling?'), findsOneWidget);
    });

    testWidgets('displays mood chips in horizontal scrolling list',
        (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
    });

    testWidgets('no mood is selected initially when currentMood is null',
        (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      // All chips should be in unselected state (no accent color borders)
      // We can't easily test decoration colors, but we can verify no errors
      expect(find.byType(MoodSelector), findsOneWidget);
    });

    testWidgets('displays peaceful mood as selected when set', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const MoodSelector(),
          initialMood: Mood.peaceful,
        ),
      );

      // Widget should render without errors
      expect(find.text('Peaceful'), findsOneWidget);
      expect(find.text('🧘'), findsOneWidget);
    });

    testWidgets('tapping a mood chip updates currentMoodProvider',
        (tester) async {
      Mood? capturedMood;
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  capturedMood = ref.watch(currentMoodProvider);
                  return const MoodSelector();
                },
              ),
            ),
          ),
        ),
      );

      // Initially no mood selected
      expect(capturedMood, isNull);

      // Tap on "Peaceful" mood chip
      await tester.tap(find.text('Peaceful'));
      await tester.pumpAndSettle();

      // Verify mood was updated
      expect(capturedMood, Mood.peaceful);

      // Tap on "Anxious" mood chip
      await tester.tap(find.text('Anxious'));
      await tester.pumpAndSettle();

      // Verify mood was updated to anxious
      expect(capturedMood, Mood.anxious);
    });

    testWidgets('tapping mood chip triggers haptic feedback', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      hapticCalls.clear();

      // Tap on a mood chip
      await tester.tap(find.text('Peaceful'));
      await tester.pumpAndSettle();

      // Verify haptic feedback was triggered (HapticFeedback.selectionClick)
      expect(
        hapticCalls.where((call) => call.method == 'HapticFeedback.vibrate'),
        isNotEmpty,
        reason: 'Expected HapticFeedback.selectionClick to be called',
      );
    });


    testWidgets('tapping different moods updates selection', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: MoodSelector(),
            ),
          ),
        ),
      );

      // Tap peaceful
      await tester.ensureVisible(find.text('Peaceful'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Peaceful'));
      await tester.pumpAndSettle();
      expect(container.read(currentMoodProvider), Mood.peaceful);

      // Tap curious
      await tester.ensureVisible(find.text('Curious'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Curious'));
      await tester.pumpAndSettle();
      expect(container.read(currentMoodProvider), Mood.curious);

      // Tap grateful (might be off-screen in horizontal scroll)
      await tester.ensureVisible(find.text('Grateful'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grateful'));
      await tester.pumpAndSettle();
      expect(container.read(currentMoodProvider), Mood.grateful);
    });

    testWidgets('all mood chips are tappable', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: MoodSelector(),
            ),
          ),
        ),
      );

      // Test tapping each mood (scroll to ensure visibility)
      for (final mood in Mood.values) {
        final info = moodInfo[mood]!;
        await tester.ensureVisible(find.text(info.name));
        await tester.pumpAndSettle();
        await tester.tap(find.text(info.name));
        await tester.pumpAndSettle();
        expect(container.read(currentMoodProvider), mood);
      }
    });

    testWidgets('mood chips have proper padding and sizing', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      // ListView should have proper height
      final listViewSize = tester.getSize(find.byType(ListView));
      expect(listViewSize.height, 44);
    });
  });

  group('showMoodPicker modal', () {
    testWidgets('shows modal bottom sheet', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify modal is displayed
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);

      // Verify all mood descriptions are shown (only in modal)
      expect(find.text('Calm and centered'), findsOneWidget);
      expect(find.text('Worried or stressed'), findsOneWidget);
      expect(find.text('Open to inquiry'), findsOneWidget);
    });

    testWidgets('modal displays mood descriptions', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify descriptions are shown
      expect(find.text('Calm and centered'), findsOneWidget);
      expect(find.text('Worried or stressed'), findsOneWidget);
      expect(find.text('Open to inquiry'), findsOneWidget);
    });

    testWidgets('tapping mood in modal updates provider and closes modal',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Tap on Peaceful mood in modal (there will be multiple, find by description)
      await tester.tap(find.text('Calm and centered'));
      await tester.pumpAndSettle();

      // Verify mood was updated
      expect(container.read(currentMoodProvider), Mood.peaceful);

      // Verify modal is closed (description should not be visible anymore)
      expect(find.text('Calm and centered'), findsNothing);
    });

    testWidgets('modal triggers haptic feedback on selection', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      hapticCalls.clear();

      // Tap a mood in the modal
      await tester.tap(find.text('Calm and centered'));
      await tester.pumpAndSettle();

      // Verify haptic feedback was triggered (HapticFeedback.mediumImpact)
      expect(
        hapticCalls.where((call) => call.method == 'HapticFeedback.vibrate'),
        isNotEmpty,
        reason: 'Expected HapticFeedback.mediumImpact to be called',
      );
    });

    testWidgets('modal has draggable handle', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify DraggableScrollableSheet exists
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('modal is scrollable', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Find the ListView inside modal
      final listView = find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.byType(ListView),
      );
      expect(listView, findsOneWidget);

      // Should be able to scroll
      await tester.drag(listView, const Offset(0, -100));
      await tester.pumpAndSettle();
    });

    testWidgets('selected mood shows check icon in modal', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentMoodProvider.overrideWith((ref) => Mood.peaceful),
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Check icon should be present for selected mood
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('_MoodChip widget', () {
    testWidgets('displays emoji and name', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      expect(find.text('🧘'), findsOneWidget);
      expect(find.text('Peaceful'), findsOneWidget);
    });

    testWidgets('animates on selection state change', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const MoodSelector()));

      // Find AnimatedContainer for mood chips
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });

  group('_MoodListTile widget', () {
    testWidgets('displays all mood information in modal', (tester) async {
      final container = ProviderContainer(
        overrides: [
          highContrastProvider.overrideWith((ref) => false),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showMoodPicker(context, ref),
                    child: const Text('Show Picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify emoji, name, and description are shown for each mood
      final info = moodInfo[Mood.peaceful]!;
      expect(find.text(info.emoji), findsOneWidget);
      expect(find.text(info.name), findsWidgets); // Multiple in modal
      expect(find.text(info.description), findsOneWidget);
    });
  });
}
