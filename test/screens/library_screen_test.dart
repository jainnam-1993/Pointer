import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/screens/article_reader_screen.dart';
import 'package:pointer/data/articles.dart';
import 'package:pointer/models/article.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/layout/adaptive.dart';

import '../helpers/app_fonts.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'pointer_onboarding_completed': true});
    prefs = await SharedPreferences.getInstance();
    resetArticlesForTesting();
    await loadArticles();
  });
  group('LibraryScreen two-pane list width', () {
    // Real fonts: the test font draws every glyph 1 em wide, which would wrap any word.
    setUpAll(loadAppFonts);
    // vivo V2330 unfolded at the user's 432 dpi display size: about 815 x 918 dp,
    // with the side rail on the left, as main_shell lays it out.
    testWidgets('topic names never break mid-word beside the detail pane', (tester) async {
      tester.view.physicalSize = const Size(815, 918);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const Scaffold(
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [SizedBox(width: kRailWidth), Expanded(child: LibraryScreen())],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.byKey(const ValueKey('library-list-detail')), findsOneWidget);
      final listPane = tester.getSize(find.byKey(const ValueKey('pane-primary')));
      expect(listPane.width, greaterThanOrEqualTo(kListPaneMinWidth));

      // The Featured strip ends at the list pane's edge: it fades there instead of cutting.
      expect(find.byKey(const ValueKey('featured-edge-fade')), findsOneWidget);

      final names = find.descendant(of: find.byKey(const ValueKey('pane-primary')), matching: find.text('Awareness'));
      expect(names, findsWidgets);
      final paragraph = tester.renderObject<RenderParagraph>(names.first);
      final lines = paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: 'Awareness'.length)).map((b) => b.top).toSet();
      expect(lines.length, 1, reason: '"Awareness" must sit on one line');
    });
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

  group('ArticleReaderScreen', () {
    testWidgets('displays article title', (tester) async {
      final article = articles.first;

      await tester.pumpWidget(
        wrapWithProviderScope(
          MaterialApp(
            theme: AppTheme.dark,
            home: ArticleReaderScreen(articleId: article.id),
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
            home: ArticleReaderScreen(articleId: article.id),
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
            home: ArticleReaderScreen(articleId: article.id),
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
            home: ArticleReaderScreen(articleId: article.id),
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
            home: ArticleReaderScreen(articleId: article.id),
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
            home: ArticleReaderScreen(articleId: article.id),
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
            home: ArticleReaderScreen(articleId: article.id),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ArticleReaderScreen), findsOneWidget);
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
