import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/screens/article_reader_screen.dart';
import 'package:pointer/data/articles.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/data/teaching.dart';
import 'package:pointer/models/article.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/widgets/animated_gradient.dart';

late SharedPreferences prefs;

/// Premium subscription state for testing
final _premiumState = SubscriptionState(
  tier: SubscriptionTier.premium,
  isLoading: false,
);

/// Test subscription notifier that returns fixed state
class _TestSubscriptionNotifier extends SubscriptionNotifier {
  final SubscriptionState _fixedState;

  _TestSubscriptionNotifier(this._fixedState) : super(_MockStorageService());

  @override
  SubscriptionState get state => _fixedState;
}

/// Minimal mock storage service for testing
class _MockStorageService extends StorageService {
  _MockStorageService() : super(prefs);
}

/// Helper to wrap widget with ProviderScope for testing
Widget wrapWithProviderScope(Widget child, {List<Override> extraOverrides = const []}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
      subscriptionProvider.overrideWith(
        (ref) => _TestSubscriptionNotifier(_premiumState),
      ),
      ...extraOverrides,
    ],
    child: child,
  );
}

/// Standard screen size setup for tests (tall enough to see all content)
void setScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 4000);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Build a LibraryScreen wrapped in MaterialApp with dark theme
Widget buildLibraryScreen({ThemeData? theme}) {
  return wrapWithProviderScope(
    MaterialApp(
      theme: theme ?? AppTheme.dark,
      home: const Scaffold(
        body: LibraryScreen(),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    // Disable animations that cause continuous ticker issues in tests
    AnimatedGradient.disableAnimations = true;

    SharedPreferences.setMockInitialValues({
      'pointer_onboarding_completed': true,
    });
    prefs = await SharedPreferences.getInstance();

    // Initialize TeachingRepository (needed for teachers/lineages/moods browse modes)
    TeachingRepository.initialize(pointings: pointings);
  });

  tearDownAll(() {
    TeachingRepository.reset();
    AnimatedGradient.disableAnimations = false;
  });

  // ═══════════════════════════════════════════════════════════════
  // LibraryScreen Content Rendering
  // ═══════════════════════════════════════════════════════════════
  group('LibraryScreen Content Rendering', () {
    testWidgets(
      'Given library screen loaded, When rendered, Then displays Library header AND subtitle',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Library'), findsOneWidget);
        expect(find.text('Explore teachings and articles'), findsOneWidget);
      },
    );

    testWidgets(
      'Given library screen loaded, When rendered, Then displays 3 featured article cards with actual titles',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        // Featured section header must exist
        expect(find.text('FEATURED'), findsOneWidget);

        // Verify actual featured article titles from data
        final featured = getFeaturedArticles(limit: 3);
        expect(featured.length, equals(3),
            reason: 'getFeaturedArticles(limit: 3) should return exactly 3 articles');

        for (final article in featured) {
          expect(
            find.text(article.title),
            findsAtLeastNWidgets(1),
            reason: 'Featured article "${article.title}" should be visible on screen',
          );
        }
      },
    );

    testWidgets(
      'Given library screen loaded, When rendered, Then featured cards show reading time',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        final featured = getFeaturedArticles(limit: 3);
        // At least the first featured article's reading time should be visible
        expect(
          find.text('${featured.first.readingTimeMinutes} min read'),
          findsAtLeastNWidgets(1),
          reason: 'Reading time "${featured.first.readingTimeMinutes} min read" should appear for first featured article',
        );
      },
    );

    testWidgets(
      'Given library screen loaded, When rendered, Then displays BROWSE BY section with Topics dropdown',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('BROWSE BY'), findsOneWidget);
        // Default browse mode is Topics
        expect(find.text('Topics'), findsOneWidget);
      },
    );

    testWidgets(
      'Given library screen loaded, When rendered, Then displays topic cards with names from TopicTags',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        // In "All" mode, topics view shows TopicTags with combined counts
        // Verify at least some well-known topic names are visible
        final visibleTopics = ['Awareness', 'Self-Inquiry', 'Presence'];
        for (final topicName in visibleTopics) {
          expect(
            find.text(topicName),
            findsAtLeastNWidgets(1),
            reason: 'Topic "$topicName" should be visible in BROWSE BY section',
          );
        }
      },
    );

    testWidgets(
      'Given library screen loaded, When rendered, Then topic cards show combined article+quote counts',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        // Each visible topic should have combined count > 0 (articles + quotes)
        final teachingCounts = TeachingRepository.topicCounts;
        // Check a few topics that definitely have content
        for (final topic in [TopicTags.awareness, TopicTags.presence, TopicTags.selfInquiry]) {
          final articleCount = getArticlesByTopic(topic).length;
          final teachingCount = teachingCounts[topic] ?? 0;
          final total = articleCount + teachingCount;
          expect(total, greaterThan(0),
              reason: 'Topic $topic should have combined content');
          expect(
            find.text('$total'),
            findsAtLeastNWidgets(1),
            reason: 'Topic $topic combined count ($total) should be displayed',
          );
        }
      },
    );

    testWidgets(
      'Given library screen loaded, When rendered, Then All content type filter is shown',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        // Default content filter shows "All"
        expect(find.text('All'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════
  // LibraryScreen Theme Variants
  // ═══════════════════════════════════════════════════════════════
  group('LibraryScreen Theme Variants', () {
    testWidgets(
      'Given library screen, When rendered in light theme, Then content is still visible',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen(theme: AppTheme.light));
        await tester.pump(const Duration(seconds: 2));

        // Must show actual content, not just the widget type
        expect(find.text('Library'), findsOneWidget);
        expect(find.text('FEATURED'), findsOneWidget);
        final featured = getFeaturedArticles(limit: 3);
        expect(find.text(featured.first.title), findsAtLeastNWidgets(1),
            reason: 'Featured article title should be visible in light theme');
      },
    );

    testWidgets(
      'Given library screen, When rendered in dark theme, Then content is still visible',
      (tester) async {
        setScreenSize(tester);
        await tester.pumpWidget(buildLibraryScreen());
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Library'), findsOneWidget);
        expect(find.text('FEATURED'), findsOneWidget);
        final featured = getFeaturedArticles(limit: 3);
        expect(find.text(featured.first.title), findsAtLeastNWidgets(1),
            reason: 'Featured article title should be visible in dark theme');
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════
  // CategoryArticlesScreen
  // ═══════════════════════════════════════════════════════════════
  group('CategoryArticlesScreen', () {
    testWidgets(
      'Given category screen, When rendered, Then shows category name AND actual article count',
      (tester) async {
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
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Nature of Awareness'), findsOneWidget);
        expect(find.text('$articleCount articles'), findsOneWidget);
        expect(articleCount, greaterThan(0),
            reason: 'Nature of Awareness should have articles');
      },
    );

    testWidgets(
      'Given category screen, When rendered, Then shows actual article titles from data',
      (tester) async {
        const category = ArticleCategory.natureOfAwareness;
        final info = categoryInfoMap[category]!;
        final categoryArticles = getArticlesByCategory(category);

        tester.view.physicalSize = const Size(1920, 6000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: CategoryArticlesScreen(category: category, info: info),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        // Verify at least the first article title is rendered
        expect(categoryArticles.isNotEmpty, isTrue,
            reason: 'Category should have articles');
        expect(
          find.text(categoryArticles.first.title),
          findsAtLeastNWidgets(1),
          reason: 'First article "${categoryArticles.first.title}" should be visible in category list',
        );
      },
    );

    testWidgets(
      'Given category screen, When rendered, Then displays back button',
      (tester) async {
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
        await tester.pump(const Duration(seconds: 2));

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      },
    );

    testWidgets(
      'Given category screen, When rendered, Then does not show lock icons (all content free)',
      (tester) async {
        const category = ArticleCategory.modernPointers;
        final info = categoryInfoMap[category]!;

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: CategoryArticlesScreen(category: category, info: info),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.lock_outline), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════
  // ArticleReaderScreen
  // ═══════════════════════════════════════════════════════════════
  group('ArticleReaderScreen', () {
    testWidgets(
      'Given article reader, When opened with first article, Then displays article title',
      (tester) async {
        final article = articles.first;

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: ArticleReaderScreen(article: article),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.text(article.title), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'Given article reader, When article has subtitle, Then displays subtitle',
      (tester) async {
        final article = articles.firstWhere((a) => a.subtitle != null);

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: ArticleReaderScreen(article: article),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.text(article.subtitle!), findsOneWidget);
      },
    );

    testWidgets(
      'Given article reader, When opened, Then displays reading time',
      (tester) async {
        final article = articles.first;

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: ArticleReaderScreen(article: article),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('${article.readingTimeMinutes} min read'), findsOneWidget);
      },
    );

    testWidgets(
      'Given article reader, When article has teacher, Then displays teacher name',
      (tester) async {
        final article = articles.firstWhere((a) => a.teacher != null);

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: ArticleReaderScreen(article: article),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.text(article.teacher!), findsOneWidget);
      },
    );

    testWidgets(
      'Given article reader, When opened, Then displays close button',
      (tester) async {
        final article = articles.first;

        await tester.pumpWidget(
          wrapWithProviderScope(
            MaterialApp(
              theme: AppTheme.dark,
              home: ArticleReaderScreen(article: article),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.byIcon(Icons.close), findsOneWidget);
      },
    );

    testWidgets(
      'Given article reader, When rendered, Then markdown content renders without error',
      (tester) async {
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

        expect(tester.takeException(), isNull);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════
  // categoryInfoMap Data Validation
  // ═══════════════════════════════════════════════════════════════
  group('categoryInfoMap', () {
    test('contains all ArticleCategory values', () {
      for (final category in ArticleCategory.values) {
        expect(categoryInfoMap.containsKey(category), isTrue,
            reason: 'Missing category: $category');
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

  // ═══════════════════════════════════════════════════════════════
  // Article Data Functions
  // ═══════════════════════════════════════════════════════════════
  group('Article data functions', () {
    test('getArticlesByCategory returns articles for each category', () {
      for (final category in ArticleCategory.values) {
        final result = getArticlesByCategory(category);
        expect(result.isNotEmpty, isTrue,
            reason: 'Category ${category.name} should have at least 1 article');
        for (final article in result) {
          expect(article.hasCategory(category), isTrue);
        }
      }
    });

    test('getFeaturedArticles returns non-premium articles with correct titles', () {
      final featured = getFeaturedArticles(limit: 3);
      expect(featured.length, equals(3));
      for (final article in featured) {
        expect(article.isPremium, isFalse);
        expect(article.title.isNotEmpty, isTrue);
      }
      // Verify specific first article (deterministic order)
      expect(featured.first.title, equals('I Am That'));
    });

    test('getFeaturedArticles respects limit parameter', () {
      final limited = getFeaturedArticles(limit: 3);
      expect(limited.length, lessThanOrEqualTo(3));
    });

    test('articles list contains expected count', () {
      // Documented as 166 articles
      expect(articles.length, greaterThanOrEqualTo(100),
          reason: 'Articles list should contain a substantial number of articles');
    });
  });
}
