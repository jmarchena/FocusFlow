import SwiftUI

struct TimerView: View {
    @Bindable var viewModel: TimerViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                phaseIndicator
                timerRing
                controlButtons
                todaySummary
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .navigationTitle("FocusFlow")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Phase Indicator

    private var phaseIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.currentPhase.systemImageName)
                .font(.title3)
            Text(viewModel.phaseLabel)
                .font(.title3.weight(.semibold))
        }
        .foregroundStyle(colorForPhase)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(colorForPhase.opacity(0.12))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current phase: \(viewModel.phaseLabel)")
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    colorForPhase.opacity(0.15),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    colorForPhase,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: viewModel.progress)

            // Time display
            VStack(spacing: 4) {
                Text(viewModel.formattedTime)
                    .font(.system(size: 56, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .linear(duration: 0.1), value: viewModel.remainingSeconds)

                if viewModel.currentPhase == .focus {
                    Text("Session \(viewModel.completedFocusSessions + 1) of \(viewModel.configuration.sessionsBeforeLongBreak)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 260, height: 260)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(timerRingAccessibilityLabel)
        .accessibilityValue(timerRingAccessibilityValue)
    }

    private var timerRingAccessibilityLabel: String {
        "\(viewModel.phaseLabel) timer"
    }

    private var timerRingAccessibilityValue: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        let timeText: String
        if minutes > 0 && seconds > 0 {
            timeText = "\(minutes) minutes \(seconds) seconds remaining"
        } else if minutes > 0 {
            timeText = "\(minutes) minutes remaining"
        } else {
            timeText = "\(seconds) seconds remaining"
        }
        guard viewModel.currentPhase == .focus else { return timeText }
        return "Session \(viewModel.completedFocusSessions + 1) of \(viewModel.configuration.sessionsBeforeLongBreak). \(timeText)"
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 24) {
            // Reset button
            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            .foregroundStyle(.secondary)
            .accessibilityLabel("Reset timer")
            .accessibilityHint("Resets the current phase to its full duration")

            // Play/Pause button
            Button {
                if viewModel.isRunning {
                    viewModel.pause()
                } else {
                    viewModel.start()
                }
            } label: {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 72, height: 72)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(colorForPhase)
                    )
                    .shadow(color: colorForPhase.opacity(0.3), radius: 8, y: 4)
            }
            .accessibilityLabel(viewModel.isRunning ? "Pause timer" : "Start timer")
            .accessibilityHint(viewModel.isRunning
                ? "Pauses the current focus session"
                : "Starts the \(viewModel.phaseLabel.lowercased()) timer")

            // Skip button
            Button {
                viewModel.skip()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            .foregroundStyle(.secondary)
            .accessibilityLabel("Skip to next phase")
            .accessibilityHint("Ends the current phase and moves to the next one")
        }
    }

    // MARK: - Today Summary

    private var todaySummary: some View {
        HStack(spacing: 32) {
            summaryItem(
                value: "\(viewModel.totalFocusToday / 60)",
                unit: "min",
                label: "Today"
            )
            summaryItem(
                value: "\(viewModel.sessionsToday)",
                unit: "",
                label: "Sessions"
            )
            summaryItem(
                value: "\(viewModel.currentStreak)",
                unit: "days",
                label: "Streak"
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summaryAccessibilityLabel)
    }

    private var summaryAccessibilityLabel: String {
        let focusMinutes = viewModel.totalFocusToday / 60
        let streakText = viewModel.currentStreak == 1 ? "1 day streak" : "\(viewModel.currentStreak) day streak"
        return "\(focusMinutes) minutes focused today, \(viewModel.sessionsToday) sessions completed, \(streakText)"
    }

    private func summaryItem(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2.weight(.bold))
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private var colorForPhase: Color {
        switch viewModel.currentPhase {
        case .focus: return .orange
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel())
}
