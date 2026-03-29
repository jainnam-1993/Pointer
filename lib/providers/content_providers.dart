/**
 * Content providers - Pointings, favorites, affinity, and teaching filters.
 *
 * Manages spiritual content delivery: daily [Pointing] navigation via
 * [CurrentPointingNotifier] (round-robin with persistent shuffle order),
 * user favorites via generic [FavoritesNotifier], tradition affinity learning via
 * [AffinityService], teaching library filters via [TeachingFilterNotifier],
 * and preferred tradition selection via [PreferredTraditionsNotifier].
 *
 * All state is persisted through [StorageService] and survives app restarts.
 */
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pointings.dart';
import '../data/teaching.dart';
import '../services/affinity_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import 'core_providers.dart';

// ============================================================
// Tradition Affinity Learning
// ============================================================

/** Affinity service provider for tracking tradition preferences */
final affinityServiceProvider = Provider<AffinityService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AffinityService(prefs);
});

// ============================================================
// Current Pointing with Round-Robin Navigation
// ============================================================

/** Current pointing state - persists across app restarts with round-robin order */
final currentPointingProvider = StateNotifierProvider<CurrentPointingNotifier, Pointing>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CurrentPointingNotifier(storage);
});

/**
 * Round-robin pointing navigation
 *
 * Shuffles all pointings once on first launch, persists the order.
 * Guarantees seeing all pointings before any repeats.
 */
class CurrentPointingNotifier extends StateNotifier<Pointing> {
  final StorageService _storage;
  late List<String> _order; // Shuffled pointing IDs
  late int _index; // Current position in order

  CurrentPointingNotifier(this._storage) : super(_initializePointing(_storage)) {
    _initializeOrder();
    _updateWidget(state);
  }

  /** Initialize or load persisted pointing order */
  void _initializeOrder() {
    final savedOrder = _storage.pointingOrder;

    if (savedOrder != null && savedOrder.isNotEmpty) {
      // Validate saved order against current pointings (in case content changed)
      final validIds = pointings.map((p) => p.id).toSet();
      final validOrder = savedOrder.where((id) => validIds.contains(id)).toList();

      // Add any new pointings not in saved order
      final newIds = validIds.difference(validOrder.toSet());
      if (newIds.isNotEmpty) {
        validOrder.addAll(newIds.toList()..shuffle(Random()));
      }

      _order = validOrder;
      _index = _storage.pointingIndex;

      // Clamp index if order changed
      if (_index >= _order.length) {
        _index = 0;
      }
    } else {
      // First launch: create shuffled order
      _order = pointings.map((p) => p.id).toList()..shuffle(Random());
      _index = 0;
      _storage.setPointingOrder(_order);
      _storage.setPointingIndex(_index);
    }

    // Sync index to current pointing ID
    final currentId = state.id;
    final currentIdx = _order.indexOf(currentId);
    if (currentIdx >= 0) {
      _index = currentIdx;
      _storage.setPointingIndex(_index);
    }
  }

  /** Load persisted pointing or get first from order */
  static Pointing _initializePointing(StorageService storage) {
    // Try to restore from saved pointing ID
    final savedId = storage.currentPointingId;
    if (savedId != null) {
      final saved = getPointingById(savedId);
      if (saved != null) return saved;
    }

    // Try to restore from saved order + index
    final savedOrder = storage.pointingOrder;
    if (savedOrder != null && savedOrder.isNotEmpty) {
      final idx = storage.pointingIndex;
      if (idx < savedOrder.length) {
        final pointing = getPointingById(savedOrder[idx]);
        if (pointing != null) return pointing;
      }
    }

    // Fallback to first pointing (will be shuffled in _initializeOrder)
    return pointings.first;
  }

  /** Move to next pointing in round-robin order */
  void nextPointing({Tradition? tradition, PointingContext? context}) {
    _index = (_index + 1) % _order.length;

    // Reshuffle when completing a full cycle
    if (_index == 0) {
      _reshuffleOrder();
    }

    state = getPointingById(_order[_index]) ?? pointings.first;
    _persistAndUpdateWidget(state);
  }

  /** Move to previous pointing in round-robin order */
  void previousPointing() {
    _index = (_index - 1 + _order.length) % _order.length;
    state = getPointingById(_order[_index]) ?? pointings.first;
    _persistAndUpdateWidget(state);
  }

  /** Jump to a specific pointing (e.g., from favorites or teacher sheet) */
  void setPointing(Pointing pointing) {
    // Find in order or add to current position
    final idx = _order.indexOf(pointing.id);
    if (idx >= 0) {
      _index = idx;
    }
    // If not in order (shouldn't happen), just update state without changing index

    state = pointing;
    _persistAndUpdateWidget(state);
  }

