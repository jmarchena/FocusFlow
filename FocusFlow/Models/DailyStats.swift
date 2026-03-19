import Foundation
import SwiftData

/// Aggregated daily statistics, computed from focus sessions.
@Model
final class DailyStats {
    var id: UUID
    var date: Date
    var dayKey: String
    var totalFocusSeconds: Int
    var sessionsCompleted: Int
    var longestSessionSeconds: Int

    init(
        id: UUID = UUID(),
        date: Date,
        dayKey: String,
        totalFocusSeconds: Int = 0,
        sessionsCompleted: Int = 0,
        longestSessionSeconds: Int = 0
    ) {
        self.id = id
        self.date = date
        self.dayKey = dayKey
        self.totalFocusSeconds = totalFocusSeconds
        self.sessionsCompleted = sessionsCompleted
        self.longestSessionSeconds = longestSessionSeconds
    }
}

extension DailyStats {
    var totalFocusMinutes: Int {
        totalFocusSeconds / 60
    }

    var formattedTotalFocus: String {
        let hours = totalFocusSeconds / 3600
        let minutes = (totalFocusSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
