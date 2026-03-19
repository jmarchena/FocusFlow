import Testing
import Foundation
@testable import FocusFlow

@MainActor
struct TimerViewModelTests {

    // MARK: - Initial state

    @Test func initialPhaseIsFocus() {
        let vm = TimerViewModel()
        #expect(vm.currentPhase == .focus)
    }

    @Test func initialRemainingSecondsIsZero() {
        let vm = TimerViewModel()
        #expect(vm.remainingSeconds == 0)
    }

    @Test func initialIsRunningIsFalse() {
        let vm = TimerViewModel()
        #expect(vm.isRunning == false)
    }

    @Test func initialCompletedSessionsIsZero() {
        let vm = TimerViewModel()
        #expect(vm.completedFocusSessions == 0)
    }

    // MARK: - Configuration

    @Test func defaultConfigurationIsPomodoro() {
        let vm = TimerViewModel()
        #expect(vm.configuration == TimerConfiguration.default)
    }

    @Test func selectConfigurationUpdatesValues() {
        let vm = TimerViewModel()
        vm.selectConfiguration(.deepWork)
        #expect(vm.configuration == TimerConfiguration.deepWork)
        #expect(vm.currentPhase == .focus)
        #expect(vm.completedFocusSessions == 0)
        #expect(vm.remainingSeconds == TimerConfiguration.deepWork.focusDurationSeconds)
    }

    @Test func selectConfigurationStopsTimer() {
        let vm = TimerViewModel()
        vm.start()
        vm.selectConfiguration(.sprint)
        #expect(vm.isRunning == false)
    }

    // MARK: - totalSecondsForCurrentPhase

    @Test func totalSecondsForFocusPhase() {
        let vm = TimerViewModel()
        vm.currentPhase = .focus
        #expect(vm.totalSecondsForCurrentPhase == TimerConfiguration.default.focusDurationSeconds)
    }

    @Test func totalSecondsForShortBreak() {
        let vm = TimerViewModel()
        vm.currentPhase = .shortBreak
        #expect(vm.totalSecondsForCurrentPhase == TimerConfiguration.default.shortBreakSeconds)
    }

    @Test func totalSecondsForLongBreak() {
        let vm = TimerViewModel()
        vm.currentPhase = .longBreak
        #expect(vm.totalSecondsForCurrentPhase == TimerConfiguration.default.longBreakSeconds)
    }

    // MARK: - formattedTime

    @Test func formattedTimeZeroIsDoubleZero() {
        let vm = TimerViewModel()
        vm.remainingSeconds = 0
        #expect(vm.formattedTime == "00:00")
    }

    @Test func formattedTimeTwentyFiveMinutes() {
        let vm = TimerViewModel()
        vm.remainingSeconds = 1500
        #expect(vm.formattedTime == "25:00")
    }

    @Test func formattedTimeZeroPadsSeconds() {
        let vm = TimerViewModel()
        vm.remainingSeconds = 65
        #expect(vm.formattedTime == "01:05")
    }

    // MARK: - progress

    @Test func progressIsZeroWhenRemainingEqualsTotal() {
        let vm = TimerViewModel()
        vm.remainingSeconds = vm.totalSecondsForCurrentPhase
        #expect(vm.progress == 0.0)
    }

    @Test func progressIsOneWhenRemainingIsZero() {
        let vm = TimerViewModel()
        let total = vm.totalSecondsForCurrentPhase
        vm.remainingSeconds = 0
        let expected = Double(total) / Double(total)
        #expect(vm.progress == expected)
    }

    @Test func progressIsHalfwayAtMidpoint() {
        let vm = TimerViewModel()
        let total = vm.totalSecondsForCurrentPhase
        vm.remainingSeconds = total / 2
        #expect(abs(vm.progress - 0.5) < 0.01)
    }

    // MARK: - Start / Pause / Reset

    @Test func startSetsIsRunning() {
        let vm = TimerViewModel()
        vm.start()
        #expect(vm.isRunning == true)
    }

    @Test func startSetsRemainingSecondsWhenZero() {
        let vm = TimerViewModel()
        #expect(vm.remainingSeconds == 0)
        vm.start()
        #expect(vm.remainingSeconds == vm.configuration.focusDurationSeconds)
    }

    @Test func pauseStopsTimer() {
        let vm = TimerViewModel()
        vm.start()
        vm.pause()
        #expect(vm.isRunning == false)
    }

    @Test func resetRestoresFullDuration() {
        let vm = TimerViewModel()
        vm.start()
        vm.remainingSeconds = 100
        vm.reset()
        #expect(vm.remainingSeconds == vm.totalSecondsForCurrentPhase)
        #expect(vm.isRunning == false)
    }

    @Test func resetClearsSessionStartDate() {
        let vm = TimerViewModel()
        vm.start()
        vm.reset()
        #expect(vm.sessionStartDate == nil)
    }

    // MARK: - Skip

    @Test func skipFromFocusGoesToShortBreak() {
        let vm = TimerViewModel()
        vm.currentPhase = .focus
        vm.skip()
        #expect(vm.currentPhase == .shortBreak)
    }

    @Test func skipFromShortBreakGoesToFocus() {
        let vm = TimerViewModel()
        vm.currentPhase = .shortBreak
        vm.skip()
        #expect(vm.currentPhase == .focus)
    }

    @Test func skipFromLongBreakGoesToFocus() {
        let vm = TimerViewModel()
        vm.currentPhase = .longBreak
        vm.skip()
        #expect(vm.currentPhase == .focus)
    }

    @Test func skipUpdatesRemainingSeconds() {
        let vm = TimerViewModel()
        vm.currentPhase = .focus
        vm.skip()
        #expect(vm.remainingSeconds == vm.configuration.shortBreakSeconds)
    }

    // MARK: - Phase label

    @Test func phaseLabelMatchesCurrentPhase() {
        let vm = TimerViewModel()
        vm.currentPhase = .focus
        #expect(vm.phaseLabel == "Focus")
        vm.currentPhase = .shortBreak
        #expect(vm.phaseLabel == "Short Break")
        vm.currentPhase = .longBreak
        #expect(vm.phaseLabel == "Long Break")
    }

    // MARK: - Long break after N sessions

    @Test func skipToLongBreakAfterConfiguredSessions() {
        let vm = TimerViewModel()
        // Complete enough sessions to trigger long break
        vm.completedFocusSessions = vm.configuration.sessionsBeforeLongBreak
        vm.currentPhase = .focus
        vm.skip()
        #expect(vm.currentPhase == .longBreak)
        #expect(vm.completedFocusSessions == 0)
    }
}
