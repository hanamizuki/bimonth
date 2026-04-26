// `kind` is a stable identity contract: bumping it orphans every user's installed widget instance.
import WidgetKit
import SwiftUI

struct BimonthWidget: Widget {
    let kind: String = "com.example.bimonth.widget.bimonth"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalendarWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Bimonth")
        .description("Two-month calendar shown side by side.")
        // spec §3.1: only systemMedium is supported.
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    BimonthWidget()
} timeline: {
    CalendarEntry(date: Date())
}
