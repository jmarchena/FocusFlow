import Foundation

/// User-configurable timer settings.
struct TimerConfiguration: Codable, Equatable {
    var focusDurationMinutes: Int
    var shortBreakMinutes: Int
    var longBreakMinutes: Int
    var sessionsBeforeLongBreak: Int

    static let `default` = TimerConfiguration(
        focusDurationMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 15,
        sessionsBeforeLongBreak: 4
    )

    static let deepWork = TimerConfiguration(
        focusDurationMinutes: 50,
        shortBreakMinutes: 10,
        longBreakMinutes: 30,
        sessionsBeforeLongBreak: 2
    )

    static let sprint = TimerConfiguration(
        focusDurationMinutes: 15,
        shortBreakMinutes: 3,
        longBreakMinutes: 10,
        sessionsBeforeLongBreak: 4
    )

    static let presets: [(name: String, config: TimerConfiguration)] = [
        ("Classic Pomodoro", .default),
        ("Deep Work", .deepWork),
        ("Sprint", .sprint)
    ]

    var focusDurationSeconds: Int { focusDurationMinutes * 60 }
    var shortBreakSeconds: Int { shortBreakMinutes * 60 }
    var longBreakSeconds: Int { longBreakMinutes * 60 }
}
