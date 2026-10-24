import WidgetKit
import SwiftUI
import AppIntents
import UIKit

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

            entries.append(PointingEntry(date: entryDate, data: data, relevance: Self.relevance(at: entryDate, minutes: rotationIntervalMinutes)))
        }

        // Each entry carries its own pointing id into SavePointingIntent (see the heart button),
        // so no "current id" is stored here.

        // Twelve distinct pointings, one per 30-minute slot (six hours); WidgetKit asks for a new
        // timeline once the last one is on screen.
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    /// Smart Stack relevance: the reflective hours (morning 5-11 and evening 17-23, aligned with the
    /// notification rotation) score higher than midday and night. Scores stay on one positive scale.
    static func relevance(at date: Date, minutes: Int) -> TimelineEntryRelevance {
        let hour = Calendar.current.component(.hour, from: date)
        let score: Float
        switch hour {
        case 5..<11, 17..<23: score = 1.0
        case 11..<17: score = 0.5
        default: score = 0.2
        }
        return TimelineEntryRelevance(score: score, duration: TimeInterval(minutes * 60))
    }

    /// Load all pointings from the JSON cache, falling back to bundled defaults.
    private func loadAllPointings() -> [[String: Any]] {
        guard let defaults = sharedDefaults else {
            print("[PointerWidget] ERROR: Could not access app group UserDefaults")
            return loadBundledDefaults()
        }

        guard let cacheJson = defaults.string(forKey: "pointings_cache") else {
            print("[PointerWidget] WARNING: No pointings_cache in UserDefaults, using bundled defaults")
            return loadBundledDefaults()
        }

        guard let data = cacheJson.data(using: .utf8) else {
            print("[PointerWidget] ERROR: Could not convert cache to data, using bundled defaults")
            return loadBundledDefaults()
        }

        guard let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("[PointerWidget] ERROR: Could not parse JSON, using bundled defaults")
            return loadBundledDefaults()
        }

        print("[PointerWidget] Loaded \(array.count) pointings from cache")
        return array
    }

    /// Load default pointings from the bundled DefaultPointings.json.
    private func loadBundledDefaults() -> [[String: Any]] {
        guard let url = Bundle.main.url(forResource: "DefaultPointings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("[PointerWidget] ERROR: Could not load bundled DefaultPointings.json")
            return []
        }
        print("[PointerWidget] Loaded \(array.count) default pointings from bundle")
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
    var relevance: TimelineEntryRelevance? = nil
}

// MARK: - Style

/// What the system is doing with the widget right now. Full color shows the house palette on its calm
/// card; accented (tinted Home Screen, iOS 18) and vibrant (clear glass on iOS 26, Lock Screen, StandBy
/// at night) take the wallpaper's tint, so content then uses hierarchical system styles only.
struct WidgetEnvironment {
    var fullColor = true
    var showsBackground = true
}

@available(iOS 17.0, *)
private struct WidgetEnvironmentReader17<Content: View>: View {
    @Environment(\.widgetRenderingMode) private var mode
    @Environment(\.showsWidgetContainerBackground) private var showsBackground
    let content: (WidgetEnvironment) -> Content
    var body: some View { content(WidgetEnvironment(fullColor: mode == .fullColor, showsBackground: showsBackground)) }
}

@available(iOS 16.0, *)
private struct WidgetEnvironmentReader16<Content: View>: View {
    @Environment(\.widgetRenderingMode) private var mode
    let content: (WidgetEnvironment) -> Content
    var body: some View { content(WidgetEnvironment(fullColor: mode == .fullColor, showsBackground: true)) }
}

/// Reads the rendering mode where the OS has it (iOS 16+) and the background state (iOS 17+).
struct WidgetEnvironmentReader<Content: View>: View {
    let content: (WidgetEnvironment) -> Content

    var body: some View {
        if #available(iOS 17.0, *) {
            WidgetEnvironmentReader17(content: content)
        } else if #available(iOS 16.0, *) {
            WidgetEnvironmentReader16(content: content)
        } else {
            content(WidgetEnvironment())
        }
    }
}

/// Colors per mode. Full-color pairs are measured on the card's darker stop (#F1EEE8 light,
/// #1C1B1F dark): ink about 15:1, secondary 6.3:1 light and 8:1 dark, accent 7:1 light and 7.5:1 dark,
/// so body text clears 4.5:1 in both. In accented and vibrant modes the system owns contrast.
struct WidgetPalette {
    let env: WidgetEnvironment
    let dark: Bool

    var ink: Color { env.fullColor ? (dark ? Color(hex: "F4F1EC") : Color(hex: "1D1B20")) : .primary }
    var secondary: Color { env.fullColor ? (dark ? Color(hex: "B4AFB8") : Color(hex: "5A5560")) : .secondary }
    var accent: Color { env.fullColor ? (dark ? Color(hex: "B79CFF") : Color(hex: "6D28D9")) : .primary }
}

