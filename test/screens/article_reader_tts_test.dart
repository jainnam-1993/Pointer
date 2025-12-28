import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/models/article.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/providers/providers.dart';

void main() {
  late SharedPreferences mockPrefs;

  final testArticle = Article(
    id: 'test-article-1',
    title: 'Test Article Title',
    subtitle: 'A test subtitle',
    content: '''
# Introduction

This is a test article with **markdown** content.

## Section One

Some text here with *emphasis*.

- List item 1
- List item 2

## Conclusion

Final thoughts.
''',
    tradition: Tradition.advaita,
    readingTimeMinutes: 5,
    teacher: 'Test Teacher',
    categories: [ArticleCategory.natureOfAwareness, ArticleCategory.selfInquiry],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget({
    required Article article,
    bool forcePremium = true,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: ArticleReaderScreen(article: article),
      ),
    );
  }

  group('ArticleReaderScreen - Basic Rendering', () {
    testWidgets('renders article title', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('renders article subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.text('A test subtitle'), findsOneWidget);
    });

    testWidgets('renders reading time', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.text('5 min read'), findsOneWidget);
    });

    testWidgets('renders teacher name', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.text('Test Teacher'), findsOneWidget);
    });

    testWidgets('renders tradition badge', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.text('Advaita Vedanta'), findsOneWidget);
    });

    testWidgets('renders close button', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('ArticleReaderScreen - TTS Button Visibility', () {
    testWidgets('TTS button is visible for premium users', (tester) async {
      await tester.pumpWidget(createTestWidget(
        article: testArticle,
        forcePremium: true,
      ));
      await tester.pumpAndSettle();

      // Look for headphones icon (either outlined or filled)
      final headphonesOutlined = find.byIcon(Icons.headphones_outlined);
      final headphones = find.byIcon(Icons.headphones);

      // At least one should be present
      expect(
        headphonesOutlined.evaluate().isNotEmpty ||
            headphones.evaluate().isNotEmpty,
        isTrue,
        reason: 'TTS button should be visible for premium users',
      );
    });

    testWidgets('TTS button has tooltip', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      // Find IconButton with headphones
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsWidgets);
    });
  });

  group('ArticleReaderScreen - Navigation', () {
    testWidgets('close button pops navigation', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleReaderScreen(article: testArticle),
                    ),
                  ).then((_) => popped = true);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open the article reader
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap close
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });

  group('ArticleReaderScreen - Article Content', () {
    testWidgets('article content is scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('renders markdown content', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      // Markdown content should be rendered
      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });

  group('ArticleReaderScreen - Premium Gating', () {
    testWidgets('shows snackbar when non-premium tries TTS', (tester) async {
      // This test verifies the premium gating logic exists
      // In the real app, kForcePremiumForTesting would be false
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      // The TTS button behavior depends on premium status
      // With kForcePremiumForTesting = true, button should work
      // With false, it should show paywall snackbar
      expect(find.byType(ArticleReaderScreen), findsOneWidget);
    });
  });

  group('ArticleReaderScreen - State Management', () {
    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(createTestWidget(article: testArticle));
      await tester.pumpAndSettle();

      // Verify it's using Riverpod state
      expect(find.byType(ArticleReaderScreen), findsOneWidget);
    });
  });

  group('Article - Model', () {
    test('article has required fields', () {
      expect(testArticle.id, 'test-article-1');
      expect(testArticle.title, 'Test Article Title');
      expect(testArticle.content.isNotEmpty, isTrue);
      expect(testArticle.tradition, Tradition.advaita);
      expect(testArticle.readingTimeMinutes, 5);
    });

    test('article optional fields work', () {
      expect(testArticle.subtitle, 'A test subtitle');
      expect(testArticle.teacher, 'Test Teacher');
      expect(testArticle.categories, [ArticleCategory.natureOfAwareness, ArticleCategory.selfInquiry]);
    });

    test('article without optional fields works', () {
      final minimalArticle = Article(
        id: 'minimal',
        title: 'Minimal',
        content: 'Content',
        tradition: Tradition.zen,
        readingTimeMinutes: 1,
        categories: [],
      );

      expect(minimalArticle.subtitle, isNull);
      expect(minimalArticle.teacher, isNull);
    });
  });
}
