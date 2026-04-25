// Generates 7 daily entries (each at local midnight) with .atEnd policy so the system
// re-requests the timeline after day 7. Covers all three spec §2.3 rollover triggers:
// daily midnight, the 7th-of-month split-point switch, and the 1st-of-month boundary.
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // .day arithmetic is DST-safe; startOfToday fallback covers exotic calendars where +day could return nil.
        let entries: [CalendarEntry] = (0..<7).map { offset in
            CalendarEntry(date: calendar.date(byAdding: .day, value: offset, to: startOfToday) ?? startOfToday)
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
