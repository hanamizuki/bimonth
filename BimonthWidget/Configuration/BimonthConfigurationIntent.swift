import AppIntents

struct BimonthConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Bimonth Settings" }
    static var description: IntentDescription {
        IntentDescription("Choose when Bimonth switches the two displayed months.")
    }
    static var isDiscoverable: Bool { false }

    @Parameter(
        title: "Switch Day",
        description: "The day of the month when Bimonth changes from previous/current to current/next.",
        default: 7,
        controlStyle: .stepper,
        inclusiveRange: (1, 31)
    )
    var switchDay: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Switch months on day \(\.$switchDay)")
    }

    var normalizedSwitchDay: Int {
        MonthResolver.normalizedSwitchDay(switchDay)
    }
}
