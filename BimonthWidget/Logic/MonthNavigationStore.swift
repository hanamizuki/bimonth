import Foundation

enum MonthNavigationStore {
    private static let offsetKey = "displayedMonthOffset"

    /// Shared by all installed Bimonth widget instances. WidgetKit doesn't expose a writable
    /// per-instance state slot for interactive App Intents, so the navigation buttons update
    /// one widget-kind-level offset.
    static var monthOffset: Int {
        UserDefaults.standard.integer(forKey: offsetKey)
    }

    static func move(by delta: Int) {
        UserDefaults.standard.set(monthOffset + delta, forKey: offsetKey)
    }
}
