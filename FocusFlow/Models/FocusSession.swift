import Foundation
import SwiftData

/// Represents a single completed focus session.
@Model
final class FocusSession {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var durationSeconds: Int
    var category: String
    var wasCompleted: Bool

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date = Date(),
        durationSeconds: Int,
        category: String = "General",
        wasCompleted: Bool = true
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.durationSeconds = durationSeconds
        self.category = category
        self.wasCompleted = wasCompleted
    }
}

extension FocusSession {
    var durationMinutes: Int {
        durationSeconds / 60
    }

    var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: startDate)
    }
}
