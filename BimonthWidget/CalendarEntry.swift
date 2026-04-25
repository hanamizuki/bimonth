// Widget timeline 的單一 entry。
// `date` 同時代表此 entry 在系統中生效的時間，以及視為「今天」的基準日。
// Provider 會產生未來 7 天、每天午夜各一個 entry，由系統自動切換。
import WidgetKit

struct CalendarEntry: TimelineEntry {
    let date: Date
}
