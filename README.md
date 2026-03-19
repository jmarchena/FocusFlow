# FocusFlow

A minimalist deep work timer and productivity tracker for iOS, built with SwiftUI and SwiftData.

## Why FocusFlow?

The productivity app space is crowded with feature-bloated tools. FocusFlow takes the opposite approach: a single-purpose utility that does one thing exceptionally well — helping you maintain deep focus using the Pomodoro technique with intelligent session tracking and streak motivation.

This app targets knowledge workers, students, and freelancers who want a native, privacy-first focus timer without subscriptions or cloud dependencies.

## Features (MVP)

- **Pomodoro Timer** — Configurable focus/break cycles with visual progress ring and smooth animations
- **Session History** — Every focus session is persisted locally using SwiftData
- **Daily & Weekly Stats** — Bar chart of weekly focus minutes, all-time totals, best day, and daily averages
- **Streak Tracking** — Consecutive-day streaks to build a focus habit
- **Timer Presets** — Classic Pomodoro (25/5), Deep Work (50/10), Sprint (15/3), plus fully custom settings
- **Dark Mode** — Full support via system appearance

## Architecture Decisions

### SwiftUI + MVVM with @Observable

The app uses SwiftUI as the sole UI framework (no UIKit bridging). View models use the `@Observable` macro (Observation framework) rather than the older `ObservableObject`/`@Published` pattern. This was chosen because:

- `@Observable` provides more granular change tracking, only re-rendering views that read changed properties
- It eliminates boilerplate (`@Published`, `objectWillChange`)
- It's Apple's recommended path forward as of iOS 17+

### SwiftData for Persistence

SwiftData was chosen over Core Data for several reasons:

- Native Swift integration with `@Model` macro — no Objective-C bridging
- Declarative schema definition alongside the model code
- Built-in SwiftUI integration via `@Query` and `.modelContainer`
- Simpler migration story for future schema changes

The data model consists of two entities: `FocusSession` (individual timer completions) and `DailyStats` (aggregated daily summaries for fast chart rendering).

### Swift Concurrency

Timer ticks and data operations use Swift's structured concurrency (`async/await`, `@MainActor`) rather than Combine or GCD. This aligns with Swift 6's direction toward compile-time concurrency safety.

### Project Structure

```
FocusFlow/
├── FocusFlowApp.swift          # App entry point, model container setup
├── ContentView.swift           # Tab-based root view
├── Models/
│   ├── FocusSession.swift      # SwiftData model for individual sessions
│   ├── DailyStats.swift        # SwiftData model for daily aggregates
│   ├── TimerConfiguration.swift # Timer presets and custom settings
│   └── TimerPhase.swift        # Focus/break phase enum
├── ViewModels/
│   ├── TimerViewModel.swift    # Timer logic, countdown, session saving
│   └── StatsViewModel.swift    # Statistics computation and queries
├── Views/
│   ├── TimerView.swift         # Main timer screen with ring animation
│   ├── StatsView.swift         # Weekly chart and session history
│   └── SettingsView.swift      # Presets and custom timer configuration
└── Resources/
    └── Assets.xcassets         # App icon, accent color
```

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 6.0

## Getting Started

1. Clone the repository
2. Open `FocusFlow.xcodeproj` in Xcode
3. Build and run on a simulator or device (iOS 17+)

No external dependencies — the app uses only Apple frameworks.

## Future Iterations

This MVP provides a foundation for:

- **Live Activities** — Show timer countdown on the Lock Screen and Dynamic Island
- **Widgets** — Today's focus summary on the Home Screen
- **On-device ML** — Learn optimal focus/break durations from usage patterns
- **Focus categories** — Tag sessions (Work, Study, Creative) with per-category stats
- **iCloud Sync** — SwiftData's CloudKit integration for multi-device history
- **Haptic feedback** — Subtle haptics on timer completion
- **Shortcuts integration** — Start focus sessions via Siri or the Shortcuts app

## License

MIT
