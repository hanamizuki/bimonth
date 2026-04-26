// entry.date is reused as the "today" baseline for both MonthView calls.
import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry
    @Environment(\.calendar) private var calendar

    var body: some View {
        let (leading, trailing) = MonthResolver.monthsToDisplay(
            for: entry.date,
            calendar: calendar
        )

        HStack(alignment: .top, spacing: 16) {
            MonthView(monthStart: leading, today: entry.date)
            MonthView(monthStart: trailing, today: entry.date)
        }
    }
}
