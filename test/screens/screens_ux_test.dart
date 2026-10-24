import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/screens/article_reader_screen.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/empty_state.dart';

void main() {
  group('stripLeadingTitle (design 22: title shown once)', () {
    test('drops a leading H1 that repeats the title, ignoring case and punctuation', () {
      expect(stripLeadingTitle('# I Am That!\n\nBody text.', 'I am that'), 'Body text.');
    });

    test('keeps a leading H1 that differs from the title', () {
      const content = '# Chapter One\n\nBody.';
      expect(stripLeadingTitle(content, 'I Am That'), content);
    });

    test('keeps content without a leading H1', () {
      const content = 'Intro paragraph.\n\n# I Am That';
      expect(stripLeadingTitle(content, 'I Am That'), content);
    });
  });

  group('EmptyStateWidget (design 21)', () {
    testWidgets('shows the in-voice line and a working call to action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: EmptyStateWidget(title: 'Nothing saved yet.', actionLabel: 'Back to today', onAction: () => tapped = true),
          ),
        ),
      );
      expect(find.text('Nothing saved yet.'), findsOneWidget);
      await tester.tap(find.text('Back to today'));
      expect(tapped, isTrue);
      final button = tester.getSize(find.byType(TextButton));
      expect(button.height, greaterThanOrEqualTo(48));
    });

    testWidgets('omits the action without a callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: EmptyStateWidget(title: 'No teachers here yet.', actionLabel: 'Back'),
          ),
        ),
      );
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
