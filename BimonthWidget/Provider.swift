// Generates 7 daily entries (each at local midnight) with .atEnd policy so the system
// re-requests the timeline after the seven-entry window. Covers daily midnight, the configured
// switch-day boundary, and the 1st-of-month boundary.
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    func snapshot(for configuration: BimonthConfigurationIntent, in context: Context) async -> CalendarEntry {
        CalendarEntry(
            date: Date(),
            switchDay: configuration.normalizedSwitchDay,
            monthOffset: MonthNavigationStore.monthOffset
        )
    }

    func timeline(for configuration: BimonthConfigurationIntent, in context: Context) async -> Timeline<CalendarEntry> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let switchDay = configuration.normalizedSwitchDay
        let monthOffset = MonthNavigationStore.monthOffset

        // .day arithmetic is DST-safe; startOfToday fallback covers exotic calendars where +day could return nil.
        let entries: [CalendarEntry] = (0..<7).map { offset in
            CalendarEntry(
                date: calendar.date(byAdding: .day, value: offset, to: startOfToday) ?? startOfToday,
                switchDay: switchDay,
                monthOffset: monthOffset
            )
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}
