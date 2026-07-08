// entry.date is reused as the "today" baseline for both MonthView calls.
import AppIntents
import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry
    @Environment(\.calendar) private var calendar

    var body: some View {
        let (leading, trailing) = MonthResolver.monthsToDisplay(
            for: entry.date,
            calendar: calendar,
            switchDay: entry.switchDay,
            monthOffset: entry.monthOffset
        )

        HStack(alignment: .center, spacing: 6) {
            MonthNavigationButton(
                delta: -1,
                systemName: "chevron.left",
                accessibilityLabel: "Show previous month"
            )

            HStack(alignment: .top, spacing: 12) {
                MonthView(monthStart: leading, today: entry.date)
                MonthView(monthStart: trailing, today: entry.date)
            }

            MonthNavigationButton(
                delta: 1,
                systemName: "chevron.right",
                accessibilityLabel: "Show next month"
            )
        }
    }
}

private struct MonthNavigationButton: View {
    let delta: Int
    let systemName: String
    let accessibilityLabel: LocalizedStringKey

    var body: some View {
        Button(intent: ChangeMonthOffsetIntent(delta: delta)) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .frame(width: 16)
                .frame(width: 24)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
