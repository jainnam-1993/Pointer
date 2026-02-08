/**
 * Application entry point and top-level widget for the Here Now app.
 *
 * Orchestrates a graceful startup sequence:
 * 1. [SharedPreferences] pre-load and router configuration via [setRouterSharedPreferences]
 * 2. [NotificationService] initialization with action callbacks (non-fatal on failure)
 * 3. [ProviderContainer] creation with service overrides for the singleton notification instance
 * 4. [WidgetService] initialization and pointings cache population for the home-screen widget
 * 5. [TeachingRepository] initialization with curated pointings and extended teachings
 * 6. Launch of [PointerApp] inside an [UncontrolledProviderScope]
 *
 * The [notificationActionCallback] is annotated with `@pragma('vm:entry-point')` so the
 * Dart VM retains it for background notification dispatch by the OS.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'router.dart';
import 'services/ambient_sound_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'theme/app_theme.dart';
import 'data/pointings.dart';
import 'data/teaching.dart';
import 'data/teachings/papaji.dart';
import 'data/teachings/adyashanti.dart';

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
    // Save the pointing to favorites
    _globalContainer!.read(favoritesProvider.notifier).toggle(payload);
  } else if (actionId == 'another') {
    // Show another notification with a new pointing
    final prefs = _globalContainer!.read(sharedPreferencesProvider);
    final service = NotificationService(prefs);
    service.sendTestNotification();
  }
}

/**
 * Application entry point.
 *
 * Performs a sequential, gracefully-degrading initialization:
 *
 * 1. Enables edge-to-edge system UI via [SystemChrome].
 * 2. Pre-loads [SharedPreferences] and configures the [GoRouter] redirect layer
 *    via [setRouterSharedPreferences].
 * 3. Initializes [NotificationService] with action callbacks — wrapped in try-catch
 *    so notification failures are non-fatal.
 * 4. Creates a [ProviderContainer] with overrides for [sharedPreferencesProvider] and
 *    [notificationServiceProvider] to guarantee a single initialized instance app-wide.
 * 5. Initializes [WidgetService] (home-screen widget), populates the pointings cache,
 *    and processes any pending iOS widget save actions.
 * 6. Initializes [TeachingRepository] with the full pointings corpus and extended teachings.
 * 7. Launches [PointerApp] inside an [UncontrolledProviderScope].
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Pre-load SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set SharedPreferences for router redirect checks (BEFORE creating router)
  setRouterSharedPreferences(sharedPreferences);

  // Initialize notifications with action handler FIRST
  final notificationService = NotificationService(sharedPreferences);
  try {
    await _initializeNotifications(notificationService);
  } catch (e) {
    debugPrint('[Main] Notification initialization failed: $e');
    // App continues without notifications - not fatal
  }

  // Create provider container with initialized services
  // CRITICAL: Override notificationServiceProvider so all code uses the SAME
  // initialized instance. Creating new NotificationService instances via
  // the default provider results in uninitialized FlutterLocalNotificationsPlugin
  // instances that cannot show notifications on iOS.
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences), notificationServiceProvider.overrideWithValue(notificationService)],
  );
  _globalContainer = container;

  // Initialize WorkManager for background notifications
  // TEMP: Disabled to diagnose iOS 26 beta crash
  // await WorkManagerService.initialize();

  // Initialize home screen widget
  await WidgetService.initialize();

  // Populate widget cache on startup
  // NOTE: Previously relied on SubscriptionNotifier._initialize() to call this,
  // but that provider is lazy and never instantiated on startup. Calling directly
  // ensures widget has data when kFreeAccessEnabled = true.
  await WidgetService.populatePointingsCache();

  // Process any pending widget actions from iOS (save requests from widget buttons)
  await WidgetService.processPendingWidgetActions();

  // Initialize teaching repository with all teachings
  TeachingRepository.initialize(pointings: pointings, additionalTeachings: [...papajiTeachings, ...adyashantiTeachings]);

  runApp(UncontrolledProviderScope(container: container, child: const PointerApp()));
}

/**
 * Initializes the [NotificationService] plugin with action callbacks.
 *
 * Calls [NotificationService.initialize] passing [notificationActionCallback] for both
 * foreground and background notification responses. This ensures the same single
 * [FlutterLocalNotificationsPlugin] instance is used throughout the app, avoiding the
 * uninitialized-plugin issue on iOS.
 */
Future<void> _initializeNotifications(NotificationService service) async {
  // Initialize the service with callbacks for notification actions (Save, Another buttons)
  // This uses a single FlutterLocalNotificationsPlugin instance throughout the app
  await service.initialize(onNotificationResponse: notificationActionCallback, onBackgroundNotificationResponse: notificationActionCallback);
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
      // Refresh widget when app comes to foreground (picks up theme changes)
      WidgetService.refreshWidget();
      // Process any pending widget saves (iOS saves from widget buttons)
      WidgetService.processPendingWidgetActions().then((_) {
        // Refresh favorites provider to pick up any new saves
        ref.invalidate(favoritesProvider);
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    // System theme changed while app is in foreground
    WidgetService.refreshWidget();
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.read (not watch) - router is a singleton that never changes.
    // Using ref.watch would cause MaterialApp.router to rebuild on unrelated
    // provider changes (like theme), triggering GlobalKey conflicts in
    // StatefulShellRoute's internal navigation state.
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
        // Update system UI based on current theme
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
