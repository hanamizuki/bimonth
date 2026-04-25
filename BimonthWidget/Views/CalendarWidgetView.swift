// entry.date is reused as the "today" baseline for both MonthView calls.
import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry

    var body: some View {
        let calendar = Calendar.current
        let (leading, trailing) = MonthResolver.monthsToDisplay(
            for: entry.date,
            calendar: calendar
        )

        HStack(alignment: .top, spacing: 16) {
            MonthView(
                monthStart: leading,
                today: entry.date,
                calendar: calendar
            )
            MonthView(
                monthStart: trailing,
                today: entry.date,
                calendar: calendar
            )
        }
    }
}
