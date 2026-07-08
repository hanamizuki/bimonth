import Foundation

enum MonthNavigationStore {
    private static let offsetKey = "displayedMonthOffset"
    static let monthOffsetRange = -24...24
    private static let queue = DispatchQueue(label: "com.example.bimonth.month-navigation-store")

    /// Shared by all installed Bimonth widget instances. WidgetKit doesn't expose a writable
    /// per-instance state slot for interactive App Intents, so the navigation buttons update
    /// one widget-kind-level offset.
    static var monthOffset: Int {
        queue.sync {
            normalizedMonthOffset(UserDefaults.standard.integer(forKey: offsetKey))
        }
    }

    static func move(by delta: Int) {
        guard let step = normalizedStep(delta) else {
            return
        }

        queue.sync {
            let current = normalizedMonthOffset(UserDefaults.standard.integer(forKey: offsetKey))
            UserDefaults.standard.set(normalizedMonthOffset(current + step), forKey: offsetKey)
        }
    }

    static func normalizedMonthOffset(_ offset: Int) -> Int {
        min(max(offset, monthOffsetRange.lowerBound), monthOffsetRange.upperBound)
    }

    static func normalizedStep(_ delta: Int) -> Int? {
        if delta < 0 { return -1 }
        if delta > 0 { return 1 }
        return nil
    }
}
