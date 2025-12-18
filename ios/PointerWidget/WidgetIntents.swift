import WidgetKit
import AppIntents
import SwiftUI

// MARK: - iOS 17+ Interactive Widget Intents

/// Intent to refresh the widget with a new pointing
@available(iOS 17.0, *)
struct RefreshPointingIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Pointing"
    static var description = IntentDescription("Get a new daily pointing")

    func perform() async throws -> some IntentResult {
        // Post notification to trigger Flutter background callback
        DistributedNotificationCenter.default().postNotificationName(
            NSNotification.Name("PointerWidgetRefresh"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        // Update widget data with a placeholder to show refresh is in progress
        let defaults = UserDefaults(suiteName: "group.com.pointer.widget")
        // The actual refresh will be handled by Flutter background callback

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
        // Post notification to trigger Flutter background callback
        DistributedNotificationCenter.default().postNotificationName(
            NSNotification.Name("PointerWidgetSave"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        return .result()
    }
}

// MARK: - iOS 17+ Interactive Widget Views

/// Widget view with interactive buttons for iOS 17+
@available(iOS 17.0, *)
struct InteractiveWidgetContent: View {
    var entry: PointingEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            // Main content
            MainContentView(entry: entry, family: family, colorScheme: colorScheme)

            // Action buttons row
            if family != .accessoryCircular && family != .accessoryInline {
                HStack(spacing: 24) {
                    Button(intent: RefreshPointingIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "505050"))
                    }
                    .buttonStyle(.plain)

                    Button(intent: SavePointingIntent()) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "505050"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
        }
    }
}

/// Main content view extracted for reuse
struct MainContentView: View {
    var entry: PointingEntry
    var family: WidgetFamily
    var colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Tradition badge
            if !entry.data.tradition.isEmpty {
                Text(entry.data.tradition)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(mutedTextColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            Spacer()

            // Quote content
            Text(entry.data.content)
                .font(.system(size: fontSize, weight: .light))
                .lineLimit(maxLines)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)

            // Teacher attribution
            if let teacher = entry.data.teacher {
                Text("— \(teacher)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(mutedTextColor)
                    .padding(.top, 4)
            }

            Spacer()
        }
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : Color(hex: "1A0A3A")
    }

    private var mutedTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.6) : Color(hex: "1A0A3A").opacity(0.6)
    }

    private var fontSize: CGFloat {
        switch family {
        case .systemSmall: return 12
        case .systemMedium: return 14
        case .systemLarge: return 17
        default: return 14
        }
    }

    private var maxLines: Int {
        switch family {
        case .systemSmall: return 4
        case .systemMedium: return 3
        case .systemLarge: return 8
        default: return 4
        }
    }
}

// MARK: - Helper to check iOS 17 availability

struct WidgetContentBuilder {
    /// Returns appropriate widget view based on iOS version
    @ViewBuilder
    static func buildContent(entry: PointingEntry) -> some View {
        if #available(iOS 17.0, *) {
            InteractiveWidgetContent(entry: entry)
        } else {
            // Fall back to non-interactive view for iOS < 17
            LegacyWidgetContent(entry: entry)
        }
    }
}

/// Legacy non-interactive widget content for iOS < 17
struct LegacyWidgetContent: View {
    var entry: PointingEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        MainContentView(entry: entry, family: family, colorScheme: colorScheme)
    }
}