/// Type: the bundled Newsreader serif for the pointing (New York if it fails to register), SF for the rest.
/// Every size is relative to a text style, so it scales with Dynamic Type up to the widget's cap.
enum WidgetType {
    static let serifName: String? = {
        for name in ["Newsreader", "Newsreader-Regular", "Newsreader16pt-Regular"] where UIFont(name: name, size: 12) != nil {
            return name
        }
        return UIFont.fontNames(forFamilyName: "Newsreader").first
    }()

    static func pointing(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        if let name = serifName { return .custom(name, size: size, relativeTo: style) }
        return .system(style, design: .serif)
    }

    static let eyebrow = Font.caption2.weight(.semibold)
}

extension View {
    /// Puts this layer in the accent group in accented and vibrant modes (no-op before iOS 16).
    @ViewBuilder func pointerAccentable() -> some View {
        if #available(iOS 16.0, *) { self.widgetAccentable() } else { self }
    }
}

// MARK: - Widget Views

struct PointerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    /// Deep-link URL for widget taps — passes the pointing ID to the app.
    private var widgetDeepLink: URL? {
        guard let id = entry.data.id else { return nil }
        return URL(string: "dailypointer://pointing/\(id)")
    }

    var body: some View {
        WidgetEnvironmentReader { env in
            content(WidgetPalette(env: env, dark: colorScheme == .dark), env: env)
        }
        .widgetURL(widgetDeepLink)
    }

    @ViewBuilder
    private func content(_ palette: WidgetPalette, env: WidgetEnvironment) -> some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularWidget
        case .accessoryRectangular:
            accessoryRectangularWidget
        case .accessoryInline:
            accessoryInlineWidget
        default:
            systemWidget(palette, env: env)
                // Widgets are glanceable: cap the scale where the layouts still fit.
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        }
    }

    @ViewBuilder
    private func systemWidget(_ palette: WidgetPalette, env: WidgetEnvironment) -> some View {
        if #available(iOS 17.0, *) {
            // iOS 17+: containerBackground supplies the card and the system content margins.
            systemLayout(palette, env: env)
        } else {
            // Before iOS 17 there are no system margins; use the system default padding.
            ZStack {
                WidgetCardBackground()
                systemLayout(palette, env: env).padding()
            }
        }
    }

    @ViewBuilder
    private func systemLayout(_ palette: WidgetPalette, env: WidgetEnvironment) -> some View {
        switch family {
        case .systemSmall: smallLayout(palette, env: env)
        case .systemLarge, .systemExtraLarge: largeLayout(palette)
        default: mediumLayout(palette)
        }
    }

    private var attribution: String? {
        guard let teacher = entry.data.teacher, !teacher.isEmpty else { return nil }
        return "\u{2014} \(teacher)"
    }

    private func eyebrow(_ text: String, _ palette: WidgetPalette) -> some View {
        Text(text)
            .font(WidgetType.eyebrow)
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(palette.accent)
            .lineLimit(1)
            .pointerAccentable()
    }

    private func pointingText(size: CGFloat, style: Font.TextStyle, lines: Int, palette: WidgetPalette) -> some View {
        Text(entry.data.content)
            .font(WidgetType.pointing(size, relativeTo: style))
            .foregroundStyle(palette.ink)
            .lineLimit(lines)
            .minimumScaleFactor(0.7)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// One VoiceOver element for the reading: "pointing, teacher, tradition". Buttons stay separate.
    private var readingLabel: String {
        [entry.data.content, entry.data.teacher, entry.data.tradition].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
    }

    // MARK: Small: teacher eyebrow, the pointing, compact controls. StandBy shows this at a distance,
    // so with the card removed the serif sets a size larger and keeps one more line.

    private func smallLayout(_ palette: WidgetPalette, env: WidgetEnvironment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 6) {
                eyebrow(entry.data.teacher ?? entry.data.tradition, palette)
                pointingText(size: env.showsBackground ? 15 : 17, style: .subheadline, lines: env.showsBackground ? 4 : 5, palette: palette)
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(readingLabel)
            controls(palette, target: 32, spread: true)
        }
    }

    // MARK: Medium: tradition eyebrow, three serif lines, one footer row with teacher and controls.

    private func mediumLayout(_ palette: WidgetPalette) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 6) {
                eyebrow(entry.data.tradition, palette)
                pointingText(size: 18, style: .body, lines: 3, palette: palette)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(readingLabel)
            Spacer(minLength: 0)
            HStack(alignment: .center, spacing: 8) {
                if let attribution {
                    Text(attribution)
                        .font(.footnote)
                        .foregroundStyle(palette.secondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: 0)
                controls(palette, target: 36, spread: false)
            }
        }
    }

    // MARK: Large: quote mark and tradition, a generous serif pointing, the teacher, a full control row.

    private func largeLayout(_ palette: WidgetPalette) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "quote.opening")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(palette.accent)
                        .pointerAccentable()
                    eyebrow(entry.data.tradition, palette)
                }
                Spacer(minLength: 0)
                pointingText(size: 24, style: .title2, lines: 9, palette: palette)
                    .lineSpacing(2)
                if let attribution {
                    Text(attribution)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(readingLabel)
            controls(palette, target: 44, spread: true)
        }
    }

    // MARK: Controls (iOS 17+ interactive widgets): Save on the leading edge, Previous and Next together.

    @ViewBuilder
    private func controls(_ palette: WidgetPalette, target: CGFloat, spread: Bool) -> some View {
        if #available(iOS 17.0, *) {
            PointerControls(data: entry.data, palette: palette, target: target, spread: spread)
        }
    }

    // MARK: - Lock Screen Widgets

    /// Circular Lock Screen widget - shows icon/symbol
    private var accessoryCircularWidget: some View {
        ZStack {
            if #available(iOS 16.0, *) {
                AccessoryWidgetBackground()
            }
            Image(systemName: "sparkles")
                .font(.title3.weight(.light))
                .pointerAccentable()
        }
        .accessibilityLabel(entry.data.content)
    }

    /// Rectangular Lock Screen widget: teacher as the headline, then the pointing in serif.
    private var accessoryRectangularWidget: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(entry.data.teacher ?? entry.data.tradition)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .pointerAccentable()
            Text(entry.data.content)
                .font(WidgetType.pointing(14, relativeTo: .footnote))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(readingLabel)
    }

    /// Inline Lock Screen widget: one line above the clock; the system truncates and tints it.
    private var accessoryInlineWidget: some View {
        Label(truncatedQuote(maxLength: 60), systemImage: "quote.opening")
            .accessibilityLabel(readingLabel)
    }

    /// Truncate quote to fit widget constraints
    private func truncatedQuote(maxLength: Int) -> String {
        let content = entry.data.content
        if content.count <= maxLength {
            return content
        }
        let truncated = String(content.prefix(maxLength - 1))
        // Try to end at a word boundary
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]) + "\u{2026}"
        }
        return truncated + "\u{2026}"
    }
}

