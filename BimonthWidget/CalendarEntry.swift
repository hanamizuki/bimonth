// `date` is both the entry's activation time AND the "today" baseline rendered downstream.
import WidgetKit

struct CalendarEntry: TimelineEntry {
    let date: Date
    let switchDay: Int
    let monthOffset: Int

    init(
        date: Date,
        switchDay: Int = MonthResolver.defaultSwitchDay,
        monthOffset: Int = 0
    ) {
        self.date = date
        self.switchDay = switchDay
        self.monthOffset = monthOffset
    }
}
