import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/inquiry_player_screen.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/providers/inquiry_providers.dart';
import 'package:pointer/data/inquiries.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/models/inquiry.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/inquiry_visual.dart';
import 'package:pointer/widgets/inquiry_phase_content.dart';
import 'package:pointer/theme/app_theme.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    // Disable animations and auto-advance for tests
    AnimatedGradient.disableAnimations = true;
    InquiryVisual.disableAnimations = true;
    InquiryPlayerScreen.disableAutoAdvance = true;
    AppTextStyles.useSystemFonts = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
    InquiryVisual.disableAnimations = false;
    InquiryPlayerScreen.disableAutoAdvance = false;
    AppTextStyles.useSystemFonts = false;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getStringList(any())).thenReturn(null);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);
  });

  Widget createInquiryPlayerScreen({String inquiryId = 'si_001'}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: InquiryPlayerScreen(inquiryId: inquiryId),
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Widget widget) async {
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

  group('InquiryPlayerScreen', () {
    testWidgets('renders without errors', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen());
      expect(find.byType(InquiryPlayerScreen), findsOneWidget);
    });

    testWidgets('shows AnimatedGradient background', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen());
      expect(find.byType(AnimatedGradient), findsOneWidget);
    });

    testWidgets('has close button', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen());
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows tradition badge', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));
      // si_001 is Advaita tradition
      expect(find.text('Advaita'), findsOneWidget);
    });

    testWidgets('loads inquiry by ID', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // si_001 is "Who is aware of this thought?"
      // Since we start in setup phase, we should see the setup text
      expect(find.text('Notice your next thought.'), findsOneWidget);
    });

    testWidgets('loads random inquiry when ID is "random"', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'random'));
      // Should render something (any inquiry)
      expect(find.byType(InquiryPhaseContent), findsOneWidget);
    });

    testWidgets('falls back to random when ID not found', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'nonexistent_id'));
      // Should still render (with a fallback inquiry)
      expect(find.byType(InquiryPhaseContent), findsOneWidget);
    });
  });

  group('InquiryPlayerScreen - Phase Transitions', () {
    testWidgets('starts in setup phase when inquiry has setup', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));
      // si_001 has setup: "Notice your next thought."
      expect(find.text('Notice your next thought.'), findsOneWidget);
    });

    testWidgets('shows question phase content', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // Get the state to manually advance phase
      final state = tester.state<ConsumerState>(find.byType(InquiryPlayerScreen));
      (state as dynamic).advancePhase();
      await tester.pump();

      // Should now show the question
      expect(find.text('Who is aware of this thought?'), findsOneWidget);
    });

    testWidgets('advances from question to followUp when available', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // Advance to question
      final state = tester.state<ConsumerState>(find.byType(InquiryPlayerScreen));
      (state as dynamic).advancePhase();
      await tester.pump();

      // Advance to follow-up
      (state as dynamic).advancePhase();
      await tester.pump();

      // si_001 has followUp: "Look for the one who noticed."
      expect(find.text('Look for the one who noticed.'), findsOneWidget);
    });

    testWidgets('shows action buttons in followUp phase', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // Advance through phases to followUp
      final state = tester.state<ConsumerState>(find.byType(InquiryPlayerScreen));
      (state as dynamic).advancePhase(); // to question
      await tester.pump();
      (state as dynamic).advancePhase(); // to followUp
      await tester.pump();

      // Should show Another and Done buttons
      expect(find.text('Another'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('advances to complete phase when no followUp', (tester) async {
      // si_002 has no followUp
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_002'));

      // Skip setup if present, advance to question then try to advance again
      final state = tester.state<ConsumerState>(find.byType(InquiryPlayerScreen));
      (state as dynamic).advancePhase(); // to question (si_002 has no setup)
      await tester.pump();
      (state as dynamic).advancePhase(); // should go to complete since no followUp
      await tester.pump();

      // Should be at complete phase with buttons
      expect(find.text('Another'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });

  group('InquiryPlayerScreen - User Actions', () {
    testWidgets('close button is tappable', (tester) async {
      // Test that close button exists and is tappable
      // Actual navigation tested via integration tests since it requires GoRouter context
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // Close button should exist
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Should be inside a Semantics widget
      expect(find.bySemanticsLabel('Close inquiry'), findsOneWidget);
    });

    testWidgets('Another button loads new inquiry', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // Advance to followUp to see buttons
      final state = tester.state<ConsumerState>(find.byType(InquiryPlayerScreen));
      (state as dynamic).advancePhase();
      await tester.pump();
      (state as dynamic).advancePhase();
      await tester.pump();

      // Tap Another
      await tester.tap(find.text('Another'));
      await tester.pump();

      // Should reset to setup phase (or show new inquiry content)
      // The key is that we're back at the beginning
      expect(find.byType(InquiryPhaseContent), findsOneWidget);
    });
  });

  group('InquiryPlayerScreen - Visual Elements', () {
    testWidgets('shows InquiryVisual when inquiry has visual element', (tester) async {
      // koan_001 has hasVisualElement: true
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'koan_001'));

      // Advance to question phase (koan_001 has no setup)
      final state = tester.state<ConsumerState>(find.byType(InquiryPlayerScreen));
      (state as dynamic).advancePhase();
      await tester.pump();

      expect(find.byType(InquiryVisual), findsWidgets);
    });

    testWidgets('has phase indicator dots', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen());

      // Should have 3 phase indicator dots
      final animatedContainers = find.byType(AnimatedContainer);
      expect(animatedContainers, findsWidgets);
    });
  });

  group('InquiryPlayerScreen - Accessibility', () {
    testWidgets('has semantic labels for buttons', (tester) async {
      await pumpScreen(tester, createInquiryPlayerScreen(inquiryId: 'si_001'));

      // Check close button has semantics
      expect(find.bySemanticsLabel('Close inquiry'), findsOneWidget);
    });

    // Skip button was removed in Phase 5.4 for cleaner experience
    // Tests for skip button functionality have been removed
  });

  group('InquiryPhase enum', () {
    test('has correct phase order', () {
      expect(InquiryPhase.setup.index, 0);
      expect(InquiryPhase.question.index, 1);
      expect(InquiryPhase.followUp.index, 2);
      expect(InquiryPhase.complete.index, 3);
    });

    test('has exactly 4 phases', () {
      expect(InquiryPhase.values.length, 4);
    });
  });

  group('InquiryPhaseContent widget', () {
    testWidgets('renders setup phase', (tester) async {
      const inquiry = Inquiry(
        id: 'test',
        question: 'Test question?',
        setup: 'Setup text',
        type: InquiryType.selfInquiry,
        tradition: Tradition.advaita,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: InquiryPhaseContent(
                inquiry: inquiry,
                phase: InquiryPhase.setup,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Setup text'), findsOneWidget);
    });

    testWidgets('renders question phase with visual', (tester) async {
      InquiryVisual.disableAnimations = true;

      const inquiry = Inquiry(
        id: 'test',
        question: 'Test question?',
        type: InquiryType.koan,
        tradition: Tradition.zen,
        hasVisualElement: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: InquiryPhaseContent(
                inquiry: inquiry,
                phase: InquiryPhase.question,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test question?'), findsOneWidget);
      expect(find.byType(InquiryVisual), findsWidgets);
    });

    testWidgets('renders followUp phase with buttons', (tester) async {
      const inquiry = Inquiry(
        id: 'test',
        question: 'Test question?',
        followUp: 'Follow up text',
        type: InquiryType.selfInquiry,
        tradition: Tradition.advaita,
      );

      bool anotherTapped = false;
      bool doneTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: InquiryPhaseContent(
                inquiry: inquiry,
                phase: InquiryPhase.followUp,
                onAnother: () => anotherTapped = true,
                onDone: () => doneTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Follow up text'), findsOneWidget);
      expect(find.text('Another'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Another'));
      expect(anotherTapped, true);

      await tester.tap(find.text('Done'));
      expect(doneTapped, true);
    });

    testWidgets('renders complete phase', (tester) async {
      InquiryVisual.disableAnimations = true;

      const inquiry = Inquiry(
        id: 'test',
        question: 'Test question?',
        type: InquiryType.selfInquiry,
        tradition: Tradition.advaita,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: InquiryPhaseContent(
                inquiry: inquiry,
                phase: InquiryPhase.complete,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Rest here.'), findsOneWidget);
      expect(find.text('Another'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });

  group('InquiryVisual widget', () {
    testWidgets('renders static when animations disabled', (tester) async {
      InquiryVisual.disableAnimations = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: InquiryVisual(size: 100),
            ),
          ),
        ),
      );

      expect(find.byType(InquiryVisual), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      InquiryVisual.disableAnimations = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: InquiryVisual(size: 200),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(InquiryVisual),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, 200);
      expect(sizedBox.height, 200);
    });

    testWidgets('renders static in reduced motion mode', (tester) async {
      InquiryVisual.disableAnimations = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            reduceMotionOverrideProvider.overrideWith((ref) => true), // Force reduce motion
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: InquiryVisual(size: 100),
            ),
          ),
        ),
      );

      expect(find.byType(InquiryVisual), findsOneWidget);
      // Should render but without animations (static version)
    });
  });

  group('inquiryByIdProvider', () {
    test('returns inquiry when ID exists', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
      addTearDown(container.dispose);

      final inquiry = container.read(inquiryByIdProvider('si_001'));
      expect(inquiry, isNotNull);
      expect(inquiry!.id, 'si_001');
      expect(inquiry.question, 'Who is aware of this thought?');
    });

    test('returns null when ID does not exist', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
      addTearDown(container.dispose);

      final inquiry = container.read(inquiryByIdProvider('nonexistent_id'));
      expect(inquiry, isNull);
    });
  });

  group('getInquiryById helper', () {
    test('returns inquiry for valid ID', () {
      final inquiry = getInquiryById('si_001');
      expect(inquiry, isNotNull);
      expect(inquiry!.id, 'si_001');
    });

    test('returns null for invalid ID', () {
      final inquiry = getInquiryById('invalid_id');
      expect(inquiry, isNull);
    });

    test('works for all inquiry types', () {
      // Test one from each type
      expect(getInquiryById('si_001'), isNotNull); // self-inquiry
      expect(getInquiryById('koan_001'), isNotNull); // koan
      expect(getInquiryById('dp_001'), isNotNull); // direct pointing
      expect(getInquiryById('cont_001'), isNotNull); // contemplation
    });
  });
}
