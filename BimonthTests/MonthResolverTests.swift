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

    // MARK: - Configurable switch day

    @Test("custom switch day 15: day 14 → previous + current")
    func customSwitchDayBeforeThreshold() {
        let result = MonthResolver.monthsToDisplay(
            for: date(2026, 4, 14),
            calendar: calendar,
            switchDay: 15
        )
        #expect(result.leading == monthStart(2026, 3))
        #expect(result.trailing == monthStart(2026, 4))
    }

    @Test("custom switch day 15: day 15 → current + next")
    func customSwitchDayOnThreshold() {
        let result = MonthResolver.monthsToDisplay(
            for: date(2026, 4, 15),
            calendar: calendar,
            switchDay: 15
        )
        #expect(result.leading == monthStart(2026, 4))
        #expect(result.trailing == monthStart(2026, 5))
    }

    @Test("switch day 1 always shows current + next")
    func switchDayOneShowsCurrentAndNext() {
        let result = MonthResolver.monthsToDisplay(
            for: date(2026, 4, 1),
            calendar: calendar,
            switchDay: 1
        )
        #expect(result.leading == monthStart(2026, 4))
        #expect(result.trailing == monthStart(2026, 5))
    }

    @Test("switch day 31 clamps to February 28 in a non-leap year")
    func switchDayClampsToLastDayOfShortMonth() {
        let beforeLastDay = MonthResolver.monthsToDisplay(
            for: date(2026, 2, 27),
            calendar: calendar,
            switchDay: 31
        )
        #expect(beforeLastDay.leading == monthStart(2026, 1))
        #expect(beforeLastDay.trailing == monthStart(2026, 2))

        let lastDay = MonthResolver.monthsToDisplay(
            for: date(2026, 2, 28),
            calendar: calendar,
            switchDay: 31
        )
        #expect(lastDay.leading == monthStart(2026, 2))
        #expect(lastDay.trailing == monthStart(2026, 3))
    }

    // MARK: - Manual month navigation

    @Test("month offset -1 moves the resolved pair back one month")
    func negativeMonthOffsetMovesPairBackward() {
        let result = MonthResolver.monthsToDisplay(
            for: date(2026, 4, 15),
            calendar: calendar,
            monthOffset: -1
        )
        #expect(result.leading == monthStart(2026, 3))
        #expect(result.trailing == monthStart(2026, 4))
    }

    @Test("month offset +2 moves the resolved pair forward two months")
    func positiveMonthOffsetMovesPairForward() {
        let result = MonthResolver.monthsToDisplay(
            for: date(2026, 11, 15),
            calendar: calendar,
            monthOffset: 2
        )
        #expect(result.leading == monthStart(2027, 1))
        #expect(result.trailing == monthStart(2027, 2))
    }

    @Test("custom switch day resolves before month offset is applied")
    func customSwitchDayAndMonthOffsetApplyInOrder() {
        let result = MonthResolver.monthsToDisplay(
            for: date(2026, 4, 14),
            calendar: calendar,
            switchDay: 15,
            monthOffset: -1
        )
        #expect(result.leading == monthStart(2026, 2))
        #expect(result.trailing == monthStart(2026, 3))
    }

    // MARK: - DST / leap-year / non-Gregorian (spec §5.3, §5.4)

    @Test("DST boundary month (US Pacific, mid-March 2026) — month boundaries still correct")
    func dstBoundaryMonth() {
        var pacific = Calendar(identifier: .gregorian)
        pacific.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        let march15Pacific = pacific.date(from: DateComponents(year: 2026, month: 3, day: 15))!
        let result = MonthResolver.monthsToDisplay(for: march15Pacific, calendar: pacific)

        let marchStart = pacific.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let aprilStart = pacific.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        #expect(result.leading == marchStart)
        #expect(result.trailing == aprilStart)
    }

    @Test("Leap-year February (Feb 29, 2024) — month-end resolution unaffected by leap day")
    func leapYearFebruaryEnd() {
        let result = MonthResolver.monthsToDisplay(for: date(2024, 2, 29), calendar: calendar)
        #expect(result.leading == monthStart(2024, 2))
        #expect(result.trailing == monthStart(2024, 3))
    }

    @Test("Non-Gregorian (Buddhist) calendar — no crash; trailing is exactly one month after leading")
    func buddhistCalendarYieldsAdjacentMonths() {
        var buddhist = Calendar(identifier: .buddhist)
        buddhist.timeZone = TimeZone(identifier: "UTC")!

        // Date is timezone-independent; pass any reference date and let buddhist's month
        // arithmetic decide the actual month boundaries.
        let testDate = date(2026, 4, 15)
        let result = MonthResolver.monthsToDisplay(for: testDate, calendar: buddhist)

        let oneMonthAfterLeading = buddhist.date(byAdding: .month, value: 1, to: result.leading)
        #expect(oneMonthAfterLeading == result.trailing)
    }
}
