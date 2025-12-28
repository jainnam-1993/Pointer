import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pointings.dart';

/// Keys for widget data storage
class _WidgetKeys {
  static const content = 'pointing_content';
  static const teacher = 'pointing_teacher';
  static const tradition = 'pointing_tradition';
  static const lastUpdated = 'pointing_last_updated';
  static const updateIntervalHours = 'update_interval_hours';
  // Multi-pointing widget cache (JSON array)
  static const pointingsCache = 'pointings_cache';
}

/// Service for managing home screen widget updates.
///
/// Communicates with native iOS (WidgetKit) and Android (AppWidgetProvider)
/// widgets through shared storage via the home_widget package.
class WidgetService {
  /// iOS App Group identifier for shared storage
  static const iosAppGroup = 'group.com.pointer.widget';

  /// Android widget provider name
  static const androidWidgetName = 'PointerWidgetProvider';

  /// Default update interval in hours
  static const defaultUpdateIntervalHours = 3;

  /// Initialize widget service and register background callback
  static Future<void> initialize() async {
    // Set iOS App Group for shared storage
    await HomeWidget.setAppGroupId(iosAppGroup);
    // Register the callback for widget taps
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
    // Populate widget cache with pointings
    await populatePointingsCache();
  }

  /// Populate the pointings cache for the multi-pointing widget.
  /// Stores all pointings as a JSON array for the Android StackView widget.
  static Future<void> populatePointingsCache() async {
    try {
      // Convert all pointings to JSON format expected by widget
      final pointingsJson = pointings.map((p) {
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
      await HomeWidget.saveWidgetData<String>(
        _WidgetKeys.pointingsCache,
        jsonString,
      );

      debugPrint('Widget cache populated with ${pointings.length} pointings');

      // Trigger widget update
      await HomeWidget.updateWidget(
        iOSName: 'PointerWidget',
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.pointer.$androidWidgetName',
      );
    } catch (e) {
      debugPrint('Failed to populate widget cache: $e');
    }
  }

  /// Update widget with the given pointing data
  static Future<void> updateWidget(Pointing pointing) async {
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
      qualifiedAndroidName: 'com.pointer.$androidWidgetName',
    );
  }

  /// Update widget with a random pointing (for background refresh)
  static Future<void> updateWithRandomPointing() async {
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
        qualifiedAndroidName: 'com.pointer.$androidWidgetName',
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
    } else {
      debugPrint('Pointing ${pointing.id} already in favorites');
    }
  } catch (e) {
    debugPrint('Error saving widget pointing: $e');
  }
}