/// Save, Previous and Next as App Intent buttons. Each has a spoken label; Save reflects its state.
@available(iOS 17.0, *)
struct PointerControls: View {
    let data: PointingData
    let palette: WidgetPalette
    let target: CGFloat
    let spread: Bool

    var body: some View {
        HStack(spacing: 2) {
            Button(intent: SavePointingIntent(pointingId: data.id ?? "")) {
                glyph(data.isFavorite ? "heart.fill" : "heart")
            }
            .accessibilityLabel(data.isFavorite ? "Saved to favorites" : "Save to favorites")
            if spread { Spacer(minLength: 0) }
            Button(intent: PreviousPointingIntent()) { glyph("chevron.left") }
                .accessibilityLabel("Previous pointing")
            Button(intent: NextPointingIntent()) { glyph("chevron.right") }
                .accessibilityLabel("Next pointing")
        }
        .buttonStyle(.plain)
        .pointerAccentable()
    }

    private func glyph(_ name: String) -> some View {
        Image(systemName: name)
            .font(.body.weight(.semibold))
            .imageScale(target >= 44 ? .large : .medium)
            .foregroundStyle(palette.accent)
            .frame(width: target, height: target)
            .contentShape(Rectangle())
    }
}

// MARK: - Container Background

/// The calm card: warm paper in light, soft graphite in dark, with a faint violet light from the top.
/// It is the container background, so the system removes it in StandBy, tinted and clear modes.
struct WidgetCardBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let dark = colorScheme == .dark
        ZStack {
            LinearGradient(
                colors: dark ? [Color(hex: "242229"), Color(hex: "1C1B1F")] : [Color(hex: "FBFAF7"), Color(hex: "F1EEE8")],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color(hex: dark ? "B79CFF" : "8B5CF6").opacity(dark ? 0.10 : 0.06), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 260
            )
        }
    }
}

// MARK: - Widget Configuration

struct PointerWidget: Widget {
    let kind: String = "PointerWidget"

    private var supportedFamiliesList: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .accessoryCircular,
                .accessoryRectangular,
                .accessoryInline,
            ]
        }

        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
        ]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PointerWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetCardBackground()
                    }
            } else {
                PointerWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Daily Pointing")
        .description("A short pointing from the non-dual traditions, with its teacher.")
        .supportedFamilies(supportedFamiliesList)
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

#if DEBUG
@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    PointerWidget()
} timeline: {
    PointingEntry(date: Date(), data: .placeholder)
}
#endif
