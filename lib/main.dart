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
import 'widgets/shared_ambient.dart';
import 'services/app_initializer.dart';
import 'services/launch_link_buffer.dart';
import 'services/widget_service.dart';
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
  _launchLink.offer('dailypointer://pointing/$pointingId');
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
 * The pending pointing deep link (widget or notification tap). Every producer
 * offers through it, so a link that arrives after the startup drain still lands.
 */
final _launchLink = LaunchLinkBuffer(isReady: () => _globalContainer != null && AppInitializer.isCriticalContentReady, deliver: _openPointingLink);

/**
 * Listens for widget-click deep-links and offers them to [_launchLink]
 * instead of navigating immediately — prevents the deep-link from racing with
 * the splash screen or SharedPreferences cache on cold start.
 */
void _setupWidgetDeepLink() {
  // Check for an initial (cold-start) widget click URI.
  WidgetService.initialLaunchUri().then((uri) {
    if (uri != null) _launchLink.offer(uri.toString());
  });

  // Listen for widget clicks while the app is running (iOS widgetURL). This is the only
  // widget-tap listener; Android taps are pulled by [_pullAndroidWidgetTap].
  HomeWidget.widgetClicked.listen((uri) {
    if (uri == null) return;
    _launchLink.offer(uri.toString());
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
  _launchLink.offer('dailypointer://pointing/$id');
}

/** Show the linked pointing on Home; unknown ids still land on Home. */
void _openPointingLink(Uri uri) {
  var found = true;
  if (uri.host == 'pointing' && uri.pathSegments.isNotEmpty) {
    found = _globalContainer!.read(currentPointingProvider.notifier).setPointingById(uri.pathSegments.first);
  }
  _globalContainer!.read(routerProvider).go('/');
  if (!found) debugPrint('[WidgetDeepLink] Pointing not found after startup: ${uri.pathSegments.firstOrNull}');
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

  // Start content loading now, before the first frame, so JSON asset reads
  // overlap engine warmup instead of waiting for the splash to mount.
  unawaited(AppInitializer.startBackgroundInitialization());

  unawaited(
    AppInitializer.criticalContentReady
        .then((_) {
          _launchLink.drain();
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
  }

  @override
  void dispose() {
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
    final highContrast = ref.watch(highContrastProvider);

    return MaterialApp.router(
      title: 'Here Now',
      debugShowCheckedModeBanner: false,
      // High contrast (in-app setting or OS) is a full theme that follows light and dark mode.
      theme: highContrast ? AppTheme.highContrastLight : AppTheme.light,
      darkTheme: highContrast ? AppTheme.highContrastDark : AppTheme.dark,
      highContrastTheme: AppTheme.highContrastLight,
      highContrastDarkTheme: AppTheme.highContrastDark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Set root context for Maestro MCP tree walker (covers all routes + overlays)
        if (kDebugMode) {
          MaestroHooks.setContext(context);
        }

        // Edge-to-edge bars are transparent by default on Android 15+; set only
        // icon brightness, declaratively, instead of calling the deprecated
        // bar color setters on every rebuild.
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final iconBrightness = isDark ? Brightness.light : Brightness.dark;
        // One text-scale clamp for the whole app; Text applies it once.
        // Fold the app's Animations toggle into disableAnimations so Motion.reduce is one check.
        // One shared backdrop for every sheet blur (BackdropFilter.grouped).
        final media = MediaQuery.of(context);
        final reduceMotion = media.disableAnimations || reduceMotionOverride == true;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarIconBrightness: iconBrightness,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarIconBrightness: iconBrightness,
          ),
          child: BackdropGroup(
            // One ambient background under every route (design 9): pushes slide over it, never cross-fade it.
            child: MediaQuery(
              data: media.copyWith(disableAnimations: reduceMotion),
              child: MediaQuery.withClampedTextScaling(
                minScaleFactor: 0.85,
                maxScaleFactor: 2.0,
                child: SharedAmbientHost(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
      },
    );
  }
}
