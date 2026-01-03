/// Content providers - Pointings, favorites, affinity, and teaching filters
///
/// Manages spiritual content: daily pointings with history navigation,
/// user favorites, tradition affinity learning, and teaching library filters.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pointings.dart';
import '../data/teaching.dart';
import '../services/affinity_service.dart';
import '../services/pointing_selector.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import 'core_providers.dart';

// ============================================================
// Tradition Affinity Learning
// ============================================================

/// Affinity service provider for tracking tradition preferences
final affinityServiceProvider = Provider<AffinityService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AffinityService(prefs);
});

// ============================================================
// Current Pointing with History Navigation
// ============================================================

/// Current pointing state - persists across app restarts
final currentPointingProvider =
    StateNotifierProvider<CurrentPointingNotifier, Pointing>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CurrentPointingNotifier(storage);
});

class CurrentPointingNotifier extends StateNotifier<Pointing> {
  final StorageService _storage;
  final PointingSelector _selector;
  final List<Pointing> _history = [];
  int _historyIndex = -1;

  CurrentPointingNotifier(this._storage, {PointingSelector? selector})
      : _selector = selector ?? PointingSelector(),
        super(_loadInitialPointing(_storage)) {
    // Add initial pointing to history
    _history.add(state);
    _historyIndex = 0;
    // Update widget with initial pointing
    _updateWidget(state);
  }

  /// Load persisted pointing or get a random one if not found
  static Pointing _loadInitialPointing(StorageService storage) {
    final savedId = storage.currentPointingId;
    if (savedId != null) {
      // Try to find the saved pointing by ID
      final saved = getPointingById(savedId);
      if (saved != null) {
        return saved;
      }
    }
    // Fall back to random pointing (no viewed filter on cold start)
    return getRandomPointing();
  }

  void nextPointing({Tradition? tradition, PointingContext? context}) {
    // If we're in the middle of history, clear forward history
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    // Get new pointing using selector (filters out viewed today, respects time context)
    final viewedToday = _storage.viewedTodayIds;
    state = _selector.selectPointing(
      all: pointings,
      viewedToday: viewedToday,
      respectTimeContext: true,
    );
    _history.add(state);
    _historyIndex = _history.length - 1;

    // Limit history to last 50 pointings
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }

    _persistAndUpdateWidget(state);
  }

  void previousPointing() {
    // Can't go back if we're at the beginning
    if (_historyIndex <= 0) {
      return;
    }

    // Navigate back in history
    _historyIndex--;
    state = _history[_historyIndex];
    _persistAndUpdateWidget(state);
  }

  void setPointing(Pointing pointing) {
    // When manually setting, add to history like nextPointing
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    state = pointing;
    _history.add(state);
    _historyIndex = _history.length - 1;

    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }

    _persistAndUpdateWidget(state);
  }

  /// Persist current pointing ID and update widget
  void _persistAndUpdateWidget(Pointing pointing) {
    _storage.setCurrentPointingId(pointing.id);
    _updateWidget(pointing);
  }

  /// Update home screen widget with current pointing
  void _updateWidget(Pointing pointing) {
    WidgetService.updateWidget(pointing);
  }
}

// ============================================================
// Favorites
// ============================================================

/// Favorites provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesNotifier(storage);
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final StorageService _storage;

  FavoritesNotifier(this._storage) : super(_storage.favorites);

  Future<void> toggle(String pointingId) async {
    if (state.contains(pointingId)) {
      await _storage.removeFavorite(pointingId);
      state = [...state]..remove(pointingId);
    } else {
      await _storage.addFavorite(pointingId);
      state = [...state, pointingId];
    }
  }

  bool isFavorite(String pointingId) => state.contains(pointingId);
}

// ============================================================
// Teaching Filter - Tag-based filtering for Library
// ============================================================

/// State for teaching filters
class TeachingFilterState {
  final Tradition? lineage;
  final Set<String> topics;
  final Set<String> moods;
  final String? teacher;
  final TeachingType? type;

  const TeachingFilterState({
    this.lineage,
    this.topics = const {},
    this.moods = const {},
    this.teacher,
    this.type,
  });

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

