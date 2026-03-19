import Foundation

/// The current phase of the focus timer cycle.
enum TimerPhase: String, Codable, CaseIterable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var displayName: String { rawValue }

    var systemImageName: String {
        switch self {
        case .focus: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer"
        case .longBreak: return "figure.walk"
        }
    }
}
