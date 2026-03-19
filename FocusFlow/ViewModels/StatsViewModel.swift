import Foundation
import SwiftData
import Observation

/// Provides computed statistics for the stats/history views.
@Observable
final class StatsViewModel {
    var weeklyStats: [DailyStats] = []
    var recentSessions: [FocusSession] = []
    var totalAllTimeMinutes: Int = 0
    var bestDayMinutes: Int = 0
    var averageDailyMinutes: Int = 0

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        refresh()
    }

    func refresh() {
        loadWeeklyStats()
        loadRecentSessions()
        loadAllTimeStats()
    }

    private func loadWeeklyStats() {
        guard let context = modelContext else { return }

        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return }

        let descriptor = FetchDescriptor<DailyStats>(
            predicate: #Predicate { $0.date >= weekAgo },
            sortBy: [SortDescriptor(\.date)]
        )

        weeklyStats = (try? context.fetch(descriptor)) ?? []
    }

    private func loadRecentSessions() {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<FocusSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 20

        recentSessions = (try? context.fetch(descriptor)) ?? []
    }

    private func loadAllTimeStats() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<DailyStats>()
        guard let allStats = try? context.fetch(descriptor) else { return }

        let totalSeconds = allStats.reduce(0) { $0 + $1.totalFocusSeconds }
        totalAllTimeMinutes = totalSeconds / 60

        bestDayMinutes = (allStats.map(\.totalFocusSeconds).max() ?? 0) / 60

        if !allStats.isEmpty {
            averageDailyMinutes = totalAllTimeMinutes / allStats.count
        }
    }
}