  /// Apply filters to get matching teachings
  List<Teaching> apply() {
    return TeachingRepository.filter(
      lineage: lineage,
      topics: topics.isEmpty ? null : topics,
      moods: moods.isEmpty ? null : moods,
      teacher: teacher,
      type: type,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      lineage != null ||
      topics.isNotEmpty ||
      moods.isNotEmpty ||
      teacher != null ||
      type != null;
}

/// Teaching filter notifier
class TeachingFilterNotifier extends StateNotifier<TeachingFilterState> {
  TeachingFilterNotifier() : super(const TeachingFilterState());

  /// Set lineage filter
  void setLineage(Tradition? lineage) {
    state = state.copyWith(lineage: lineage, clearLineage: lineage == null);
  }

  /// Toggle a topic tag
  void toggleTopic(String topic) {
    final topics = Set<String>.from(state.topics);
    if (topics.contains(topic)) {
      topics.remove(topic);
    } else {
      topics.add(topic);
    }
    state = state.copyWith(topics: topics);
  }

  /// Set topics (replace all)
  void setTopics(Set<String> topics) {
    state = state.copyWith(topics: topics);
  }

  /// Toggle a mood tag
  void toggleMood(String mood) {
    final moods = Set<String>.from(state.moods);
    if (moods.contains(mood)) {
      moods.remove(mood);
    } else {
      moods.add(mood);
    }
    state = state.copyWith(moods: moods);
  }

  /// Set moods (replace all)
  void setMoods(Set<String> moods) {
    state = state.copyWith(moods: moods);
  }

  /// Set teacher filter
  void setTeacher(String? teacher) {
    state = state.copyWith(teacher: teacher, clearTeacher: teacher == null);
  }

  /// Set teaching type filter
  void setType(TeachingType? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  /// Clear all filters
  void reset() {
    state = const TeachingFilterState();
  }
}

/// Provider for teaching filter state
final teachingFilterProvider =
    StateNotifierProvider<TeachingFilterNotifier, TeachingFilterState>((ref) {
  return TeachingFilterNotifier();
});

/// Derived provider for filtered teachings
final filteredTeachingsProvider = Provider<List<Teaching>>((ref) {
  final filterState = ref.watch(teachingFilterProvider);
  return filterState.apply();
});

/// Provider for unique teachers with teaching counts
final teacherListProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final counts = TeachingRepository.teacherCounts;
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries;
});

/// Provider for topic tag counts
final topicCountsProvider = Provider<Map<String, int>>((ref) {
  return TeachingRepository.topicCounts;
});

/// Provider for mood tag counts
final moodCountsProvider = Provider<Map<String, int>>((ref) {
  return TeachingRepository.moodCounts;
});

/// Provider for lineage counts
final lineageCountsProvider = Provider<Map<Tradition, int>>((ref) {
  return TeachingRepository.lineageCounts;
});

// ============================================================
// Preferred Traditions Selection
// ============================================================

/// Provider for user's preferred/enabled traditions
/// By default, all traditions are enabled
final preferredTraditionsProvider =
    StateNotifierProvider<PreferredTraditionsNotifier, Set<Tradition>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PreferredTraditionsNotifier(storage);
});

/// Notifier for managing preferred traditions
class PreferredTraditionsNotifier extends StateNotifier<Set<Tradition>> {
  final StorageService _storage;

  PreferredTraditionsNotifier(this._storage)
      : super(_loadFromStorage(_storage));

  static Set<Tradition> _loadFromStorage(StorageService storage) {
    final stored = storage.preferredTraditions;
    if (stored.isEmpty) {
      // Default: all traditions enabled
      return Tradition.values.toSet();
    }
    return stored
        .map((name) => Tradition.values.firstWhere(
              (t) => t.name == name,
              orElse: () => Tradition.advaita,
            ))
        .toSet();
  }

  /// Toggle a tradition's enabled state
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

  /// Check if a tradition is enabled
  bool isEnabled(Tradition tradition) => state.contains(tradition);

  /// Enable all traditions
  void enableAll() {
    state = Tradition.values.toSet();
    _persist();
  }

  void _persist() {
    _storage.setPreferredTraditions(state.map((t) => t.name).toList());
  }
}
