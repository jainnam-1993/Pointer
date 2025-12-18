import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Data Model

struct PointingData: Codable {
    let content: String
    let teacher: String?
    let tradition: String
    let lastUpdated: String?

    static let placeholder = PointingData(
        content: "Rest doesn't come from stopping. Notice what has never been disturbed.",
        teacher: "Papaji",
        tradition: "Advaita Vedanta",
        lastUpdated: nil
    )
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    private let appGroupId = "group.com.pointer.widget"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    func placeholder(in context: Context) -> PointingEntry {
        PointingEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PointingEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PointingEntry>) -> Void) {
        let entry = loadCurrentEntry()

        // Refresh every 3 hours
        let nextUpdate = Calendar.current.date(
            byAdding: .hour,
            value: 3,
            to: Date()
        ) ?? Date().addingTimeInterval(3600 * 3)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> PointingEntry {
        guard let defaults = sharedDefaults else {
            return PointingEntry(date: Date(), data: .placeholder)
        }

        let content = defaults.string(forKey: "pointing_content")
        let teacher = defaults.string(forKey: "pointing_teacher")
        let tradition = defaults.string(forKey: "pointing_tradition")
        let lastUpdated = defaults.string(forKey: "pointing_last_updated")

        guard let content = content, !content.isEmpty else {
            return PointingEntry(date: Date(), data: .placeholder)
        }

        let data = PointingData(
            content: content,
            teacher: teacher?.isEmpty == true ? nil : teacher,
            tradition: tradition ?? "Unknown",
            lastUpdated: lastUpdated
        )

        return PointingEntry(date: Date(), data: data)
    }
}

// MARK: - Entry

struct PointingEntry: TimelineEntry {
    let date: Date
    let data: PointingData
}

// MARK: - Widget Views

