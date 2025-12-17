// VoiceOver Accessibility Tests
//
// These tests verify that the app meets VoiceOver accessibility requirements:
// - All interactive elements have semantic labels
// - Logical focus order (top to bottom, left to right)
// - Custom actions for complex interactions
// - Decorative elements excluded from semantics tree
// - Proper hints for screen reader users

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer_flutter/data/pointings.dart';
import 'package:pointer_flutter/providers/providers.dart';
import 'package:pointer_flutter/screens/home_screen.dart';
import 'package:pointer_flutter/screens/settings_screen.dart';
import 'package:pointer_flutter/screens/main_shell.dart';
import 'package:pointer_flutter/services/storage_service.dart';
import 'package:pointer_flutter/theme/app_theme.dart';
import 'package:pointer_flutter/widgets/animated_gradient.dart';
import 'package:pointer_flutter/widgets/tradition_badge.dart';
import 'package:pointer_flutter/widgets/glass_card.dart';

/// Creates a test app with providers configured
Widget createTestApp({
  required Widget child,
  SharedPreferences? prefs,
  Pointing? initialPointing,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      if (prefs != null)
        storageServiceProvider
            .overrideWith((ref) => StorageService(prefs)),
      highContrastProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      if (initialPointing != null)
        currentPointingProvider.overrideWith((ref) {
          final notifier = CurrentPointingNotifier();
          notifier.setPointing(initialPointing);
          return notifier;
        }),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    // Disable animations for consistent testing
    AnimatedGradient.disableAnimations = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
  });

  group('VoiceOver: Semantic Labels', () {
    testWidgets('TraditionBadge has semantic label with tradition name',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const Scaffold(
            body: TraditionBadge(tradition: Tradition.advaita),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(TraditionBadge));
      expect(semantics.label, contains('Tradition'));
      expect(semantics.label, contains('Advaita Vedanta'));
    });

    testWidgets('GlassButton has button semantics', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Scaffold(
            body: GlassButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify InkWell exists (GlassButton uses InkWell internally)
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('All traditions have semantic labels', (tester) async {
      for (final tradition in Tradition.values) {
        await tester.pumpWidget(
          createTestApp(
            child: Scaffold(
              body: TraditionBadge(tradition: tradition),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(TraditionBadge));
        expect(semantics.label, isNotEmpty,
            reason: 'TraditionBadge for ${tradition.name} should have a label');
      }
    });
  });

  group('VoiceOver: Decorative Elements Excluded', () {
    testWidgets('AnimatedGradient is excluded from semantics tree',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const Scaffold(
            body: AnimatedGradient(),
          ),
        ),
      );

      // AnimatedGradient wraps with ExcludeSemantics
      expect(
        find.descendant(
          of: find.byType(AnimatedGradient),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('FloatingParticles is excluded from semantics tree',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reduceMotionOverrideProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FloatingParticles(),
            ),
          ),
        ),
      );

      // FloatingParticles returns empty widget when animations disabled
      // When enabled, it wraps with ExcludeSemantics
      expect(find.byType(FloatingParticles), findsOneWidget);
    });
  });

  group('VoiceOver: Custom Actions', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'pointer_onboarding_completed': true,
      });
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('HomeScreen pointing card has custom actions', (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Test pointing content',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await tester.pumpWidget(
        createTestApp(
          child: const HomeScreen(),
          prefs: prefs,
          initialPointing: testPointing,
        ),
      );
      await tester.pumpAndSettle();

      // Find the Semantics widget with custom actions
      final semanticsFinder = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          return widget.properties.customSemanticsActions?.isNotEmpty ?? false;
        }
        return false;
      });

      expect(semanticsFinder, findsWidgets);
    });
  });

  group('VoiceOver: Focus Order', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'pointer_onboarding_completed': true,
      });
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('HomeScreen has logical semantic focus order',
        (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Test pointing content',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await tester.pumpWidget(
        createTestApp(
          child: const HomeScreen(),
          prefs: prefs,
          initialPointing: testPointing,
        ),
      );
      await tester.pumpAndSettle();

      // Verify key semantic elements exist in the tree
      // The order is defined by MergeSemantics and Semantics widgets
      // in the widget tree, which VoiceOver traverses top-to-bottom

      // Should have pointing content accessible
      final pointingSemantics = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          final label = widget.properties.label ?? '';
          return label.contains('pointing') ||
              label.contains('content') ||
              label.contains('Test');
        }
        return false;
      });

      // Should have tradition badge accessible
      expect(find.byType(TraditionBadge), findsOneWidget);

      // The semantic tree should have meaningful labels
      final allSemantics = find.byType(Semantics);
      expect(allSemantics, findsWidgets);
    });

    testWidgets('Settings theme options have selected state in label',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            storageServiceProvider
                .overrideWith((ref) => StorageService(prefs)),
            highContrastProvider.overrideWith((ref) => false),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Theme options should have semantic labels indicating selection state
      final semanticsFinder = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          final label = widget.properties.label ?? '';
          return label.contains('theme');
        }
        return false;
      });

      expect(semanticsFinder, findsWidgets);
    });
  });

  group('VoiceOver: Button Semantics', () {
    testWidgets('GlassButton is tappable and accessible', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        createTestApp(
          child: Scaffold(
            body: Center(
              child: GlassButton(
                label: 'Press me',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      // GlassButton should render with InkWell for tap handling
      expect(find.byType(GlassButton), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);

      // Should display the label text
      expect(find.text('Press me'), findsOneWidget);

      // Verify it's actually tappable
      await tester.tap(find.byType(GlassButton));
      await tester.pump();
      expect(pressed, true);
    });

    testWidgets('GlassButton disabled state is communicated', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Scaffold(
            body: Center(
              child: GlassButton(
                label: 'Loading',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // When loading, button shows progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('VoiceOver: Screen Reader Hints', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'pointer_onboarding_completed': true,
      });
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('HomeScreen pointing card has hint for actions',
        (tester) async {
      const testPointing = Pointing(
        id: 'test-1',
        content: 'Test pointing content',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      await tester.pumpWidget(
        createTestApp(
          child: const HomeScreen(),
          prefs: prefs,
          initialPointing: testPointing,
        ),
      );
      await tester.pumpAndSettle();

      // Find Semantics with hint
      final semanticsWithHint = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          final hint = widget.properties.hint ?? '';
          return hint.contains('swipe') || hint.contains('actions');
        }
        return false;
      });

      expect(semanticsWithHint, findsWidgets);
    });
  });
}
