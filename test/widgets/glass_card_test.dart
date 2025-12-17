import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';

/// Helper to wrap widget with ProviderScope for high contrast tests
Widget wrapWithProviderScope(Widget child, {bool highContrast = false}) {
  return ProviderScope(
    overrides: [
      highContrastProvider.overrideWith((ref) => highContrast),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
    ],
    child: child,
  );
}

void main() {
  group('GlassCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            highContrastProvider.overrideWith((ref) => false),
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GlassCard(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies default padding', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        )),
      );

      // Find the container with padding (the innermost one)
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      );

      final containerWithPadding = containers.firstWhere(
        (c) => c.padding != null,
      );
      expect(containerWithPadding.padding, const EdgeInsets.all(24));
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: EdgeInsets.all(16),
              child: Text('Test'),
            ),
          ),
        )),
      );

      // Find the container with padding (the innermost one)
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      );

      final containerWithPadding = containers.firstWhere(
        (c) => c.padding != null,
      );
      expect(containerWithPadding.padding, const EdgeInsets.all(16));
    });

    testWidgets('uses ClipRRect with default borderRadius', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        )),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('uses ClipRRect with custom borderRadius', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              borderRadius: 16,
              child: Text('Test'),
            ),
          ),
        )),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('applies BackdropFilter with blur', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              intensity: GlassIntensity.heavy,
              child: Text('Test'),
            ),
          ),
        )),
      );

      final backdropFilter = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );
      // BackdropFilter uses ImageFilter
      expect(backdropFilter.filter, isNotNull);
    });

    testWidgets('has glass gradient in decoration', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        )),
      );

      // Find all containers within GlassCard and check if any has gradient
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      );

      final containerWithGradient = containers.firstWhere(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).gradient != null,
      );
      expect((containerWithGradient.decoration as BoxDecoration).gradient, isA<LinearGradient>());
    });

    testWidgets('has gradient border', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        )),
      );

      // Find all containers within GlassCard and check if any has GradientBoxBorder
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      );

      final containerWithBorder = containers.firstWhere(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).border is GradientBoxBorder,
      );
      expect(containerWithBorder.decoration, isA<BoxDecoration>());
      expect((containerWithBorder.decoration as BoxDecoration).border, isA<GradientBoxBorder>());
    });

    testWidgets('wraps in GestureDetector when onTap provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapped = true,
              child: const Text('Test'),
            ),
          ),
        )),
      );

      expect(find.byType(GestureDetector), findsOneWidget);

      await tester.tap(find.byType(GlassCard));
      expect(tapped, true);
    });

    testWidgets('does not wrap in GestureDetector without onTap', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test'),
            ),
          ),
        )),
      );

      // GlassCard itself is not a GestureDetector
      // Check there are no GestureDetectors that are ancestors of our content
      expect(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('renders complex child content', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Title'),
                  SizedBox(height: 8),
                  Text('Subtitle'),
                  Icon(Icons.star),
                ],
              ),
            ),
          ),
        )),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('GlassButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        )),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        )),
      );

      await tester.tap(find.byType(GlassButton));
      expect(pressed, true);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        )),
      );

      await tester.tap(find.byType(GlassButton));
      expect(pressed, false);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        )),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
        )),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('hides icon when loading', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              isLoading: true,
            ),
          ),
        )),
      );

      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('uses InkWell for tap effect', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        )),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('uses correct border radius for pill shape', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        )),
      );

      final clipRRect = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(GlassButton),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clipRRect.borderRadius, BorderRadius.circular(32));
    });

    testWidgets('has BackdropFilter for glass effect', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        )),
      );

      expect(
        find.descendant(
          of: find.byType(GlassButton),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has gradient border for glass effect', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: GlassButton(
              label: 'Primary',
              onPressed: () {},
              isPrimary: true,
            ),
          ),
        )),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassButton),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isA<GradientBoxBorder>());
    });
  });

  group('GradientBoxBorder', () {
    test('creates border with gradient', () {
      const border = GradientBoxBorder(
        gradient: LinearGradient(colors: [Colors.white, Colors.black]),
        width: 2.0,
      );
      expect(border.gradient, isA<LinearGradient>());
      expect(border.width, 2.0);
    });

    test('has correct dimensions', () {
      const border = GradientBoxBorder(
        gradient: LinearGradient(colors: [Colors.white, Colors.black]),
        width: 3.0,
      );
      expect(border.dimensions, const EdgeInsets.all(3.0));
    });

    test('is uniform', () {
      const border = GradientBoxBorder(
        gradient: LinearGradient(colors: [Colors.white, Colors.black]),
      );
      expect(border.isUniform, true);
    });

    test('scales correctly', () {
      const border = GradientBoxBorder(
        gradient: LinearGradient(colors: [Colors.white, Colors.black]),
        width: 2.0,
      );
      final scaled = border.scale(0.5) as GradientBoxBorder;
      expect(scaled.width, 1.0);
    });
  });
}
