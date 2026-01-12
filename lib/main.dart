import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'router.dart';
import 'services/ambient_sound_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/revenue_cat_service.dart';
import 'services/widget_service.dart';
import 'services/workmanager_service.dart';
import 'theme/app_theme.dart';
import 'data/pointings.dart';
import 'data/teaching.dart';
import 'data/teachings/papaji.dart';
import 'data/teachings/adyashanti.dart';

/// Global container reference for notification action handling
ProviderContainer? _globalContainer;

/// Global guard for ambient sound (prevents double-play during startup)
bool _globalAmbientSoundPlayed = false;

/// Handle notification action responses (Save, Another buttons)
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Firebase FIRST (required for auth)
  // Note: This will fail gracefully if Firebase is not configured (no google-services.json)
  try {
    await AuthService.instance.initialize();
  } catch (e) {
    // Firebase not configured - app works in anonymous-only mode
    debugPrint('[Main] Firebase not configured, running in anonymous mode: $e');
  }

  // Pre-load SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set SharedPreferences for router redirect checks (BEFORE creating router)
  setRouterSharedPreferences(sharedPreferences);

  // Initialize RevenueCat EARLY (before any auth callbacks might use it)
  // Skip in free access mode - RevenueCat not needed when all features are free
  if (!kFreeAccessEnabled) {
    try {
      await RevenueCatService.instance.initialize();
    } catch (e) {
      debugPrint('[Main] RevenueCat initialization failed: $e');
      // App continues without purchases - not fatal for basic functionality
    }
  }

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
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
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
  TeachingRepository.initialize(
    pointings: pointings,
    additionalTeachings: [
      ...papajiTeachings,
      ...adyashantiTeachings,
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PointerApp(),
    ),
  );
}

/// Initialize notification plugin with action callbacks and create Android channel
Future<void> _initializeNotifications(NotificationService service) async {
  // Initialize the service with callbacks for notification actions (Save, Another buttons)
  // This uses a single FlutterLocalNotificationsPlugin instance throughout the app
  await service.initialize(
    onNotificationResponse: notificationActionCallback,
    onBackgroundNotificationResponse: notificationActionCallback,
  );
}

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
    // Play ambient sound on cold start (configurable in Settings)
    _playAmbientSound();
  }

  void _playAmbientSound() {
    // Guard against duplicate plays (can happen during debug mode rebuilds)
    debugPrint('AmbientSound: _playAmbientSound called, global guard=$_globalAmbientSoundPlayed');
    if (_globalAmbientSoundPlayed) {
      debugPrint('AmbientSound: Skipping duplicate call (already played this launch)');
      return;
    }
    _globalAmbientSoundPlayed = true;
    debugPrint('AmbientSound: Global guard set to true');

    // Delay slightly to ensure providers are ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final sound = ref.read(ambientSoundProvider);
      ref.read(ambientSoundServiceProvider).playOpeningSound(sound);
    });
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
