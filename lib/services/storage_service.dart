import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys
class StorageKeys {
  static const onboardingCompleted = 'pointer_onboarding_completed';
  static const favoritePointings = 'pointer_favorites';
  static const viewedPointings = 'pointer_viewed';
  static const viewedTeachings = 'pointer_viewed_teachings';
  static const preferredTraditions = 'pointer_preferred_traditions';
  static const settings = 'pointer_settings';
  static const subscriptionTier = 'pointer_subscription';
  static const hasEverSaved = 'pointer_has_ever_saved';
  static const currentPointingId = 'pointer_current_pointing_id';
  // Round-robin pointing order (shuffled once, persists across restarts)
  static const pointingOrder = 'pointer_pointing_order';
  static const pointingIndex = 'pointer_pointing_index';
}

/// App settings model
class AppSettings {
  final bool hapticFeedback;
  final bool autoAdvance;
  final int autoAdvanceDelay;
  final String theme;
  final bool highContrast;
  final bool oledMode;
  final bool zenMode;

  const AppSettings({
    this.hapticFeedback = true,
    this.autoAdvance = true,  // Default ON (opt-out)
    this.autoAdvanceDelay = 60, // 1 minute default
    this.theme = 'system',
    this.highContrast = false,
    this.oledMode = false,
    this.zenMode = false,
  });

  AppSettings copyWith({
    bool? hapticFeedback,
    bool? autoAdvance,
    int? autoAdvanceDelay,
    String? theme,
    bool? highContrast,
    bool? oledMode,
    bool? zenMode,
  }) {
    return AppSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      autoAdvanceDelay: autoAdvanceDelay ?? this.autoAdvanceDelay,
      theme: theme ?? this.theme,
      highContrast: highContrast ?? this.highContrast,
      oledMode: oledMode ?? this.oledMode,
      zenMode: zenMode ?? this.zenMode,
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
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hapticFeedback: json['hapticFeedback'] ?? true,
      autoAdvance: json['autoAdvance'] ?? true,  // Default ON
      autoAdvanceDelay: json['autoAdvanceDelay'] ?? 60, // 1 minute
      theme: json['theme'] ?? 'system',
      highContrast: json['highContrast'] ?? false,
      oledMode: json['oledMode'] ?? false,
      zenMode: json['zenMode'] ?? false,
    );
  }
}

/// Storage service for persisting app data
class StorageService {
  final SharedPreferences _prefs;

  // Cache for viewed teachings to avoid repeated JSON parsing
  Set<String>? _viewedTeachingIdsCache;

  StorageService(this._prefs);

