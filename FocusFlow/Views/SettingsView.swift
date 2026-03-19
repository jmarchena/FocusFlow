import SwiftUI

struct SettingsView: View {
    @Bindable var timerVM: TimerViewModel
    @State private var customFocus: Double = 25
    @State private var customShortBreak: Double = 5
    @State private var customLongBreak: Double = 15
    @State private var customSessions: Double = 4

    var body: some View {
        NavigationStack {
            List {
                presetsSection
                customSection
                aboutSection
            }
            .navigationTitle("Settings")
            .onAppear {
                customFocus = Double(timerVM.configuration.focusDurationMinutes)
                customShortBreak = Double(timerVM.configuration.shortBreakMinutes)
                customLongBreak = Double(timerVM.configuration.longBreakMinutes)
                customSessions = Double(timerVM.configuration.sessionsBeforeLongBreak)
            }
        }
    }

    // MARK: - Presets

    private var presetsSection: some View {
        Section("Timer Presets") {
            ForEach(TimerConfiguration.presets, id: \.name) { preset in
                Button {
                    timerVM.selectConfiguration(preset.config)
                    customFocus = Double(preset.config.focusDurationMinutes)
                    customShortBreak = Double(preset.config.shortBreakMinutes)
                    customLongBreak = Double(preset.config.longBreakMinutes)
                    customSessions = Double(preset.config.sessionsBeforeLongBreak)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                                .font(.subheadline.weight(.medium))
                            Text("\(preset.config.focusDurationMinutes)m focus / \(preset.config.shortBreakMinutes)m break")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if timerVM.configuration == preset.config {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .foregroundStyle(.primary)
                .accessibilityLabel(preset.name)
                .accessibilityValue("\(preset.config.focusDurationMinutes) minute focus, \(preset.config.shortBreakMinutes) minute break")
                .accessibilityHint(timerVM.configuration == preset.config ? "Currently selected" : "Double tap to select this preset")
                .accessibilityAddTraits(timerVM.configuration == preset.config ? .isSelected : [])
            }
        }
    }

    // MARK: - Custom Settings

    private var customSection: some View {
        Section("Custom Timer") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Focus: \(Int(customFocus)) minutes")
                    .font(.subheadline)
                Slider(value: $customFocus, in: 5...90, step: 5)
                    .tint(.orange)
                    .accessibilityLabel("Focus duration")
                    .accessibilityValue("\(Int(customFocus)) minutes")
                    .accessibilityHint("Swipe up or down to adjust in 5 minute increments")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Short Break: \(Int(customShortBreak)) minutes")
                    .font(.subheadline)
                Slider(value: $customShortBreak, in: 1...30, step: 1)
                    .tint(.green)
                    .accessibilityLabel("Short break duration")
                    .accessibilityValue("\(Int(customShortBreak)) minutes")
                    .accessibilityHint("Swipe up or down to adjust in 1 minute increments")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Long Break: \(Int(customLongBreak)) minutes")
                    .font(.subheadline)
                Slider(value: $customLongBreak, in: 5...60, step: 5)
                    .tint(.blue)
                    .accessibilityLabel("Long break duration")
                    .accessibilityValue("\(Int(customLongBreak)) minutes")
                    .accessibilityHint("Swipe up or down to adjust in 5 minute increments")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Sessions before long break: \(Int(customSessions))")
                    .font(.subheadline)
                Slider(value: $customSessions, in: 2...8, step: 1)
                    .tint(.purple)
                    .accessibilityLabel("Sessions before long break")
                    .accessibilityValue("\(Int(customSessions)) sessions")
                    .accessibilityHint("Swipe up or down to adjust")
            }

            Button("Apply Custom Settings") {
                let config = TimerConfiguration(
                    focusDurationMinutes: Int(customFocus),
                    shortBreakMinutes: Int(customShortBreak),
                    longBreakMinutes: Int(customLongBreak),
                    sessionsBeforeLongBreak: Int(customSessions)
                )
                timerVM.selectConfiguration(config)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.orange)
            .accessibilityLabel("Apply custom settings")
            .accessibilityHint("Applies \(Int(customFocus)) minute focus, \(Int(customShortBreak)) minute short break, \(Int(customLongBreak)) minute long break")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Architecture")
                Spacer()
                Text("SwiftUI + SwiftData")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView(timerVM: TimerViewModel())
}
