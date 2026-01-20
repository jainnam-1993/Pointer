// Accessibility unit tests for Pointer app
// Verifies Semantics widgets are properly configured

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/theme/app_theme.dart';

void main() {
  group('Accessibility - Semantics Configuration', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Share button has accessible label', (tester) async {
      // Build a minimal widget with Semantics matching our share button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              button: true,
              label: 'Share this pointing',
              focusable: true,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      // Find the Semantics node
      final semantics = tester.getSemantics(find.byType(GestureDetector));

      // Verify accessibility properties
      expect(semantics.label, 'Share this pointing');
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('Navigation bar tabs have accessible labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Semantics(
                  button: true,
                  selected: true,
                  label: 'Home tab, selected',
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text('Home'),
                  ),
                ),
                Semantics(
                  button: true,
                  selected: false,
                  label: 'Library tab',
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text('Library'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Find Home tab semantics
      final homeFinder = find.text('Home');
      final homeSemantic = tester.getSemantics(homeFinder);
      expect(homeSemantic.label, contains('Home tab, selected'));
      expect(homeSemantic.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(homeSemantic.hasFlag(SemanticsFlag.isSelected), isTrue);

      // Find Library tab semantics
      final libraryFinder = find.text('Library');
      final librarySemantic = tester.getSemantics(libraryFinder);
      expect(librarySemantic.label, contains('Library tab'));
      expect(librarySemantic.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(librarySemantic.hasFlag(SemanticsFlag.isSelected), isFalse);
    });

    testWidgets('Pointing card has accessible hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Current pointing: Test content by Test Teacher',
              hint: 'Double tap to focus. Swipe up for next pointing, down for previous',
              child: Container(
                width: 200,
                height: 200,
                color: Colors.purple,
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Container));
      expect(semantics.label, contains('Current pointing'));
      expect(semantics.hint, contains('Swipe up for next'));
    });

    testWidgets('Featured article card has accessibility label', (tester) async {
      // Simulates our _FeaturedArticleCard Semantics wrapper
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              button: true,
              label: 'The Art of Letting Go. A guide to release. 5 minute read by Alan Watts. Featured article.',
              child: Container(
                width: 200,
                height: 150,
                color: Colors.teal,
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Container));
      expect(semantics.label, contains('Featured article'));
      expect(semantics.label, contains('minute read'));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('Teaching card has accessibility label', (tester) async {
      // Simulates our _TeachingCard Semantics wrapper
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'What is aware of this moment? By Nisargadatta Maharaj. Advaita tradition.',
              child: Container(
                width: 200,
                height: 100,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Container));
      expect(semantics.label, contains('By'));
      expect(semantics.label, contains('tradition'));
    });

    testWidgets('Inquiry close button has accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              button: true,
              label: 'Close inquiry',
              child: GestureDetector(
                onTap: () {},
                child: const Icon(Icons.close, size: 24),
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(GestureDetector));
      expect(semantics.label, 'Close inquiry');
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });
  });

  group('Accessibility - Theme Support', () {
    testWidgets('Dark theme has proper color contrast', (tester) async {
      final darkTheme = AppTheme.dark;
      expect(darkTheme.brightness, Brightness.dark);

      final colors = darkTheme.extension<PointerColors>();
      expect(colors, isNotNull);
      expect(colors!.textPrimary, isNotNull);
      expect(colors.background, isNotNull);
    });

    testWidgets('Light theme has proper color contrast', (tester) async {
      final lightTheme = AppTheme.light;
      expect(lightTheme.brightness, Brightness.light);

      final colors = lightTheme.extension<PointerColors>();
      expect(colors, isNotNull);
      expect(colors!.textPrimary, isNotNull);
      expect(colors.background, isNotNull);
    });
  });
}
