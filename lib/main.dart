/**
 * Application entry point and top-level widget for the Here Now app.
 *
 * Delegates startup bootstrap to [AppInitializer], then starts heavier
 * warmup work behind the splash screen so the first Flutter frame can render
 * immediately.
 *
 * This file retains only:
 * - The global [ProviderContainer] reference for deep-link and notification routing.
 * - Main-isolate notification tap and action handling (background actions live in
 *   `notification_content.dart`).
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
import 'services/notification_content.dart';
import 'theme/app_theme.dart';

/**
 * Global [ProviderContainer] reference for top-level deep-link and
 * notification routing. Null only before [main] finishes bootstrap.
 */
ProviderContainer? _globalContainer;

/**
 * Handles notification responses delivered to the main isolate.
 *
 * A plain tap (`actionId == null`) opens the pointing named by the payload
 * through the same buffered path widget deep links use. Action buttons share
 * [handleNotificationAction] with the background isolate, then favourites are
 * reloaded so the UI reflects a Save.
 */
void _onForegroundNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (response.actionId == null) {
    if (payload != null && payload.isNotEmpty) _routeToPointing(payload);
    return;
  }
  final container = _globalContainer;
  if (container == null) return;
  unawaited(
    handleNotificationAction(
      response,
      prefs: container.read(sharedPreferencesProvider),
      plugin: FlutterLocalNotificationsPlugin(),
      loadPool: loadNotificationPool,
    ).then((_) => container.invalidate(favoritesProvider)),
  );
}

/** Buffer a pointing deep link and navigate once startup content is ready. */
void _routeToPointing(String pointingId) {
  _pendingWidgetUri = 'dailypointer://pointing/$pointingId';
  _drainPendingWidgetUri();
}

/** Cold start from a notification tap: open the pointing it showed. */
Future<void> _captureNotificationLaunch() async {
  try {
    final details = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp != true || response == null) return;
    if (response.actionId == null && response.payload != null && response.payload!.isNotEmpty) {
      _routeToPointing(response.payload!);
    }
  } catch (e) {
    debugPrint('[NotificationLaunch] Launch details unavailable: $e');
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

  // Listen for widget clicks while the app is running (iOS widgetURL). This is the only
  // widget-tap listener; Android taps are pulled by [_pullAndroidWidgetTap].
  HomeWidget.widgetClicked.listen((uri) {
    if (uri == null) return;
    _pendingWidgetUri = uri.toString();
    _drainPendingWidgetUri();
  });
}

/**
 * Pull the pointing id of an Android widget tap from MainActivity and route it through
 * the same buffered path. Called once startup content is ready and on every resume, so
 * cold and warm taps both land; native clears the id when it is taken.
 */
Future<void> _pullAndroidWidgetTap() async {
  final container = _globalContainer;
  if (container == null) return;
  final id = await container.read(widgetServiceProvider).takePendingWidgetPointingId();
  if (id == null || id.isEmpty) return;
  _pendingWidgetUri = 'dailypointer://pointing/$id';
  _drainPendingWidgetUri();
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
/** Adds the bundled OFL font licenses to the license page. */
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, path) in const [('Inter', 'assets/fonts/Inter-OFL.txt'), ('Newsreader', 'assets/fonts/Newsreader-OFL.txt')]) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString(path));
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Maestro MCP VM Service extensions in debug mode
  if (kDebugMode) {
    MaestroHooks.init();
  }

  // Start listening for widget deep-links early so cold-start URIs are
  // captured, but navigation is deferred until init completes.
  _setupWidgetDeepLink();

  final result = await AppInitializer.initialize(onNotificationAction: _onForegroundNotificationResponse);
  _globalContainer = result.container;
  unawaited(_captureNotificationLaunch());

  unawaited(
    AppInitializer.criticalContentReady
        .then((_) {
          _drainPendingWidgetUri();
          return _pullAndroidWidgetTap();
        })
        .catchError((error, stackTrace) {
          debugPrint('[AppInitializer] Critical startup failed: $error');
        }),
  );

  _registerFontLicenses();
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
      // Reloads SharedPreferences first, so favorites saved from the widget or from the
      // notification action isolate while the app was in the background are visible
      // before favorites are re-read.
      ref.read(widgetServiceProvider).processPendingWidgetActions().then((_) {
        ref.invalidate(favoritesProvider);
      });
      unawaited(ref.read(notificationServiceProvider).refillIfDue());
      _pullAndroidWidgetTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);
    final themeMode = ref.watch(flutterThemeModeProvider);
    final reduceMotionOverride = ref.watch(reduceMotionOverrideProvider);

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
        // One text-scale clamp for the whole app; Text applies it once.
        // Fold the app's Animations toggle into disableAnimations so Motion.reduce is one check.
        final media = MediaQuery.of(context);
        final reduceMotion = media.disableAnimations || reduceMotionOverride == true;
        return MediaQuery(
          data: media.copyWith(disableAnimations: reduceMotion),
          child: MediaQuery.withClampedTextScaling(minScaleFactor: 0.85, maxScaleFactor: 2.0, child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
