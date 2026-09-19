# MTD367 TMA02 — Basic Blackjack iOS App

Build a complete, runnable Xcode iOS project implementing a simple Blackjack game for SUSS MTD367 TMA02.

The objective is not to build a production casino application. Prioritize:

1. Correct Blackjack game logic
2. Clear mobile UI/UX
3. Required gesture recognisers
4. Animations and visual feedback
5. Audio feedback
6. Clean, readable, organised Swift code
7. A project structure that is easy to explain in an academic report

Do not over-engineer the application.

---

# 1. Technical Requirements

Platform:

* iOS
* Xcode
* Swift
* Prefer SwiftUI unless an existing project or course requirement specifically requires UIKit
* Target a reasonably recent iOS version supported by current Xcode

Architecture:

* MVVM-style separation
* Views should not contain significant Blackjack business logic
* Game state should be managed by a dedicated ViewModel/GameManager
* Models should represent cards, suits, ranks, hands and game state

Suggested structure:

BlackjackApp/
├── App/
│   └── BlackjackApp.swift
│
├── Models/
│   ├── Card.swift
│   ├── Rank.swift
│   ├── Suit.swift
│   └── GameResult.swift
│
├── ViewModels/
│   └── BlackjackViewModel.swift
│
├── Views/
│   ├── MainMenuView.swift
│   ├── BlackjackTableView.swift
│   ├── PlayingCardView.swift
│   ├── HandView.swift
│   ├── GameResultView.swift
│   └── RulesView.swift
│
├── Services/
│   └── AudioManager.swift
│
├── Resources/
│   ├── Assets.xcassets
│   └── audio files
│
└── Utilities/
└── optional reusable helpers

Keep naming conventional and obvious.

---

# 2. Required Screens

## Main Menu

Purpose:
Entry point into the application.

UI:

* App title: "Blackjack"
* Blackjack/card-themed visual
* "Play" button
* "How to Play" button
* Optional short subtitle such as "Try to reach 21 without going over."

Interactions:

* Play → Blackjack Table
* How to Play → Rules screen/modal

Keep this screen visually simple and mobile friendly.

---

## Blackjack Table

This is the main gameplay screen.

Layout should roughly be:

---

```
       BLACKJACK
```

Dealer
[Card] [Card] [Card]
Dealer: 17

```
      Result/status
```

Player
[Card] [Card] [Card]
Player: 19

```
  [ HIT ]   [ STAND ]
```

Gesture hint:
↑ Hit     ↓ Stand
Double tap: New round
Long press: Rules
-----------------

Use a green/dark-green Blackjack table aesthetic.

Required information:

* Dealer cards
* Player cards
* Player hand value
* Dealer hand value when appropriate
* Current game status
* Hit button
* Stand button

Buttons are required even though gestures exist.

Do not make gestures the only way to play because discoverability and accessibility are important usability considerations.

---

# 3. Blackjack Rules

Implement a standard simplified Blackjack game.

## Deck

Create a normal 52-card deck:

Suits:

* Hearts
* Diamonds
* Clubs
* Spades

Ranks:

* 2 through 10
* Jack
* Queen
* King
* Ace

Values:

* 2–10 = face value
* Jack/Queen/King = 10
* Ace = 11 where possible, otherwise 1

Shuffle the deck before each round or when creating a fresh deck.

Use Swift's built-in randomisation/shuffle functionality.

---

# 4. Hand Value Calculation

Ace handling must work correctly.

Example:

Ace + 9 = 20

Ace + 9 + 5 should become:

1 + 9 + 5 = 15

rather than 25.

Recommended algorithm:

1. Count every Ace initially as 11.
2. Calculate total.
3. While total > 21 and there is an Ace still counted as 11:

   * subtract 10.
4. Return final total.

---

# 5. Starting a Round

When starting a new round:

1. Clear previous hands.
2. Reset result/game state.
3. Create/shuffle deck if necessary.
4. Deal:

   * player card
   * dealer card
   * player card
   * dealer card
5. Dealer's second card should initially be hidden.
6. Check whether either hand has Blackjack.

Animate each card appearing.

---

# 6. Hit

Triggered by:

* Hit button
* Swipe upward

Behaviour:

