/// Content providers - Pointings, favorites, affinity, and teaching filters
///
/// Manages spiritual content: daily pointings with round-robin navigation,
/// user favorites, tradition affinity learning, and teaching library filters.
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

/// Affinity service provider for tracking tradition preferences
final affinityServiceProvider = Provider<AffinityService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AffinityService(prefs);
});

// ============================================================
// Current Pointing with Round-Robin Navigation
// ============================================================

/// Current pointing state - persists across app restarts with round-robin order
final currentPointingProvider =
    StateNotifierProvider<CurrentPointingNotifier, Pointing>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CurrentPointingNotifier(storage);
});

/// Round-robin pointing navigation
///
/// Shuffles all pointings once on first launch, persists the order.
/// Guarantees seeing all pointings before any repeats.
class CurrentPointingNotifier extends StateNotifier<Pointing> {
  final StorageService _storage;
  late List<String> _order;  // Shuffled pointing IDs
  late int _index;           // Current position in order

  CurrentPointingNotifier(this._storage) : super(_initializePointing(_storage)) {
    _initializeOrder();
    _updateWidget(state);
  }

  /// Initialize or load persisted pointing order
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

  /// Load persisted pointing or get first from order
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

  /// Move to next pointing in round-robin order
  void nextPointing({Tradition? tradition, PointingContext? context}) {
    _index = (_index + 1) % _order.length;

    // Reshuffle when completing a full cycle
    if (_index == 0) {
      _reshuffleOrder();
    }

    state = getPointingById(_order[_index]) ?? pointings.first;
    _persistAndUpdateWidget(state);
  }

  /// Move to previous pointing in round-robin order
  void previousPointing() {
    _index = (_index - 1 + _order.length) % _order.length;
    state = getPointingById(_order[_index]) ?? pointings.first;
    _persistAndUpdateWidget(state);
  }

  /// Jump to a specific pointing (e.g., from favorites or teacher sheet)
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

  /// Reshuffle order for next cycle (keeps current pointing at index 0)
  void _reshuffleOrder() {
    final current = _order[_index];
    _order.shuffle(Random());
    // Move current to front so it's not immediately repeated
    _order.remove(current);
    _order.insert(0, current);
    _index = 0;
    _storage.setPointingOrder(_order);
  }

  /// Persist current state and update widget
  void _persistAndUpdateWidget(Pointing pointing) {
    _storage.setCurrentPointingId(pointing.id);
    _storage.setPointingIndex(_index);
    _updateWidget(pointing);
  }

  /// Update home screen widget with current pointing
  void _updateWidget(Pointing pointing) {
    WidgetService.updateWidget(pointing);
  }

  /// Get current position info (for UI display if needed)
  int get currentIndex => _index;
  int get totalPointings => _order.length;
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
