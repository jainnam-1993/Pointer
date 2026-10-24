import Flutter
import UIKit
import flutter_local_notifications

// UIScene lifecycle (required from the iOS 27 SDK): Info.plist declares
// UIApplicationSceneManifest with SceneDelegate (a FlutterSceneDelegate subclass),
// which owns the window and the FlutterViewController. The AppDelegate keeps process
// work only; plugins and method channels are registered in
// didInitializeImplicitFlutterEngine, once the implicit engine exists.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Background isolates of flutter_local_notifications register plugins through this.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // The UNUserNotificationCenter delegate must be set before launch finishes, so a
    // notification tap or action that cold-launches the app still reaches the plugin.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    // No background modes on iOS: reminders are local notifications scheduled
    // by flutter_local_notifications; WorkManager runs on Android only.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()

    // Opens app notification settings; reports Low Power Mode.
    let settingsChannel = FlutterMethodChannel(
      name: "com.dailypointer/settings",
      binaryMessenger: messenger
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
      binaryMessenger: messenger
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
