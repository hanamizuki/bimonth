// 單一日期格。
// 三種樣式：
//   - isToday：紅色實心圓圈底 + 白字（覆蓋一切）
//   - isCurrentMonth = false：次要色 + 半透明（前後月補滿格）
//   - 其他（本月一般日）：粗體主要色
import SwiftUI

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let calendar: Calendar

    var body: some View {
        let day = calendar.component(.day, from: date)

        Text("\(day)")
            .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
            .foregroundStyle(foreground)
            .frame(width: 18, height: 18)
            .background {
                if isToday {
                    Circle().fill(Color.red)
                }
            }
            .frame(maxWidth: .infinity)
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
