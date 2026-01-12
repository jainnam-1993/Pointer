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
            let newIndex = max(0, currentIndex - 1)
            defaults.set(newIndex, forKey: "widget_current_index")
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

/// Intent to save the current pointing to favorites
@available(iOS 17.0, *)
struct SavePointingIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Pointing"
    static var description = IntentDescription("Save this pointing to your favorites")

    func perform() async throws -> some IntentResult {
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return .result()
        }

        // Get current pointing ID and content
        let currentId = defaults.string(forKey: "pointing_id")
        let currentContent = defaults.string(forKey: "pointing_content")

        // Store save request for Flutter to persist to SharedPreferences on next launch
        if let content = currentContent {
            var pendingSaves = defaults.stringArray(forKey: "pending_saves") ?? []
            if !pendingSaves.contains(content) {
                pendingSaves.append(content)
                defaults.set(pendingSaves, forKey: "pending_saves")
            }
        }

        // Update widget_favorites immediately for instant UI feedback (optimistic update)
        if let pointingId = currentId, !pointingId.isEmpty {
            // Load current favorites from JSON
            var favorites: [String] = []
            if let favoritesJson = defaults.string(forKey: "widget_favorites"),
               let data = favoritesJson.data(using: .utf8),
               let array = try? JSONSerialization.jsonObject(with: data) as? [String] {
                favorites = array
            }

            // Toggle favorite: add if not present, remove if present
            if favorites.contains(pointingId) {
                favorites.removeAll { $0 == pointingId }
            } else {
                favorites.append(pointingId)
            }

            // Save back as JSON
            if let jsonData = try? JSONSerialization.data(withJSONObject: favorites),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                defaults.set(jsonString, forKey: "widget_favorites")
            }
        }

        // Reload widget timeline to refresh UI
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
