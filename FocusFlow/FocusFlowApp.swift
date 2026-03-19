import SwiftUI
import SwiftData

@main
struct FocusFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [FocusSession.self, DailyStats.self])
    }
}
