import Testing
@testable import FocusFlow

struct TimerPhaseTests {

    @Test func focusDisplayName() {
        #expect(TimerPhase.focus.displayName == "Focus")
    }

    @Test func shortBreakDisplayName() {
        #expect(TimerPhase.shortBreak.displayName == "Short Break")
    }

    @Test func longBreakDisplayName() {
        #expect(TimerPhase.longBreak.displayName == "Long Break")
    }

    @Test func allCasesCount() {
        #expect(TimerPhase.allCases.count == 3)
    }

    @Test func systemImageNames() {
        #expect(TimerPhase.focus.systemImageName == "brain.head.profile")
        #expect(TimerPhase.shortBreak.systemImageName == "cup.and.saucer")
        #expect(TimerPhase.longBreak.systemImageName == "figure.walk")
    }

    @Test func rawValues() {
        #expect(TimerPhase.focus.rawValue == "Focus")
        #expect(TimerPhase.shortBreak.rawValue == "Short Break")
        #expect(TimerPhase.longBreak.rawValue == "Long Break")
    }
}
