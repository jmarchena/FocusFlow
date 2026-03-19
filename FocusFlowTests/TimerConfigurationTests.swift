import Testing
@testable import FocusFlow

struct TimerConfigurationTests {

    // MARK: - Presets

    @Test func defaultPresetValues() {
        let config = TimerConfiguration.default
        #expect(config.focusDurationMinutes == 25)
        #expect(config.shortBreakMinutes == 5)
        #expect(config.longBreakMinutes == 15)
        #expect(config.sessionsBeforeLongBreak == 4)
    }

    @Test func deepWorkPresetValues() {
        let config = TimerConfiguration.deepWork
        #expect(config.focusDurationMinutes == 50)
        #expect(config.shortBreakMinutes == 10)
        #expect(config.longBreakMinutes == 30)
        #expect(config.sessionsBeforeLongBreak == 2)
    }

    @Test func sprintPresetValues() {
        let config = TimerConfiguration.sprint
        #expect(config.focusDurationMinutes == 15)
        #expect(config.shortBreakMinutes == 3)
        #expect(config.longBreakMinutes == 10)
        #expect(config.sessionsBeforeLongBreak == 4)
    }

    @Test func presetsContainsThreeEntries() {
        #expect(TimerConfiguration.presets.count == 3)
    }

    // MARK: - Computed seconds

    @Test func focusDurationSeconds() {
        let config = TimerConfiguration.default
        #expect(config.focusDurationSeconds == 25 * 60)
    }

    @Test func shortBreakSeconds() {
        let config = TimerConfiguration.default
        #expect(config.shortBreakSeconds == 5 * 60)
    }

    @Test func longBreakSeconds() {
        let config = TimerConfiguration.default
        #expect(config.longBreakSeconds == 15 * 60)
    }

    // MARK: - Equality

    @Test func samePresetsAreEqual() {
        #expect(TimerConfiguration.default == TimerConfiguration.default)
    }

    @Test func differentPresetsAreNotEqual() {
        #expect(TimerConfiguration.default != TimerConfiguration.deepWork)
    }
}
