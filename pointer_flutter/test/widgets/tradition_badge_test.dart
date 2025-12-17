import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_flutter/widgets/tradition_badge.dart';
import 'package:pointer_flutter/data/pointings.dart';
import 'package:pointer_flutter/theme/app_theme.dart';

void main() {
  group('TraditionBadge', () {
    testWidgets('renders Advaita tradition correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.advaita),
          ),
        ),
      );

      expect(find.text('Advaita Vedanta'), findsOneWidget);
      expect(find.text(traditions[Tradition.advaita]!.icon), findsOneWidget);
    });

    testWidgets('renders Zen tradition correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.zen),
          ),
        ),
      );

      expect(find.text('Zen Buddhism'), findsOneWidget);
      expect(find.text(traditions[Tradition.zen]!.icon), findsOneWidget);
    });

    testWidgets('renders Direct Path tradition correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.direct),
          ),
        ),
      );

      expect(find.text('Direct Path'), findsOneWidget);
      expect(find.text(traditions[Tradition.direct]!.icon), findsOneWidget);
    });

    testWidgets('renders Contemporary tradition correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.contemporary),
          ),
        ),
      );

      expect(find.text('Contemporary'), findsOneWidget);
      expect(find.text(traditions[Tradition.contemporary]!.icon), findsOneWidget);
    });

    testWidgets('renders Original tradition correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.original),
          ),
        ),
      );

      expect(find.text('Original'), findsOneWidget);
      expect(find.text(traditions[Tradition.original]!.icon), findsOneWidget);
    });

    testWidgets('uses pill shape (high borderRadius)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.advaita),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(999));
    });

    testWidgets('has glass background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: TraditionBadge(tradition: Tradition.zen),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TraditionBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      // Check that background color is set (uses theme-aware color)
      expect(decoration.color, isNotNull);
    });

    testWidgets('has glass border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: TraditionBadge(tradition: Tradition.direct),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TraditionBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, 1);
    });

    testWidgets('has BackdropFilter for blur effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.contemporary),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(TraditionBadge),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.original),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TraditionBadge),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });

    testWidgets('uses Row for icon and text layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.advaita),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(TraditionBadge),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
    });

    testWidgets('icon has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.zen),
          ),
        ),
      );

      final iconText = tester.widget<Text>(
        find.text(traditions[Tradition.zen]!.icon),
      );
      expect(iconText.style?.fontSize, 18);
    });

    testWidgets('name text has correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.direct),
          ),
        ),
      );

      final nameText = tester.widget<Text>(
        find.text('Direct Path'),
      );
      expect(nameText.style?.fontSize, 14);
      expect(nameText.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('renders all traditions without errors', (tester) async {
      for (final tradition in Tradition.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TraditionBadge(tradition: tradition),
            ),
          ),
        );

        final info = traditions[tradition]!;
        expect(find.text(info.name), findsOneWidget);
        expect(find.text(info.icon), findsOneWidget);

        // Reset for next iteration
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('has mainAxisSize.min for minimal width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TraditionBadge(tradition: Tradition.advaita),
          ),
        ),
      );

      final row = tester.widget<Row>(
        find.descendant(
          of: find.byType(TraditionBadge),
          matching: find.byType(Row),
        ),
      );
      expect(row.mainAxisSize, MainAxisSize.min);
    });
  });

  group('TraditionInfo data', () {
    test('all traditions have TraditionInfo', () {
      for (final tradition in Tradition.values) {
        expect(traditions.containsKey(tradition), true);
        final info = traditions[tradition]!;
        expect(info.name, isNotEmpty);
        expect(info.icon, isNotEmpty);
        expect(info.description, isNotEmpty);
      }
    });

    test('tradition names are unique', () {
      final names = traditions.values.map((t) => t.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('tradition icons are unique', () {
      final icons = traditions.values.map((t) => t.icon).toList();
      expect(icons.toSet().length, icons.length);
    });

    test('Advaita has correct info', () {
      final info = traditions[Tradition.advaita]!;
      expect(info.name, 'Advaita Vedanta');
      expect(info.icon, isNotEmpty);
    });

    test('Zen has correct info', () {
      final info = traditions[Tradition.zen]!;
      expect(info.name, 'Zen Buddhism');
      expect(info.icon, isNotEmpty);
    });

    test('Direct Path has correct info', () {
      final info = traditions[Tradition.direct]!;
      expect(info.name, 'Direct Path');
      expect(info.icon, isNotEmpty);
    });

    test('Contemporary has correct info', () {
      final info = traditions[Tradition.contemporary]!;
      expect(info.name, 'Contemporary');
      expect(info.icon, isNotEmpty);
    });

    test('Original has correct info', () {
      final info = traditions[Tradition.original]!;
      expect(info.name, 'Original');
      expect(info.icon, isNotEmpty);
    });
  });
}
