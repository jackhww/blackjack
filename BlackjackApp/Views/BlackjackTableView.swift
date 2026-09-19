import SwiftUI

/// The main gameplay screen. Contains no Blackjack rules itself — every
/// action just calls a method on the view model, whether triggered by a
/// button tap or a gesture.
struct BlackjackTableView: View {
    @StateObject private var viewModel = BlackjackViewModel()
    @State private var showRules = false

    var body: some View {
        ZStack {
            tableBackground

            VStack(spacing: 0) {
                Text("BLACKJACK")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 12)

                Spacer(minLength: 12)

                HandView(
                    title: "Dealer",
                    cards: viewModel.dealerHand,
                    faceUpFlags: dealerFaceUpFlags,
                    scoreText: dealerScoreText
                )

                Spacer(minLength: 8)

                // Result banner replaces the status line inline — never a
                // popup — so Hit/Stand/New Round stay exactly where they are.
                Group {
                    if let result = viewModel.result {
                        GameResultView(result: result)
                    } else {
                        statusText
                    }
                }
                .frame(minHeight: 44)

                Spacer(minLength: 8)

                HandView(
                    title: "Player",
                    cards: viewModel.playerHand,
                    faceUpFlags: Array(repeating: true, count: viewModel.playerHand.count),
                    scoreText: "Player: \(viewModel.playerScore)"
                )

                Spacer(minLength: 20)

                controls
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .simultaneousGesture(doubleTapGesture)
        .simultaneousGesture(longPressGesture)
        .sheet(isPresented: $showRules) {
            RulesView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.canStartNewRound {
                await viewModel.startNewRound()
            }
        }
    }

    // MARK: - Layout pieces

    private var tableBackground: some View {
        RadialGradient(
            colors: [Color(red: 0.05, green: 0.35, blue: 0.18), Color(red: 0.01, green: 0.12, blue: 0.06)],
            center: .center,
            startRadius: 40,
            endRadius: 420
        )
        .ignoresSafeArea()
    }

    private var statusText: some View {
        Text(statusMessage)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white.opacity(0.85))
            .frame(minHeight: 20)
    }

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 14) {
            if viewModel.gameState == .finished {
                Button {
                    Task { await viewModel.startNewRound() }
                } label: {
                    Text("NEW ROUND")
                        .font(.title3.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!viewModel.canStartNewRound)
            } else {
                HStack(spacing: 16) {
                    Button {
                        Task { await viewModel.hit() }
                    } label: {
                        Text("HIT")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(!viewModel.canHit)

                    Button {
                        Task { await viewModel.stand() }
                    } label: {
                        Text("STAND")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(!viewModel.canStand)
                }
            }

            VStack(spacing: 4) {
                Text("↑ Swipe to Hit • ↓ Swipe to Stand")
                Text("Double tap after a round to deal again")
                Text("Hold anywhere on the table for rules")
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Derived display state

    private var dealerFaceUpFlags: [Bool] {
        viewModel.dealerHand.indices.map { index in
            index == 1 ? !viewModel.dealerCardHidden : true
        }
    }

    private var dealerScoreText: String {
        viewModel.dealerCardHidden ? "Dealer: \(viewModel.dealerVisibleScore) + ?" : "Dealer: \(viewModel.dealerScore)"
    }

    private var statusMessage: String {
        switch viewModel.gameState {
        case .ready: return "Dealing…"
        case .dealing: return "Dealing…"
        case .playerTurn: return "Your move — Hit or Stand"
        case .dealerTurn: return "Dealer is playing…"
        case .finished: return " "
        }
    }

    // MARK: - Gestures (all call the same methods the buttons use)

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(vertical) > abs(horizontal) else { return }

                if vertical < 0 {
                    Task { await viewModel.hit() }
                } else {
                    Task { await viewModel.stand() }
                }
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            Task { await viewModel.startNewRound() }
        }
    }

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.6).onEnded { _ in
            showRules = true
        }
    }
}

#Preview {
    NavigationStack {
        BlackjackTableView()
    }
}
