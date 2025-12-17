// Library Model Tests
// Tests for Article, TeacherProfile models and library providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_flutter/data/articles.dart';
import 'package:pointer_flutter/data/pointings.dart';
import 'package:pointer_flutter/data/teacher_profiles.dart';
import 'package:pointer_flutter/models/article.dart';
import 'package:pointer_flutter/models/teacher_profile.dart';
import 'package:pointer_flutter/providers/library_providers.dart';

void main() {
  group('Article Model', () {
    test('creates Article correctly with all fields', () {
      final article = Article(
        id: 'test_001',
        title: 'Test Article',
        subtitle: 'A test subtitle',
        content: '# Test Content\n\nSome markdown content.',
        excerpt: 'Short preview',
        tradition: Tradition.advaita,
        teacher: 'Test Teacher',
        categories: [ArticleCategory.selfInquiry, ArticleCategory.natureOfAwareness],
        readingTimeMinutes: 5,
        dateAdded: DateTime(2024, 1, 1),
        isPremium: true,
      );

      expect(article.id, 'test_001');
      expect(article.title, 'Test Article');
      expect(article.subtitle, 'A test subtitle');
      expect(article.content, contains('# Test Content'));
      expect(article.excerpt, 'Short preview');
      expect(article.tradition, Tradition.advaita);
      expect(article.teacher, 'Test Teacher');
      expect(article.categories.length, 2);
      expect(article.readingTimeMinutes, 5);
      expect(article.isPremium, true);
    });

    test('creates Article with minimal required fields', () {
      const article = Article(
        id: 'test_002',
        title: 'Minimal Article',
        content: 'Content here',
        tradition: Tradition.zen,
        categories: [],
        readingTimeMinutes: 3,
      );

      expect(article.id, 'test_002');
      expect(article.subtitle, isNull);
      expect(article.excerpt, isNull);
      expect(article.teacher, isNull);
      expect(article.dateAdded, isNull);
      expect(article.isPremium, false);
    });

    test('hasCategory returns correct result', () {
      const article = Article(
        id: 'test_003',
        title: 'Category Test',
        content: 'Content',
        tradition: Tradition.direct,
        categories: [ArticleCategory.selfInquiry],
        readingTimeMinutes: 2,
      );

      expect(article.hasCategory(ArticleCategory.selfInquiry), true);
      expect(article.hasCategory(ArticleCategory.everydayAwakening), false);
    });

    test('isBy returns correct result for teacher matching', () {
      const article = Article(
        id: 'test_004',
        title: 'Teacher Test',
        content: 'Content',
        tradition: Tradition.advaita,
        teacher: 'Ramana Maharshi',
        categories: [],
        readingTimeMinutes: 2,
      );

      expect(article.isBy('Ramana Maharshi'), true);
      expect(article.isBy('ramana maharshi'), true);
      expect(article.isBy('Nisargadatta'), false);
    });

    test('equality works correctly', () {
      const article1 = Article(
        id: 'test_005',
        title: 'Equality Test',
        content: 'Content',
        tradition: Tradition.zen,
        categories: [],
        readingTimeMinutes: 2,
      );

      const article2 = Article(
        id: 'test_005',
        title: 'Different Title',
        content: 'Different Content',
        tradition: Tradition.advaita,
        categories: [],
        readingTimeMinutes: 10,
      );

      expect(article1 == article2, true);
      expect(article1.hashCode, article2.hashCode);
    });
  });

  group('TeacherProfile Model', () {
    test('creates TeacherProfile correctly with all fields', () {
      const teacher = TeacherProfile(
        name: 'Test Teacher',
        bio: 'A biographical description',
        dates: '1900-2000',
        primaryTradition: Tradition.advaita,
        imageAsset: 'assets/teachers/test.png',
        keyTeachings: ['Teaching 1', 'Teaching 2'],
        articleIds: ['art_001', 'art_002'],
        pointingIds: ['p_001'],
        quote: 'A famous quote',
        location: 'Test Location',
      );

      expect(teacher.name, 'Test Teacher');
      expect(teacher.bio, 'A biographical description');
      expect(teacher.dates, '1900-2000');
      expect(teacher.primaryTradition, Tradition.advaita);
      expect(teacher.imageAsset, 'assets/teachers/test.png');
      expect(teacher.keyTeachings.length, 2);
      expect(teacher.articleIds.length, 2);
      expect(teacher.pointingIds.length, 1);
      expect(teacher.quote, 'A famous quote');
      expect(teacher.location, 'Test Location');
    });

    test('creates TeacherProfile with minimal required fields', () {
      const teacher = TeacherProfile(
        name: 'Minimal Teacher',
        primaryTradition: Tradition.zen,
      );

      expect(teacher.name, 'Minimal Teacher');
      expect(teacher.bio, isNull);
      expect(teacher.dates, isNull);
      expect(teacher.imageAsset, isNull);
      expect(teacher.keyTeachings, isEmpty);
      expect(teacher.articleIds, isEmpty);
      expect(teacher.pointingIds, isEmpty);
    });

    test('hasArticle returns correct result', () {
      const teacher = TeacherProfile(
        name: 'Article Teacher',
        primaryTradition: Tradition.direct,
        articleIds: ['art_001', 'art_002'],
      );

      expect(teacher.hasArticle('art_001'), true);
      expect(teacher.hasArticle('art_003'), false);
    });

    test('hasPointing returns correct result', () {
      const teacher = TeacherProfile(
        name: 'Pointing Teacher',
        primaryTradition: Tradition.contemporary,
        pointingIds: ['p_001'],
      );

      expect(teacher.hasPointing('p_001'), true);
      expect(teacher.hasPointing('p_002'), false);
    });

    test('isFromTradition returns correct result', () {
      const teacher = TeacherProfile(
        name: 'Tradition Teacher',
        primaryTradition: Tradition.advaita,
      );

      expect(teacher.isFromTradition(Tradition.advaita), true);
      expect(teacher.isFromTradition(Tradition.zen), false);
    });

    test('equality works correctly', () {
      const teacher1 = TeacherProfile(
        name: 'Same Teacher',
        primaryTradition: Tradition.zen,
      );

      const teacher2 = TeacherProfile(
        name: 'Same Teacher',
        primaryTradition: Tradition.advaita,
        bio: 'Different bio',
      );

      expect(teacher1 == teacher2, true);
      expect(teacher1.hashCode, teacher2.hashCode);
    });
  });

  group('Articles Data', () {
    test('articles list is not empty', () {
      expect(articles, isNotEmpty);
    });

    test('articles have unique IDs', () {
      final ids = articles.map((a) => a.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, ids.length);
    });

    test('all articles have required fields populated', () {
      for (final article in articles) {
        expect(article.id, isNotEmpty);
        expect(article.title, isNotEmpty);
        expect(article.content, isNotEmpty);
        expect(article.readingTimeMinutes, greaterThan(0));
      }
    });

    test('articles cover multiple traditions', () {
      final traditions = articles.map((a) => a.tradition).toSet();
      expect(traditions.length, greaterThanOrEqualTo(3));
    });

    test('getArticlesByTradition returns correct articles', () {
      final advaitaArticles = getArticlesByTradition(Tradition.advaita);
      expect(advaitaArticles, isNotEmpty);
      for (final article in advaitaArticles) {
        expect(article.tradition, Tradition.advaita);
      }
    });

    test('getArticlesByCategory returns correct articles', () {
      final selfInquiryArticles =
          getArticlesByCategory(ArticleCategory.selfInquiry);
      expect(selfInquiryArticles, isNotEmpty);
      for (final article in selfInquiryArticles) {
        expect(article.hasCategory(ArticleCategory.selfInquiry), true);
      }
    });

    test('getArticlesByTeacher returns correct articles', () {
      final ramanaArticles = getArticlesByTeacher('Ramana Maharshi');
      expect(ramanaArticles, isNotEmpty);
      for (final article in ramanaArticles) {
        expect(article.teacher?.toLowerCase(), 'ramana maharshi');
      }
    });

    test('getFeaturedArticles returns non-premium articles', () {
      final featured = getFeaturedArticles();
      expect(featured, isNotEmpty);
      expect(featured.length, lessThanOrEqualTo(5));
      for (final article in featured) {
        expect(article.isPremium, false);
      }
    });

    test('searchArticles finds articles by title', () {
      final results = searchArticles('Who Am I');
      expect(results, isNotEmpty);
    });
  });

  group('Teacher Profiles Data', () {
    test('teacher profiles list is not empty', () {
      expect(teacherProfiles, isNotEmpty);
    });

    test('all teacher profiles have required fields', () {
      for (final teacher in teacherProfiles) {
        expect(teacher.name, isNotEmpty);
      }
    });

    test('teacher profiles cover multiple traditions', () {
      final traditions =
          teacherProfiles.map((t) => t.primaryTradition).toSet();
      expect(traditions.length, greaterThanOrEqualTo(3));
    });

    test('getTeacherProfile returns correct teacher', () {
      final nisargadatta = getTeacherProfile('Nisargadatta Maharaj');
      expect(nisargadatta, isNotNull);
      expect(nisargadatta!.name, 'Nisargadatta Maharaj');
    });

    test('getTeacherProfile is case insensitive', () {
      final teacher = getTeacherProfile('nisargadatta maharaj');
      expect(teacher, isNotNull);
    });

    test('getTeacherProfile returns null for unknown teacher', () {
      final unknown = getTeacherProfile('Unknown Teacher');
      expect(unknown, isNull);
    });

    test('getTeachersByTradition returns correct teachers', () {
      final advaitaTeachers = getTeachersByTradition(Tradition.advaita);
      expect(advaitaTeachers, isNotEmpty);
      for (final teacher in advaitaTeachers) {
        expect(teacher.primaryTradition, Tradition.advaita);
      }
    });

    test('getAllTeacherNames returns all names', () {
      final names = getAllTeacherNames();
      expect(names.length, teacherProfiles.length);
    });

    test('getTeachersWithArticles returns teachers with articleIds', () {
      final teachers = getTeachersWithArticles();
      expect(teachers, isNotEmpty);
      for (final teacher in teachers) {
        expect(teacher.articleIds, isNotEmpty);
      }
    });
  });

  group('Library Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('articlesProvider returns all articles', () {
      final allArticles = container.read(articlesProvider);
      expect(allArticles, articles);
    });

    test('articlesByTraditionProvider filters correctly', () {
      final zenArticles =
          container.read(articlesByTraditionProvider(Tradition.zen));
      expect(zenArticles, isNotEmpty);
      for (final article in zenArticles) {
        expect(article.tradition, Tradition.zen);
      }
    });

    test('articlesByCategoryProvider filters correctly', () {
      final natureArticles = container.read(
        articlesByCategoryProvider(ArticleCategory.natureOfAwareness),
      );
      expect(natureArticles, isNotEmpty);
      for (final article in natureArticles) {
        expect(article.hasCategory(ArticleCategory.natureOfAwareness), true);
      }
    });

    test('articlesByTeacherProvider filters correctly', () {
      final rupertArticles =
          container.read(articlesByTeacherProvider('Rupert Spira'));
      expect(rupertArticles, isNotEmpty);
      for (final article in rupertArticles) {
        expect(article.teacher?.toLowerCase(), 'rupert spira');
      }
    });

    test('articleByIdProvider returns correct article', () {
      final article = container.read(articleByIdProvider('art_iam_that_001'));
      expect(article, isNotNull);
      expect(article!.id, 'art_iam_that_001');
    });

    test('articleByIdProvider returns null for unknown ID', () {
      final article = container.read(articleByIdProvider('unknown_id'));
      expect(article, isNull);
    });

    test('featuredArticlesProvider returns non-premium articles', () {
      final featured = container.read(featuredArticlesProvider);
      expect(featured, isNotEmpty);
      expect(featured.length, lessThanOrEqualTo(5));
      for (final article in featured) {
        expect(article.isPremium, false);
      }
    });

    test('premiumArticlesProvider returns only premium articles', () {
      final premium = container.read(premiumArticlesProvider);
      for (final article in premium) {
        expect(article.isPremium, true);
      }
    });

    test('teacherProfilesProvider returns all teachers', () {
      final teachers = container.read(teacherProfilesProvider);
      expect(teachers, teacherProfiles);
    });

    test('teacherByNameProvider returns correct teacher', () {
      final teacher =
          container.read(teacherByNameProvider('Ramana Maharshi'));
      expect(teacher, isNotNull);
      expect(teacher!.name, 'Ramana Maharshi');
    });

    test('teacherByNameProvider is case insensitive', () {
      final teacher =
          container.read(teacherByNameProvider('ramana maharshi'));
      expect(teacher, isNotNull);
    });

    test('teacherByNameProvider returns null for unknown', () {
      final teacher = container.read(teacherByNameProvider('Unknown'));
      expect(teacher, isNull);
    });

    test('teachersByTraditionProvider filters correctly', () {
      final directTeachers =
          container.read(teachersByTraditionProvider(Tradition.direct));
      expect(directTeachers, isNotEmpty);
      for (final teacher in directTeachers) {
        expect(teacher.primaryTradition, Tradition.direct);
      }
    });

    test('librarySearchQueryProvider starts empty', () {
      final query = container.read(librarySearchQueryProvider);
      expect(query, isEmpty);
    });

    test('articleSearchResultsProvider returns empty when no query', () {
      final results = container.read(articleSearchResultsProvider);
      expect(results, isEmpty);
    });

    test('articleSearchResultsProvider returns results for query', () {
      container.read(librarySearchQueryProvider.notifier).state = 'Ramana';
      final results = container.read(articleSearchResultsProvider);
      expect(results, isNotEmpty);
    });

    test('teacherSearchResultsProvider returns results for query', () {
      container.read(librarySearchQueryProvider.notifier).state = 'Nisargadatta';
      final results = container.read(teacherSearchResultsProvider);
      expect(results, isNotEmpty);
    });

    test('filteredArticlesProvider respects tradition filter', () {
      container.read(selectedTraditionFilterProvider.notifier).state =
          Tradition.zen;
      final filtered = container.read(filteredArticlesProvider);

      expect(filtered, isNotEmpty);
      for (final article in filtered) {
        expect(article.tradition, Tradition.zen);
      }
    });

    test('filteredArticlesProvider respects category filter', () {
      container.read(selectedCategoryFilterProvider.notifier).state =
          ArticleCategory.selfInquiry;
      final filtered = container.read(filteredArticlesProvider);

      expect(filtered, isNotEmpty);
      for (final article in filtered) {
        expect(article.hasCategory(ArticleCategory.selfInquiry), true);
      }
    });

    test('filteredArticlesProvider respects both filters', () {
      container.read(selectedTraditionFilterProvider.notifier).state =
          Tradition.advaita;
      container.read(selectedCategoryFilterProvider.notifier).state =
          ArticleCategory.selfInquiry;
      final filtered = container.read(filteredArticlesProvider);

      for (final article in filtered) {
        expect(article.tradition, Tradition.advaita);
        expect(article.hasCategory(ArticleCategory.selfInquiry), true);
      }
    });

    test('totalArticleCountProvider returns correct count', () {
      final count = container.read(totalArticleCountProvider);
      expect(count, articles.length);
    });

    test('totalTeacherCountProvider returns correct count', () {
      final count = container.read(totalTeacherCountProvider);
      expect(count, teacherProfiles.length);
    });

    test('totalReadingTimeProvider calculates correctly', () {
      final total = container.read(totalReadingTimeProvider);
      final expected =
          articles.fold(0, (sum, a) => sum + a.readingTimeMinutes);
      expect(total, expected);
    });

    test('articlesPerTraditionProvider returns map for all traditions', () {
      final map = container.read(articlesPerTraditionProvider);
      expect(map.keys.length, Tradition.values.length);
    });

    test('teachersPerTraditionProvider returns map for all traditions', () {
      final map = container.read(teachersPerTraditionProvider);
      expect(map.keys.length, Tradition.values.length);
    });
  });
}
