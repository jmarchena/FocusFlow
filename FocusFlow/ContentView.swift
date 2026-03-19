import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var timerVM = TimerViewModel()
    @State private var statsVM = StatsViewModel()
    @State private var selectedTab: Tab = .timer
    @Environment(\.modelContext) private var modelContext

    enum Tab: String, CaseIterable {
        case timer = "Timer"
        case stats = "Stats"
        case settings = "Settings"

        var iconName: String {
            switch self {
            case .timer: return "timer"
            case .stats: return "chart.bar"
            case .settings: return "gearshape"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView(viewModel: timerVM)
                .tabItem {
                    Label(Tab.timer.rawValue, systemImage: Tab.timer.iconName)
                }
                .tag(Tab.timer)

            StatsView(viewModel: statsVM)
                .tabItem {
                    Label(Tab.stats.rawValue, systemImage: Tab.stats.iconName)
                }
                .tag(Tab.stats)

            SettingsView(timerVM: timerVM)
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.iconName)
                }
                .tag(Tab.settings)
        }
        .tint(.orange)
        .onAppear {
            timerVM.setModelContext(modelContext)
            statsVM.setModelContext(modelContext)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .stats {
                statsVM.refresh()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FocusSession.self, DailyStats.self], inMemory: true)
}
