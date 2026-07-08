// `kind` is a stable identity contract: bumping it orphans every user's installed widget instance. Opaque to WidgetKit — does not need to match the bundle ID.
import WidgetKit
import SwiftUI

struct BimonthWidget: Widget {
    let kind: String = BimonthWidgetConstants.kind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: BimonthConfigurationIntent.self, provider: Provider()) { entry in
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
