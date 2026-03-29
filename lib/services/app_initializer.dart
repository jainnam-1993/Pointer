/**
 * Phased application initialization.
 *
 * Extracts the imperative startup sequence from `main()` into a testable,
 * structured initializer with explicit phase ordering:
 *
 * 1. **Platform** — Flutter bindings, system UI chrome.
 * 2. **Core** — [SharedPreferences], router configuration.
 * 3. **Services** — [NotificationService] (non-fatal on failure).
 * 4. **Container** — [ProviderContainer] with service overrides.
 * 5. **Content** — [WidgetService], [TeachingRepository].
 *
 * Usage from `main()`:
 * ```dart
 * final result = await AppInitializer.initialize(
 *   onNotificationAction: notificationActionCallback,
 * );
 * runApp(UncontrolledProviderScope(
 *   container: result.container,
 *   child: const PointerApp(),
 * ));
 * ```
 */
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/articles.dart';
import '../data/pointings.dart';
import '../data/teachers.dart';
import '../data/teaching.dart';
import '../providers/core_providers.dart';
import '../router.dart';
import 'notification_service.dart';
import 'widget_service.dart';
import 'workmanager_service.dart';

/**
 * Result of [AppInitializer.initialize], carrying the configured
 * [ProviderContainer] for use in [UncontrolledProviderScope].
 */
class InitResult {
  /** The fully configured provider container with service overrides. */
  final ProviderContainer container;

  const InitResult({required this.container});
}

/**
 * Phased application startup orchestrator.
 *
 * Each phase runs sequentially because later phases depend on earlier ones
 * (e.g., [NotificationService] needs [SharedPreferences], the container
 * needs both). Individual service failures within a phase are caught and
 * logged so the app degrades gracefully.
 */
class AppInitializer {
  AppInitializer._();

  /**
   * Run the full initialization sequence and return the configured container.
   *
   * [onNotificationAction] is the callback for both foreground and background
   * notification responses (annotated `@pragma('vm:entry-point')` at the
   * call site).
   */
  static Future<InitResult> initialize({
    required void Function(NotificationResponse) onNotificationAction,
  }) async {
    // Phase 1: Platform
    _initPlatform();

    // Phase 2: Core
    final prefs = await _initCore();

    // Phase 3: Services
    final notificationService = await _initServices(prefs, onNotificationAction);

    // Phase 4: Container
    final container = _createContainer(prefs, notificationService);

    // Phase 5: Content
    await _initContent(prefs);

    return InitResult(container: container);
  }

  // ------------------------------------------------------------------
  // Phase 1: Platform bindings and system UI
  // ------------------------------------------------------------------

  static void _initPlatform() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ------------------------------------------------------------------
  // Phase 2: Core persistence and router
  // ------------------------------------------------------------------

  static Future<SharedPreferences> _initCore() async {
    final prefs = await SharedPreferences.getInstance();
    setRouterSharedPreferences(prefs);
    return prefs;
  }

  // ------------------------------------------------------------------
  // Phase 3: Services (non-fatal failures)
  // ------------------------------------------------------------------

  static Future<NotificationService> _initServices(
    SharedPreferences prefs,
    void Function(NotificationResponse) onNotificationAction,
  ) async {
    final service = NotificationService(prefs);
    try {
      await service.initialize(
        onNotificationResponse: onNotificationAction,
        onBackgroundNotificationResponse: onNotificationAction,
      );
    } catch (e) {
      debugPrint('[AppInitializer] Notification init failed (non-fatal): $e');
    }

    // WorkManager for background notifications (Android only — iOS 26 beta crashes)
    if (Platform.isAndroid) {
      await WorkManagerService.initialize();
    }

    return service;
  }

  // ------------------------------------------------------------------
  // Phase 4: Provider container with service overrides
  // ------------------------------------------------------------------

  static ProviderContainer _createContainer(
    SharedPreferences prefs,
    NotificationService notificationService,
  ) {
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Phase 5: Content — widget cache and teaching repository
  // ------------------------------------------------------------------

  static Future<void> _initContent(SharedPreferences prefs) async {
    // Load pointings from JSON asset before anything that depends on them
    await loadPointings();

    // Load article metadata from JSON (content lazy-loaded on demand)
    await loadArticles();

    final widgetService = WidgetService(prefs);
    await widgetService.initialize();
    await widgetService.populatePointingsCache();
    await widgetService.processPendingWidgetActions();

    // Load teacher data from JSON asset
    await loadTeachers();

    // Initialize teaching repository with pointings + JSON teachings
    TeachingRepository.initialize(pointings: pointings);
    await TeachingRepository.loadFromAsset();
  }
}
