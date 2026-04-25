// Edge-case tests for MonthResolver (spec §6.1). UTC + Gregorian fixed so results are
// independent of the machine's time zone.
import Testing
import Foundation

@Suite("MonthResolver")
struct MonthResolverTests {

    /// UTC fixed so timezones like Asia/Taipei don't shift 0:00 into the next day.
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()

    /// (year, month, day) → UTC 0:00 Date.
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    /// Year + month → first day at UTC 0:00. Used to assert expected months.
    private func monthStart(_ y: Int, _ m: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: 1))!
    }

    // MARK: - The 5 cases listed in spec §6.1

    @Test("day 6 → previous + current")
    func day6() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 6), calendar: calendar)
        #expect(result.leading == monthStart(2026, 3))
        #expect(result.trailing == monthStart(2026, 4))
    }

    @Test("day 7 → current + next")
    func day7() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 7), calendar: calendar)
        #expect(result.leading == monthStart(2026, 4))
        #expect(result.trailing == monthStart(2026, 5))
    }

    @Test("early January (day 3) → previous Dec + current Jan, cross-year")
    func earlyJanuaryCrossesYearBackwards() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 1, 3), calendar: calendar)
        #expect(result.leading == monthStart(2025, 12))
        #expect(result.trailing == monthStart(2026, 1))
    }

    @Test("mid December (day 15) → current Dec + next-year Jan, cross-year")
    func midDecemberCrossesYearForwards() {
        let result = MonthResolver.monthsToDisplay(for: date(2025, 12, 15), calendar: calendar)
        #expect(result.leading == monthStart(2025, 12))
        #expect(result.trailing == monthStart(2026, 1))
    }

    @Test("month-end (April 30) → current April + next May")
    func endOfMonth() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 30), calendar: calendar)
        #expect(result.leading == monthStart(2026, 4))
        #expect(result.trailing == monthStart(2026, 5))
    }

    // MARK: - Additional edge cases

    @Test("day 1 (< 7) → previous + current")
    func day1ReturnsPreviousAndCurrent() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 1), calendar: calendar)
        #expect(result.leading == monthStart(2026, 3))
        #expect(result.trailing == monthStart(2026, 4))
    }

    @Test("January 1 → leading must be previous-year December")
    func january1CrossesYearBackwardsToDecember() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 1, 1), calendar: calendar)
        #expect(result.leading == monthStart(2025, 12))
        #expect(result.trailing == monthStart(2026, 1))
    }
}
