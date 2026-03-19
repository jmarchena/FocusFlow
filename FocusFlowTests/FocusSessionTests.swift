import Testing
import Foundation
@testable import FocusFlow

struct FocusSessionTests {

    // MARK: - durationMinutes

    @Test func durationMinutesRoundsDown() {
        let session = FocusSession(
            startDate: Date(),
            durationSeconds: 1500  // 25 minutes exactly
        )
        #expect(session.durationMinutes == 25)
    }

    @Test func durationMinutesWithRemainder() {
        let session = FocusSession(
            startDate: Date(),
            durationSeconds: 1530  // 25m 30s
        )
        #expect(session.durationMinutes == 25)
    }

    @Test func durationMinutesZero() {
        let session = FocusSession(startDate: Date(), durationSeconds: 0)
        #expect(session.durationMinutes == 0)
    }

    // MARK: - formattedDuration

    @Test func formattedDurationZeroPads() {
        let session = FocusSession(startDate: Date(), durationSeconds: 65)
        #expect(session.formattedDuration == "01:05")
    }

    @Test func formattedDurationFullHour() {
        let session = FocusSession(startDate: Date(), durationSeconds: 3600)
        #expect(session.formattedDuration == "60:00")
    }

    @Test func formattedDurationTwentyFiveMinutes() {
        let session = FocusSession(startDate: Date(), durationSeconds: 1500)
        #expect(session.formattedDuration == "25:00")
    }

    // MARK: - dayKey

    @Test func dayKeyFormat() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 19
        let date = Calendar.current.date(from: components)!

        let session = FocusSession(startDate: date, durationSeconds: 100)
        #expect(session.dayKey == "2026-03-19")
    }

    // MARK: - Default values

    @Test func defaultCategoryIsGeneral() {
        let session = FocusSession(startDate: Date(), durationSeconds: 100)
        #expect(session.category == "General")
    }

    @Test func defaultWasCompletedIsTrue() {
        let session = FocusSession(startDate: Date(), durationSeconds: 100)
        #expect(session.wasCompleted == true)
    }
}
