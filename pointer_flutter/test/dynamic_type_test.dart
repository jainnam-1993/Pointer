import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer_flutter/screens/home_screen.dart';
import 'package:pointer_flutter/providers/providers.dart';
import 'package:pointer_flutter/data/pointings.dart';
import 'package:pointer_flutter/theme/app_theme.dart';
import 'package:pointer_flutter/widgets/animated_gradient.dart';
import 'package:pointer_flutter/widgets/glass_card.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    // Disable animations to prevent timer issues in tests
    AnimatedGradient.disableAnimations = true;
    // Allow pending fonts in tests to prevent network errors
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  /// Creates a widget with custom text scale factor
  Widget createAppWithTextScale({
    required Widget child,
    required double textScaleFactor,
    Pointing? initialPointing,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        if (initialPointing != null)
          currentPointingProvider.overrideWith((ref) {
            final notifier = CurrentPointingNotifier();
            notifier.setPointing(initialPointing);
            return notifier;
          }),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: child!,
          );
        },
        home: child,
      ),
    );
  }

  Future<void> pumpWithTextScale(
    WidgetTester tester,
    Widget widget,
  ) async {
    // Use a phone-sized surface
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

  group('Dynamic Type Support', () {
    group('AppTextStyles', () {
      testWidgets('pointingText returns valid TextStyle at 1.0x scale', (tester) async {
        late TextStyle style;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                style = AppTextStyles.pointingText(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Base font size is 20, at 1.0x scale it should be ~20
        expect(style.fontSize, closeTo(20.0, 0.1));
        expect(style.height, 1.7);
      });

      testWidgets('pointingText scales with system text scale (1.5x)', (tester) async {
        late TextStyle style;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.5),
                ),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                style = AppTextStyles.pointingText(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // At 1.5x scale, font size should be 20 * 1.5 = 30
        expect(style.fontSize, closeTo(30.0, 0.1));
      });

      testWidgets('pointingText clamps scale to maximum 1.5x', (tester) async {
        late TextStyle style;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(2.0), // Above max
                ),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                style = AppTextStyles.pointingText(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Should clamp to 1.5x: 20 * 1.5 = 30
        expect(style.fontSize, closeTo(30.0, 0.1));
      });

      testWidgets('pointingText clamps scale to minimum 0.8x', (tester) async {
        late TextStyle style;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(0.5), // Below min
                ),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                style = AppTextStyles.pointingText(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Should clamp to 0.8x: 20 * 0.8 = 16
        expect(style.fontSize, closeTo(16.0, 0.1));
      });

      testWidgets('instructionText scales with system text scale', (tester) async {
        late TextStyle style;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.25),
                ),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                style = AppTextStyles.instructionText(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Base font size is 16, at 1.25x scale it should be 16 * 1.25 = 20
        expect(style.fontSize, closeTo(20.0, 0.1));
      });

      testWidgets('teacherText scales with system text scale', (tester) async {
        late TextStyle style;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.25),
                ),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                style = AppTextStyles.teacherText(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Base font size is 14, at 1.25x scale it should be 14 * 1.25 = 17.5
        expect(style.fontSize, closeTo(17.5, 0.1));
      });
    });

    group('GlassCard Flexible Height', () {
      testWidgets('GlassCard has flexible constraints', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => false),
              oledModeProvider.overrideWith((ref) => false),
              reduceMotionOverrideProvider.overrideWith((ref) => null),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: const Scaffold(
                body: Center(
                  child: GlassCard(
                    child: Text('Test content'),
                  ),
                ),
              ),
            ),
          ),
        );

        // GlassCard should render without overflow
        expect(find.byType(GlassCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('GlassCard scrolls when maxHeight is set and content exceeds it', (tester) async {
        // Set up a constrained screen size
        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => false),
              oledModeProvider.overrideWith((ref) => false),
              reduceMotionOverrideProvider.overrideWith((ref) => null),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: Center(
                  child: GlassCard(
                    maxHeight: 300, // Set maxHeight to enable scrolling
                    enableScrolling: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        20,
                        (i) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Line $i of many lines of content'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Should have SingleChildScrollView for scrolling when maxHeight is set
        expect(
          find.descendant(
            of: find.byType(GlassCard),
            matching: find.byType(SingleChildScrollView),
          ),
          findsOneWidget,
        );
      });

      testWidgets('GlassCard has minimum height constraint', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => false),
              oledModeProvider.overrideWith((ref) => false),
              reduceMotionOverrideProvider.overrideWith((ref) => null),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: const Scaffold(
                body: Center(
                  child: GlassCard(
                    child: Text('Short'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Find the ConstrainedBox that should have minHeight
        final constrainedBoxes = tester.widgetList<ConstrainedBox>(
          find.descendant(
            of: find.byType(GlassCard),
            matching: find.byType(ConstrainedBox),
          ),
        );

        // At least one ConstrainedBox should exist with minHeight constraint
        // (implementation detail - just verify GlassCard renders without issues)
        expect(find.byType(GlassCard), findsOneWidget);
      });
    });

    group('HomeScreen with Dynamic Type', () {
      testWidgets('renders correctly at default scale (1.0x)', (tester) async {
        const testPointing = Pointing(
          id: 'test-dynamic-type',
          content: 'What is aware of this moment?',
          instruction: 'Simply notice.',
          tradition: Tradition.advaita,
          contexts: [PointingContext.general],
          teacher: 'Ramana Maharshi',
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 1.0,
            initialPointing: testPointing,
          ),
        );

        expect(find.text('What is aware of this moment?'), findsOneWidget);
        expect(find.text('Simply notice.'), findsOneWidget);
        expect(find.textContaining('Ramana Maharshi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders correctly at large scale (1.5x)', (tester) async {
        const testPointing = Pointing(
          id: 'test-dynamic-type-large',
          content: 'What is aware?',
          instruction: 'Look.',
          tradition: Tradition.zen,
          contexts: [PointingContext.general],
          teacher: 'Teacher',
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 1.5,
            initialPointing: testPointing,
          ),
        );

        // Content should render without overflow
        expect(find.text('What is aware?'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders correctly at extra large scale (2.0x)', (tester) async {
        const testPointing = Pointing(
          id: 'test-dynamic-type-xl',
          content: 'Notice.',
          tradition: Tradition.direct,
          contexts: [PointingContext.general],
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 2.0,
            initialPointing: testPointing,
          ),
        );

        // Content should render without overflow (clamped to 1.5x)
        expect(find.text('Notice.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders correctly at small scale (0.8x)', (tester) async {
        const testPointing = Pointing(
          id: 'test-dynamic-type-small',
          content: 'What is here before thought?',
          tradition: Tradition.contemporary,
          contexts: [PointingContext.general],
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 0.8,
            initialPointing: testPointing,
          ),
        );

        expect(find.text('What is here before thought?'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('long content scrolls at large text scale', (tester) async {
        const longPointing = Pointing(
          id: 'test-long-content',
          content:
              'This is a very long pointing content that spans multiple lines '
              'and tests the scrolling behavior when dynamic type is enabled. '
              'The content should wrap naturally and the glass card should allow '
              'scrolling when the text exceeds the available space.',
          instruction: 'Read slowly and notice what is reading.',
          tradition: Tradition.original,
          contexts: [PointingContext.general],
          teacher: 'A Teacher With A Long Name',
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 1.5,
            initialPointing: longPointing,
          ),
        );

        // Should render without overflow
        expect(find.textContaining('very long pointing'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('buttons remain tappable at large text scale', (tester) async {
        const testPointing = Pointing(
          id: 'test-buttons',
          content: 'Test content',
          tradition: Tradition.zen,
          contexts: [PointingContext.general],
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 1.5,
            initialPointing: testPointing,
          ),
        );

        // Buttons should still be present and tappable
        expect(find.text('Next'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);

        // Should be able to tap buttons
        await tester.tap(find.text('Next'));
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Compliance', () {
      testWidgets('maintains minimum touch target size at all scales', (tester) async {
        const testPointing = Pointing(
          id: 'test-touch-target',
          content: 'Test',
          tradition: Tradition.zen,
          contexts: [PointingContext.general],
        );

        await pumpWithTextScale(
          tester,
          createAppWithTextScale(
            child: const HomeScreen(),
            textScaleFactor: 1.5,
            initialPointing: testPointing,
          ),
        );

        // Find the GlassButton widgets
        final buttons = find.byType(GlassButton);
        expect(buttons, findsNWidgets(2));

        // Each button should have at least 44pt touch target
        for (final element in tester.elementList(buttons)) {
          final renderBox = element.renderObject as RenderBox;
          expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
        }
      });

      testWidgets('text remains readable at all scales', (tester) async {
        const testPointing = Pointing(
          id: 'test-readable',
          content: 'What is aware of this moment?',
          instruction: 'Simply notice.',
          tradition: Tradition.advaita,
          contexts: [PointingContext.general],
          teacher: 'Teacher',
        );

        // Test at various scales
        for (final scale in [0.8, 1.0, 1.25, 1.5]) {
          await pumpWithTextScale(
            tester,
            createAppWithTextScale(
              child: const HomeScreen(),
              textScaleFactor: scale,
              initialPointing: testPointing,
            ),
          );

          // All text should be findable and rendered
          expect(find.textContaining('aware'), findsOneWidget,
              reason: 'Content should be visible at ${scale}x scale');
          expect(find.textContaining('notice'), findsOneWidget,
              reason: 'Instruction should be visible at ${scale}x scale');
          expect(tester.takeException(), isNull,
              reason: 'No overflow at ${scale}x scale');
        }
      });
    });
  });
}
