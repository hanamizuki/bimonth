// Single-month grid (6 rows × 7 cols).
// Leading offset = (firstDay.weekday − calendar.firstWeekday + 7) mod 7.
import SwiftUI

struct MonthView: View {
    /// First day of the month at 00:00.
    let monthStart: Date
    /// "Today" baseline from the widget timeline entry.
    let today: Date
    @Environment(\.calendar) private var calendar

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Uppercase month name in brand red, no year — matches system Calendar widget.
            // padding(.leading, 6): aligns the title's left edge with two-digit day numbers
            // in column 1 (17pt cell centered in ~22pt column → digit-left at ≈6pt).
            Text(monthTitle)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.red)
                .padding(.leading, 6)
                .padding(.bottom, 3)

            // Weekday header AND date grid live in ONE LazyVGrid so column widths are guaranteed
            // identical. An HStack header + LazyVGrid grid can distribute width slightly
            // differently and the columns drift visually.
            // 3pt spacing applies between every row — header→first-week and week→week alike.
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 3
            ) {
                // Row 0: weekday header letters (S M T W T F S, reordered by firstWeekday).
                // Match the date row's color logic — weekdays primary, weekends secondary.
                ForEach(weekdaySymbols.indices, id: \.self) { i in
                    Text(weekdaySymbols[i])
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(isWeekendColumn(i) ? Color.secondary : Color.primary)
                        .frame(height: 12)
                }
                // Rows 1–6: 42 date cells.
                ForEach(daysToDisplay, id: \.self) { date in
                    let isCurrentMonth = calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
                    DayCell(
                        date: date,
                        isCurrentMonth: isCurrentMonth,
                        // Highlight only when the cell is in the current month — neighbor-month fill cells must not match.
                        isToday: isCurrentMonth && calendar.isDate(date, inSameDayAs: today)
                    )
                }
            }
        }
    }

    /// Locale-aware uppercase month name, e.g. "APRIL". Date.FormatStyle is value-type, so
    /// no DateFormatter allocation per body call.
    private var monthTitle: String {
        let locale = calendar.locale ?? Locale.current
        return monthStart
            .formatted(.dateTime.month(.wide).locale(locale))
            .uppercased(with: locale)
    }

    /// Whether the column at `index` (0-based, after firstWeekday rotation) corresponds to a
    /// weekend day. Delegates to `Calendar.isDateInWeekend` so locales with non-Sat/Sun weekends
    /// (e.g. Friday-Saturday in some Middle Eastern locales) tint the header consistently with
    /// the date cells below.
    private func isWeekendColumn(_ index: Int) -> Bool {
        // Pick the date in the first grid row at `index`. Each column shares the same weekday
        // across all 6 rows, so the first row's date is sufficient to ask the Calendar.
        guard index < daysToDisplay.count else { return false }
        return calendar.isDateInWeekend(daysToDisplay[index])
    }

    /// Weekday header symbols rotated to match calendar.firstWeekday.
    /// firstWeekday = 1 (Sunday) → ["S","M","T","W","T","F","S"]
    /// firstWeekday = 2 (Monday) → ["M","T","W","T","F","S","S"]
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        guard offset > 0 else { return symbols }
        return Array(symbols[offset...] + symbols[..<offset])
    }

    /// 42 dates filling the grid, with leading days from the previous month and trailing from the next.
    private var daysToDisplay: [Date] {
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        // Cells to pad before the first day so it lines up with calendar.firstWeekday.
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7

        guard let gridStart = calendar.date(byAdding: .day, value: -leadingEmpty, to: monthStart) else {
            return []
        }

        return (0..<42).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: gridStart)
        }
    }
}

#Preview("Sunday-start (default)") {
    MonthView(
        monthStart: Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date(),
        today: Date()
    )
    .padding()
    .frame(width: 200)
}

#Preview("Monday-start") {
    var monday = Calendar(identifier: .gregorian)
    monday.firstWeekday = 2
    return MonthView(
        monthStart: monday.dateInterval(of: .month, for: Date())?.start ?? Date(),
        today: Date()
    )
    .environment(\.calendar, monday)
    .padding()
    .frame(width: 200)
}
