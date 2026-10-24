import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for flutter_local_notifications to handle foreground notifications
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Set notification center delegate for foreground notification display
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)

    // No background modes on iOS: reminders are local notifications scheduled
    // by flutter_local_notifications; WorkManager runs on Android only.

    // MethodChannel for opening app notification settings
    let controller = window?.rootViewController as! FlutterViewController
    let settingsChannel = FlutterMethodChannel(
      name: "com.dailypointer/settings",
      binaryMessenger: controller.binaryMessenger
    )
    settingsChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "openNotificationSettings" {
        self?.openNotificationSettings(result: result)
      } else if call.method == "isLowPowerMode" {
        // Ambient clock drops to 15 fps in Low Power Mode.
        result(ProcessInfo.processInfo.isLowPowerModeEnabled)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Push Low Power Mode changes to the ambient clock: toggling it in Control Center
    // keeps the app active, so a query on resume alone misses the change.
    NotificationCenter.default.addObserver(
      forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main
    ) { _ in
      settingsChannel.invokeMethod("lowPowerModeChanged", arguments: ProcessInfo.processInfo.isLowPowerModeEnabled)
    }

    // Reduce Transparency: the tab bar and rail drop their glass for a frosted, opaque fill.
    let accessibilityChannel = FlutterMethodChannel(
      name: "com.dailypointer/accessibility",
      binaryMessenger: controller.binaryMessenger
    )
    accessibilityChannel.setMethodCallHandler { (call, result) in
      if call.method == "isReduceTransparency" {
        result(UIAccessibility.isReduceTransparencyEnabled)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    NotificationCenter.default.addObserver(
      forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil, queue: .main
    ) { _ in
      accessibilityChannel.invokeMethod("reduceTransparencyChanged", arguments: UIAccessibility.isReduceTransparencyEnabled)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func openNotificationSettings(result: @escaping FlutterResult) {
    if #available(iOS 16.0, *) {
      if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
        UIApplication.shared.open(url)
      }
    } else {
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
    }
    result(nil)
  }
}
