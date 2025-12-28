import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys
class StorageKeys {
  static const onboardingCompleted = 'pointer_onboarding_completed';
  static const favoritePointings = 'pointer_favorites';
  static const viewedPointings = 'pointer_viewed';
  static const preferredTraditions = 'pointer_preferred_traditions';
  static const settings = 'pointer_settings';
  static const subscriptionTier = 'pointer_subscription';
  static const hasEverSaved = 'pointer_has_ever_saved';
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
    this.autoAdvance = false,
    this.autoAdvanceDelay = 30,
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
      autoAdvance: json['autoAdvance'] ?? false,
      autoAdvanceDelay: json['autoAdvanceDelay'] ?? 30,
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

  // Clear all
  Future<void> clearAll() async {
    await _prefs.remove(StorageKeys.onboardingCompleted);
    await _prefs.remove(StorageKeys.favoritePointings);
    await _prefs.remove(StorageKeys.viewedPointings);
    await _prefs.remove(StorageKeys.preferredTraditions);
    await _prefs.remove(StorageKeys.settings);
    await _prefs.remove(StorageKeys.subscriptionTier);
    await _prefs.remove(StorageKeys.hasEverSaved);
  }
}
