// Widget 根 View：水平排列兩個 MonthView。
// 由 MonthResolver 決定要顯示哪兩個月，entry.date 同時作為「今天」的基準。
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

        HStack(alignment: .top, spacing: 12) {
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

#Preview(as: .systemMedium) {
    BimonthWidget()
} timeline: {
    CalendarEntry(date: Date())
}
