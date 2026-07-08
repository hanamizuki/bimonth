// entry.date is reused as the "today" baseline for both MonthView calls.
import AppIntents
import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry
    @Environment(\.calendar) private var calendar

    /// Width of the strip reserved on each side for a navigation button. The
    /// months are inset by the same amount, so the buttons live entirely in
    /// the gutters and never cover a day cell.
    static let navigationGutter: CGFloat = 18

    var body: some View {
        let (leading, trailing) = MonthResolver.monthsToDisplay(
            for: entry.date,
            calendar: calendar,
            switchDay: entry.switchDay,
            monthOffset: entry.monthOffset
        )

        // The navigation buttons are overlaid rather than placed in an
        // enclosing HStack. LazyVGrid reports its ideal width as its minimum
        // (7 columns × GridItem's default 10pt minimum = 70pt), and an HStack
        // that mixes fixed-width siblings with the month views sizes the
        // months at that ideal — collapsing both grids to 70pt no matter how
        // much space the widget offers (day digits overlap, titles truncate).
        // Overlays take no part in the width negotiation, so the calendar
        // keeps the exact pre-navigation layout.
        HStack(alignment: .top, spacing: 16) {
            MonthView(monthStart: leading, today: entry.date)
            MonthView(monthStart: trailing, today: entry.date)
        }
        .padding(.horizontal, Self.navigationGutter)
        .overlay(alignment: .leading) {
            MonthNavigationButton(
                delta: -1,
                systemName: "chevron.left",
                accessibilityLabel: "Show previous month"
            )
        }
        .overlay(alignment: .trailing) {
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
                // Full-height gutter-wide strip: a generous tap target that
                // still cannot overlap the inset month grids.
                .frame(width: CalendarWidgetView.navigationGutter)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
