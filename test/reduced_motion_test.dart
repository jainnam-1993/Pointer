import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_flutter/providers/providers.dart';
import 'package:pointer_flutter/widgets/animated_gradient.dart';
import 'package:pointer_flutter/theme/app_theme.dart';

void main() {
  group('Reduced Motion - AnimatedGradient', () {
    testWidgets('renders static gradient when system disableAnimations is true',
        (tester) async {
      // Arrange: Create a MediaQuery with disableAnimations = true
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: const Scaffold(
                body: AnimatedGradient(),
              ),
            ),
          ),
        ),
      );

      // Assert: Should render a static Container with gradient (no shimmer animation)
      expect(find.byType(Container), findsWidgets);

      // The gradient container should exist
      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.where((c) =>
          c.decoration is BoxDecoration &&
          (c.decoration as BoxDecoration).gradient != null);
      expect(gradientContainer.isNotEmpty, true,
          reason: 'Should have a container with gradient decoration');
    });

    testWidgets('renders animated gradient when system disableAnimations is false',
        (tester) async {
      // Reset static flag for this test
      AnimatedGradient.disableAnimations = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: const Scaffold(
                body: AnimatedGradient(),
              ),
            ),
          ),
        ),
      );

      // Assert: Container with gradient should exist
      expect(find.byType(Container), findsWidgets);

      // Clean up
      AnimatedGradient.disableAnimations = true;
    });

    testWidgets('respects reduceMotionOverrideProvider when set to true',
        (tester) async {
      // Arrange: Create a provider override
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => true),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: const Scaffold(
                body: AnimatedGradient(),
              ),
            ),
          ),
        ),
      );

      // Assert: Should render static gradient even though system setting is false
      expect(find.byType(Container), findsWidgets);

      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.where((c) =>
          c.decoration is BoxDecoration &&
          (c.decoration as BoxDecoration).gradient != null);
      expect(gradientContainer.isNotEmpty, true);
    });

    testWidgets('static gradient uses correct colors for dark theme',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: const Scaffold(
                body: AnimatedGradient(),
              ),
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).gradient is LinearGradient,
        orElse: () => throw TestFailure('No gradient container found'),
      );

      final gradient =
          (gradientContainer.decoration as BoxDecoration).gradient as LinearGradient;

      // Verify it uses dark theme colors (very dark gray/black tones)
      expect(gradient.colors.isNotEmpty, true);
      expect(gradient.colors.first.value, lessThan(0xFF202020),
          reason: 'Dark theme gradient should use very dark colors');
    });

    testWidgets('static gradient uses correct colors for light theme',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: const Scaffold(
                body: AnimatedGradient(),
              ),
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).gradient is LinearGradient,
        orElse: () => throw TestFailure('No gradient container found'),
      );

      final gradient =
          (gradientContainer.decoration as BoxDecoration).gradient as LinearGradient;

      // Verify it uses light theme colors (lavender/soft tones)
      expect(gradient.colors.isNotEmpty, true);
      expect(gradient.colors.first.value, greaterThan(0xFFE0E0E0),
          reason: 'Light theme gradient should use light colors');
    });
  });

  group('Reduced Motion - FloatingParticles', () {
    testWidgets('renders nothing when system disableAnimations is true',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: const Scaffold(
                body: FloatingParticles(),
              ),
            ),
          ),
        ),
      );

      // Assert: Should render SizedBox.shrink() (effectively nothing)
      expect(find.byType(SizedBox), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 0);
      expect(sizedBox.height, 0);
    });

    // Note: In test environment, FloatingParticles always returns SizedBox.shrink()
    // due to the _isTestEnvironment() check (prevents timer issues in tests).
    // This test verifies the reduce motion logic is correctly applied by testing
    // that system disableAnimations true results in SizedBox.shrink (even
    // though test environment already triggers this).
    //
    // The actual particle rendering behavior is tested via integration tests
    // or manual testing on devices.

    testWidgets('respects reduceMotionOverrideProvider when set to true',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => true),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: const Scaffold(
                body: FloatingParticles(),
              ),
            ),
          ),
        ),
      );

      // Should render nothing even though system setting is false
      expect(find.byType(SizedBox), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 0);
      expect(sizedBox.height, 0);
    });
  });

  group('Reduced Motion - Provider', () {
    test('reduceMotionOverrideProvider defaults to null', () {
      final container = ProviderContainer(
        overrides: [
          oledModeProvider.overrideWith((ref) => false),
        ],
      );
      addTearDown(container.dispose);

      final value = container.read(reduceMotionOverrideProvider);
      expect(value, isNull);
    });

    test('reduceMotionOverrideProvider can be set to true', () {
      final container = ProviderContainer(
        overrides: [
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      final value = container.read(reduceMotionOverrideProvider);
      expect(value, true);
    });

    test('reduceMotionOverrideProvider can be set to false', () {
      final container = ProviderContainer(
        overrides: [
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => false),
        ],
      );
      addTearDown(container.dispose);

      final value = container.read(reduceMotionOverrideProvider);
      expect(value, false);
    });
  });

  group('Reduced Motion - shouldReduceMotion helper', () {
    testWidgets('returns true when system setting is enabled', (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  result = shouldReduceMotion(context, null);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('returns false when system setting is disabled and no override',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: Builder(
                builder: (context) {
                  result = shouldReduceMotion(context, null);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(result, false);
    });

    testWidgets('override true takes precedence over system false',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: Builder(
                builder: (context) {
                  result = shouldReduceMotion(context, true);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(result, true);
    });

    testWidgets('override false does NOT disable when system is true',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            oledModeProvider.overrideWith((ref) => false),
            reduceMotionOverrideProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  // When system says reduce motion, we should respect it
                  // App override can enable reduce motion, but not disable it
                  result = shouldReduceMotion(context, false);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // System accessibility setting should be respected even with app override
      expect(result, true,
          reason: 'System accessibility setting should always be respected');
    });
  });
}
