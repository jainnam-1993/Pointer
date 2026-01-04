import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'router.dart';
import 'services/ambient_sound_service.dart';
import 'services/notification_service.dart';
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

  // Pre-load SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create provider container for notification callbacks
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );
  _globalContainer = container;

  // Initialize notifications with action handler
  final notificationService = NotificationService(sharedPreferences);
  await _initializeNotifications(notificationService);

  // Initialize WorkManager for background notifications
  await WorkManagerService.initialize();

  // Initialize home screen widget
  await WidgetService.initialize();

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
  // Initialize the service (creates Android notification channel)
  await service.initialize();

  // Re-initialize with action callbacks (required for notification actions)
  final plugin = FlutterLocalNotificationsPlugin();

  // Use dedicated notification icon (white-only for Android status bar)
  const initSettingsAndroid = AndroidInitializationSettings('@drawable/ic_notification');
  const initSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await plugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: notificationActionCallback,
    onDidReceiveBackgroundNotificationResponse: notificationActionCallback,
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
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp.router(
      title: 'Pointer',
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
