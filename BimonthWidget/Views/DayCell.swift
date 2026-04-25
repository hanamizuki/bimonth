// Style precedence: today's filled circle overrides everything; out-of-month days are blank
// (matching the system Calendar widget — no leading/trailing month fill); weekday vs weekend
// differ by both weight and color opacity to emphasize weekdays.
import SwiftUI

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    @Environment(\.calendar) private var calendar

    var body: some View {
        Group {
            if isCurrentMonth {
                let day = calendar.component(.day, from: date)
                Text("\(day)")
                    .font(.system(size: 10, weight: .medium))
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
        // Out-of-month cells render as Color.clear (no visible content), so they must also be
        // hidden from VoiceOver. Otherwise users land on blank cells and hear an irrelevant date.
        .accessibilityHidden(!isCurrentMonth)
        .accessibilityLabel(isCurrentMonth ? accessibilityDateLabel : "")
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

    /// Weekday vs weekend differ only by color — all numbers share the same medium weight.
    /// Today wins white; weekends use system .secondary (matching the weekday header's gray);
    /// weekdays use full primary.
    private var foreground: Color {
        if isToday {
            return .white
        }
        if calendar.isDateInWeekend(date) {
            return Color.secondary
        }
        return Color.primary
    }
}

#Preview {
    HStack {
        DayCell(date: Date(), isCurrentMonth: true, isToday: true)
        DayCell(date: Date(), isCurrentMonth: true, isToday: false)
        DayCell(date: Date(), isCurrentMonth: false, isToday: false)
    }
    .padding()
}
