import SwiftUI

struct StatsView: View {
    @Bindable var viewModel: StatsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewCards
                    weeklyChart
                    recentSessionsList
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Statistics")
        }
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            statCard(
                title: "All Time",
                value: formatMinutes(viewModel.totalAllTimeMinutes),
                icon: "clock.fill",
                color: .orange
            )
            statCard(
                title: "Best Day",
                value: formatMinutes(viewModel.bestDayMinutes),
                icon: "star.fill",
                color: .yellow
            )
            statCard(
                title: "Daily Avg",
                value: formatMinutes(viewModel.averageDailyMinutes),
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            if viewModel.weeklyStats.isEmpty {
                Text("No data yet. Complete a focus session to see your progress.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(last7Days(), id: \.self) { day in
                        let stats = viewModel.weeklyStats.first(where: { $0.dayKey == dayKey(for: day) })
                        let minutes = (stats?.totalFocusSeconds ?? 0) / 60
                        let maxMinutes = max(
                            (viewModel.weeklyStats.map(\.totalFocusSeconds).max() ?? 1) / 60,
                            1
                        )

                        VStack(spacing: 4) {
                            Text("\(minutes)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    minutes > 0 ? Color.orange : Color.gray.opacity(0.2)
                                )
                                .frame(
                                    height: max(4, CGFloat(minutes) / CGFloat(maxMinutes) * 100)
                                )

                            Text(shortDayName(for: day))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 140)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Recent Sessions

    private var recentSessionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)

            if viewModel.recentSessions.isEmpty {
                Text("No sessions yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.recentSessions, id: \.id) { session in
                    sessionRow(session)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack {
            Circle()
                .fill(session.wasCompleted ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.formattedDuration)
                    .font(.subheadline.weight(.medium))
                Text(session.startDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if session.wasCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func last7Days() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: Date())
        }
    }

    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func shortDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes)m"
    }
}

#Preview {
    StatsView(viewModel: StatsViewModel())
}
