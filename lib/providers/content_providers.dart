/// Content providers - Pointings, favorites, affinity, and teaching filters
///
/// Manages spiritual content: daily pointings with round-robin navigation,
/// user favorites, tradition affinity learning, and teaching library filters.
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pointings.dart';
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