1. Deal one card to player.
2. Animate card entering player's hand.
3. Play card-dealing sound.
4. Recalculate hand value.
5. If player value > 21:

   * Player busts.
   * End round.
   * Reveal dealer card.
   * Display losing feedback.

If player reaches exactly 21, either:

* automatically trigger dealer turn, or
* allow Stand.

Prefer automatically proceeding to the dealer turn for smoother gameplay.

---

# 7. Stand

Triggered by:

* Stand button
* Swipe downward

Behaviour:

1. Disable additional player actions.
2. Reveal dealer's hidden card with flip animation.
3. Dealer draws cards until dealer hand value is at least 17.
4. Animate each dealer card.
5. Evaluate winner.

Simplified dealer rule:

Dealer hits while score < 17.
Dealer stands on 17 or above.

No need to implement casino-specific soft-17 variations.

---

# 8. Blackjack Detection

Blackjack means:

* exactly two initial cards
* total hand value = 21

Detect Blackjack after the initial deal.

Possible results:

* Player Blackjack only → player wins
* Dealer Blackjack only → dealer wins
* Both Blackjack → draw/push

---

# 9. Result Evaluation

Possible states:

* Player Win
* Dealer Win
* Player Bust
* Dealer Bust
* Blackjack
* Draw / Push

General evaluation:

if player > 21:
player loses

else if dealer > 21:
player wins

else if player > dealer:
player wins

else if dealer > player:
player loses

else:
draw

Represent game results using an enum rather than arbitrary strings where practical.

Example:

enum GameResult {
case playerBlackjack
case dealerBlackjack
case playerWin
case dealerWin
case playerBust
case dealerBust
case push
}

---

# 10. Game Result UI

When a round ends, clearly show the result.

Examples:

"BLACKJACK!"
"YOU WIN!"
"DEALER WINS"
"BUST!"
"PUSH"

Provide strong visual feedback.

Suggested effects:

Win:

* green/gold glow
* celebratory scale or pulse animation
* win sound

Loss/bust:

* red overlay/glow
* shake animation
* losing/bust sound

Draw:

* neutral animation/colour

After result:

* Show a "Deal Again" / "New Round" button.

The user should not need to return to the Main Menu between rounds.

---

# 11. Required Gestures

The assignment specifically requires four gestures.

Implement all four.

## Swipe Up — Hit

Detect upward swipe over the Blackjack table.

Action:
Call the same `hit()` method used by the Hit button.

Reasoning:
An upward motion can metaphorically represent requesting/bringing another card into the hand and provides quick one-handed interaction.

Do not duplicate game logic inside gesture handlers.

---

## Swipe Down — Stand

Detect downward swipe.

Action:
Call the same `stand()` method used by the Stand button.

Reasoning:
The downward movement can represent stopping/settling the hand and forms a natural opposite to swipe-up Hit.

---

## Double Tap — Deal / Restart Round

Double tap the Blackjack table.

If no active round:

* start game

If round has ended:

* start new round

Avoid accidentally resetting an active round.

Recommended behaviour:

if gameState == .finished:
startNewRound()

Optionally allow double tap on initial empty table to deal.

---

## Long Press — Show Rules or Hint

Long press the game table.

Present:

* sheet/modal
* basic Blackjack instructions
* gesture cheat sheet

Example:

Goal:
Get closer to 21 than the dealer without exceeding 21.

Controls:
↑ Swipe Up — Hit
↓ Swipe Down — Stand
Double Tap — New Round
Long Press — Show Rules

The long press must not interrupt or corrupt game state.

---

# 12. Gesture Discoverability

Because gesture-only controls are difficult to discover, include a small hint underneath the normal controls.

Example:

↑ Swipe to Hit • ↓ Swipe to Stand
Double tap after a round to deal again
Hold anywhere on the table for rules

Buttons remain visible.

This supports the report discussion around usability limitations of gesture controls.

---

# 13. Card UI

Build a reusable PlayingCardView.

Card should display:

* rank
* suit
* suit symbol
* red colouring for hearts/diamonds
* dark colouring for clubs/spades

Example:

┌─────────┐
│ A       │
│    ♠    │
│       A │
└─────────┘

Do not rely on external card image libraries unless absolutely necessary.

