/**
 * Application entry point and top-level widget for the Here Now app.
 *
 * Delegates startup bootstrap to [AppInitializer], then starts heavier
 * warmup work behind the splash screen so the first Flutter frame can render
 * immediately.
 *
 * This file retains only:
 * - The global [ProviderContainer] reference for background notification dispatch.
 * - The `@pragma('vm:entry-point')` notification action callback.
 * - The root [PointerApp] widget.
 */
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'providers/providers.dart';
import 'router.dart';
import 'services/ambient_sound_service.dart';
import 'services/app_initializer.dart';
import 'debug/maestro_hooks.dart';
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
 * URI buffered from a widget deep-link that arrived before critical startup
 * content finished loading. Drained once [AppInitializer.criticalContentReady]
 * completes.
 */
String? _pendingWidgetUri;

/**
 * Listens for widget-click deep-links and buffers them in [_pendingWidgetUri]
 * instead of navigating immediately — prevents the deep-link from racing with
 * the splash screen or SharedPreferences cache on cold start.
 */
void _setupWidgetDeepLink() {
  // Check for an initial (cold-start) widget click URI.
  HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
    if (uri != null) {
      _pendingWidgetUri = uri.toString();
    }
  });

  // Listen for widget clicks while the app is running.
  HomeWidget.widgetClicked.listen((uri) {
    if (uri == null) return;
    _pendingWidgetUri = uri.toString();
    _drainPendingWidgetUri();
  });
}

/**
 * If critical startup content is ready and a pending URI is buffered,
 * navigate to the home screen and clear the buffer.
 */
void _drainPendingWidgetUri() {
  if (_pendingWidgetUri == null || _globalContainer == null) return;
  if (!AppInitializer.isCriticalContentReady) return;

  final uri = Uri.tryParse(_pendingWidgetUri!);
  var found = true;
  if (uri != null && uri.host == 'pointing' && uri.pathSegments.isNotEmpty) {
    found = _globalContainer!.read(currentPointingProvider.notifier).setPointingById(uri.pathSegments.first);
  }
  final router = _globalContainer!.read(routerProvider);
  router.go('/');
  if (!found) {
    final missingId = (uri != null && uri.pathSegments.isNotEmpty) ? uri.pathSegments.first : null;
    debugPrint('[WidgetDeepLink] Pointing not found after startup: $missingId');
  }
  _pendingWidgetUri = null;
}

/**
 * Application entry point.
 *
 * Delegates initialization to [AppInitializer.initialize] and launches
 * [PointerApp] inside an [UncontrolledProviderScope].
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Maestro MCP VM Service extensions in debug mode
  if (kDebugMode) {
    MaestroHooks.init();
  }

  // Start listening for widget deep-links early so cold-start URIs are
  // captured, but navigation is deferred until init completes.
  _setupWidgetDeepLink();

  final result = await AppInitializer.initialize(onNotificationAction: notificationActionCallback);
  _globalContainer = result.container;

  unawaited(
    AppInitializer.criticalContentReady
        .then((_) {
          _drainPendingWidgetUri();
        })
        .catchError((error, stackTrace) {
          debugPrint('[AppInitializer] Critical startup failed: $error');
        }),
  );

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
  static const _widgetChannel = MethodChannel('com.dailypointer/widget');
  StreamSubscription? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Opening bell sound is embedded in the splash video asset —
    // no separate just_audio playback needed (avoids codec contention).

    _setupWidgetDeepLink();
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    ref.read(ambientSoundServiceProvider).dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Set up listeners for widget deep-link taps from both platforms.
  void _setupWidgetDeepLink() {
    // Android: MethodChannel from MainActivity
    _widgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'onWidgetPointingTap') {
        final pointingId = call.arguments as String?;
        if (pointingId != null) {
          debugPrint('[WidgetDeepLink] Android tap: $pointingId');
          _navigateToPointing(pointingId);
        }
      }
    });

    // iOS: widgetURL deep-link via home_widget
    _widgetClickSub = HomeWidget.widgetClicked.listen((uri) {
      if (uri == null) return;
      debugPrint('[WidgetDeepLink] iOS tap: $uri');
      // URI format: dailypointer://pointing/{id}
      if (uri.host == 'pointing' && uri.pathSegments.isNotEmpty) {
        _navigateToPointing(uri.pathSegments.first);
      }
    });
  }

  /// Navigate to the home tab and set the current pointing by ID.
  void _navigateToPointing(String pointingId) {
    if (!AppInitializer.isCriticalContentReady) {
      _pendingWidgetUri = 'dailypointer://pointing/$pointingId';
      debugPrint('[WidgetDeepLink] Buffered until startup ready: $pointingId');
      return;
    }

    final found = ref.read(currentPointingProvider.notifier).setPointingById(pointingId);
    if (found) {
      // Navigate to home tab
      final router = ref.read(routerProvider);
      router.go('/');
      debugPrint('[WidgetDeepLink] Navigated to pointing: $pointingId');
    } else {
      debugPrint('[WidgetDeepLink] Pointing not found: $pointingId');
    }
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
        // Set root context for Maestro MCP tree walker (covers all routes + overlays)
        if (kDebugMode) {
          MaestroHooks.setContext(context);
        }

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
