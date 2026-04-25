// Pure logic, extracted so MonthResolverTests can exercise month-end and cross-year edges.
import Foundation

enum MonthResolver {
    /// Returns the two months to display as (leading, trailing). Each `Date` is that month's
    /// first day at 00:00 in `calendar`'s time zone.
    static func monthsToDisplay(
        for date: Date,
        calendar: Calendar
    ) -> (leading: Date, trailing: Date) {
        let day = calendar.component(.day, from: date)
        // guard fallback (vs. force-unwrap) covers non-Gregorian calendars per spec §5.4 —
        // degrade gracefully instead of crashing the widget.
        guard let currentMonth = calendar.dateInterval(of: .month, for: date)?.start else {
            return (date, date)
        }

        if day < 7 {
            // day 1–6: previous + current.
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else {
                return (currentMonth, currentMonth)
            }
            return (previousMonth, currentMonth)
        } else {
            // day ≥ 7: current + next. Switching on the 7th — looking forward is more useful
            // when 3+ weeks of the current month are still ahead.
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else {
                return (currentMonth, currentMonth)
            }
            return (currentMonth, nextMonth)
        }
    }
}
