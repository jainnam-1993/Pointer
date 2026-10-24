import WidgetKit
import AppIntents
import SwiftUI

// MARK: - App Group Constants

private let appGroupId = "group.com.dailypointer.widget"

// MARK: - iOS 17+ Interactive Widget Intents

/// Intent to show the previous pointing (like Android's ◀ button)
@available(iOS 17.0, *)
struct PreviousPointingIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Pointing"
    static var description = IntentDescription("Show the previous pointing")

    func perform() async throws -> some IntentResult {
        if let defaults = UserDefaults(suiteName: appGroupId) {
            let currentIndex = defaults.integer(forKey: "widget_current_index")
            defaults.set(currentIndex - 1, forKey: "widget_current_index")
            defaults.set(Date().timeIntervalSince1970, forKey: "widget_nav_requested")
        }

        // Request widget timeline reload
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

/// Intent to show the next pointing (like Android's ▶ button)
@available(iOS 17.0, *)
struct NextPointingIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Pointing"
    static var description = IntentDescription("Show the next pointing")

    func perform() async throws -> some IntentResult {
        if let defaults = UserDefaults(suiteName: appGroupId) {
            let currentIndex = defaults.integer(forKey: "widget_current_index")
            // Increment and wrap around (handled by timeline provider)
            defaults.set(currentIndex + 1, forKey: "widget_current_index")
            defaults.set(Date().timeIntervalSince1970, forKey: "widget_nav_requested")
        }

        // Request widget timeline reload
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

/// Intent to save a pointing to favorites.
///
/// Each timeline entry builds its own intent with the id it shows, so the heart always saves
/// the pointing on screen, not the one the timeline started from. Saves add and never remove:
/// the id joins `widget_favorites` (heart state) and the `pending_saves` queue, which the app
/// merges idempotently into its favorites on the next launch or resume.
@available(iOS 17.0, *)
struct SavePointingIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Pointing"
    static var description = IntentDescription("Save this pointing to your favorites")

    @Parameter(title: "Pointing ID")
    var pointingId: String

    init() {}

    init(pointingId: String) {
        self.pointingId = pointingId
    }

    func perform() async throws -> some IntentResult {
        guard !pointingId.isEmpty, let defaults = UserDefaults(suiteName: appGroupId) else {
            return .result()
        }

        appendUnique(pointingId, toJsonArrayAt: "widget_favorites", in: defaults)
        appendUnique(pointingId, toJsonArrayAt: "pending_saves", in: defaults)

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    private func appendUnique(_ id: String, toJsonArrayAt key: String, in defaults: UserDefaults) {
        var ids: [String] = []
        if let json = defaults.string(forKey: key),
           let data = json.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(with: data) as? [String] {
            ids = array
        }
        guard !ids.contains(id) else { return }
        ids.append(id)
        if let data = try? JSONSerialization.data(withJSONObject: ids),
           let json = String(data: data, encoding: .utf8) {
            defaults.set(json, forKey: key)
        }
    }
}
