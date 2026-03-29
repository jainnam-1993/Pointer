/**
 * Application entry point and top-level widget for the Here Now app.
 *
 * Delegates the startup sequence to [AppInitializer] which orchestrates
 * five phases (platform → core → services → container → content).
 *
 * This file retains only:
 * - The global [ProviderContainer] reference for background notification dispatch.
 * - The `@pragma('vm:entry-point')` notification action callback.
 * - The root [PointerApp] widget.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'providers/providers.dart';
import 'router.dart';
import 'services/ambient_sound_service.dart';
import 'services/app_initializer.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

/**
 * Global [ProviderContainer] reference retained for notification action handling.
 *
 * Set once in [main] after the container is created and read by [notificationActionCallback]
 * when the OS delivers a notification action while the app may not have an active widget tree.
 */
ProviderContainer? _globalContainer;

/**
 * Handles notification action responses dispatched by the OS.
 *
 * Supports two action identifiers:
 * - `save` — toggles the pointing identified by [NotificationResponse.payload] as a favorite
 *   via [favoritesProvider].
 * - `another` — sends a new test notification through [NotificationService.sendTestNotification].
 *
 * Annotated with `@pragma('vm:entry-point')` to ensure the Dart VM retains this function
 * for invocation from native background isolates.
 */
@pragma('vm:entry-point')
void notificationActionCallback(NotificationResponse response) {
  if (_globalContainer == null) return;

  final actionId = response.actionId;
  final payload = response.payload;

  if (actionId == 'save' && payload != null) {
    _globalContainer!.read(favoritesProvider.notifier).toggle(payload);
  } else if (actionId == 'another') {
    final prefs = _globalContainer!.read(sharedPreferencesProvider);
    final service = NotificationService(prefs);
    service.sendTestNotification();
  }
}

/**
 * Application entry point.
 *
 * Delegates initialization to [AppInitializer.initialize] and launches
 * [PointerApp] inside an [UncontrolledProviderScope].
 */
void main() async {
  MediaKit.ensureInitialized();

  final result = await AppInitializer.initialize(
    onNotificationAction: notificationActionCallback,
  );
  _globalContainer = result.container;

  runApp(UncontrolledProviderScope(container: result.container, child: const PointerApp()));
}

/**
 * Root widget for the Here Now application.
 *
 * A [ConsumerStatefulWidget] that:
 * - Observes the app lifecycle via [WidgetsBindingObserver] to refresh the home-screen
 *   widget and process pending widget save actions on resume.
 * - Syncs system UI chrome (status bar, navigation bar) with the current theme brightness.
 * - Reads [routerProvider] once (via `ref.read`, not `ref.watch`) to avoid [MaterialApp.router]
 *   rebuilds that would trigger [GlobalKey] conflicts in [StatefulShellRoute].
 * - Watches [flutterThemeModeProvider] to reactively switch between light and dark themes.
 * - Disposes the [AmbientSoundService] when the app is torn down.
 */
class PointerApp extends ConsumerStatefulWidget {
  const PointerApp({super.key});

  @override
  ConsumerState<PointerApp> createState() => _PointerAppState();
}

class _PointerAppState extends ConsumerState<PointerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Opening bell sound is embedded in the splash video asset —
    // no separate just_audio playback needed (avoids codec contention).
  }

  @override
  void dispose() {
    ref.read(ambientSoundServiceProvider).dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final widgetService = ref.read(widgetServiceProvider);
      widgetService.refreshWidget();
      widgetService.processPendingWidgetActions().then((_) {
        ref.invalidate(favoritesProvider);
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(widgetServiceProvider).refreshWidget();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp.router(
      title: 'Here Now',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