  /** Reshuffle order for next cycle (keeps current pointing at index 0) */
  void _reshuffleOrder() {
    final current = _order[_index];
    _order.shuffle(Random());
    // Move current to front so it's not immediately repeated
    _order.remove(current);
    _order.insert(0, current);
    _index = 0;
    _storage.setPointingOrder(_order);
  }

  /** Persist current state and update widget */
  void _persistAndUpdateWidget(Pointing pointing) {
    _storage.setCurrentPointingId(pointing.id);
    _storage.setPointingIndex(_index);
    _updateWidget(pointing);
  }

  /** Update home screen widget with current pointing */
  void _updateWidget(Pointing pointing) {
    WidgetService.updateWidget(pointing);
  }

  /** Get current position info (for UI display if needed) */
  int get currentIndex => _index;
  int get totalPointings => _order.length;
}

// ============================================================
// Favorites
// ============================================================

/**
 * Generic favorites manager with toggle semantics.
 *
 * Replaces the former `FavoritesNotifier` and `ArticleFavoritesNotifier`
 * which were structural clones differing only in storage callbacks.
 * Persists state via injected [load], [add], and [remove] functions,
 * decoupling the notifier from specific [StorageService] methods.
 */
class FavoritesNotifier extends StateNotifier<List<String>> {
  final Future<void> Function(String) _add;
  final Future<void> Function(String) _remove;

  FavoritesNotifier({
    required List<String> Function() load,
    required Future<void> Function(String) add,
    required Future<void> Function(String) remove,
  })  : _add = add,
        _remove = remove,
        super(load());

  /** Whether the given [id] is currently in the favorites list. */
  bool isFavorite(String id) => state.contains(id);

  /**
   * Toggles the favorite state of an item by [id].
   *
   * Adds if absent, removes if present. Persists immediately.
   */
  Future<void> toggle(String id) async {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
      await _remove(id);
    } else {
      state = [...state, id];
      await _add(id);
    }
  }
}

/**
 * Provider for saved/favorited [Pointing] IDs.
 *
 * State is a list of pointing ID strings, persisted via [StorageService].
 * Favorites are interleaved into the home widget rotation by [WidgetService]
 * and feed into [AffinityService] for tradition preference learning (3x weight).
 */
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesNotifier(
    load: () => storage.favorites,
    add: storage.addFavorite,
    remove: storage.removeFavorite,
  );
});

/**
 * Provider for saved/bookmarked [Article] IDs, persisted via [StorageService].
 */
final articleFavoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesNotifier(
    load: () => storage.favoriteArticles,
    add: storage.addFavoriteArticle,
    remove: storage.removeFavoriteArticle,
  );
});

// ============================================================
// Teaching Filter - Tag-based filtering for Library
// ============================================================

/**
 * Immutable state for tag-based [Teaching] filters in the library.
 *
 * Combines multiple filter dimensions ([lineage], [topics], [moods],
 * [teacher], [type]) that are AND-composed when applied via [apply].
 * Used by [TeachingFilterNotifier] and consumed by [filteredTeachingsProvider].
 */
class TeachingFilterState {
  /** Filter by spiritual tradition/lineage (e.g., Advaita, Zen, Direct Path). */
  final Tradition? lineage;

  /** Active topic tag filters from [TopicTags] constants. */
  final Set<String> topics;

  /** Active mood tag filters from [MoodTags] constants. */
  final Set<String> moods;

  /** Filter by teacher name. */
  final String? teacher;

  /** Filter by teaching type (quote or article). */
  final TeachingType? type;

  const TeachingFilterState({this.lineage, this.topics = const {}, this.moods = const {}, this.teacher, this.type});

  /**
   * Creates a copy with selectively overridden fields.
   *
   * Use `clearLineage`, `clearTeacher`, or `clearType` to explicitly
   * set those fields to `null` (since passing `null` preserves the current value).
   */
  TeachingFilterState copyWith({
    Tradition? lineage,
    Set<String>? topics,
    Set<String>? moods,
    String? teacher,
    TeachingType? type,
    bool clearLineage = false,
    bool clearTeacher = false,
    bool clearType = false,
  }) {
    return TeachingFilterState(
      lineage: clearLineage ? null : (lineage ?? this.lineage),
      topics: topics ?? this.topics,
      moods: moods ?? this.moods,
      teacher: clearTeacher ? null : (teacher ?? this.teacher),
      type: clearType ? null : (type ?? this.type),
    );
  }

  /** Apply filters to get matching teachings */
  List<Teaching> apply() {
    return TeachingRepository.filter(
      lineage: lineage,
      topics: topics.isEmpty ? null : topics,
      moods: moods.isEmpty ? null : moods,
      teacher: teacher,
      type: type,
    );
  }

