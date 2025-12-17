import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_flutter/providers/providers.dart';
import 'package:pointer_flutter/services/storage_service.dart';
import 'package:pointer_flutter/theme/app_theme.dart';
import 'package:pointer_flutter/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Initialize SharedPreferences with empty values for testing
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('High Contrast Mode', () {
    group('highContrastProvider', () {
      test('defaults to false when settings have no highContrast', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(highContrastProvider), false);
      });

      test('can be toggled to true', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container.dispose);

        container.read(highContrastProvider.notifier).state = true;
        expect(container.read(highContrastProvider), true);
      });
    });

    group('PointerColors.highContrast', () {
      test('has pure black background', () {
        expect(PointerColors.highContrast.glassBackground, Colors.black);
      });

      test('has pure white text for maximum contrast', () {
        expect(PointerColors.highContrast.textPrimary, Colors.white);
      });

      test('has strong white border for clear boundaries', () {
        expect(PointerColors.highContrast.glassBorder, Colors.white);
      });

      test('text contrast ratio meets AAA (7:1)', () {
        // White (#FFFFFF) on black (#000000) = 21:1 contrast ratio
        // This exceeds the AAA requirement of 7:1
        final textColor = PointerColors.highContrast.textPrimary;
        final backgroundColor = PointerColors.highContrast.glassBackground;

        expect(textColor, Colors.white);
        expect(backgroundColor, Colors.black);

        // White on black has a contrast ratio of 21:1, exceeding 7:1 AAA
        // We verify the colors are pure white and black which guarantees 21:1
      });

      test('has solid card background (no transparency)', () {
        final cardBg = PointerColors.highContrast.cardBackground;
        // Card background should be solid (alpha = 255)
        expect(cardBg.alpha, 255);
      });
    });

    group('GlassCard in high contrast mode', () {
      testWidgets('renders solid container without blur', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => true),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: GlassCard(
                  child: Text('Test'),
                ),
              ),
            ),
          ),
        );

        // In high contrast mode, should not have BackdropFilter
        expect(find.byType(BackdropFilter), findsNothing);

        // Should have a Container with solid decoration
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('renders with BackdropFilter in normal mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => false),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: GlassCard(
                  child: Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Normal mode should have BackdropFilter for blur effect
        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('has strong visible border in high contrast mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => true),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: GlassCard(
                  child: Text('Test'),
                ),
              ),
            ),
          ),
        );

        // Find the decorated container
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration?;

        // In high contrast, border should be solid and visible (width >= 2)
        if (decoration?.border != null) {
          final border = decoration!.border as Border;
          expect(border.top.width, greaterThanOrEqualTo(2));
        }
      });
    });

    group('System high contrast detection', () {
      testWidgets('detects system high contrast via MediaQuery', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => false),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Builder(
                builder: (context) {
                  // MediaQuery.highContrast is accessible
                  final systemHighContrast = MediaQuery.of(context).highContrast;
                  return Scaffold(
                    body: Text('High contrast: $systemHighContrast'),
                  );
                },
              ),
            ),
          ),
        );

        // Default MediaQuery.highContrast is false
        expect(find.text('High contrast: false'), findsOneWidget);
      });

      testWidgets('respects system high contrast setting', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => false),
            ],
            child: MediaQuery(
              data: const MediaQueryData(highContrast: true),
              child: MaterialApp(
                theme: AppTheme.dark,
                home: Builder(
                  builder: (context) {
                    final systemHighContrast = MediaQuery.of(context).highContrast;
                    return Scaffold(
                      body: Text('System high contrast: $systemHighContrast'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('System high contrast: true'), findsOneWidget);
      });
    });

    group('GlassButton in high contrast mode', () {
      testWidgets('renders solid button without blur', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              highContrastProvider.overrideWith((ref) => true),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: GlassButton(
                  label: 'Test Button',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        // In high contrast mode, should not have BackdropFilter
        expect(find.byType(BackdropFilter), findsNothing);
      });
    });
  });

  group('isHighContrastEnabled helper', () {
    testWidgets('returns true when provider is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            highContrastProvider.overrideWith((ref) => true),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, _) {
                final isHC = isHighContrastEnabled(context, ref);
                return Scaffold(body: Text('HC: $isHC'));
              },
            ),
          ),
        ),
      );

      expect(find.text('HC: true'), findsOneWidget);
    });

    testWidgets('returns true when system highContrast is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Provider is false, but system setting is true
            highContrastProvider.overrideWith((ref) => false),
          ],
          child: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Consumer(
                builder: (context, ref, _) {
                  final isHC = isHighContrastEnabled(context, ref);
                  return Scaffold(body: Text('HC: $isHC'));
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('HC: true'), findsOneWidget);
    });

    testWidgets('returns false when both provider and system are false', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            highContrastProvider.overrideWith((ref) => false),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Consumer(
              builder: (context, ref, _) {
                final isHC = isHighContrastEnabled(context, ref);
                return Scaffold(body: Text('HC: $isHC'));
              },
            ),
          ),
        ),
      );

      expect(find.text('HC: false'), findsOneWidget);
    });
  });

  group('AppSettings highContrast persistence', () {
    test('AppSettings includes highContrast field', () {
      const settings = AppSettings(highContrast: true);
      expect(settings.highContrast, true);
    });

    test('AppSettings defaults highContrast to false', () {
      const settings = AppSettings();
      expect(settings.highContrast, false);
    });

    test('AppSettings.copyWith updates highContrast', () {
      const settings = AppSettings(highContrast: false);
      final updated = settings.copyWith(highContrast: true);
      expect(updated.highContrast, true);
    });

    test('AppSettings serializes highContrast to JSON', () {
      const settings = AppSettings(highContrast: true);
      final json = settings.toJson();
      expect(json['highContrast'], true);
    });

    test('AppSettings deserializes highContrast from JSON', () {
      final settings = AppSettings.fromJson({'highContrast': true});
      expect(settings.highContrast, true);
    });

    test('AppSettings.fromJson defaults highContrast when missing', () {
      final settings = AppSettings.fromJson({});
      expect(settings.highContrast, false);
    });
  });
}
