// Widget 設定：定義 kind、display name、description、支援尺寸。
// kind 為系統用來識別 widget 的字串，未來若新增更多 widget 種類務必使用不同 kind。
import WidgetKit
import SwiftUI

struct BimonthWidget: Widget {
    let kind: String = "tw.hanamizuki.bimonth.widget.bimonth.v4"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalendarWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Bimonth")
        .description("並排顯示兩個月的月曆。")
        // spec 3.1：本版僅支援 systemMedium。
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    BimonthWidget()
} timeline: {
    CalendarEntry(date: Date())
}
