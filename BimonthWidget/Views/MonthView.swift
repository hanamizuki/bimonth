// 單月檢視：月份標題 + 星期標題列 + 6×7 日期網格。
//
// 網格生成邏輯（spec §3.5）：
//   1. 找到月份第一天的 weekday（1 = 週日 ... 7 = 週六）
//   2. 計算需往前補幾格才能對齊到 calendar.firstWeekday
//   3. 從補齊後的起始日往後產生 42 個日期（6 列 × 7 欄）
//
// 每一格依「該日是否屬於本月」與「該日是否為今天」決定樣式（見 DayCell）。
import SwiftUI

struct MonthView: View {
    /// 該月第一天 00:00。
    let monthStart: Date
    /// 用來判斷「今天」的基準日（來自 widget timeline entry）。
    let today: Date
    let calendar: Calendar

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // 月份標題：大寫月份名 + 主題紅色（不含年份），跟系統 Calendar widget 一致。
            Text(monthTitle)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(.red)

            // 星期標題列：粗體、次要色，跟隨系統 firstWeekday 重排。
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 6×7 日期網格。row spacing 3pt 製造跟系統 Calendar widget 接近的呼吸感。
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 3
            ) {
                ForEach(daysToDisplay, id: \.self) { date in
                    let isCurrentMonth = calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
                    DayCell(
                        date: date,
                        isCurrentMonth: isCurrentMonth,
                        // 只有當月當日才高亮，避免相鄰月份的補滿格也被誤標為今天。
                        isToday: isCurrentMonth && calendar.isDate(date, inSameDayAs: today),
                        calendar: calendar
                    )
                }
            }
        }
    }

    /// 月份標題字串，例：「APRIL」（不含年份，與系統 Calendar widget 一致）。
    /// 使用 dateFormat(fromTemplate: "MMMM") 讓不同 locale 取得對應月份名稱，
    /// 最後 uppercased() 統一以全大寫呈現。
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale ?? Locale.current
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM",
            options: 0,
            locale: formatter.locale
        )
        return formatter.string(from: monthStart).uppercased(with: formatter.locale)
    }

    /// 星期標題列，依 calendar.firstWeekday 重新排序。
    /// 例：firstWeekday = 1（週日）→ ["S","M","T","W","T","F","S"]
    /// 例：firstWeekday = 2（週一）→ ["M","T","W","T","F","S","S"]
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        guard offset > 0 else { return symbols }
        return Array(symbols[offset...] + symbols[..<offset])
    }

    /// 產生本月網格用的 42 個日期：含上月補齊與下月填補。
    private var daysToDisplay: [Date] {
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        // 計算月份第一天距離週首要往前補幾格。
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7

        guard let gridStart = calendar.date(byAdding: .day, value: -leadingEmpty, to: monthStart) else {
            return []
        }

        return (0..<42).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: gridStart)
        }
    }
}

#Preview {
    MonthView(
        monthStart: Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date(),
        today: Date(),
        calendar: .current
    )
    .padding()
    .frame(width: 200)
}
