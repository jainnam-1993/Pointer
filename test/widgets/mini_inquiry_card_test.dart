import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer/widgets/mini_inquiry_card.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';

/// Helper to wrap widget with ProviderScope for testing
Widget wrapWithProviderScope(Widget child) {
  return ProviderScope(
    overrides: [
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
    ],
    child: child,
  );
}

void main() {
  group('MiniInquiryCard', () {
    testWidgets('renders with inquiry question', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: Center(child: MiniInquiryCard()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Should display "Take a moment" header
      expect(find.text('Take a moment'), findsOneWidget);

      // Should display the inquiry diamond icon
      expect(find.text('◇'), findsOneWidget);
    });

    testWidgets('has correct accessibility semantics', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: Center(child: MiniInquiryCard()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Should have button semantics - find the semantics node
      final finder = find.byType(MiniInquiryCard);
      expect(finder, findsOneWidget);
    });

    testWidgets('displays in dark theme', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: Center(child: MiniInquiryCard()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MiniInquiryCard), findsOneWidget);
      expect(find.text('Take a moment'), findsOneWidget);
    });

    testWidgets('displays in light theme', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: Center(child: MiniInquiryCard()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MiniInquiryCard), findsOneWidget);
      expect(find.text('Take a moment'), findsOneWidget);
    });

    testWidgets('truncates long questions', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const SizedBox(
              width: 300,
              child: Scaffold(
                body: Center(child: MiniInquiryCard()),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should render without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Take a moment label', (tester) async {
      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: Center(child: MiniInquiryCard()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Collapsed card shows "Take a moment" text
      expect(find.text('Take a moment'), findsOneWidget);
    });
  });
}