  /** Check if any filters are active */
  bool get hasActiveFilters => lineage != null || topics.isNotEmpty || moods.isNotEmpty || teacher != null || type != null;
}

/**
 * Manages [TeachingFilterState] with granular setters for each filter dimension.
 *
 * Provides toggle semantics for topics and moods (add/remove from set),
 * direct setters for lineage, teacher, and type, and a [reset] to clear all filters.
 * State changes reactively update [filteredTeachingsProvider].
 */
class TeachingFilterNotifier extends StateNotifier<TeachingFilterState> {
  TeachingFilterNotifier() : super(const TeachingFilterState());

  /** Set lineage filter */
  void setLineage(Tradition? lineage) {
    state = state.copyWith(lineage: lineage, clearLineage: lineage == null);
  }

  /** Toggle a topic tag */
  void toggleTopic(String topic) {
    final topics = Set<String>.from(state.topics);
    if (topics.contains(topic)) {
      topics.remove(topic);
    } else {
      topics.add(topic);
    }
    state = state.copyWith(topics: topics);
  }

  /** Set topics (replace all) */
  void setTopics(Set<String> topics) {
    state = state.copyWith(topics: topics);
  }

  /** Toggle a mood tag */
  void toggleMood(String mood) {
    final moods = Set<String>.from(state.moods);
    if (moods.contains(mood)) {
      moods.remove(mood);
    } else {
      moods.add(mood);
    }
    state = state.copyWith(moods: moods);
  }

  /** Set moods (replace all) */
  void setMoods(Set<String> moods) {
    state = state.copyWith(moods: moods);
  }

  /** Set teacher filter */
  void setTeacher(String? teacher) {
    state = state.copyWith(teacher: teacher, clearTeacher: teacher == null);
  }

  /** Set teaching type filter */
  void setType(TeachingType? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  /** Clear all filters */
  void reset() {
    state = const TeachingFilterState();
  }
}

/** Provider for teaching filter state */
final teachingFilterProvider = StateNotifierProvider<TeachingFilterNotifier, TeachingFilterState>((ref) {
  return TeachingFilterNotifier();
});

/** Derived provider for filtered teachings */
final filteredTeachingsProvider = Provider<List<Teaching>>((ref) {
  final filterState = ref.watch(teachingFilterProvider);
  return filterState.apply();
});

/** Provider for unique teachers with teaching counts */
final teacherListProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final counts = TeachingRepository.teacherCounts;
  final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries;
});

/** Provider for topic tag counts */
final topicCountsProvider = Provider<Map<String, int>>((ref) {
  return TeachingRepository.topicCounts;
});

/** Provider for mood tag counts */
final moodCountsProvider = Provider<Map<String, int>>((ref) {
  return TeachingRepository.moodCounts;
});

/** Provider for lineage counts */
final lineageCountsProvider = Provider<Map<Tradition, int>>((ref) {
  return TeachingRepository.lineageCounts;
});

// ============================================================
// Preferred Traditions Selection
// ============================================================

/**
 * Provider for user's preferred/enabled traditions
 * By default, all traditions are enabled
 */
final preferredTraditionsProvider = StateNotifierProvider<PreferredTraditionsNotifier, Set<Tradition>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PreferredTraditionsNotifier(storage);
});

/**
 * Manages the user's preferred/enabled [Tradition] set.
 *
 * All traditions are enabled by default. Users can toggle individual
 * traditions on/off, with a minimum of one always remaining enabled.
 * Persisted via [StorageService] as a list of tradition name strings.
 */
class PreferredTraditionsNotifier extends StateNotifier<Set<Tradition>> {
  final StorageService _storage;

  PreferredTraditionsNotifier(this._storage) : super(_loadFromStorage(_storage));

  static Set<Tradition> _loadFromStorage(StorageService storage) {
    final stored = storage.preferredTraditions;
    if (stored.isEmpty) {
      // Default: all traditions enabled
      return Tradition.values.toSet();
    }
    return stored.map((name) => Tradition.values.firstWhere((t) => t.name == name, orElse: () => Tradition.advaita)).toSet();
  }

  /** Toggle a tradition's enabled state */
  void toggle(Tradition tradition) {
    if (state.contains(tradition)) {
      // Don't allow disabling all traditions - keep at least one
      if (state.length > 1) {
        state = {...state}..remove(tradition);
      }
    } else {
      state = {...state, tradition};
    }
    _persist();
  }

  /** Check if a tradition is enabled */
  bool isEnabled(Tradition tradition) => state.contains(tradition);

  /** Enable all traditions */
  void enableAll() {
    state = Tradition.values.toSet();
    _persist();
  }

  void _persist() {
    _storage.setPreferredTraditions(state.map((t) => t.name).toList());
  }
}
