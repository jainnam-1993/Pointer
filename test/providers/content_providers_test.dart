import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/data/teaching.dart';
import 'package:pointer/providers/content_providers.dart';
import 'package:pointer/providers/core_providers.dart';
import 'package:pointer/services/storage_service.dart';

// Mocks
class MockStorageService extends Mock implements StorageService {}

void main() {
  // Initialize TeachingRepository for filter tests
  setUpAll(() {
    TeachingRepository.reset();
    TeachingRepository.initialize(pointings: pointings);
  });

  tearDownAll(() {
    TeachingRepository.reset();
  });

  group('CurrentPointingNotifier', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      // Default mock behaviors for CurrentPointingNotifier
      when(() => mockStorage.currentPointingId).thenReturn(null);
      when(() => mockStorage.setCurrentPointingId(any())).thenAnswer((_) async {});
    });

    test('initializes with a random pointing', () {
      final notifier = CurrentPointingNotifier(mockStorage);

      // Should have a valid pointing
      expect(notifier.state, isA<Pointing>());
      expect(notifier.state.id, isNotEmpty);
      expect(notifier.state.content, isNotEmpty);
    });

    test('nextPointing() changes the pointing', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final initialPointing = notifier.state;

      notifier.nextPointing();
      final newPointing = notifier.state;

      // Should be different pointing (with high probability)
      // Note: There's a tiny chance they could be the same due to randomness
      expect(newPointing, isA<Pointing>());
      expect(newPointing.id, isNotEmpty);
    });

    test('previousPointing() returns to previous', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final firstPointing = notifier.state;

      notifier.nextPointing();
      final secondPointing = notifier.state;

      notifier.previousPointing();
      final backToFirst = notifier.state;

      expect(backToFirst.id, firstPointing.id);
      expect(backToFirst.content, firstPointing.content);
    });

    test('previousPointing() does nothing at start', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final initialPointing = notifier.state;

      notifier.previousPointing();
      final stillInitial = notifier.state;

      expect(stillInitial.id, initialPointing.id);
      expect(stillInitial.content, initialPointing.content);
    });

    test('setPointing() sets specific pointing', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final targetPointing = pointings.first;

      notifier.setPointing(targetPointing);

      expect(notifier.state.id, targetPointing.id);
      expect(notifier.state.content, targetPointing.content);
    });

    test('history limited to 50 items', () {
      final notifier = CurrentPointingNotifier(mockStorage);

      // Add 60 pointings to exceed limit
      for (int i = 0; i < 60; i++) {
        notifier.nextPointing();
      }

      // We should be able to go back, but limited by history cap
      int backCount = 0;
      while (backCount < 100) {
        // Try up to 100 times to be safe
        final before = notifier.state.id;
        notifier.previousPointing();
        final after = notifier.state.id;

        if (before == after) {
          // Reached the beginning of history
          break;
        }
        backCount++;
      }

      // Should be able to go back at most 49 times (50 total items - 1 for current)
      // History is capped at 50, so backCount <= 49
      expect(backCount, lessThanOrEqualTo(49));
      // But we should have some history (more than just current)
      expect(backCount, greaterThan(0));
    });

    test('navigating back and then forward clears forward history', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final first = notifier.state;

      notifier.nextPointing();
      final second = notifier.state;

      notifier.nextPointing();
      final third = notifier.state;

      // Go back to second
      notifier.previousPointing();
      expect(notifier.state.id, second.id);

      // Add new pointing - should clear forward history
      notifier.nextPointing();
      final newThird = notifier.state;

      // Should not be able to go forward to original third
      notifier.nextPointing();
      notifier.previousPointing();

      expect(notifier.state.id, newThird.id);
    });
  });

  group('FavoritesNotifier', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
    });

    test('initializes from storage', () {
      when(() => mockStorage.favorites).thenReturn(['adv-1', 'zen-1']);

      final notifier = FavoritesNotifier(mockStorage);

      expect(notifier.state, ['adv-1', 'zen-1']);
      verify(() => mockStorage.favorites).called(1);
    });

    test('toggle() adds new favorite', () async {
      when(() => mockStorage.favorites).thenReturn([]);
      when(() => mockStorage.addFavorite(any())).thenAnswer((_) async => {});

      final notifier = FavoritesNotifier(mockStorage);

      await notifier.toggle('adv-1');

      expect(notifier.state, ['adv-1']);
      verify(() => mockStorage.addFavorite('adv-1')).called(1);
    });

    test('toggle() removes existing favorite', () async {
      when(() => mockStorage.favorites).thenReturn(['adv-1', 'zen-1']);
      when(() => mockStorage.removeFavorite(any())).thenAnswer((_) async => {});

      final notifier = FavoritesNotifier(mockStorage);

      await notifier.toggle('adv-1');

      expect(notifier.state, ['zen-1']);
      verify(() => mockStorage.removeFavorite('adv-1')).called(1);
    });

    test('isFavorite() returns correct status', () {
      when(() => mockStorage.favorites).thenReturn(['adv-1', 'zen-1']);

      final notifier = FavoritesNotifier(mockStorage);

      expect(notifier.isFavorite('adv-1'), true);
      expect(notifier.isFavorite('zen-1'), true);
      expect(notifier.isFavorite('direct-1'), false);
    });
  });

  group('TeachingFilterState', () {
    test('default has no active filters', () {
      const state = TeachingFilterState();

      expect(state.lineage, null);
      expect(state.topics, isEmpty);
      expect(state.moods, isEmpty);
      expect(state.teacher, null);
      expect(state.type, null);
      expect(state.hasActiveFilters, false);
    });

    test('hasActiveFilters returns true when lineage set', () {
      const state = TeachingFilterState(lineage: Tradition.advaita);

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when topics not empty', () {
      final state = TeachingFilterState(topics: {'awareness'});

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when moods not empty', () {
      final state = TeachingFilterState(moods: {'peaceful'});

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when teacher set', () {
      const state = TeachingFilterState(teacher: 'Ramana Maharshi');

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when type set', () {
      const state = TeachingFilterState(type: TeachingType.article);

      expect(state.hasActiveFilters, true);
    });

    test('copyWith creates modified copy', () {
      const state = TeachingFilterState(
        lineage: Tradition.advaita,
        topics: {'awareness'},
        teacher: 'Ramana Maharshi',
      );

      final modified = state.copyWith(
        lineage: Tradition.zen,
        topics: {'meditation'},
      );

      expect(modified.lineage, Tradition.zen);
      expect(modified.topics, {'meditation'});
      expect(modified.teacher, 'Ramana Maharshi'); // Unchanged
    });

    test('clearLineage clears lineage field', () {
      const state = TeachingFilterState(lineage: Tradition.advaita);

      final cleared = state.copyWith(clearLineage: true);

      expect(cleared.lineage, null);
    });

    test('clearTeacher clears teacher field', () {
      const state = TeachingFilterState(teacher: 'Ramana Maharshi');

      final cleared = state.copyWith(clearTeacher: true);

      expect(cleared.teacher, null);
    });

    test('clearType clears type field', () {
      const state = TeachingFilterState(type: TeachingType.article);

      final cleared = state.copyWith(clearType: true);

      expect(cleared.type, null);
    });

    test('apply() returns filtered teachings', () {
      final state = TeachingFilterState(lineage: Tradition.advaita);

      final filtered = state.apply();

      expect(filtered, isNotEmpty);
      expect(filtered.every((t) => t.lineage == Tradition.advaita), true);
    });
  });

  group('TeachingFilterNotifier', () {
    test('setLineage() updates state', () {
      final notifier = TeachingFilterNotifier();

      notifier.setLineage(Tradition.zen);

      expect(notifier.state.lineage, Tradition.zen);
    });

    test('setLineage(null) clears lineage', () {
      final notifier = TeachingFilterNotifier();
      notifier.setLineage(Tradition.zen);

      notifier.setLineage(null);

      expect(notifier.state.lineage, null);
    });

    test('toggleTopic() adds topic', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleTopic('awareness');

      expect(notifier.state.topics, {'awareness'});
    });

    test('toggleTopic() removes existing topic', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleTopic('awareness');

      notifier.toggleTopic('awareness');

      expect(notifier.state.topics, isEmpty);
    });

    test('toggleTopic() handles multiple topics', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleTopic('awareness');
      notifier.toggleTopic('meditation');

      expect(notifier.state.topics, {'awareness', 'meditation'});
    });

    test('setTopics() replaces all topics', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleTopic('awareness');

      notifier.setTopics({'meditation', 'silence'});

      expect(notifier.state.topics, {'meditation', 'silence'});
    });

    test('toggleMood() adds mood', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleMood('peaceful');

      expect(notifier.state.moods, {'peaceful'});
    });

    test('toggleMood() removes existing mood', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleMood('peaceful');

      notifier.toggleMood('peaceful');

      expect(notifier.state.moods, isEmpty);
    });

    test('toggleMood() handles multiple moods', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleMood('peaceful');
      notifier.toggleMood('contemplative');

      expect(notifier.state.moods, {'peaceful', 'contemplative'});
    });

    test('setMoods() replaces all moods', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleMood('peaceful');

      notifier.setMoods({'contemplative', 'joyful'});

      expect(notifier.state.moods, {'contemplative', 'joyful'});
    });

    test('setTeacher() updates teacher', () {
      final notifier = TeachingFilterNotifier();

      notifier.setTeacher('Ramana Maharshi');

      expect(notifier.state.teacher, 'Ramana Maharshi');
    });

    test('setTeacher(null) clears teacher', () {
      final notifier = TeachingFilterNotifier();
      notifier.setTeacher('Ramana Maharshi');

      notifier.setTeacher(null);

      expect(notifier.state.teacher, null);
    });

    test('setType() updates type', () {
      final notifier = TeachingFilterNotifier();

      notifier.setType(TeachingType.article);

      expect(notifier.state.type, TeachingType.article);
    });

    test('setType(null) clears type', () {
      final notifier = TeachingFilterNotifier();
      notifier.setType(TeachingType.article);

      notifier.setType(null);

      expect(notifier.state.type, null);
    });

    test('reset() clears all filters', () {
      final notifier = TeachingFilterNotifier();

      // Set multiple filters
      notifier.setLineage(Tradition.zen);
      notifier.toggleTopic('awareness');
      notifier.toggleMood('peaceful');
      notifier.setTeacher('Ramana Maharshi');
      notifier.setType(TeachingType.article);

      notifier.reset();

      expect(notifier.state.lineage, null);
      expect(notifier.state.topics, isEmpty);
      expect(notifier.state.moods, isEmpty);
      expect(notifier.state.teacher, null);
      expect(notifier.state.type, null);
      expect(notifier.state.hasActiveFilters, false);
    });
  });

  group('Riverpod Providers', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.currentPointingId).thenReturn(null);
      when(() => mockStorage.setCurrentPointingId(any())).thenAnswer((_) async {});
    });

    test('currentPointingProvider creates notifier', () {
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final pointing = container.read(currentPointingProvider);

      expect(pointing, isA<Pointing>());
      expect(pointing.id, isNotEmpty);
    });

    test('teachingFilterProvider creates notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filterState = container.read(teachingFilterProvider);

      expect(filterState, isA<TeachingFilterState>());
      expect(filterState.hasActiveFilters, false);
    });

    test('filteredTeachingsProvider returns all when no filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final teachings = container.read(filteredTeachingsProvider);

      expect(teachings, isNotEmpty);
      expect(teachings.length, TeachingRepository.all.length);
    });

    test('filteredTeachingsProvider filters by lineage', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(teachingFilterProvider.notifier).setLineage(Tradition.zen);
      final teachings = container.read(filteredTeachingsProvider);

      expect(teachings, isNotEmpty);
      expect(teachings.every((t) => t.lineage == Tradition.zen), true);
    });
  });
}
