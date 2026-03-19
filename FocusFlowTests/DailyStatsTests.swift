import Testing
import Foundation
@testable import FocusFlow

struct DailyStatsTests {

    // MARK: - totalFocusMinutes

    @Test func totalFocusMinutesConversion() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19", totalFocusSeconds: 3600)
        #expect(stats.totalFocusMinutes == 60)
    }

    @Test func totalFocusMinutesZero() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19", totalFocusSeconds: 0)
        #expect(stats.totalFocusMinutes == 0)
    }

    // MARK: - formattedTotalFocus

    @Test func formattedTotalFocusUnderAnHour() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19", totalFocusSeconds: 1500)
        #expect(stats.formattedTotalFocus == "25m")
    }

    @Test func formattedTotalFocusExactlyOneHour() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19", totalFocusSeconds: 3600)
        #expect(stats.formattedTotalFocus == "1h 0m")
    }

    @Test func formattedTotalFocusOneHourThirty() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19", totalFocusSeconds: 5400)
        #expect(stats.formattedTotalFocus == "1h 30m")
    }

    @Test func formattedTotalFocusZero() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19", totalFocusSeconds: 0)
        #expect(stats.formattedTotalFocus == "0m")
    }

    // MARK: - Default values

    @Test func defaultTotalFocusSecondsIsZero() {
        let stats = DailyStats(date: Date(), dayKey: "2026-03-19")
        #expect(stats.totalFocusSeconds == 0)
        #expect(stats.sessionsCompleted == 0)
        #expect(stats.longestSessionSeconds == 0)
    }
}
