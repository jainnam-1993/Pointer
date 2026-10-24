// Timeline check for the widget, run without Xcode test targets:
//   swiftc -o /tmp/schedcheck ios/PointerWidget/PointerSchedule.swift ios/PointerWidgetTests/main.swift && /tmp/schedcheck
import Foundation

func check(_ ok: Bool, _ what: String) {
    if !ok { print("FAIL: \(what)"); exit(1) }
    print("ok: \(what)")
}

let start = Date(timeIntervalSince1970: 1_800_000_000)
let slots = PointerSchedule.slots(start: start, currentIndex: 7, total: 2400)
check(slots.count == 12, "twelve entries cover six hours")
check(Set(slots.map(\.index)).count == 12, "every entry shows a different pointing")
check(slots.first?.index == 7, "the first entry is the pointing the user is on")
check(zip(slots, slots.dropFirst()).allSatisfy { $1.date.timeIntervalSince($0.date) == 1800 }, "entries advance every 30 minutes")
check(slots.last!.date.timeIntervalSince(start) == 5.5 * 3600, "the last entry starts 5.5 h out; .atEnd then reloads")
check(PointerSchedule.slots(start: start, currentIndex: -1, total: 5, count: 3).map(\.index) == [4, 0, 1], "Previous past the start wraps")
check(PointerSchedule.slots(start: start, currentIndex: 0, total: 0).isEmpty, "no pointings, no entries")
print("PointerSchedule: all checks passed")
