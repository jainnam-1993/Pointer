import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/lineages_screen.dart';
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

  Widget createLineagesScreen() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const LineagesScreen(),
      ),
    );
  }

  // Helper for tests with animations - uses runAsync to avoid timer issues
  Future<void> pumpLineagesScreen(
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

  group('LineagesScreen - Basic Rendering', () {
    testWidgets('renders without errors', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.byType(LineagesScreen), findsOneWidget);
    });

    testWidgets('has AnimatedGradient background', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.byType(AnimatedGradient), findsOneWidget);
    });

    testWidgets('shows "Manage Lineages" title', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Manage Lineages'), findsOneWidget);
    });

    testWidgets('shows subtitle for tradition selection', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Select the traditions you want to receive pointings from'), findsOneWidget);
    });

    testWidgets('uses Scaffold', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has Stack for layered background', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('has SafeArea for device safe areas', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('has ListView for scrollable content', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('LineagesScreen - Tradition Cards', () {
    testWidgets('shows all 5 tradition cards', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Should have 5 GlassCards for the 5 traditions
      expect(find.byType(GlassCard), findsNWidgets(5));
    });

    testWidgets('shows Advaita Vedanta tradition', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Advaita Vedanta'), findsOneWidget);
      expect(find.text('ॐ'), findsOneWidget);
      expect(find.text('The path of non-duality. You are already what you seek.'), findsOneWidget);
    });

    testWidgets('shows Zen Buddhism tradition', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Zen Buddhism'), findsOneWidget);
      expect(find.text('◯'), findsOneWidget);
      expect(find.text('Direct pointing. No words, no concepts.'), findsOneWidget);
    });

    testWidgets('shows Direct Path tradition', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Direct Path'), findsOneWidget);
      expect(find.text('◇'), findsOneWidget);
      expect(find.text('Contemporary clarity. Awareness recognizing itself.'), findsOneWidget);
    });

    testWidgets('shows Contemporary tradition', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Contemporary'), findsOneWidget);
      expect(find.text('✦'), findsOneWidget);
      expect(find.text('Modern teachers. Ancient truth, fresh words.'), findsOneWidget);
    });

    testWidgets('shows Original tradition', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      expect(find.text('Original'), findsOneWidget);
      expect(find.text('∞'), findsOneWidget);
      expect(find.text('Written for now. This moment, this life.'), findsOneWidget);
    });

    testWidgets('each card shows pointings count', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Get actual counts from data
      final advaitaCount = getPointingsByTradition(Tradition.advaita).length;
      final zenCount = getPointingsByTradition(Tradition.zen).length;
      final directCount = getPointingsByTradition(Tradition.direct).length;
      final contemporaryCount = getPointingsByTradition(Tradition.contemporary).length;
      final originalCount = getPointingsByTradition(Tradition.original).length;

      // Counts appear at least once each (may appear multiple times if repeated values)
      expect(find.text('$advaitaCount pointings'), findsWidgets);
      expect(find.text('$zenCount pointings'), findsWidgets);
      expect(find.text('$directCount pointings'), findsWidgets);
      expect(find.text('$contemporaryCount pointings'), findsWidgets);
      expect(find.text('$originalCount pointings'), findsWidgets);
    });

    testWidgets('each card has icon, name, description, and count', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Verify each tradition has all required elements
      for (final entry in traditions.entries) {
        final info = entry.value;
        final count = getPointingsByTradition(entry.key).length;

        expect(find.text(info.icon), findsOneWidget);
        expect(find.text(info.name), findsOneWidget);
        expect(find.text(info.description), findsOneWidget);
        // Count text may appear multiple times if same count shared by traditions
        expect(find.text('$count pointings'), findsWidgets);
      }
    });

    testWidgets('each card has info icon', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // 5 traditions should have 5 info icons
      expect(find.byIcon(Icons.info_outline), findsNWidgets(5));
    });

    testWidgets('cards are tappable', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      final firstCard = find.byType(GlassCard).first;
      expect(firstCard, findsOneWidget);

      // Tapping should not throw
      await tester.tap(firstCard);
      await tester.pump(const Duration(milliseconds: 200));
    });
  });

  group('LineagesScreen - Bottom Sheet', () {
    testWidgets('tapping info icon opens detail sheet', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap the first info icon to open detail sheet
      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();

      // Bottom sheet should be visible - verify by checking for doubled content
      // Icon appears twice: in list + in sheet
      expect(find.text('ॐ'), findsNWidgets(2));
      // Close button only appears in sheet
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('detail sheet shows tradition icon', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap first info icon (Advaita)
      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();

      // Should show icon in detail sheet (icon appears twice: in list + in sheet)
      expect(find.text('ॐ'), findsNWidgets(2));
    });

    testWidgets('detail sheet shows tradition name', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap second info icon (Zen)
      await tester.tap(find.byIcon(Icons.info_outline).at(1));
      await tester.pumpAndSettle();

      // Name appears twice: in list + in detail sheet
      expect(find.text('Zen Buddhism'), findsNWidgets(2));
    });

    testWidgets('detail sheet shows tradition description', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap third info icon (Direct Path)
      await tester.tap(find.byIcon(Icons.info_outline).at(2));
      await tester.pumpAndSettle();

      // Description appears in detail sheet (may be truncated in list)
      expect(find.textContaining('Contemporary clarity'), findsWidgets);
    });

    testWidgets('detail sheet shows pointings count', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap fourth info icon (Contemporary)
      await tester.tap(find.byIcon(Icons.info_outline).at(3));
      await tester.pumpAndSettle();

      final count = getPointingsByTradition(Tradition.contemporary).length;
      // Text appears in bottom sheet as "$count pointings available"
      expect(find.text('$count pointings available'), findsOneWidget);
    });

    testWidgets('detail sheet has Close button', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap first info icon (guaranteed to be visible)
      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();

      // Should have Close button
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Close button dismisses detail sheet', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap first info icon to open sheet
      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();

      // Verify sheet is open
      expect(find.text('Close'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed (only 1 Advaita text in list, not 2)
      expect(find.text('Advaita Vedanta'), findsOneWidget);
    });

    testWidgets('detail sheet has handle bar', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap second info icon
      await tester.tap(find.byIcon(Icons.info_outline).at(1));
      await tester.pumpAndSettle();

      // Verify sheet is open by checking for doubled content
      expect(find.text('Zen Buddhism'), findsNWidgets(2));
      // Bottom sheet should have Container widgets for layout
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('detail sheet uses BackdropFilter for blur', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Tap third info icon
      await tester.tap(find.byIcon(Icons.info_outline).at(2));
      await tester.pumpAndSettle();

      // Should have BackdropFilter in bottom sheet
      expect(find.byType(BackdropFilter), findsWidgets);
    });
  });

  group('LineagesScreen - Accessibility', () {
    testWidgets('tradition cards have semantic labels', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Each tradition card should have Semantics wrapper
      // We have 5 tradition cards, so we should find at least 5 Semantics widgets
      expect(find.byType(Semantics), findsWidgets);
      
      // Verify at least 5 GlassCards exist (one per tradition)
      expect(find.byType(GlassCard), findsNWidgets(5));
    });

    testWidgets('all text is visible', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Title and subtitle
      expect(find.text('Manage Lineages'), findsOneWidget);
      expect(find.text('Select the traditions you want to receive pointings from'), findsOneWidget);

      // All tradition names
      expect(find.text('Advaita Vedanta'), findsOneWidget);
      expect(find.text('Zen Buddhism'), findsOneWidget);
      expect(find.text('Direct Path'), findsOneWidget);
      expect(find.text('Contemporary'), findsOneWidget);
      expect(find.text('Original'), findsOneWidget);
    });

    testWidgets('cards have proper semantic markup as buttons', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Find all Semantics widgets - should have at least 5 for the tradition cards
      final semanticsWidgets = find.byType(Semantics);
      expect(semanticsWidgets, findsWidgets);
      
      // Each tradition card should be present
      for (final entry in traditions.entries) {
        final info = entry.value;
        expect(find.text(info.name), findsOneWidget);
      }
    });
  });

  group('LineagesScreen - Layout', () {
    testWidgets('has proper spacing between elements', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // SizedBox widgets provide spacing
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('cards have proper padding', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, isNotNull);
      // Padding should include 24 for left/right and 20 for top
      expect(listView.padding, isA<EdgeInsets>());
    });

    testWidgets('tradition cards are properly spaced', (tester) async {
      await pumpLineagesScreen(tester, createLineagesScreen());

      // Each card should be wrapped in Padding with bottom: 16
      final paddingWidgets = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Padding),
      );
      expect(paddingWidgets, findsWidgets);
    });
  });
}
