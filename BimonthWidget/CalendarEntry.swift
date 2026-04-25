// `date` is both the entry's activation time AND the "today" baseline rendered downstream.
import WidgetKit

struct CalendarEntry: TimelineEntry {
    let date: Date
}
