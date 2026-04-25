// 單一日期格。
// 樣式組合：
//   - isToday：紅色實心圓圈底 + 白字（覆蓋一切）
//   - isCurrentMonth = false：次要色 + 半透明（前後月補滿格）
//   - 週末（六、日）：regular 字重
//   - 平日（一～五）：bold 字重
import SwiftUI

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let calendar: Calendar

    var body: some View {
        let day = calendar.component(.day, from: date)

        Text("\(day)")
            .font(.system(size: 10, weight: weight).monospacedDigit())
            .foregroundStyle(foreground)
            .frame(width: 17, height: 17)
            .background {
                if isToday {
                    Circle().fill(Color.red)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel(accessibilityDateLabel)
            .accessibilityAddTraits(isToday ? [.isSelected] : [])
    }

    /// VoiceOver label：固定英文長日期格式（例：「April 26, 2026」）。
    /// 不跟隨系統 locale，避免不同地區得到不同的 widget 朗讀文字。
    private var accessibilityDateLabel: String {
        date.formatted(
            .dateTime
                .year()
                .month(.wide)
                .day()
                .locale(Locale(identifier: "en_US"))
        )
    }

    /// 週末用 regular，平日用 bold，藉字重對比強化平日。
    private var weight: Font.Weight {
        calendar.isDateInWeekend(date) ? .regular : .bold
    }

    /// 文字色：今天白字覆蓋；非本月用半透明次要色；本月一般日用主要色。
    private var foreground: Color {
        if isToday {
            return .white
        }
        return isCurrentMonth ? .primary : .secondary.opacity(0.5)
    }
}

#Preview {
    HStack {
        DayCell(date: Date(), isCurrentMonth: true, isToday: true, calendar: .current)
        DayCell(date: Date(), isCurrentMonth: true, isToday: false, calendar: .current)
        DayCell(date: Date(), isCurrentMonth: false, isToday: false, calendar: .current)
    }
    .padding()
}
