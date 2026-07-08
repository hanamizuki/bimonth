import AppIntents
import WidgetKit

struct ChangeMonthOffsetIntent: AppIntent {
    static var title: LocalizedStringResource { "Change Displayed Month" }
    static var description: IntentDescription {
        IntentDescription("Move the Bimonth widget to the previous or next month.")
    }
    static var isDiscoverable: Bool { false }
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "Month Delta")
    var delta: Int

    init() {
        delta = 0
    }

    init(delta: Int) {
        self.delta = delta
    }

    func perform() async throws -> some IntentResult {
        MonthNavigationStore.move(by: delta)
        WidgetCenter.shared.reloadTimelines(ofKind: BimonthWidgetConstants.kind)
        return .result()
    }
}
