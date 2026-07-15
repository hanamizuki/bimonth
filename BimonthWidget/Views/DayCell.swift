// Style precedence: today's filled circle overrides everything; out-of-month days are blank
// (matching the system Calendar widget — no leading/trailing month fill); weekday vs weekend
// differ by both weight and color opacity to emphasize weekdays.
import SwiftUI
import WidgetKit

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    @Environment(\.calendar) private var calendar
    @Environment(\.widgetRenderingMode) private var renderingMode

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
                            // Brand accent: muted sage green is the only chromatic color
                            // in the palette, reserved for today's single point of emphasis.
                            // Accented rendering (macOS Clear/Tinted widget styles) discards
                            // custom hues and keeps only alpha, so a fully-opaque circle behind
                            // a fully-opaque digit both collapse to solid white — invisible.
                            // Lowering the circle's opacity there preserves a visible contrast
                            // once color is stripped away.
                            Circle().fill(Color.brandSage.opacity(renderingMode == .accented ? 0.3 : 1))
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

    /// VoiceOver label following the calendar's locale (same source the visible month title uses),
    /// so a Chinese system reads dates in Chinese and an English system in English.
    private var accessibilityDateLabel: String {
        date.formatted(
            .dateTime
                .year()
                .month(.wide)
                .day()
                .locale(calendar.locale ?? .current)
        )
    }

    /// Weekday vs weekend differ only by color — all numbers share the same medium weight.
    /// Today wins brand `ink` (deep olive-black on sage, ≈ 7.6:1 contrast, AAA);
    /// weekends use system `.secondary` (matching the weekday header's gray);
    /// weekdays use full `.primary`. Body text intentionally stays on system semantic
    /// colors so light/dark mode adapts automatically without a custom palette mapping.
    private var foreground: Color {
        if isToday {
            return .brandInk
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
