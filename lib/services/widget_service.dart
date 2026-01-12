import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pointings.dart';
import '../providers/subscription_providers.dart' show kFreeAccessEnabled;

/// Keys for widget data storage
class _WidgetKeys {
  static const content = 'pointing_content';
  static const teacher = 'pointing_teacher';
  static const tradition = 'pointing_tradition';
  static const lastUpdated = 'pointing_last_updated';
  static const updateIntervalHours = 'update_interval_hours';
  // Multi-pointing widget cache (JSON array)
  static const pointingsCache = 'pointings_cache';
  // Premium status for widget gating
  static const isPremium = 'widget_is_premium';
  // Favorites list (JSON array of pointing IDs)
  static const favorites = 'widget_favorites';
}

/// Service for managing home screen widget updates.
///
/// Communicates with native iOS (WidgetKit) and Android (AppWidgetProvider)
/// widgets through shared storage via the home_widget package.
class WidgetService {
  /// iOS App Group identifier for shared storage
  static const iosAppGroup = 'group.com.dailypointer.widget';

  /// Android widget provider name
  static const androidWidgetName = 'PointerWidgetProvider';

  /// Default update interval in hours
  static const defaultUpdateIntervalHours = 3;

  /// Initialize widget service and register background callback
  ///
  /// NOTE: Widget is a PREMIUM feature. The widget will only show content
  /// for premium users. Call [setPremiumStatus] when subscription status changes.
  static Future<void> initialize() async {
    // Set iOS App Group for shared storage
    await HomeWidget.setAppGroupId(iosAppGroup);
    debugPrint('[WidgetService] App Group ID set: $iosAppGroup');
    // Register the callback for widget taps
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
    debugPrint('[WidgetService] Initialized');
  }

  /// Set premium status for widget gating.
  /// Call this when subscription status changes.
  static Future<void> setPremiumStatus(bool isPremium) async {
    try {
      await HomeWidget.saveWidgetData<bool>(_WidgetKeys.isPremium, isPremium);
      if (isPremium) {
        // Premium user - populate widget with data
        await populatePointingsCache();
      } else {
        // Free user - clear widget data
        await clearWidgetData();
      }
    } catch (e) {
      debugPrint('Failed to set widget premium status: $e');
    }
  }

