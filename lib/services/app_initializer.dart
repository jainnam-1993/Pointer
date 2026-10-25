/**
 * Startup bootstrap and warmup orchestration.
 *
 * Keeps the first Flutter frame cheap by only doing the minimum work needed
 * before `runApp()`, then loading content and non-critical services behind
 * the splash screen.
 */
library;

import 'dart:async';
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
import '../providers/donation_providers.dart';
import '../router.dart';
import 'notification_content.dart';
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
 * Background startup coordinator.
 *
 * Exposes a "critical content" future for the splash screen to await before
 * leaving, while continuing notification/widget warmup in the background.
 */
class StartupCoordinator {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;
  final void Function(NotificationResponse) _onNotificationAction;

  Completer<void> _criticalReady = Completer<void>();
  Future<void>? _startFuture;
  bool _criticalFailed = false;

  StartupCoordinator({
    required SharedPreferences prefs,
    required NotificationService notificationService,
    required void Function(NotificationResponse) onNotificationAction,
  }) : _prefs = prefs,
       _notificationService = notificationService,
       _onNotificationAction = onNotificationAction;

  bool get isCriticalReady => _criticalReady.isCompleted && !_criticalFailed;
  bool get hasCriticalFailed => _criticalFailed;
  Future<void> get criticalReady => _criticalReady.future;

  Future<void> start() => _startFuture ??= _run();

  /**
   * Retry startup after a critical content failure. Returns the new
   * [criticalReady] future; a no-op when startup has not failed.
   */
  Future<void> retry() {
    if (_criticalFailed) {
      _criticalFailed = false;
      _criticalReady = Completer<void>();
      _startFuture = null;
      unawaited(start().catchError((Object _) {}));
    }
    return criticalReady;
  }

  Future<void> _run() async {
    try {
      await Future.wait([loadPointings(), loadArticles(), loadTeachers()]);

      TeachingRepository.initialize(pointings: pointings);
      await TeachingRepository.loadFromAsset();

      if (!_criticalReady.isCompleted) {
        _criticalReady.complete();
      }
    } catch (e, stackTrace) {
      debugPrint('[AppInitializer] Critical content failed: $e');
      if (!_criticalReady.isCompleted) {
        _criticalFailed = true;
        _criticalReady.completeError(e, stackTrace);
      }
      return;
    }

    await Future.wait([_initializeNotifications(), _initializeWidgetCache(), if (Platform.isAndroid) _initializeWorkManager()]);
    await _refillNotifications();
  }

  Future<void> _refillNotifications() async {
    try {
      await _notificationService.refillIfDue();
    } catch (e) {
      debugPrint('[AppInitializer] Notification refill failed (non-fatal): $e');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize(
        onNotificationResponse: _onNotificationAction,
        onBackgroundNotificationResponse: notificationBackgroundHandler,
      );
    } catch (e) {
      debugPrint('[AppInitializer] Notification init failed (non-fatal): $e');
    }
  }

  Future<void> _initializeWidgetCache() async {
    try {
      final widgetService = WidgetService(_prefs);
      await widgetService.initialize();
      await widgetService.processPendingWidgetActions();
      await widgetService.populatePointingsCache();
    } catch (e) {
      debugPrint('[AppInitializer] Widget init failed (non-fatal): $e');
    }
  }

  Future<void> _initializeWorkManager() async {
    try {
      await WorkManagerService.initialize();
    } catch (e) {
      debugPrint('[AppInitializer] WorkManager init failed (non-fatal): $e');
    }
  }
}

/**
 * Minimal startup bootstrap plus background warmup accessors.
 */
class AppInitializer {
  AppInitializer._();

  static StartupCoordinator? _startupCoordinator;

  static StartupCoordinator get startupCoordinator {
    final coordinator = _startupCoordinator;
    if (coordinator == null) {
      throw StateError('AppInitializer.startupCoordinator accessed before initialize()');
    }
    return coordinator;
  }

  static bool get isCriticalContentReady => startupCoordinator.isCriticalReady;
  static Future<void> get criticalContentReady => startupCoordinator.criticalReady;
  static bool get hasCriticalContentFailed => startupCoordinator.hasCriticalFailed;
  static Future<void> startBackgroundInitialization() => startupCoordinator.start();
  static Future<void> retryCriticalContent() => startupCoordinator.retry();

  /**
   * Run the minimal bootstrap needed before `runApp()`.
   *
   * Heavy content loading and service warmup are kicked off separately via
   * [startBackgroundInitialization].
   */
  static Future<InitResult> initialize({required void Function(NotificationResponse) onNotificationAction}) async {
    _initPlatform();
    final prefs = await _initCore();
    final notificationService = NotificationService(prefs);

    _startupCoordinator = StartupCoordinator(prefs: prefs, notificationService: notificationService, onNotificationAction: onNotificationAction);

    final container = _createContainer(prefs, notificationService);
    return InitResult(container: container);
  }

  /**
   * Start launch work the first frame does not need, once that frame is built.
   *
   * Content loading (asset reads, JSON decode on background isolates) and the
   * tip purchase listener (billing connection on the platform thread) used to
   * start before `runApp()` and competed with the first frame. Both still run
   * on every launch, one frame later; [StartupCoordinator.start] is idempotent,
   * so the splash screen starting it first is harmless.
   */
  static void startAfterFirstFrame(ProviderContainer container) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Finish interrupted and pending tips from launch, not when Settings opens.
      container.read(tipPurchaseListenerProvider);
      unawaited(startBackgroundInitialization());
    });
  }

  static void _initPlatform() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  static Future<SharedPreferences> _initCore() async {
    final prefs = await SharedPreferences.getInstance();
    setRouterSharedPreferences(prefs);
    return prefs;
  }

  static ProviderContainer _createContainer(SharedPreferences prefs, NotificationService notificationService) {
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), notificationServiceProvider.overrideWithValue(notificationService)],
    );
  }
}
