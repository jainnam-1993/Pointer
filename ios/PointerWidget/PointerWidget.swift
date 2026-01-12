import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Data Model

struct PointingData: Codable {
    let id: String?
    let content: String
    let teacher: String?
    let tradition: String
    let lastUpdated: String?
    let isFavorite: Bool

    static let placeholder = PointingData(
        id: nil,
        content: "Rest doesn't come from stopping. Notice what has never been disturbed.",
        teacher: "Papaji",
        tradition: "Advaita Vedanta",
        lastUpdated: nil,
        isFavorite: false
    )
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    private let appGroupId = "group.com.dailypointer.widget"

    /// How often to show a new quote (in minutes)
    private let rotationIntervalMinutes = 30

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    func placeholder(in context: Context) -> PointingEntry {
        PointingEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PointingEntry) -> Void) {
        let entry = loadRandomEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PointingEntry>) -> Void) {
        // Load all pointings and favorites from cache
        let allPointings = loadAllPointings()
        let favorites = loadFavorites()

        guard !allPointings.isEmpty else {
            // No cache - use single entry and request refresh
            let entry = PointingEntry(date: Date(), data: .placeholder)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            return
        }

        // Get current index from user navigation (prev/next buttons)
        let currentIndex = sharedDefaults?.integer(forKey: "widget_current_index") ?? 0
        // Wrap around if index exceeds bounds
        let safeIndex = currentIndex % allPointings.count
        // Ensure non-negative after wrap
        let normalizedIndex = safeIndex >= 0 ? safeIndex : allPointings.count + safeIndex

        // Create timeline entries starting from current index
        var entries: [PointingEntry] = []
        let currentDate = Date()

        // Generate 12 entries (6 hours worth at 30-min intervals)
        // Starting from the user-selected index
        for i in 0..<12 {
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: i * rotationIntervalMinutes,
                to: currentDate
            ) ?? currentDate.addingTimeInterval(Double(i * rotationIntervalMinutes * 60))

            // Start from current index and advance
            let index = (normalizedIndex + i) % allPointings.count
            let pointing = allPointings[index]
            let pointingId = pointing["id"] as? String

            let data = PointingData(
                id: pointingId,
                content: pointing["content"] as? String ?? "",
                teacher: pointing["teacher"] as? String,
                tradition: pointing["tradition"] as? String ?? "Unknown",
                lastUpdated: nil,
                isFavorite: pointingId != nil && favorites.contains(pointingId!)
            )

            entries.append(PointingEntry(date: entryDate, data: data))
        }

        // Store current pointing content and ID for save intent
        if let firstPointing = allPointings[safe: normalizedIndex] {
            sharedDefaults?.set(firstPointing["content"] as? String ?? "", forKey: "pointing_content")
            sharedDefaults?.set(firstPointing["id"] as? String ?? "", forKey: "pointing_id")
        }

        // Request refresh after all entries are shown
        let lastEntryDate = entries.last?.date ?? currentDate
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: rotationIntervalMinutes, to: lastEntryDate) ?? lastEntryDate.addingTimeInterval(1800)

        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    /// Load all pointings from the JSON cache
    private func loadAllPointings() -> [[String: Any]] {
        guard let defaults = sharedDefaults else {
            print("[PointerWidget] ERROR: Could not access app group UserDefaults")
            return []
        }

        guard let cacheJson = defaults.string(forKey: "pointings_cache") else {
            print("[PointerWidget] WARNING: No pointings_cache in UserDefaults")
            // Debug: List all keys to see what's there
            let allKeys = defaults.dictionaryRepresentation().keys
            print("[PointerWidget] Available keys: \(Array(allKeys.prefix(10)))")
            return []
        }

        guard let data = cacheJson.data(using: .utf8) else {
            print("[PointerWidget] ERROR: Could not convert cache to data")
            return []
        }

        guard let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("[PointerWidget] ERROR: Could not parse JSON")
            return []
        }

        print("[PointerWidget] Loaded \(array.count) pointings from cache")
        return array
    }

    /// Load favorites set from the JSON cache
    private func loadFavorites() -> Set<String> {
        guard let defaults = sharedDefaults,
              let favoritesJson = defaults.string(forKey: "widget_favorites"),
              let data = favoritesJson.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return []
        }
        return Set(array)
    }

    /// Load a random entry for snapshots
    private func loadRandomEntry() -> PointingEntry {
        let allPointings = loadAllPointings()
        let favorites = loadFavorites()

        guard !allPointings.isEmpty else {
            return PointingEntry(date: Date(), data: .placeholder)
        }

        let randomIndex = Int.random(in: 0..<allPointings.count)
        let pointing = allPointings[randomIndex]
        let pointingId = pointing["id"] as? String

        let data = PointingData(
            id: pointingId,
            content: pointing["content"] as? String ?? "",
            teacher: pointing["teacher"] as? String,
            tradition: pointing["tradition"] as? String ?? "Unknown",
            lastUpdated: nil,
            isFavorite: pointingId != nil && favorites.contains(pointingId!)
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
            // Glass background for iOS < 17 (iOS 17+ uses containerBackground)
            if #unavailable(iOS 17.0), !isAccessoryWidget {
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

            // Quote excerpt with auto-sizing (like Android autoSizeTextType)
            Text(entry.data.content)
                .font(.system(size: dynamicFontSize(for: .systemSmall), weight: .light))
                .minimumScaleFactor(0.7)  // Can shrink to 70% for long text
                .lineLimit(6)
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

            // Quote with auto-sizing (like Android autoSizeTextType)
            Text(entry.data.content)
                .font(.system(size: dynamicFontSize(for: .systemMedium), weight: .light))
                .minimumScaleFactor(0.65)  // Can shrink to 65% for long text
                .lineLimit(5)
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

            // Quote with auto-sizing (like Android autoSizeTextType)
            Text(entry.data.content)
                .font(.system(size: dynamicFontSize(for: .systemLarge), weight: .light))
                .minimumScaleFactor(0.6)  // Can shrink to 60% for long text
                .lineLimit(10)
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
                .minimumScaleFactor(0.6)  // Can shrink to 60% for long text
                .lineLimit(8)
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

    /// Action buttons for interactive widgets - matches Android layout: Save | ◀ | ▶
    @ViewBuilder
    private func actionButtons(iconSize: CGFloat, spacing: CGFloat) -> some View {
        if #available(iOS 17.0, *) {
            HStack(spacing: 0) {
                // Save button on left (like Android) - filled heart if already saved
                Button(intent: SavePointingIntent()) {
                    Image(systemName: entry.data.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(entry.data.isFavorite ? accentColor : mutedTextColor)
                }
                .buttonStyle(.plain)

                Spacer()

                // Navigation buttons centered (like Android ◀ ▶)
                HStack(spacing: spacing * 1.5) {
                    Button(intent: PreviousPointingIntent()) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: iconSize + 4, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(.plain)

                    Button(intent: NextPointingIntent()) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: iconSize + 4, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Empty spacer to balance layout (like Android)
                Color.clear
                    .frame(width: iconSize + 16)
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

    // MARK: - Dynamic Font Sizing

    /// Calculate base font size for widget family (matches Android autoSizeTextType)
    /// The minimumScaleFactor allows shrinking for longer text
    private func dynamicFontSize(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall:
            return 13  // Base size, can shrink to 70% (9.1pt) for long text
        case .systemMedium:
            return 15  // Base size, can shrink to 65% (9.75pt) for long text
        case .systemLarge:
            return 17  // Base size, can shrink to 60% (10.2pt) for long text
        default:
            return 14
        }
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

// MARK: - Container Background (iOS 17+)

/// Custom container background for iOS 17+ widgets
/// Matches the app's glass/gradient theme
@available(iOS 17.0, *)
struct ContainerBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Base gradient matching app theme
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
}

// MARK: - Widget Configuration

struct PointerWidget: Widget {
    let kind: String = "PointerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PointerWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        // Use custom glass background matching app theme
                        ContainerBackgroundView()
                    }
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

// MARK: - Collection Extension

extension Collection {
    /// Safe subscript that returns nil for out-of-bounds indices
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    PointerWidget()
} timeline: {
    PointingEntry(date: .now, data: .placeholder)
}
