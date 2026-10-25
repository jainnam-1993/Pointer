import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
export '../models/app_settings.dart';

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

  // Notification keys
  /** Whether notifications are globally enabled. */
  static const notificationsEnabled = 'pointer_notifications_enabled';

  /** JSON-encoded [NotificationSchedule] configuration. */
  static const notificationSchedule = 'pointer_notification_schedule';

  /** Notification interval in minutes (used by WorkManager background tasks). */
  static const notificationFrequency = 'pointer_notification_frequency';

  /** Start hour of the notification window (used by WorkManager background tasks). */
  static const notificationStartHour = 'pointer_notification_start_hour';

  /** End hour of the notification window (used by WorkManager background tasks). */
  static const notificationEndHour = 'pointer_notification_end_hour';

  /** JSON-encoded list of recently shown notification IDs (duplicate prevention). */
  static const recentNotificationIds = 'pointer_recent_notification_ids';

  /** JSON-encoded pointings cache for background notification access. */
  static const notificationPointingsCache = 'pointer_notification_pointings_cache';

  // Affinity keys
  /** JSON-encoded tradition view counts for affinity learning. */
  static const affinityViewCounts = 'pointer_affinity_view_counts';

  /** JSON-encoded tradition save counts for affinity learning. */
  static const affinitySaveCounts = 'pointer_affinity_save_counts';

  /** ISO timestamp of last affinity data update. */
  static const affinityLastUpdated = 'pointer_affinity_last_updated';

  // Usage keys
  /** Query-string-encoded daily usage data (viewCount, lastResetDate). */
  static const dailyUsage = 'pointer_daily_usage';

  // Share keys
  /** Persisted share template preference (enum name string). */
  static const shareTemplate = 'pointer_share_template';

  /** Persisted share format preference (enum name string). */
  static const shareFormat = 'pointer_share_format';
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

  /**
   * List of saved [Pointing] IDs, ordered from oldest to newest.
   *
   * Stored as a JSON array of id strings, the format this class, the iOS
   * pending-saves merge and the Android widget all write. A value in any
   * other shape (a list written with setStringList, a JSON value that is not
   * an array, garbled text) keeps the ids it can read instead of throwing,
   * and the next save rewrites it in the right format.
   */
  List<String> get favorites => decodeFavoriteIds(_prefs.get(StorageKeys.favoritePointings));

  /** Add a [Pointing] ID to the favourites list (no-op if already present). */
  Future<void> addFavorite(String pointingId) async {
    // The home-screen widget writes this key natively; reload so a widget Save
    // made while the app is open is not overwritten by a stale cached list.
    await _prefs.reload();
    final current = favorites;
    if (!current.contains(pointingId)) {
      current.add(pointingId);
      await _prefs.setString(StorageKeys.favoritePointings, jsonEncode(current));
    }
  }

  /** Remove a [Pointing] ID from the favourites list. */
  Future<void> removeFavorite(String pointingId) async {
    await _prefs.reload();
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

  /**
   * Current [AppSettings], returning defaults if nothing is persisted.
   *
   * A stored value that is not a JSON object (an interrupted write, an older
   * schema, a manual edit) also yields defaults instead of throwing. The bad
   * value stays in place until the next [updateSettings] overwrites it.
   */
  AppSettings get settings {
    final stored = _prefs.getString(StorageKeys.settings);
    if (stored == null) return const AppSettings();
    final Object? decoded;
    try {
      decoded = jsonDecode(stored);
    } on FormatException catch (error) {
      debugPrint('StorageService: saved settings are not valid JSON ($error); using defaults');
      return const AppSettings();
    }
    if (decoded is! Map<String, dynamic>) {
      debugPrint('StorageService: saved settings are a ${decoded.runtimeType}, not a JSON object; using defaults');
      return const AppSettings();
    }
    return AppSettings.fromJson(decoded);
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

/**
 * Reads a stored favorites value into ids, never throwing. Accepts the JSON
 * array string every writer produces, and a native string list; keeps the
 * string ids and drops anything else, logging the bad shape once.
 */
List<String> decodeFavoriteIds(Object? raw) {
  if (raw == null) return [];
  Object? decoded = raw;
  if (raw is String) {
    if (raw.isEmpty) return [];
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      _logBadFavorites('not valid JSON ($error)');
      return [];
    }
  }
  if (decoded is! List) {
    _logBadFavorites('a ${decoded.runtimeType}, not a list');
    return [];
  }
  final ids = decoded.whereType<String>().where((id) => id.isNotEmpty).toList();
  if (ids.length != decoded.length) _logBadFavorites('a list with ${decoded.length - ids.length} non-id entries');
  return ids;
}

bool _loggedBadFavorites = false;

void _logBadFavorites(String what) {
  if (_loggedBadFavorites) return;
  _loggedBadFavorites = true;
  debugPrint('StorageService: saved favorites are $what; keeping the readable ids');
}
