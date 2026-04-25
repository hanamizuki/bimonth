// Edge-case tests for MonthResolver (spec §6.1). UTC + Gregorian fixed so results are
// independent of the machine's time zone.
import XCTest

final class MonthResolverTests: XCTestCase {

    /// UTC fixed so timezones like Asia/Taipei don't shift 0:00 into the next day.
    private var calendar: Calendar = {
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

    func test_day6_returns_previousAndCurrent() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 6), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2026, 3))
        XCTAssertEqual(result.trailing, monthStart(2026, 4))
    }

    func test_day7_returns_currentAndNext() {
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 7), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2026, 4))
        XCTAssertEqual(result.trailing, monthStart(2026, 5))
    }

    func test_earlyJanuary_crossesYear_backwards() {
        // Jan 3: previous Dec + current Jan.
        let result = MonthResolver.monthsToDisplay(for: date(2026, 1, 3), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2025, 12))
        XCTAssertEqual(result.trailing, monthStart(2026, 1))
    }

    func test_midDecember_crossesYear_forwards() {
        // Dec 15: current Dec + next-year Jan.
        let result = MonthResolver.monthsToDisplay(for: date(2025, 12, 15), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2025, 12))
        XCTAssertEqual(result.trailing, monthStart(2026, 1))
    }

    func test_endOfMonth_returns_currentAndNext() {
        // Apr 30 (month-end): current Apr + next May.
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 30), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2026, 4))
        XCTAssertEqual(result.trailing, monthStart(2026, 5))
    }

    // MARK: - Additional edge cases

    func test_day1_returns_previousAndCurrent() {
        // day = 1 (< 7): previous + current.
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 1), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2026, 3))
        XCTAssertEqual(result.trailing, monthStart(2026, 4))
    }

    func test_january1_crossesYear_backwards_to_december() {
        // Jan 1: leading must be previous Dec.
        let result = MonthResolver.monthsToDisplay(for: date(2026, 1, 1), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2025, 12))
        XCTAssertEqual(result.trailing, monthStart(2026, 1))
    }
}