  /// Check if widget is enabled for premium user
  /// Also respects kFreeAccessEnabled flag for free release mode
  static Future<bool> isPremiumEnabled() async {
    // Free access mode - all users get premium features
    if (kFreeAccessEnabled) {
      return true;
    }
    try {
      final isPremium = await HomeWidget.getWidgetData<bool>(_WidgetKeys.isPremium);
      return isPremium ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear widget data (for free users)
  static Future<void> clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.pointingsCache, '[]');
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.content, '');
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.teacher, '');
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.tradition, '');

      // Trigger widget update to show empty state
      await HomeWidget.updateWidget(
        iOSName: 'PointerWidget',
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.dailypointer.$androidWidgetName',
      );
      debugPrint('Widget data cleared (free user)');
    } catch (e) {
      debugPrint('Failed to clear widget data: $e');
    }
  }

  /// Populate the pointings cache for the multi-pointing widget.
  /// Stores all pointings as a JSON array for the Android StackView widget.
  /// Randomizes order and prioritizes favorites for better discovery.
  /// Also syncs favorites list for save button state.
  /// Only works for premium users.
  static Future<void> populatePointingsCache() async {
    debugPrint('[WidgetService] populatePointingsCache called');
    try {
      // Check premium status first
      final isPremium = await isPremiumEnabled();
      debugPrint('[WidgetService] isPremiumEnabled: $isPremium, kFreeAccessEnabled: $kFreeAccessEnabled');
      if (!isPremium) {
        debugPrint('[WidgetService] Widget cache not populated - not premium');
        return;
      }

      // Load favorites list first
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('favorite_pointings');
      final favoriteIds = stored != null
          ? Set<String>.from(jsonDecode(stored))
          : <String>{};

      // Separate favorites from non-favorites
      final favoritePointings = <Pointing>[];
      final otherPointings = <Pointing>[];

      for (final p in pointings) {
        if (favoriteIds.contains(p.id)) {
          favoritePointings.add(p);
        } else {
          otherPointings.add(p);
        }
      }

      // Shuffle both lists for variety
      favoritePointings.shuffle();
      otherPointings.shuffle();

      // Interleave favorites throughout the list for better distribution
      // Pattern: favorite, other, other, other, favorite, other, other, other...
      // This ensures favorites appear regularly without clustering at start
      final interleavedList = <Pointing>[];
      int favIndex = 0;
      int otherIndex = 0;
      int othersBetweenFavorites = 3; // Show 3 others between each favorite

      while (otherIndex < otherPointings.length || favIndex < favoritePointings.length) {
        // Add a favorite if available
        if (favIndex < favoritePointings.length) {
          interleavedList.add(favoritePointings[favIndex]);
          favIndex++;
        }

        // Add several others
        for (int i = 0; i < othersBetweenFavorites && otherIndex < otherPointings.length; i++) {
          interleavedList.add(otherPointings[otherIndex]);
          otherIndex++;
        }
      }

      // Convert to JSON format expected by widget
      final pointingsJson = interleavedList.map((p) {
        final traditionInfo = traditions[p.tradition];
        return {
          'id': p.id,
          'content': p.content,
          'tradition': traditionInfo?.name ?? p.tradition.name,
          'teacher': p.teacher ?? '',
        };
      }).toList();

      // Save as JSON string
      final jsonString = jsonEncode(pointingsJson);
      debugPrint('[WidgetService] Saving ${pointingsJson.length} pointings to widget cache (${jsonString.length} bytes)');
      await HomeWidget.saveWidgetData<String>(
        _WidgetKeys.pointingsCache,
        jsonString,
      );

      // Verify the data was saved correctly
      final verifyData = await HomeWidget.getWidgetData<String>(_WidgetKeys.pointingsCache);
      if (verifyData != null) {
        debugPrint('[WidgetService] VERIFIED: Cache saved successfully (${verifyData.length} bytes)');
      } else {
        debugPrint('[WidgetService] ERROR: Failed to verify cache save - data is null!');
      }

      debugPrint('[WidgetService] Widget cache populated: ${favoritePointings.length} favorites, '
          '${otherPointings.length} others, ${interleavedList.length} total');

      // Also sync favorites from SharedPreferences
      await _syncFavoritesFromStorage();

      // Trigger widget update
      await HomeWidget.updateWidget(
        iOSName: 'PointerWidget',
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.dailypointer.$androidWidgetName',
      );
    } catch (e) {
      debugPrint('Failed to populate widget cache: $e');
    }
  }

  /// Internal helper to sync favorites from SharedPreferences to widget.
  static Future<void> _syncFavoritesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('favorite_pointings');
      final favorites = stored != null
          ? List<String>.from(jsonDecode(stored))
          : <String>[];

      await HomeWidget.saveWidgetData<String>(
        _WidgetKeys.favorites,
        jsonEncode(favorites),
      );

      debugPrint('Widget favorites synced: ${favorites.length} items');
    } catch (e) {
      debugPrint('Failed to sync favorites to widget: $e');
    }
  }

  /// Update widget with the given pointing data.
  /// Only updates for premium users.
  static Future<void> updateWidget(Pointing pointing) async {
    // Check premium status first
    final isPremium = await isPremiumEnabled();
    if (!isPremium) {
      debugPrint('Widget not updated - not premium');
      return;
    }

    final traditionInfo = traditions[pointing.tradition];

    // Save data to shared storage
    await Future.wait([
      HomeWidget.saveWidgetData<String>(_WidgetKeys.content, pointing.content),
      HomeWidget.saveWidgetData<String>(_WidgetKeys.teacher, pointing.teacher ?? ''),
      HomeWidget.saveWidgetData<String>(_WidgetKeys.tradition, traditionInfo?.name ?? pointing.tradition.name),
      HomeWidget.saveWidgetData<String>(_WidgetKeys.lastUpdated, DateTime.now().toIso8601String()),
    ]);

    // Trigger widget update on both platforms
    await HomeWidget.updateWidget(
      iOSName: 'PointerWidget',
      androidName: androidWidgetName,
      qualifiedAndroidName: 'com.dailypointer.$androidWidgetName',
    );
  }

  /// Update widget with a random pointing (for background refresh).
  /// Only updates for premium users.
  static Future<void> updateWithRandomPointing() async {
    final isPremium = await isPremiumEnabled();
    if (!isPremium) return;

    final pointing = getRandomPointing();
    await updateWidget(pointing);
  }

  /// Get the current pointing data from widget storage
  static Future<WidgetPointing?> getCurrentWidgetPointing() async {
    final content = await HomeWidget.getWidgetData<String>(_WidgetKeys.content);
    if (content == null) return null;

    final teacher = await HomeWidget.getWidgetData<String>(_WidgetKeys.teacher);
    final tradition = await HomeWidget.getWidgetData<String>(_WidgetKeys.tradition);
    final lastUpdated = await HomeWidget.getWidgetData<String>(_WidgetKeys.lastUpdated);

    return WidgetPointing(
      content: content,
      teacher: teacher?.isNotEmpty == true ? teacher : null,
      tradition: tradition ?? 'Unknown',
      lastUpdated: lastUpdated != null ? DateTime.tryParse(lastUpdated) : null,
    );
  }

  /// Sync widget update schedule with notification settings.
  ///
  /// When user changes notification frequency, call this to update
  /// the widget's refresh interval accordingly.
  static Future<void> syncScheduleWithNotifications(int intervalHours) async {
    try {
      await HomeWidget.saveWidgetData<int>(
        _WidgetKeys.updateIntervalHours,
        intervalHours,
      );

      // Force a widget refresh to apply new schedule
      await HomeWidget.updateWidget(
        iOSName: 'PointerWidget',
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.dailypointer.$androidWidgetName',
      );

      debugPrint('Widget schedule synced: $intervalHours hours');
    } catch (e) {
      debugPrint('Failed to sync widget schedule: $e');
    }
  }

  /// Check if any widgets are currently installed
  static Future<bool> hasActiveWidgets() async {
    try {
      // This is a best-effort check - may not be 100% accurate
      final data = await HomeWidget.getWidgetData<String>(_WidgetKeys.lastUpdated);
      return data != null;
    } catch (e) {
      return false;
    }
  }

  /// Process any pending widget actions from iOS.
  /// iOS widget intents store pending saves in UserDefaults via app groups.
  /// Call this on app launch/resume to process queued actions.
  static Future<void> processPendingWidgetActions() async {
    try {
      // Check for pending saves (iOS widget save button stores content here)
      final pendingSavesJson = await HomeWidget.getWidgetData<String>('pending_saves');
      if (pendingSavesJson != null && pendingSavesJson.isNotEmpty) {
        final List<dynamic> pendingSaves = jsonDecode(pendingSavesJson);

        if (pendingSaves.isNotEmpty) {
          debugPrint('Processing ${pendingSaves.length} pending widget saves');

          // Process each pending save
          for (final content in pendingSaves) {
            if (content is String && content.isNotEmpty) {
              await _savePointingByContent(content);
            }
          }

          // Clear pending saves
          await HomeWidget.saveWidgetData<String>('pending_saves', '[]');
          debugPrint('Pending widget saves processed and cleared');
        }
      }
    } catch (e) {
      debugPrint('Error processing pending widget actions: $e');
    }
  }

  /// Save a pointing by matching its content.
  /// Used by iOS widget intent callback processing.
  static Future<void> _savePointingByContent(String content) async {
    try {
      // Find matching pointing by content
      final matching = pointings.where((p) => p.content == content).toList();
      if (matching.isEmpty) {
        debugPrint('Could not find pointing to save by content');
        return;
      }

      final pointing = matching.first;
      final prefs = await SharedPreferences.getInstance();
      const favoritesKey = 'favorite_pointings';
      final stored = prefs.getString(favoritesKey);
      final favorites = stored != null
          ? List<String>.from(jsonDecode(stored))
          : <String>[];

      if (!favorites.contains(pointing.id)) {
        favorites.add(pointing.id);
        await prefs.setString(favoritesKey, jsonEncode(favorites));
        debugPrint('Widget save: Added ${pointing.id} to favorites');

        // Sync favorites to widget
        await updateFavorites(favorites.toSet());
      }
    } catch (e) {
      debugPrint('Error saving pointing by content: $e');
    }
  }

  /// Refresh widget to pick up theme changes.
  /// Call this when app resumes or user changes theme.
  static Future<void> refreshWidget() async {
    try {
      await HomeWidget.updateWidget(
        iOSName: 'PointerWidget',
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.dailypointer.$androidWidgetName',
      );
      debugPrint('Widget refreshed for theme update');
    } catch (e) {
      debugPrint('Failed to refresh widget: $e');
    }
  }

  /// Update favorites list for widget display.
  /// Widget shows filled heart for favorited pointings.
  static Future<void> updateFavorites(Set<String> favoriteIds) async {
    try {
      // Check premium status first
      final isPremium = await isPremiumEnabled();
      if (!isPremium) {
        debugPrint('Widget favorites not updated - not premium');
        return;
      }

      // Save favorites as JSON array
      final jsonString = jsonEncode(favoriteIds.toList());
      await HomeWidget.saveWidgetData<String>(
        _WidgetKeys.favorites,
        jsonString,
      );

      debugPrint('Widget favorites updated: ${favoriteIds.length} items');

      // Trigger widget update to reflect favorite state
      await HomeWidget.updateWidget(
        iOSName: 'PointerWidget',
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.dailypointer.$androidWidgetName',
      );
    } catch (e) {
      debugPrint('Failed to update widget favorites: $e');
    }
  }
}

