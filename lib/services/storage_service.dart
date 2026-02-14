import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * [SharedPreferences] key constants for all persisted app data.
 *
 * Each key is namespaced with `pointer_` to avoid collisions with
 * third-party packages that share the same preferences store.
 */
class StorageKeys {
  /** Whether the user has completed the onboarding flow. */
  static const onboardingCompleted = 'pointer_onboarding_completed';

  /** JSON-encoded list of saved [Pointing] IDs. */
  static const favoritePointings = 'pointer_favorites';

  /** JSON-encoded list of saved [Article] IDs. */
  static const favoriteArticles = 'pointer_favorite_articles';

  /** JSON-encoded list of recently viewed [Pointing] entries (id + timestamp). */
  static const viewedPointings = 'pointer_viewed';

  /** JSON-encoded list of recently viewed teaching entries for library sort rotation. */
  static const viewedTeachings = 'pointer_viewed_teachings';

  /** JSON-encoded list of user-selected [Tradition] names. */
  static const preferredTraditions = 'pointer_preferred_traditions';

  /** JSON-encoded [AppSettings] object containing all user preferences. */
  static const settings = 'pointer_settings';

  /** ID of the last viewed [Pointing], used to restore state after restart. */
  static const currentPointingId = 'pointer_current_pointing_id';

  /** JSON-encoded shuffled list of [Pointing] IDs for round-robin navigation. */
  static const pointingOrder = 'pointer_pointing_order';

  /** Current index into the [pointingOrder] list. */
  static const pointingIndex = 'pointer_pointing_index';
}

/**
 * Immutable model of all user-configurable app settings.
 *
 * Persisted as JSON via [StorageService.updateSettings] and
 * loaded via [StorageService.settings]. Defaults are chosen for
 * a mindful, non-intrusive experience (auto-advance on, haptics on).
 */
class AppSettings {
  /** Whether haptic feedback is enabled for interactions. */
  final bool hapticFeedback;

  /** Whether pointings auto-advance to the next after [autoAdvanceDelay] seconds. */
  final bool autoAdvance;

  /** Seconds to wait before auto-advancing to the next pointing. */
  final int autoAdvanceDelay;

  /** Theme mode string: `'system'`, `'light'`, or `'dark'`. */
  final String theme;

  /** Whether high-contrast colour palette is active for accessibility. */
  final bool highContrast;

  /** Whether OLED-optimized true-black background is enabled. */
  final bool oledMode;

  /** Whether zen mode is active (hides UI chrome for distraction-free reading). */
  final bool zenMode;

  /** Whether animations and transitions are enabled (false forces reduced motion). */
  final bool animationsEnabled;

  const AppSettings({
    this.hapticFeedback = true,
    this.autoAdvance = true, // Default ON (opt-out)
    this.autoAdvanceDelay = 60, // 1 minute default
    this.theme = 'system',
    this.highContrast = false,
    this.oledMode = false,
    this.zenMode = false,
    this.animationsEnabled = true,
  });

  AppSettings copyWith({
    bool? hapticFeedback,
    bool? autoAdvance,
    int? autoAdvanceDelay,
    String? theme,
    bool? highContrast,
    bool? oledMode,
    bool? zenMode,
    bool? animationsEnabled,
  }) {
    return AppSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      autoAdvanceDelay: autoAdvanceDelay ?? this.autoAdvanceDelay,
      theme: theme ?? this.theme,
      highContrast: highContrast ?? this.highContrast,
      oledMode: oledMode ?? this.oledMode,
      zenMode: zenMode ?? this.zenMode,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'hapticFeedback': hapticFeedback,
    'autoAdvance': autoAdvance,
    'autoAdvanceDelay': autoAdvanceDelay,
    'theme': theme,
    'highContrast': highContrast,
    'oledMode': oledMode,
    'zenMode': zenMode,
    'animationsEnabled': animationsEnabled,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hapticFeedback: json['hapticFeedback'] ?? true,
      autoAdvance: json['autoAdvance'] ?? true, // Default ON
      autoAdvanceDelay: json['autoAdvanceDelay'] ?? 60, // 1 minute
      theme: json['theme'] ?? 'system',
      highContrast: json['highContrast'] ?? false,
      oledMode: json['oledMode'] ?? false,
      zenMode: json['zenMode'] ?? false,
      animationsEnabled: json['animationsEnabled'] ?? true,
    );
  }
}

