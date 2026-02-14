import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/screens/article_reader_screen.dart';
import 'package:pointer/data/articles.dart';
import 'package:pointer/models/article.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';

late SharedPreferences prefs;

/// Helper to wrap widget with ProviderScope for testing
Widget wrapWithProviderScope(Widget child) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
    ],
    child: child,
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'pointer_onboarding_completed': true});
    prefs = await SharedPreferences.getInstance();
  });
  group('LibraryScreen', () {
    testWidgets('renders header with title and subtitle', (tester) async {
      // Use a larger surface to avoid overflow in featured cards
      tester.view.physicalSize = const Size(1920, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: LibraryScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Explore teachings and articles'), findsOneWidget);
    });

    testWidgets('displays featured section header', (tester) async {
      tester.view.physicalSize = const Size(1920, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: LibraryScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('FEATURED'), findsOneWidget);
    });

    testWidgets('displays browse by section', (tester) async {
      tester.view.physicalSize = const Size(1920, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: LibraryScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      // Updated from "BROWSE BY TOPIC" to "BROWSE BY" with dropdown
      expect(find.text('BROWSE BY'), findsOneWidget);
    });

    testWidgets('displays some topic names visible on screen', (tester) async {
      tester.view.physicalSize = const Size(1920, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: LibraryScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Topics browse now shows TopicTags for all filters (unified view)
      expect(find.text('Self-Inquiry'), findsOneWidget);
      expect(find.text('Awareness'), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      tester.view.physicalSize = const Size(1920, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: LibraryScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(LibraryScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      tester.view.physicalSize = const Size(1920, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: LibraryScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(LibraryScreen), findsOneWidget);
    });
  });

  group('CategoryArticlesScreen', () {
    testWidgets('displays category name and article count', (tester) async {
      const category = ArticleCategory.natureOfAwareness;
      final info = categoryInfoMap[category]!;
      final articleCount = getArticlesByCategory(category).length;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: CategoryArticlesScreen(category: category, info: info),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Nature of Awareness'), findsOneWidget);
      expect(find.text('$articleCount articles'), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      const category = ArticleCategory.selfInquiry;
      final info = categoryInfoMap[category]!;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: CategoryArticlesScreen(category: category, info: info),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('ArticleReaderScreen', () {
    testWidgets('displays article title', (tester) async {
      final article = articles.first;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Title may appear in header and markdown content
      expect(find.text(article.title), findsAtLeastNWidgets(1));
    });

    testWidgets('displays article subtitle when present', (tester) async {
      final article = articles.firstWhere((a) => a.subtitle != null);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(article.subtitle!), findsOneWidget);
    });

    testWidgets('displays reading time', (tester) async {
      final article = articles.first;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('${article.readingTimeMinutes} min read'), findsOneWidget);
    });

    testWidgets('displays teacher when present', (tester) async {
      final article = articles.firstWhere((a) => a.teacher != null);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(article.teacher!), findsOneWidget);
    });

    testWidgets('displays close button', (tester) async {
      final article = articles.first;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders markdown content without error', (tester) async {
      final article = articles.first;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Article content should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in light theme', (tester) async {
      final article = articles.first;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.light,
            home: ArticleReaderScreen(article: article),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ArticleReaderScreen), findsOneWidget);
    });
  });

  group('categoryInfoMap', () {
    test('contains all ArticleCategory values', () {
      for (final category in ArticleCategory.values) {
        expect(categoryInfoMap.containsKey(category), isTrue, reason: 'Missing category: $category');
      }
    });

    test('all categories have non-empty names', () {
      for (final info in categoryInfoMap.values) {
        expect(info.name.isNotEmpty, isTrue);
      }
    });

    test('all categories have icons', () {
      for (final info in categoryInfoMap.values) {
        expect(info.icon.isNotEmpty, isTrue);
      }
    });

    test('all categories have descriptions', () {
      for (final info in categoryInfoMap.values) {
        expect(info.description.isNotEmpty, isTrue);
      }
    });
  });

  group('Article data functions', () {
    test('getArticlesByCategory returns articles for valid category', () {
      final result = getArticlesByCategory(ArticleCategory.selfInquiry);
      expect(result.isNotEmpty, isTrue);
      for (final article in result) {
        expect(article.hasCategory(ArticleCategory.selfInquiry), isTrue);
      }
    });

    test('getFeaturedArticles returns entries', () {
      final featured = getFeaturedArticles(limit: 10);
      expect(featured, isNotEmpty);
    });

    test('getFeaturedArticles respects limit parameter', () {
      final limited = getFeaturedArticles(limit: 3);
      expect(limited.length, lessThanOrEqualTo(3));
    });
  });
}
