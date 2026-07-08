// entry.date is reused as the "today" baseline for both MonthView calls.
import AppIntents
import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry
    @Environment(\.calendar) private var calendar
    @Environment(\.widgetContentMargins) private var margins

    static let navigationGutter: CGFloat = 6
    /// Target distance from the chevron glyph to the widget's rounded-rect edge.
    private static let chevronEdgeInset: CGFloat = 8

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
        // Push chevrons into the system content margin so they sit ~8pt from
        // the widget border. widgetContentMargins is .zero in the picker
        // preview, so the offset becomes a no-op there (safe).
        .overlay(alignment: .leading) {
            MonthNavigationButton(
                delta: -1,
                systemName: "chevron.left",
                accessibilityLabel: "Show previous month",
                alignment: .leading
            )
            .offset(x: -(margins.leading - Self.chevronEdgeInset))
        }
        .overlay(alignment: .trailing) {
            MonthNavigationButton(
                delta: 1,
                systemName: "chevron.right",
                accessibilityLabel: "Show next month",
                alignment: .trailing
            )
            .offset(x: margins.trailing - Self.chevronEdgeInset)
        }
    }
}

private struct MonthNavigationButton: View {
    let delta: Int
    let systemName: String
    let accessibilityLabel: LocalizedStringKey
    let alignment: Alignment

    var body: some View {
        Button(intent: ChangeMonthOffsetIntent(delta: delta)) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary.opacity(0.35))
                .frame(width: CalendarWidgetView.navigationGutter, alignment: alignment)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
