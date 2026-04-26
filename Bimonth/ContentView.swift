import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            // The vintage tear-off calendar illustration (also the AppIcon source) is
            // the single illustrative moment in Bimonth's identity — see DESIGN.md.
            // The container app simply hosts the widget extension, so it stays
            // restrained around this one warm focal point.
            Image("BrandIcon")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 64, height: 64)

            // Live preview rendered with the same MonthView the widget uses, so what
            // the user sees here is exactly what they'll get on the desktop. Wrapped
            // in a rounded rectangle hint to suggest "this is the widget" without
            // copying WidgetKit's exact `containerBackground` chrome.
            WidgetPreview()

            Text("Add the Bimonth widget from Notification Center, or right-click the desktop and choose Edit Widgets.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 24)
        .frame(width: 420)
    }
}

private struct WidgetPreview: View {
    @Environment(\.calendar) private var calendar

    var body: some View {
        let today = Date()
        let (leading, trailing) = MonthResolver.monthsToDisplay(for: today, calendar: calendar)
        HStack(alignment: .top, spacing: 16) {
            MonthView(monthStart: leading, today: today)
            MonthView(monthStart: trailing, today: today)
        }
        .padding(16)
        .frame(width: 360)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
        )
    }
}

#Preview {
    ContentView()
}