  // Onboarding
  bool get hasCompletedOnboarding =>
      _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool completed) =>
      _prefs.setBool(StorageKeys.onboardingCompleted, completed);

  // First save milestone tracking
  bool get hasEverSaved =>
      _prefs.getBool(StorageKeys.hasEverSaved) ?? false;

  Future<void> markFirstSaveCompleted() =>
      _prefs.setBool(StorageKeys.hasEverSaved, true);

  // Favorites
  List<String> get favorites {
    final stored = _prefs.getString(StorageKeys.favoritePointings);
    if (stored == null) return [];
    return List<String>.from(jsonDecode(stored));
  }

  Future<void> addFavorite(String pointingId) async {
    final current = favorites;
    if (!current.contains(pointingId)) {
      current.add(pointingId);
      await _prefs.setString(StorageKeys.favoritePointings, jsonEncode(current));
    }
  }

  Future<void> removeFavorite(String pointingId) async {
    final current = favorites;
    current.remove(pointingId);
    await _prefs.setString(StorageKeys.favoritePointings, jsonEncode(current));
  }

  bool isFavorite(String pointingId) => favorites.contains(pointingId);

  // Viewed pointings
  List<Map<String, dynamic>> get viewedPointings {
    final stored = _prefs.getString(StorageKeys.viewedPointings);
    if (stored == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(stored));
  }

  Future<void> markPointingAsViewed(String pointingId) async {
    final viewed = viewedPointings;
    // Remove if already exists
    viewed.removeWhere((v) => v['id'] == pointingId);
    // Add to front, keep last 100
    viewed.insert(0, {'id': pointingId, 'viewedAt': DateTime.now().millisecondsSinceEpoch});
    final trimmed = viewed.take(100).toList();
    await _prefs.setString(StorageKeys.viewedPointings, jsonEncode(trimmed));
  }

  /// Get IDs of pointings viewed today (since midnight local time)
  Set<String> get viewedTodayIds {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayStartMs = todayStart.millisecondsSinceEpoch;

    return viewedPointings
        .where((v) => (v['viewedAt'] as int?) != null && v['viewedAt'] >= todayStartMs)
        .map((v) => v['id'] as String)
        .toSet();
  }

  // Viewed teachings (for library rotation - read items sink down)
  List<Map<String, dynamic>> get viewedTeachings {
    final stored = _prefs.getString(StorageKeys.viewedTeachings);
    if (stored == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(stored));
  }

  /// Mark a teaching as viewed (for library sorting)
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

  /// Get all viewed teaching IDs (cached for performance)
  /// Cache invalidated on markTeachingAsViewed()
  Set<String> get viewedTeachingIds {
    _viewedTeachingIdsCache ??= viewedTeachings.map((v) => v['id'] as String).toSet();
    return _viewedTeachingIdsCache!;
  }

  // Preferred traditions
  List<String> get preferredTraditions {
    final stored = _prefs.getString(StorageKeys.preferredTraditions);
    if (stored == null) return [];
    return List<String>.from(jsonDecode(stored));
  }

  Future<void> setPreferredTraditions(List<String> traditions) =>
      _prefs.setString(StorageKeys.preferredTraditions, jsonEncode(traditions));

  // Settings
  AppSettings get settings {
    final stored = _prefs.getString(StorageKeys.settings);
    if (stored == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(stored));
  }

  Future<void> updateSettings(AppSettings newSettings) =>
      _prefs.setString(StorageKeys.settings, jsonEncode(newSettings.toJson()));

  // Subscription
  String get subscriptionTier =>
      _prefs.getString(StorageKeys.subscriptionTier) ?? 'free';

  Future<void> setSubscriptionTier(String tier) =>
      _prefs.setString(StorageKeys.subscriptionTier, tier);

  // Current pointing persistence (for restoring state after app restart)
  String? get currentPointingId =>
      _prefs.getString(StorageKeys.currentPointingId);

  Future<void> setCurrentPointingId(String? id) async {
    if (id == null) {
      await _prefs.remove(StorageKeys.currentPointingId);
    } else {
      await _prefs.setString(StorageKeys.currentPointingId, id);
    }
  }

  // Round-robin pointing order (shuffled list of IDs, persists across restarts)
  List<String>? get pointingOrder {
    final stored = _prefs.getString(StorageKeys.pointingOrder);
    if (stored == null) return null;
    return List<String>.from(jsonDecode(stored));
  }

  Future<void> setPointingOrder(List<String> order) =>
      _prefs.setString(StorageKeys.pointingOrder, jsonEncode(order));

  // Current index in the pointing order
  int get pointingIndex => _prefs.getInt(StorageKeys.pointingIndex) ?? 0;

  Future<void> setPointingIndex(int index) =>
      _prefs.setInt(StorageKeys.pointingIndex, index);

  // Clear all
  Future<void> clearAll() async {
    await _prefs.remove(StorageKeys.onboardingCompleted);
    await _prefs.remove(StorageKeys.favoritePointings);
    await _prefs.remove(StorageKeys.viewedPointings);
    await _prefs.remove(StorageKeys.viewedTeachings);
    await _prefs.remove(StorageKeys.preferredTraditions);
    await _prefs.remove(StorageKeys.settings);
    await _prefs.remove(StorageKeys.subscriptionTier);
    await _prefs.remove(StorageKeys.hasEverSaved);
    await _prefs.remove(StorageKeys.currentPointingId);
    await _prefs.remove(StorageKeys.pointingOrder);
    await _prefs.remove(StorageKeys.pointingIndex);
    // Invalidate caches
    _viewedTeachingIdsCache = null;
  }
}
