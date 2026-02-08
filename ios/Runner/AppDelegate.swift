import Flutter
import UIKit
import AVFoundation
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure audio session for playback (required for just_audio on iOS)
    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.mixWithOthers, .duckOthers]
      )
    } catch {
      print("Failed to set up AVAudioSession: \(error)")
    }

    // Required for flutter_local_notifications to handle foreground notifications
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Set notification center delegate for foreground notification display
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)

    // Enable background fetch for WorkManager periodic notifications
    // WorkManager's Flutter plugin automatically registers BGTaskScheduler handlers
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