/**
 * Persistent storage wrapper around [SharedPreferences].
 *
 * Provides typed access to all app data — favourites, view history,
 * settings, and round-robin pointing order — via
 * [StorageKeys]. Caches frequently-accessed data (viewed teaching IDs)
 * to avoid repeated JSON parsing.
 */
class StorageService {
  final SharedPreferences _prefs;

  /** In-memory cache for viewed teaching IDs to avoid repeated JSON parsing. */
  Set<String>? _viewedTeachingIdsCache;

  StorageService(this._prefs);

  /** Whether the user has completed the onboarding flow. */
  bool get hasCompletedOnboarding => _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  /** Persist the onboarding completion state. */
  Future<void> setOnboardingCompleted(bool completed) => _prefs.setBool(StorageKeys.onboardingCompleted, completed);

  /** List of saved [Pointing] IDs, ordered from oldest to newest. */
  List<String> get favorites {
    final stored = _prefs.getString(StorageKeys.favoritePointings);
    if (stored == null) return [];
    return List<String>.from(jsonDecode(stored));
  }

  /** Add a [Pointing] ID to the favourites list (no-op if already present). */
  Future<void> addFavorite(String pointingId) async {
    final current = favorites;
    if (!current.contains(pointingId)) {
      current.add(pointingId);
      await _prefs.setString(StorageKeys.favoritePointings, jsonEncode(current));
    }
  }

  /** Remove a [Pointing] ID from the favourites list. */
  Future<void> removeFavorite(String pointingId) async {
    final current = favorites;
    current.remove(pointingId);
    await _prefs.setString(StorageKeys.favoritePointings, jsonEncode(current));
  }

  /** Whether the given [Pointing] ID is in the favourites list. */
  bool isFavorite(String pointingId) => favorites.contains(pointingId);

  // ---- Article Favorites ----

  /** Saved article IDs, ordered by save time (newest last). */
  List<String> get favoriteArticles {
    final stored = _prefs.getString(StorageKeys.favoriteArticles);
    if (stored == null) return [];
    return List<String>.from(jsonDecode(stored));
  }

  /** Add an [Article] ID to the saved articles list. */
  Future<void> addFavoriteArticle(String articleId) async {
    final current = favoriteArticles;
    if (!current.contains(articleId)) {
      current.add(articleId);
      await _prefs.setString(StorageKeys.favoriteArticles, jsonEncode(current));
    }
  }

  /** Remove an [Article] ID from the saved articles list. */
  Future<void> removeFavoriteArticle(String articleId) async {
    final current = favoriteArticles;
    current.remove(articleId);
    await _prefs.setString(StorageKeys.favoriteArticles, jsonEncode(current));
  }

  /** Recently viewed pointings as a list of `{id, viewedAt}` maps, newest first. */
  List<Map<String, dynamic>> get viewedPointings {
    final stored = _prefs.getString(StorageKeys.viewedPointings);
    if (stored == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(stored));
  }

  /** Record a [Pointing] as viewed, moving it to the front of the list (capped at 100). */
  Future<void> markPointingAsViewed(String pointingId) async {
    final viewed = viewedPointings;
    // Remove if already exists
    viewed.removeWhere((v) => v['id'] == pointingId);
    // Add to front, keep last 100
    viewed.insert(0, {'id': pointingId, 'viewedAt': DateTime.now().millisecondsSinceEpoch});
    final trimmed = viewed.take(100).toList();
    await _prefs.setString(StorageKeys.viewedPointings, jsonEncode(trimmed));
  }

  /** Get IDs of pointings viewed today (since midnight local time) */
  Set<String> get viewedTodayIds {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayStartMs = todayStart.millisecondsSinceEpoch;

    return viewedPointings.where((v) => (v['viewedAt'] as int?) != null && v['viewedAt'] >= todayStartMs).map((v) => v['id'] as String).toSet();
  }

