import Testing

@Suite("MonthNavigationStore")
struct MonthNavigationStoreTests {
    @Test("month offset is clamped to the supported browsing range")
    func monthOffsetClampsToRange() {
        #expect(MonthNavigationStore.normalizedMonthOffset(-100) == MonthNavigationStore.monthOffsetRange.lowerBound)
        #expect(MonthNavigationStore.normalizedMonthOffset(0) == 0)
        #expect(MonthNavigationStore.normalizedMonthOffset(100) == MonthNavigationStore.monthOffsetRange.upperBound)
    }

    @Test("arbitrary deltas normalize to one-month navigation steps")
    func arbitraryDeltasNormalizeToSingleSteps() {
        #expect(MonthNavigationStore.normalizedStep(-99) == -1)
        #expect(MonthNavigationStore.normalizedStep(0) == nil)
        #expect(MonthNavigationStore.normalizedStep(99) == 1)
    }
}
