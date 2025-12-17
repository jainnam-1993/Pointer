import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer_flutter/services/affinity_service.dart';
import 'package:pointer_flutter/data/pointings.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late AffinityService affinityService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    affinityService = AffinityService(mockPrefs);
  });

  group('AffinityService - recordView', () {
    test('increments view count for tradition', () async {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await affinityService.recordView(Tradition.advaita);

      final captured = verify(
        () => mockPrefs.setString('affinity_view_counts', captureAny()),
      ).captured.single as String;
      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['advaita'], 1);
    });

    test('increments existing view count', () async {
      final existing = jsonEncode({'advaita': 2, 'zen': 1});
      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(existing);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await affinityService.recordView(Tradition.advaita);

      final captured = verify(
        () => mockPrefs.setString('affinity_view_counts', captureAny()),
      ).captured.single as String;
      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['advaita'], 3);
      expect(decoded['zen'], 1);
    });

    test('updates last updated timestamp', () async {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await affinityService.recordView(Tradition.advaita);

      verify(() => mockPrefs.setString('affinity_last_updated', any()))
          .called(1);
    });
  });

  group('AffinityService - recordSave', () {
    test('increments save count for tradition', () async {
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await affinityService.recordSave(Tradition.zen);

      final captured = verify(
        () => mockPrefs.setString('affinity_save_counts', captureAny()),
      ).captured.single as String;
      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['zen'], 1);
    });

    test('increments existing save count', () async {
      final existing = jsonEncode({'advaita': 1, 'zen': 3});
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(existing);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await affinityService.recordSave(Tradition.zen);

      final captured = verify(
        () => mockPrefs.setString('affinity_save_counts', captureAny()),
      ).captured.single as String;
      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['zen'], 4);
      expect(decoded['advaita'], 1);
    });
  });

  group('AffinityService - getAffinityScore', () {
    test('returns 0.2 when no data', () {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);

      final score = affinityService.getAffinityScore(Tradition.advaita);

      expect(score, 0.2);
    });

    test('weights saves 3x more than views', () {
      // Tradition A: 10 views, 0 saves = score of 10
      // Tradition B: 0 views, 3 saves = score of 9 (3 * 3)
      // Total score: 19
      // Expected: A = 10/19 ≈ 0.526, B = 9/19 ≈ 0.474
      final viewCounts = jsonEncode({'advaita': 10, 'zen': 0});
      final saveCounts = jsonEncode({'advaita': 0, 'zen': 3});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final advaitaScore = affinityService.getAffinityScore(Tradition.advaita);
      final zenScore = affinityService.getAffinityScore(Tradition.zen);

      expect(advaitaScore, closeTo(0.526, 0.001));
      expect(zenScore, closeTo(0.474, 0.001));
    });

    test('calculates correct score with mixed interactions', () {
      // Advaita: 6 views + 2 saves = 6 + 6 = 12
      // Zen: 3 views + 1 save = 3 + 3 = 6
      // Total: 18
      // Expected: Advaita = 12/18 = 0.667, Zen = 6/18 = 0.333
      final viewCounts = jsonEncode({'advaita': 6, 'zen': 3});
      final saveCounts = jsonEncode({'advaita': 2, 'zen': 1});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final advaitaScore = affinityService.getAffinityScore(Tradition.advaita);
      final zenScore = affinityService.getAffinityScore(Tradition.zen);

      expect(advaitaScore, closeTo(0.667, 0.001));
      expect(zenScore, closeTo(0.333, 0.001));
    });

    test('returns 0.0 for tradition with no interactions', () {
      final viewCounts = jsonEncode({'advaita': 10});
      final saveCounts = jsonEncode({'advaita': 2});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final zenScore = affinityService.getAffinityScore(Tradition.zen);

      expect(zenScore, 0.0);
    });
  });

  group('AffinityService - getAllAffinities', () {
    test('returns sorted list by score descending', () {
      // Set up scores: Advaita=0.5, Zen=0.3, Direct=0.2
      final viewCounts = jsonEncode({'advaita': 8, 'zen': 3, 'direct': 5});
      final saveCounts = jsonEncode({'advaita': 2, 'zen': 1, 'direct': 0});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final affinities = affinityService.getAllAffinities();

      expect(affinities.length, Tradition.values.length);

      // Check that scores are in descending order
      for (int i = 0; i < affinities.length - 1; i++) {
        expect(affinities[i].score >= affinities[i + 1].score, true,
            reason: 'Affinities should be sorted by score descending');
      }

      // Check top traditions
      expect(affinities[0].tradition, Tradition.advaita);
      expect(affinities[0].viewCount, 8);
      expect(affinities[0].saveCount, 2);
    });

    test('returns all traditions even when no data', () {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);

      final affinities = affinityService.getAllAffinities();

      expect(affinities.length, Tradition.values.length);
      for (final affinity in affinities) {
        expect(affinity.score, 0.2); // Default score
        expect(affinity.viewCount, 0);
        expect(affinity.saveCount, 0);
      }
    });

    test('includes correct view and save counts', () {
      final viewCounts = jsonEncode({'advaita': 10, 'zen': 5});
      final saveCounts = jsonEncode({'advaita': 3, 'zen': 2});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final affinities = affinityService.getAllAffinities();
      final advaitaAffinity = affinities.firstWhere(
        (a) => a.tradition == Tradition.advaita,
      );
      final zenAffinity = affinities.firstWhere(
        (a) => a.tradition == Tradition.zen,
      );

      expect(advaitaAffinity.viewCount, 10);
      expect(advaitaAffinity.saveCount, 3);
      expect(zenAffinity.viewCount, 5);
      expect(zenAffinity.saveCount, 2);
    });
  });

  group('AffinityService - getTopTradition', () {
    test('returns null when no data', () {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);

      final top = affinityService.getTopTradition();

      expect(top, null);
    });

    test('returns highest affinity tradition', () {
      final viewCounts = jsonEncode({'advaita': 5, 'zen': 10});
      final saveCounts = jsonEncode({'advaita': 2, 'zen': 1});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final top = affinityService.getTopTradition();

      // Advaita: 5 + 6 = 11, Zen: 10 + 3 = 13
      expect(top, Tradition.zen);
    });

    test('returns null when all counts are zero', () {
      // Even though getAllAffinities returns data, if all view/save counts are 0,
      // getTopTradition should return null
      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(jsonEncode({}));
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(jsonEncode({}));

      final top = affinityService.getTopTradition();

      expect(top, null);
    });

    test('returns tradition with saves even if views are zero', () {
      final viewCounts = jsonEncode({});
      final saveCounts = jsonEncode({'zen': 1});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final top = affinityService.getTopTradition();

      expect(top, Tradition.zen);
    });
  });

  group('AffinityService - getTraditionsByPreference', () {
    test('returns traditions in order by affinity score', () {
      final viewCounts = jsonEncode({'advaita': 10, 'zen': 5, 'direct': 8});
      final saveCounts = jsonEncode({'advaita': 1, 'zen': 2, 'direct': 0});

      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      final ordered = affinityService.getTraditionsByPreference();

      expect(ordered.length, Tradition.values.length);

      // Verify ordering matches getAllAffinities
      final affinities = affinityService.getAllAffinities();
      for (int i = 0; i < ordered.length; i++) {
        expect(ordered[i], affinities[i].tradition);
      }
    });

    test('returns all traditions when no data', () {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);

      final ordered = affinityService.getTraditionsByPreference();

      expect(ordered.length, Tradition.values.length);
    });
  });

  group('AffinityService - reset', () {
    test('clears all data', () async {
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      await affinityService.reset();

      verify(() => mockPrefs.remove('affinity_view_counts')).called(1);
      verify(() => mockPrefs.remove('affinity_save_counts')).called(1);
      verify(() => mockPrefs.remove('affinity_last_updated')).called(1);
    });

    test('returns default scores after reset', () async {
      // Set up initial data
      final viewCounts = jsonEncode({'advaita': 10});
      final saveCounts = jsonEncode({'advaita': 5});
      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(viewCounts);
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(saveCounts);

      // After reset, return null
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      await affinityService.reset();

      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);

      final score = affinityService.getAffinityScore(Tradition.advaita);
      expect(score, 0.2);
    });
  });

  group('AffinityService - Data Persistence', () {
    test('data persists across AffinityService instances', () async {
      // First instance records data
      final firstService = AffinityService(mockPrefs);
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await firstService.recordView(Tradition.advaita);

      // Capture what was saved
      final capturedViews = verify(
        () => mockPrefs.setString('affinity_view_counts', captureAny()),
      ).captured.single as String;

      // Second instance reads the same data
      final secondService = AffinityService(mockPrefs);
      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(capturedViews);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);

      final affinities = secondService.getAllAffinities();
      final advaitaAffinity = affinities.firstWhere(
        (a) => a.tradition == Tradition.advaita,
      );

      expect(advaitaAffinity.viewCount, 1);
    });

    test('multiple operations accumulate correctly', () async {
      when(() => mockPrefs.getString('affinity_view_counts')).thenReturn(null);
      when(() => mockPrefs.getString('affinity_save_counts')).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      // Record multiple views
      await affinityService.recordView(Tradition.advaita);

      // Update mock to return saved data
      var capturedViews = verify(
        () => mockPrefs.setString('affinity_view_counts', captureAny()),
      ).captured.last as String;
      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(capturedViews);

      await affinityService.recordView(Tradition.advaita);

      capturedViews = verify(
        () => mockPrefs.setString('affinity_view_counts', captureAny()),
      ).captured.last as String;
      when(() => mockPrefs.getString('affinity_view_counts'))
          .thenReturn(capturedViews);

      // Record a save
      await affinityService.recordSave(Tradition.advaita);

      final capturedSaves = verify(
        () => mockPrefs.setString('affinity_save_counts', captureAny()),
      ).captured.last as String;
      when(() => mockPrefs.getString('affinity_save_counts'))
          .thenReturn(capturedSaves);

      // Verify accumulated data
      final affinities = affinityService.getAllAffinities();
      final advaitaAffinity = affinities.firstWhere(
        (a) => a.tradition == Tradition.advaita,
      );

      expect(advaitaAffinity.viewCount, 2);
      expect(advaitaAffinity.saveCount, 1);
    });
  });

  group('TraditionAffinity - preferenceLevel', () {
    test('returns correct preference levels', () {
      const high = TraditionAffinity(
        tradition: Tradition.advaita,
        score: 0.5,
        viewCount: 10,
        saveCount: 5,
      );
      expect(high.preferenceLevel, 'High');

      const medium = TraditionAffinity(
        tradition: Tradition.zen,
        score: 0.3,
        viewCount: 5,
        saveCount: 2,
      );
      expect(medium.preferenceLevel, 'Medium');

      const low = TraditionAffinity(
        tradition: Tradition.direct,
        score: 0.2,
        viewCount: 2,
        saveCount: 0,
      );
      expect(low.preferenceLevel, 'Low');

      const minimal = TraditionAffinity(
        tradition: Tradition.contemporary,
        score: 0.1,
        viewCount: 1,
        saveCount: 0,
      );
      expect(minimal.preferenceLevel, 'Minimal');
    });
  });
}
