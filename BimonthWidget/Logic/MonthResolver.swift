// 決定要顯示哪兩個月的純函式。
// 根據今天是幾號決定：
//   - 1–6 號 → 顯示「上個月 + 本月」
//   - 7–31 號 → 顯示「本月 + 下個月」
// 抽成獨立模組是為了能用單元測試覆蓋月底、跨年等邊界情境（見 BimonthTests）。
import Foundation

enum MonthResolver {
    /// 回傳要顯示的兩個月，每個 Date 代表該月第一天 00:00（依傳入 calendar 的時區）。
    /// - Parameters:
    ///   - date: 用以計算「今天」的基準日
    ///   - calendar: 用來做日期運算的曆法（決定月份區間、加減月份等）
    /// - Returns: (左側月份, 右側月份)
    static func monthsToDisplay(
        for date: Date,
        calendar: Calendar
    ) -> (leading: Date, trailing: Date) {
        let day = calendar.component(.day, from: date)
        // dateInterval(of: .month, for:).start 永遠回傳該月第一天 00:00。
        // 這個 force unwrap 在 Gregorian 等正常曆法下不會失敗。
        let currentMonth = calendar.dateInterval(of: .month, for: date)!.start

        if day < 7 {
            // 月初前 6 天：左側顯示上個月、右側顯示本月。
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            return (previousMonth, currentMonth)
        } else {
            // 7 號當天起：左側本月、右側下個月。
            // 7 號為切換點的理由：本月還剩超過三週要過，看下個月比較有用。
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
            return (currentMonth, nextMonth)
        }
    }
}