/// Simplified pointing data for widget display
class WidgetPointing {
  final String content;
  final String? teacher;
  final String tradition;
  final DateTime? lastUpdated;

  const WidgetPointing({
    required this.content,
    this.teacher,
    required this.tradition,
    this.lastUpdated,
  });
}

/// Background callback for widget interactions
///
/// Handles URIs in format: pointer://widget/{action}
/// Supported actions:
/// - /refresh: Load a new random pointing
/// - /save: Save current pointing to favorites
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  debugPrint('Widget callback received: $uri');

  final path = uri.path;

  if (path == '/refresh' || uri.host == 'refresh') {
    // User tapped refresh - repopulate cache and update widget
    await WidgetService.populatePointingsCache();
  } else if (path == '/prefetch' || uri.host == 'prefetch') {
    // Widget requesting more data - repopulate cache
    await WidgetService.populatePointingsCache();
  } else if (path == '/save' || uri.host == 'save') {
    // User tapped save - save current pointing to favorites
    await _saveCurrentWidgetPointing();
  } else if (uri.host == 'open') {
    // User tapped to open app - handled by native code
    // The app will open automatically
  }
}

/// Save the current widget pointing to favorites
Future<void> _saveCurrentWidgetPointing() async {
  try {
    // Get current pointing content from widget storage
    final content = await HomeWidget.getWidgetData<String>('pointing_content');
    if (content == null || content.isEmpty) {
      debugPrint('No pointing content to save');
      return;
    }

    // Find matching pointing by content
    final matching = pointings.where((p) => p.content == content).toList();

    if (matching.isEmpty) {
      debugPrint('Could not find pointing to save');
      return;
    }

    final pointing = matching.first;

    // Initialize SharedPreferences and save to favorites
    final prefs = await SharedPreferences.getInstance();
    final favoritesKey = 'favorite_pointings';
    final stored = prefs.getString(favoritesKey);
    final favorites = stored != null
        ? List<String>.from(jsonDecode(stored))
        : <String>[];

    if (!favorites.contains(pointing.id)) {
      favorites.add(pointing.id);
      await prefs.setString(favoritesKey, jsonEncode(favorites));
      debugPrint('Saved pointing ${pointing.id} to favorites');

      // Sync favorites to widget data so heart icon updates immediately
      await WidgetService.updateFavorites(favorites.toSet());
    } else {
      debugPrint('Pointing ${pointing.id} already in favorites');
    }
  } catch (e) {
    debugPrint('Error saving widget pointing: $e');
  }
}
