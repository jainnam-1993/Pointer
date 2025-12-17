import 'package:home_widget/home_widget.dart';

import '../data/pointings.dart';

/// Keys for widget data storage
class _WidgetKeys {
  static const content = 'pointing_content';
  static const teacher = 'pointing_teacher';
  static const tradition = 'pointing_tradition';
  static const lastUpdated = 'pointing_last_updated';
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

  /// Initialize widget service and register background callback
  static Future<void> initialize() async {
    // Register the callback for widget taps
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
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
      qualifiedAndroidName: 'com.pointer.pointer_flutter.$androidWidgetName',
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
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  final host = uri.host;

  if (host == 'refresh') {
    // User tapped refresh - update with new pointing
    await WidgetService.updateWithRandomPointing();
  } else if (host == 'open') {
    // User tapped to open app - handled by native code
    // The app will open automatically
  }
}
