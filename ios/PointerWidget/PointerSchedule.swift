import Foundation

/// The widget timeline schedule as a pure function, so it can be checked without WidgetKit
/// (see ios/PointerWidgetTests/main.swift).
enum PointerSchedule {
    struct Slot: Equatable {
        let date: Date
        let index: Int
    }

    /// `count` slots, `intervalMinutes` apart from `start`, showing consecutive pointings from the
    /// user's current position (wrapped into 0..<total, negatives included).
    static func slots(start: Date, currentIndex: Int, total: Int, count: Int = 12, intervalMinutes: Int = 30) -> [Slot] {
        guard total > 0, count > 0 else { return [] }
        let first = ((currentIndex % total) + total) % total
        return (0..<count).map { i in
            Slot(date: start.addingTimeInterval(TimeInterval(i * intervalMinutes * 60)), index: (first + i) % total)
        }
    }
}