Generate cards natively with SwiftUI views so the implementation remains easy to explain.

Face-down card:

* display a patterned/simple card back
* no rank/suit visible

Cards should have:

* rounded corners
* subtle shadow
* readable typography

---

# 14. Card Dealing Animation

Required.

When a card enters a hand:

* card begins offset from deck/dealer area
* slightly scaled down
* optionally slightly rotated
* animates into its final position

Use SwiftUI animation.

Example conceptual state:

Initial:
opacity = 0
scale = 0.7
offset y = -80

Final:
opacity = 1
scale = 1
offset = 0

Aim for approximately 0.25–0.4 second animations.

Do not make gameplay unnecessarily slow.

---

# 15. Card Flip Animation

Required for dealer's hidden card.

Dealer's second card should initially be face down.

When player stands or the round ends:

* perform 3D Y-axis rotation
* swap card back → card face around the halfway point

Use something resembling:

.rotation3DEffect(
.degrees(rotation),
axis: (x: 0, y: 1, z: 0)
)

The result should visibly resemble a card flip.

---

# 16. Result Animations

Implement at least basic feedback.

Win:

* scale/pulse result text
* optional subtle glow

Loss:

* shake result text/table

Bust:

* red flash or shake

Push:

* neutral fade/scale

Keep animations clean rather than excessive.

---

# 17. Audio

Create an AudioManager.

Required categories:

* card deal
* button interaction
* win
* lose/bust

Optional:

* card flip

Use AVFoundation / AVAudioPlayer.

Audio failures must not crash the game.

Example API:

AudioManager.shared.play(.cardDeal)
AudioManager.shared.play(.win)
AudioManager.shared.play(.lose)
AudioManager.shared.play(.button)

Keep audio implementation isolated from game logic.

---

# 18. Game State

Do not manage gameplay through miscellaneous Boolean variables.

Use a clear state representation.

For example:

enum GameState {
case ready
case dealing
case playerTurn
case dealerTurn
case finished
}

BlackjackViewModel may contain:

@Published var deck: [Card]
@Published var playerHand: [Card]
@Published var dealerHand: [Card]
@Published var gameState: GameState
@Published var result: GameResult?
@Published var dealerCardHidden: Bool

Methods:

startNewRound()
hit()
stand()
dealerTurn()
calculateHandValue(_:)
evaluateInitialBlackjack()
determineWinner()

Computed properties:

playerScore
dealerScore
canHit
canStand

---

# 19. Rules Screen

Create a small RulesView.

Explain:

Goal:
Get closer to 21 than the dealer without going over.

Card values:

* Number cards = face value
* J/Q/K = 10
* Ace = 1 or 11

Gameplay:

1. Player and dealer receive two cards.
2. Hit to draw another card.
3. Stand to keep current hand.
4. Dealer draws until reaching at least 17.
5. Going above 21 is a bust.

Gestures:

* Swipe ↑ = Hit
* Swipe ↓ = Stand
* Double tap = Deal again
* Long press = Rules

Do not add unsupported advanced rules such as split, insurance or surrender.

---

# 20. Navigation

Use a simple navigation hierarchy.

Main Menu
|
+---- Play --------> Blackjack Table
|
+---- How to Play -> Rules

Blackjack Table
|
+---- Long Press --> Rules sheet
|
+---- Back --------> Main Menu
|
+---- Round End ---> Result presented within table/result overlay
|
+---- New Round

Avoid unnecessarily complicated navigation.

---

# 21. UX Requirements

Design primarily for portrait mobile use.

Ensure:

* large touch targets
* readable text
* clear visual hierarchy
* actions reachable near bottom of screen
* cards fit common iPhone widths
* controls do not overlap
* interface handles different screen sizes reasonably
* gestures and buttons perform the same actions
* unavailable actions become disabled

Examples:

During dealer turn:

* disable Hit
* disable Stand

After round ends:

* disable Hit/Stand
* enable New Round

---

# 22. Accessibility / Usability

Where reasonable:

* Buttons should have text labels, not icon-only controls.
* Do not communicate result using colour alone.
* Maintain useful contrast.
* Gesture actions must have equivalent buttons.
* Avoid extremely small card text.
* Respect reduced-motion settings if straightforward.

