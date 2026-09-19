# blackjack

A simple Blackjack game for iOS, built with SwiftUI (MVVM). See [`docs/spec.md`](docs/spec.md) for the full assignment spec.

## Requirements

- macOS with Xcode 16 or later
- iOS 17+ simulator or device (no third-party dependencies to install)

## Running the app

1. Open `BlackjackApp.xcodeproj` in Xcode.
2. Select the **BlackjackApp** scheme and an iOS Simulator (or a connected device) from the scheme/destination picker in the toolbar.
3. If running on a physical device, select your team under the target's **Signing & Capabilities** tab (Automatic signing is already enabled).
4. Press **Run** (`Cmd+R`).

## Running the tests

- In Xcode: `Cmd+U`, or open the Test navigator and run `BlackjackAppTests`.
- From the command line: `xcodebuild test -project BlackjackApp.xcodeproj -scheme BlackjackApp -destination 'platform=iOS Simulator,name=iPhone 16'`

## Project structure

- `BlackjackApp/Models` — `Card`, `Suit`, `Rank`, `Deck`, `GameResult`, `GameState`
- `BlackjackApp/ViewModels` — `BlackjackViewModel` (all game logic)
- `BlackjackApp/Views` — Main Menu, Blackjack Table, Rules, and reusable card/result views
- `BlackjackApp/Services` — `AudioManager`
- `BlackjackApp/Resources` — `Assets.xcassets` and sound effects
- `BlackjackAppTests` — unit tests for hand-value, blackjack, bust, and winner logic
