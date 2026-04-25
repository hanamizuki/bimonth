// Timeline provider：負責告訴 WidgetKit 在不同時間點要顯示哪個 entry。
//
// 策略：每次被叫到 getTimeline 時，產生「今天 00:00」起未來 7 天的 entries，
// 每個 entry 的 date 是該日的 00:00（系統時區）。policy 設為 .atEnd，
// 系統會在最後一個 entry 過後再次請求新的 timeline，達成每日午夜自動更新的效果。
//
// 這個策略覆蓋 spec §2.3 列出的三個更新時機：
//   - 每天 00:00：高亮圓圈跳到新日期
//   - 每月 7 號 00:00：左右兩月切換邏輯改變
//   - 每月 1 號 00:00：右側月份變成新月份
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // 產生未來 7 天、每天 00:00 各一個 entry。
        // 使用 calendar.date(byAdding: .day, value:) 而非加減秒數，可正確處理 DST。
        let entries: [CalendarEntry] = (0..<7).compactMap { offset in
            guard let entryDate = calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
                return nil
            }
            return CalendarEntry(date: entryDate)
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