  /**
   * Recently viewed teachings as a list of `{id, viewedAt}` maps, newest first.
   * Used by the library screen to sink already-read items in sort order.
   */
  List<Map<String, dynamic>> get viewedTeachings {
    final stored = _prefs.getString(StorageKeys.viewedTeachings);
    if (stored == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(stored));
  }

  /** Mark a teaching as viewed (for library sorting) */
  Future<void> markTeachingAsViewed(String teachingId) async {
    final viewed = viewedTeachings;
    // Remove if already exists (to update timestamp)
    viewed.removeWhere((v) => v['id'] == teachingId);
    // Add to front with timestamp
    viewed.insert(0, {'id': teachingId, 'viewedAt': DateTime.now().millisecondsSinceEpoch});
    // Keep last 200 teachings (more than pointings since library is larger)
    final trimmed = viewed.take(200).toList();
    await _prefs.setString(StorageKeys.viewedTeachings, jsonEncode(trimmed));
    // Invalidate cache - will be repopulated on next access
    _viewedTeachingIdsCache = null;
  }

  /**
   * Get all viewed teaching IDs (cached for performance)
   * Cache invalidated on markTeachingAsViewed()
   */
  Set<String> get viewedTeachingIds {
    _viewedTeachingIdsCache ??= viewedTeachings.map((v) => v['id'] as String).toSet();
    return _viewedTeachingIdsCache!;
  }

  /** User's preferred [Tradition] names, used for content personalisation. */
  List<String> get preferredTraditions {
    final stored = _prefs.getString(StorageKeys.preferredTraditions);
    if (stored == null) return [];
    return List<String>.from(jsonDecode(stored));
  }

  /** Persist the user's preferred [Tradition] names. */
  Future<void> setPreferredTraditions(List<String> traditions) => _prefs.setString(StorageKeys.preferredTraditions, jsonEncode(traditions));

  /** Current [AppSettings], returning defaults if nothing is persisted. */
  AppSettings get settings {
    final stored = _prefs.getString(StorageKeys.settings);
    if (stored == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(stored));
  }

  /** Persist updated [AppSettings] as JSON. */
  Future<void> updateSettings(AppSettings newSettings) => _prefs.setString(StorageKeys.settings, jsonEncode(newSettings.toJson()));

  /** ID of the last-viewed [Pointing], used to restore position on restart. */
  String? get currentPointingId => _prefs.getString(StorageKeys.currentPointingId);

  /** Set or clear the current [Pointing] ID for state restoration. */
  Future<void> setCurrentPointingId(String? id) async {
    if (id == null) {
      await _prefs.remove(StorageKeys.currentPointingId);
    } else {
      await _prefs.setString(StorageKeys.currentPointingId, id);
    }
  }

  /** Shuffled list of [Pointing] IDs for round-robin navigation, or `null` if not yet initialized. */
  List<String>? get pointingOrder {
    final stored = _prefs.getString(StorageKeys.pointingOrder);
    if (stored == null) return null;
    return List<String>.from(jsonDecode(stored));
  }

  /** Persist the shuffled round-robin [Pointing] order. */
  Future<void> setPointingOrder(List<String> order) => _prefs.setString(StorageKeys.pointingOrder, jsonEncode(order));

  /** Current zero-based index into the [pointingOrder] list. */
  int get pointingIndex => _prefs.getInt(StorageKeys.pointingIndex) ?? 0;

  /** Persist the current round-robin index. */
  Future<void> setPointingIndex(int index) => _prefs.setInt(StorageKeys.pointingIndex, index);

  /** Remove all persisted data and invalidate caches. Used for account reset / testing. */
  Future<void> clearAll() async {
    await _prefs.remove(StorageKeys.onboardingCompleted);
    await _prefs.remove(StorageKeys.favoritePointings);
    await _prefs.remove(StorageKeys.favoriteArticles);
    await _prefs.remove(StorageKeys.viewedPointings);
    await _prefs.remove(StorageKeys.viewedTeachings);
    await _prefs.remove(StorageKeys.preferredTraditions);
    await _prefs.remove(StorageKeys.settings);
    await _prefs.remove(StorageKeys.currentPointingId);
    await _prefs.remove(StorageKeys.pointingOrder);
    await _prefs.remove(StorageKeys.pointingIndex);
    // Invalidate caches
    _viewedTeachingIdsCache = null;
  }
}