struct PointerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Glass background (only for home screen widgets)
            if !isAccessoryWidget {
                glassBackground
            }

            // Content based on widget size
            switch family {
            case .systemSmall:
                smallWidgetWithActions
            case .systemMedium:
                mediumWidgetWithActions
            case .systemLarge:
                largeWidgetWithActions
            case .accessoryCircular:
                accessoryCircularWidget
            case .accessoryRectangular:
                accessoryRectangularWidget
            case .accessoryInline:
                accessoryInlineWidget
            default:
                mediumWidgetWithActions
            }
        }
    }

    private var isAccessoryWidget: Bool {
        switch family {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return true
        default:
            return false
        }
    }

    // MARK: - Glass Background

    private var glassBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "0F0524"), Color(hex: "1A0A3A")]
                    : [Color(hex: "F8F6FF"), Color(hex: "EDE8F5")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Glass overlay
            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.6)
        }
    }

    // MARK: - Small Widget (2x2)

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Tradition
            Text(entry.data.tradition)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(mutedTextColor)
                .textCase(.uppercase)
                .tracking(0.5)

            Spacer()

            // Quote excerpt
            Text(entry.data.content)
                .font(.system(size: 12, weight: .light))
                .lineLimit(4)
                .foregroundColor(textColor)

            Spacer()
        }
        .padding(12)
    }

    // MARK: - Medium Widget (4x2)

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(entry.data.tradition)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(mutedTextColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            Spacer()

            // Quote
            Text(entry.data.content)
                .font(.system(size: 14, weight: .light))
                .lineLimit(3)
                .foregroundColor(textColor)

            // Teacher
            if let teacher = entry.data.teacher {
                Text("— \(teacher)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(mutedTextColor)
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Large Widget (4x4)

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(entry.data.tradition)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(mutedTextColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            Spacer()

            // Quote
            Text(entry.data.content)
                .font(.system(size: 17, weight: .light))
                .foregroundColor(textColor)
                .multilineTextAlignment(.leading)

            Spacer()

            // Footer
            HStack {
                if let teacher = entry.data.teacher {
                    Text("— \(teacher)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(mutedTextColor)
                }
                Spacer()
                Text("Tap to explore")
                    .font(.system(size: 10))
                    .foregroundColor(accentColor.opacity(0.7))
            }
        }
        .padding(20)
    }

    // MARK: - Widgets with Action Buttons (iOS 17+)

    /// Small widget with action buttons
    @ViewBuilder
    private var smallWidgetWithActions: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 4) {
                smallWidgetContent
                actionButtons(iconSize: 14, spacing: 16)
            }
            .padding(12)
        } else {
            smallWidget
        }
    }

    /// Medium widget with action buttons
    @ViewBuilder
    private var mediumWidgetWithActions: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 6) {
                mediumWidgetContent
                actionButtons(iconSize: 16, spacing: 20)
            }
            .padding(16)
        } else {
            mediumWidget
        }
    }

    /// Large widget with action buttons
    @ViewBuilder
    private var largeWidgetWithActions: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 8) {
                largeWidgetContent
                actionButtons(iconSize: 18, spacing: 24)
            }
            .padding(20)
        } else {
            largeWidget
        }
    }

    /// Content for small widget (without padding)
    private var smallWidgetContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.data.tradition)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(mutedTextColor)
                .textCase(.uppercase)
                .tracking(0.5)

            Spacer()

            Text(entry.data.content)
                .font(.system(size: 11, weight: .light))
                .lineLimit(3)
                .foregroundColor(textColor)

            Spacer()
        }
    }

    /// Content for medium widget (without padding)
    private var mediumWidgetContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.data.tradition)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(mutedTextColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            Spacer()

            Text(entry.data.content)
                .font(.system(size: 13, weight: .light))
                .lineLimit(2)
                .foregroundColor(textColor)

            if let teacher = entry.data.teacher {
                Text("— \(teacher)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(mutedTextColor)
            }

            Spacer()
        }
    }

    /// Content for large widget (without padding)
    private var largeWidgetContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.data.tradition)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(mutedTextColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            Spacer()

            Text(entry.data.content)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(textColor)
                .multilineTextAlignment(.leading)

            if let teacher = entry.data.teacher {
                Text("— \(teacher)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(mutedTextColor)
            }

            Spacer()
        }
    }

    /// Action buttons for interactive widgets
    @ViewBuilder
    private func actionButtons(iconSize: CGFloat, spacing: CGFloat) -> some View {
        if #available(iOS 17.0, *) {
            HStack(spacing: spacing) {
                Button(intent: RefreshPointingIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(mutedTextColor)
                }
                .buttonStyle(.plain)

                Button(intent: SavePointingIntent()) {
                    Image(systemName: "bookmark")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(mutedTextColor)
                }
                .buttonStyle(.plain)
            }
        } else {
            // No interactive buttons for iOS < 17
            EmptyView()
        }
    }

    // MARK: - Lock Screen Widgets

    /// Circular Lock Screen widget - shows icon/symbol
    private var accessoryCircularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .light))
        }
    }

    /// Rectangular Lock Screen widget - shows quote excerpt
    private var accessoryRectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(truncatedQuote(maxLength: 60))
                .font(.system(size: 12, weight: .regular))
                .lineLimit(2)

            if let teacher = entry.data.teacher {
                Text("— \(teacher)")
                    .font(.system(size: 10, weight: .medium))
                    .opacity(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Inline Lock Screen widget - single line text
    private var accessoryInlineWidget: some View {
        Text(truncatedQuote(maxLength: 30))
            .font(.system(size: 12))
    }

    /// Truncate quote to fit widget constraints
    private func truncatedQuote(maxLength: Int) -> String {
        let content = entry.data.content
        if content.count <= maxLength {
            return content
        }
        let truncated = String(content.prefix(maxLength - 3))
        // Try to end at a word boundary
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]) + "..."
        }
        return truncated + "..."
    }

    // MARK: - Colors

    private var textColor: Color {
        colorScheme == .dark ? .white : Color(hex: "1A0A3A")
    }

    private var mutedTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.6) : Color(hex: "1A0A3A").opacity(0.6)
    }

    private var accentColor: Color {
        Color(hex: "8B5CF6")
    }
}

// MARK: - Widget Configuration

struct PointerWidget: Widget {
    let kind: String = "PointerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PointerWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PointerWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Daily Pointing")
        .description("Wisdom from non-dual traditions")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    PointerWidget()
} timeline: {
    PointingEntry(date: .now, data: .placeholder)
}
