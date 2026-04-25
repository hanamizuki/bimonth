// Style precedence: today's filled circle overrides everything; out-of-month days are blank
// (matching the system Calendar widget — no leading/trailing month fill); weekday vs weekend
// differ by both weight and color opacity to emphasize weekdays.
import SwiftUI

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let calendar: Calendar

    var body: some View {
        Group {
            if isCurrentMonth {
                let day = calendar.component(.day, from: date)
                Text("\(day)")
                    .font(.system(size: 10, weight: .regular).monospacedDigit())
                    .foregroundStyle(foreground)
                    .frame(width: 17, height: 17)
                    .background {
                        if isToday {
                            Circle().fill(Color.red)
                        }
                    }
            } else {
                // Out-of-month days render blank but keep the slot to preserve grid alignment.
                Color.clear
                    .frame(width: 17, height: 17)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(accessibilityDateLabel)
        .accessibilityAddTraits(isToday ? [.isSelected] : [])
    }

    /// VoiceOver label, fixed en_US (e.g. "April 26, 2026") to keep the spoken text consistent across locales.
    private var accessibilityDateLabel: String {
        date.formatted(
            .dateTime
                .year()
                .month(.wide)
                .day()
                .locale(Locale(identifier: "en_US"))
        )
    }

    /// Weekday vs weekend differ only by color (not weight) — all numbers share the same regular weight.
    /// Today wins white; weekends fade to lighter primary; weekdays use full primary.
    private var foreground: Color {
        if isToday {
            return .white
        }
        if calendar.isDateInWeekend(date) {
            return .primary.opacity(0.45)
        }
        return .primary
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
