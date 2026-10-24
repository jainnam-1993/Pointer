import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pointings.dart';
import 'storage_service.dart';

/** Keys in the iOS App Group store (home_widget). */
class _WidgetKeys {
  // Multi-pointing widget cache (JSON array), read by the iOS widget only.
  static const pointingsCache = 'pointings_cache';
  // Favorites mirror (JSON array of ids) for the iOS heart state.
  static const favorites = 'widget_favorites';
  // Ids the iOS Save intent added while the app was not running (JSON array).
  static const pendingSaves = 'pending_saves';
  // Legacy single-slot pending save written by builds before 2026-10.
  static const legacySavePendingId = 'save_pending_id';
}

/**
 * Service for the home-screen widgets.
 *
 * Android: the widget is self-sufficient. Kotlin reads the pointings from the bundled
 * asset and keeps its position and the favorites in the app's own SharedPreferences file
 * (`flutter.pointer_favorites`), so there is nothing to push and nothing to reconcile.
 * The app only asks the widget to re-render when favorites change, and pulls the pointing
 * id of a widget tap over [widgetChannel].
 *
 * iOS: WidgetKit reads the App Group store. The app writes the pointings cache and the
 * favorites mirror there, and merges ids the Save intent queued in `pending_saves`.
 */
class WidgetService {
  /** iOS App Group identifier for shared storage */
  static const iosAppGroup = 'group.com.dailypointer.widget';

  /** Android widget provider name */
  static const androidWidgetName = 'PointerWidgetProvider';

  /** Default update interval in hours */
  static const defaultUpdateIntervalHours = 3;

  /** Channel to MainActivity: `takePendingPointingId` and `renderWidgets`. */
  static const widgetChannel = MethodChannel('com.dailypointer/widget');

  final SharedPreferences _prefs;

  WidgetService(this._prefs);

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /**
   * The widget URL that cold-started the app, if any. On iOS the App Group must be
   * set first: home_widget answers `initiallyLaunchedFromHomeWidget` with
   * PlatformException(-7, "AppGroupId not set") otherwise, and the tap was lost, so
   * Home showed its stored pointing instead of the one the widget showed.
   */
  static Future<Uri?> initialLaunchUri() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) await HomeWidget.setAppGroupId(iosAppGroup);
    return HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  /** Initialize widget storage. */
  Future<void> initialize() async {
    if (_isIOS) {
      await HomeWidget.setAppGroupId(iosAppGroup);
    } else if (_isAndroid) {
      // Builds before 2026-10 copied ~347 KB of pointings into HomeWidgetPreferences.
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.pointingsCache, null);
    }
  }

  /**
   * Populate the iOS widget's pointings cache. Android reads the bundled asset natively.
   * Randomizes order and interleaves favorites for better discovery.
   */
  Future<void> populatePointingsCache() async {
    if (!_isIOS) return;
    try {
      final favoriteIds = _readFavorites().toSet();
      final favoritePointings = pointings.where((p) => favoriteIds.contains(p.id)).toList()..shuffle();
      final otherPointings = pointings.where((p) => !favoriteIds.contains(p.id)).toList()..shuffle();

      // Pattern: favorite, other, other, other, favorite, ...
      final interleaved = <Pointing>[];
      var favIndex = 0;
      var otherIndex = 0;
      const othersBetweenFavorites = 3;
      while (otherIndex < otherPointings.length || favIndex < favoritePointings.length) {
        if (favIndex < favoritePointings.length) interleaved.add(favoritePointings[favIndex++]);
        for (var i = 0; i < othersBetweenFavorites && otherIndex < otherPointings.length; i++) {
          interleaved.add(otherPointings[otherIndex++]);
        }
      }

      final json = interleaved.map((p) {
        final traditionInfo = traditions[p.tradition];
        return {'id': p.id, 'content': p.content, 'tradition': traditionInfo?.name ?? p.tradition.name, 'teacher': p.teacher ?? ''};
      }).toList();
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.pointingsCache, jsonEncode(json));
      await updateFavorites(favoriteIds);
    } catch (e) {
      // Non-critical: widget is a companion feature; app works without it
      debugPrint('Failed to populate widget cache: $e');
    }
  }

  /**
   * Merge widget saves into the app's favorites. Call on launch and on every resume,
   * before favorites are read.
   *
   * Reloads [SharedPreferences] first: the Android widget writes `pointer_favorites`
   * natively, and the plugin's in-memory cache would otherwise hide that write (and the
   * next in-app save would overwrite it). iOS ids queued by the Save intent are added
   * idempotently; a save never removes a favorite.
   *
   * Returns true when favorites changed.
   */
  Future<bool> processPendingWidgetActions() async {
    await _prefs.reload();
    try {
      final queued = <String>[];
      final pendingJson = await HomeWidget.getWidgetData<String>(_WidgetKeys.pendingSaves);
      if (pendingJson != null && pendingJson.isNotEmpty) {
        final decoded = jsonDecode(pendingJson);
        if (decoded is List) queued.addAll(decoded.whereType<String>());
      }
      final legacyId = await HomeWidget.getWidgetData<String>(_WidgetKeys.legacySavePendingId);
      if (legacyId != null && legacyId.isNotEmpty) queued.add(legacyId);
      if (queued.isEmpty) return false;

      final favorites = _readFavorites();
      var changed = false;
      for (final id in queued) {
        if (id.isNotEmpty && !favorites.contains(id)) {
          favorites.add(id);
          changed = true;
        }
      }
      if (changed) await _prefs.setString(StorageKeys.favoritePointings, jsonEncode(favorites));
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.pendingSaves, null);
      await HomeWidget.saveWidgetData<String>(_WidgetKeys.legacySavePendingId, null);
      if (changed) await updateFavorites(favorites.toSet());
      return changed;
    } catch (e) {
      // Non-critical: the queue is left in place and retried on the next resume
      debugPrint('Error processing pending widget actions: $e');
      return false;
    }
  }

  /**
   * Pull the pointing id of the last Android widget tap, once. Returns null when there
   * was none. Dart pulls instead of native pushing, so a cold-start tap is not lost before
   * the handler exists.
   */
  Future<String?> takePendingWidgetPointingId() async {
    if (!_isAndroid) return null;
    try {
      return await widgetChannel.invokeMethod<String>('takePendingPointingId');
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('Widget tap pull failed: $e');
      return null;
    }
  }

  /**
   * Reflect a favorites change in the widgets. Android re-renders from the shared store
   * (no copy needed); iOS gets the favorites mirror and one timeline reload.
   */
  Future<void> updateFavorites(Set<String> favoriteIds) async {
    try {
      if (_isIOS) {
        await HomeWidget.saveWidgetData<String>(_WidgetKeys.favorites, jsonEncode(favoriteIds.toList()));
        await HomeWidget.updateWidget(iOSName: 'PointerWidget');
      } else if (_isAndroid) {
        await widgetChannel.invokeMethod<void>('renderWidgets');
      }
    } catch (e) {
      // Non-critical: widget favorite indicator is cosmetic
      debugPrint('Failed to update widget favorites: $e');
    }
  }

  List<String> _readFavorites() {
    final stored = _prefs.getString(StorageKeys.favoritePointings);
    if (stored == null) return <String>[];
    final decoded = jsonDecode(stored);
    return decoded is List ? decoded.whereType<String>().toList() : <String>[];
  }
}