This gives useful material for the assignment's UI/UX and gesture-usability discussion.

---

# 23. Error Prevention

Prevent:

* Hit after bust
* Hit after standing
* Stand more than once
* repeated dealer turns
* starting several rounds simultaneously
* double tap resetting an active round
* drawing from an empty deck
* revealing hidden dealer score prematurely

If deck gets unexpectedly low, recreate and shuffle it safely.

---

# 24. Code Quality

Code should look like student-written, understandable Swift.

Avoid:

* giant 500-line View
* excessive abstraction
* unnecessary protocols/generic frameworks
* external dependencies
* networking
* databases
* authentication
* persistence unless genuinely useful

Prefer simple Swift constructs.

Each important function should have a brief explanatory comment where helpful.

Example:

/// Calculates the optimal Blackjack score for a hand,
/// treating Aces as either 1 or 11.
func calculateHandValue(_ hand: [Card]) -> Int

Do not comment every obvious line.

---

# 25. Testing

At minimum verify these scenarios manually and preferably with unit tests for game logic:

Ace handling:
A + 9 = 20
A + 9 + 5 = 15
A + A + 9 = 21

Blackjack:
A + K = 21

Bust:
K + Q + 2 = 22

Winner:
Player 20 vs Dealer 18 → player wins

Dealer bust:
Player 18 vs Dealer 23 → player wins

Push:
Player 18 vs Dealer 18 → draw

Dealer behaviour:
Dealer 16 → must hit
Dealer 17 → must stand

If tests are added, concentrate on ViewModel/model logic rather than UI snapshot tests.

---

# 26. Submission-Focused Requirements

The finished Xcode project must visibly demonstrate:

* Deck creation
* Deck shuffling
* Player and dealer hands
* Hit
* Stand
* Bust detection
* Blackjack detection
* Win detection
* Loss detection
* Draw detection
* Swipe up interaction
* Swipe down interaction
* Double-tap interaction
* Long-press interaction
* Card dealing animation
* Card flip animation
* Result visual feedback
* Audio feedback
* Navigation between screens
* Mobile-friendly layout
* Organised Swift source files
* Clear naming conventions

Do not mark a feature complete unless it is actually wired into the running UI.

---

# 27. Development Strategy

Implement incrementally.

Phase 1:
Create models and Blackjack game logic.

Phase 2:
Create basic playable BlackjackTableView using buttons only.

Phase 3:
Add Main Menu and navigation.

Phase 4:
Add gesture recognisers, sharing the same game methods as buttons.

Phase 5:
Add card dealing and card flip animations.

Phase 6:
Add win/lose/bust visual feedback.

Phase 7:
Add audio.

Phase 8:
Polish responsive layout and accessibility.

Phase 9:
Test all gameplay paths and remove warnings/errors.

Do not try to implement everything in one enormous file.

---

# 28. Important Instruction for Claude Code

Work directly on the provided Xcode project.

Before changing code:

1. Inspect the existing project structure.
2. Determine whether it uses SwiftUI or UIKit.
3. Preserve the existing approach where reasonable.
4. Do not replace working project configuration unnecessarily.

After every significant implementation step:

1. Build the project.
2. Fix compilation errors immediately.
3. Check for obvious warnings.
4. Keep the application runnable.

Do not invent APIs without checking that they exist.

When modifying files, provide a concise explanation of:

* what was changed
* why it was changed
* which assignment requirement it satisfies

Do not introduce third-party dependencies unless explicitly approved.

---

# 29. Acceptance Criteria

The project is complete when I can:

1. Launch the app.
2. See a Main Menu.
3. Open the Blackjack game.
4. Receive two cards.
5. See one dealer card hidden.
6. Hit using either button or swipe up.
7. Stand using either button or swipe down.
8. Watch dealer's hidden card flip.
9. Watch dealer automatically play to 17+.
10. Receive an accurate win/loss/draw/bust/Blackjack result.
11. See visual feedback.
12. Hear appropriate audio.
13. Double tap after the round to deal again.
14. Long press to view Blackjack rules.
15. Return to the Main Menu.
16. Repeat several rounds without game-state bugs.
17. Rotate through common gameplay scenarios without crashes.

The final result should be clean enough that screenshots can be directly used in the accompanying TMA report.

