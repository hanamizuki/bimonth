// Pure logic, extracted so MonthResolverTests can exercise month-end and cross-year edges.
import Foundation

enum MonthResolver {
    static let defaultSwitchDay = 7

    static func normalizedSwitchDay(_ switchDay: Int) -> Int {
        min(max(switchDay, 1), 31)
    }

    /// Returns the two months to display as (leading, trailing). Each `Date` is that month's
    /// first day at 00:00 in `calendar`'s time zone.
    static func monthsToDisplay(
        for date: Date,
        calendar: Calendar,
        switchDay: Int = defaultSwitchDay,
        monthOffset: Int = 0
    ) -> (leading: Date, trailing: Date) {
        let day = calendar.component(.day, from: date)
        // guard fallback (vs. force-unwrap) covers non-Gregorian calendars per spec §5.4 —
        // degrade gracefully instead of crashing the widget.
        guard let currentMonth = calendar.dateInterval(of: .month, for: date)?.start else {
            return (date, date)
        }
        let effectiveSwitchDay = effectiveSwitchDay(switchDay, for: date, calendar: calendar)

        let baseMonths: (leading: Date, trailing: Date)
        if day < effectiveSwitchDay {
            // Before the configured switch day: previous + current.
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else {
                return (currentMonth, currentMonth)
            }
            baseMonths = (previousMonth, currentMonth)
        } else {
            // On/after the configured switch day: current + next. The default 7th keeps the
            // original behavior — looking forward while most of the current month is ahead.
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else {
                return (currentMonth, currentMonth)
            }
            baseMonths = (currentMonth, nextMonth)
        }

        return monthsByApplyingOffset(monthOffset, to: baseMonths, calendar: calendar)
    }

    private static func effectiveSwitchDay(
        _ switchDay: Int,
        for date: Date,
        calendar: Calendar
    ) -> Int {
        let normalized = normalizedSwitchDay(switchDay)
        guard let dayRange = calendar.range(of: .day, in: .month, for: date) else {
            return normalized
        }
        return min(normalized, dayRange.count)
    }

    private static func monthsByApplyingOffset(
        _ monthOffset: Int,
        to baseMonths: (leading: Date, trailing: Date),
        calendar: Calendar
    ) -> (leading: Date, trailing: Date) {
        guard monthOffset != 0 else {
            return baseMonths
        }
        guard let shiftedLeading = calendar.date(byAdding: .month, value: monthOffset, to: baseMonths.leading) else {
            return baseMonths
        }
        // Derive trailing from the shifted leading month so the pair remains adjacent even
        // if month arithmetic behaves differently in a non-Gregorian calendar.
        guard let shiftedTrailing = calendar.date(byAdding: .month, value: 1, to: shiftedLeading) else {
            return (shiftedLeading, shiftedLeading)
        }
        return (shiftedLeading, shiftedTrailing)
    }
}
