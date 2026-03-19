import Foundation
import SwiftData
import Observation

/// Manages timer state, countdown logic, and session persistence.
/// @MainActor ensures all mutations happen on the main thread, which is required
/// by @Observable and eliminates Swift 6 concurrency warnings throughout.
@MainActor
@Observable
final class TimerViewModel {
    // MARK: - Timer State

    var remainingSeconds: Int = 0
    var isRunning: Bool = false
    var currentPhase: TimerPhase = .focus
    var completedFocusSessions: Int = 0
    var configuration: TimerConfiguration = .default

    // MARK: - Session Tracking

    var sessionStartDate: Date?
    var totalFocusToday: Int = 0
    var sessionsToday: Int = 0
    var currentStreak: Int = 0

    // MARK: - Private

    private var timer: Timer?
    private var modelContext: ModelContext?

    // MARK: - Computed Properties

    var progress: Double {
        let total = totalSecondsForCurrentPhase
        guard total > 0 else { return 0 }
        return Double(total - remainingSeconds) / Double(total)
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var totalSecondsForCurrentPhase: Int {
        switch currentPhase {
        case .focus:
            return configuration.focusDurationSeconds
        case .shortBreak:
            return configuration.shortBreakSeconds
        case .longBreak:
            return configuration.longBreakSeconds
        }
    }

    var phaseLabel: String {
        currentPhase.displayName
    }

    // MARK: - Setup

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTodayStats()
        calculateStreak()
    }

    // MARK: - Timer Controls

    func start() {
        if remainingSeconds == 0 {
            remainingSeconds = totalSecondsForCurrentPhase
        }
        if currentPhase == .focus {
            sessionStartDate = Date()
        }
        isRunning = true
        startCountdown()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        remainingSeconds = totalSecondsForCurrentPhase
        sessionStartDate = nil
    }

    func skip() {
        pause()
        advancePhase(sessionCompleted: false)
    }

    func selectConfiguration(_ config: TimerConfiguration) {
        pause()
        configuration = config
        currentPhase = .focus
        completedFocusSessions = 0
        remainingSeconds = config.focusDurationSeconds
    }

    // MARK: - Private Methods

    private func startCountdown() {
        timer?.invalidate()
        // The Timer closure is nonisolated, so we hop back to MainActor explicitly.
        // Using `[weak self]` prevents a retain cycle; the Task wrapper is the only
        // safe way to call a @MainActor method from a @Sendable closure.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard isRunning else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }

        if remainingSeconds == 0 {
            phaseCompleted()
        }
    }

    private func phaseCompleted() {
        pause()

        if currentPhase == .focus {
            saveFocusSession(completed: true)
            completedFocusSessions += 1
        }

        advancePhase(sessionCompleted: true)
    }

    private func advancePhase(sessionCompleted: Bool) {
        switch currentPhase {
        case .focus:
            if completedFocusSessions >= configuration.sessionsBeforeLongBreak {
                currentPhase = .longBreak
                completedFocusSessions = 0
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .focus
        }

        remainingSeconds = totalSecondsForCurrentPhase
        sessionStartDate = nil
    }

    private func saveFocusSession(completed: Bool) {
        guard let context = modelContext else { return }
        let start = sessionStartDate ?? Date()
        let duration = configuration.focusDurationSeconds - remainingSeconds

        let session = FocusSession(
            startDate: start,
            endDate: Date(),
            durationSeconds: duration,
            wasCompleted: completed
        )

        context.insert(session)
        try? context.save()

        totalFocusToday += duration
        sessionsToday += 1

        updateDailyStats(additionalSeconds: duration)
        calculateStreak()
    }

    private func loadTodayStats() {
        guard let context = modelContext else { return }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.startDate >= startOfDay }
        )

        if let sessions = try? context.fetch(descriptor) {
            totalFocusToday = sessions.reduce(0) { $0 + $1.durationSeconds }
            sessionsToday = sessions.filter(\.wasCompleted).count
        }
    }

    private func updateDailyStats(additionalSeconds: Int) {
        guard let context = modelContext else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())

        let descriptor = FetchDescriptor<DailyStats>(
            predicate: #Predicate { $0.dayKey == todayKey }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.totalFocusSeconds += additionalSeconds
            existing.sessionsCompleted += 1
            existing.longestSessionSeconds = max(existing.longestSessionSeconds, additionalSeconds)
        } else {
            let stats = DailyStats(
                date: Date(),
                dayKey: todayKey,
                totalFocusSeconds: additionalSeconds,
                sessionsCompleted: 1,
                longestSessionSeconds: additionalSeconds
            )
            context.insert(stats)
        }

        try? context.save()
    }

    private func calculateStreak() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<DailyStats>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let allStats = try? context.fetch(descriptor), !allStats.isEmpty else {
            currentStreak = 0
            return
        }

        var streak = 0
        let calendar = Calendar.current
        var expectedDate = calendar.startOfDay(for: Date())

        for stats in allStats {
            let statsDay = calendar.startOfDay(for: stats.date)
            if statsDay == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate) ?? expectedDate
            } else if statsDay < expectedDate {
                break
            }
        }

        currentStreak = streak
    }
}
