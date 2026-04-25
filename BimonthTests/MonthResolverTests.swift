// MonthResolver 邊界情境測試（對應 spec §6.1）。
// 為了讓測試結果與機器時區無關，所有測試都用 UTC + Gregorian 曆法的固定 calendar。
import XCTest

final class MonthResolverTests: XCTestCase {

    /// 為避免 Asia/Taipei 等時區把 0:00 拉成隔天，這裡固定用 UTC。
    private var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()

    /// helper：把 (year, month, day) 轉成 UTC 0:00 的 Date。
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    /// 同上，但只指定年月、回傳該月第一天 0:00。用來 assert 預期月份。
    private func monthStart(_ y: Int, _ m: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: 1))!
    }

    // MARK: - spec §6.1 列出的 5 個 case

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
        // 1 月 3 號：應顯示去年 12 月 + 今年 1 月。
        let result = MonthResolver.monthsToDisplay(for: date(2026, 1, 3), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2025, 12))
        XCTAssertEqual(result.trailing, monthStart(2026, 1))
    }

    func test_midDecember_crossesYear_forwards() {
        // 12 月 15 號：應顯示 12 月 + 隔年 1 月。
        let result = MonthResolver.monthsToDisplay(for: date(2025, 12, 15), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2025, 12))
        XCTAssertEqual(result.trailing, monthStart(2026, 1))
    }

    func test_endOfMonth_returns_currentAndNext() {
        // 月底 4/30：應顯示 4 月 + 5 月。
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 30), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2026, 4))
        XCTAssertEqual(result.trailing, monthStart(2026, 5))
    }

    // MARK: - 額外的邊界 case

    func test_day1_returns_previousAndCurrent() {
        // 1 號：day < 7，左側上月、右側本月。
        let result = MonthResolver.monthsToDisplay(for: date(2026, 4, 1), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2026, 3))
        XCTAssertEqual(result.trailing, monthStart(2026, 4))
    }

    func test_january1_crossesYear_backwards_to_december() {
        // 1/1：左側應為去年 12 月。
        let result = MonthResolver.monthsToDisplay(for: date(2026, 1, 1), calendar: calendar)
        XCTAssertEqual(result.leading, monthStart(2025, 12))
        XCTAssertEqual(result.trailing, monthStart(2026, 1))
    }
}
