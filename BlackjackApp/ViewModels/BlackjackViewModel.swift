import Foundation

/// Owns all Blackjack game state and rules. Views read published state and
/// call these methods; they never touch card/deck logic themselves.
@MainActor
final class BlackjackViewModel: ObservableObject {

    @Published private(set) var deck: [Card] = []
    @Published private(set) var playerHand: [Card] = []
    @Published private(set) var dealerHand: [Card] = []
    @Published private(set) var gameState: GameState = .ready
    @Published private(set) var result: GameResult?
    @Published private(set) var dealerCardHidden: Bool = true

    /// Cards remaining below this count trigger a fresh, reshuffled deck
    /// before the next deal so we can never run out mid-round.
    private let minimumDeckSize = 15
    private let dealDelayNanoseconds: UInt64 = 220_000_000

    // MARK: - Computed scores

    var playerScore: Int { Self.calculateHandValue(playerHand) }
    var dealerScore: Int { Self.calculateHandValue(dealerHand) }

    /// The score to display for the dealer while their hole card is hidden
    /// (only the face-up card counts), so we never leak the true total early.
    var dealerVisibleScore: Int {
        guard dealerCardHidden, let firstCard = dealerHand.first else { return dealerScore }
        return Self.calculateHandValue([firstCard])
    }

    var canHit: Bool { gameState == .playerTurn }
    var canStand: Bool { gameState == .playerTurn }
    var canStartNewRound: Bool { gameState == .ready || gameState == .finished }

    // MARK: - Hand value calculation

    /// Calculates the optimal Blackjack score for a hand, treating Aces as
    /// either 11 or 1 so the total never busts unnecessarily.
    static func calculateHandValue(_ hand: [Card]) -> Int {
        var total = hand.reduce(0) { $0 + $1.rank.baseValue }
        var acesAsEleven = hand.filter { $0.rank.isAce }.count
        while total > 21 && acesAsEleven > 0 {
            total -= 10
            acesAsEleven -= 1
        }
        return total
    }

    private static func isBlackjack(_ hand: [Card]) -> Bool {
        hand.count == 2 && calculateHandValue(hand) == 21
    }

    /// Pure result of comparing two final scores, following the general
    /// evaluation rules (bust beats everything else, then highest score).
    static func evaluateOutcome(playerScore: Int, dealerScore: Int) -> GameResult {
        if playerScore > 21 {
            return .playerBust
        } else if dealerScore > 21 {
            return .dealerBust
        } else if playerScore > dealerScore {
            return .playerWin
        } else if dealerScore > playerScore {
            return .dealerWin
        } else {
            return .push
        }
    }

    /// The dealer must keep hitting below 17 and stand once at 17 or above.
    static func dealerShouldHit(score: Int) -> Bool {
        score < 17
    }

    /// Checks the initial two-card hands for a natural Blackjack. Returns
    /// nil when neither hand qualifies.
    static func initialBlackjackOutcome(playerHand: [Card], dealerHand: [Card]) -> GameResult? {
        let playerHasBlackjack = isBlackjack(playerHand)
        let dealerHasBlackjack = isBlackjack(dealerHand)

        guard playerHasBlackjack || dealerHasBlackjack else { return nil }
        if playerHasBlackjack && dealerHasBlackjack { return .push }
        return playerHasBlackjack ? .playerBlackjack : .dealerBlackjack
    }

    // MARK: - Round lifecycle

    /// Begins a new round: clears hands, reshuffles if needed, deals four
    /// cards, and checks for an immediate Blackjack.
    func startNewRound() async {
        guard canStartNewRound else { return }

        gameState = .dealing
        result = nil
        playerHand = []
        dealerHand = []
        dealerCardHidden = true
        ensureDeckHasEnoughCards()

        await dealCard(to: .player)
        await dealCard(to: .dealer)
        await dealCard(to: .player)
        await dealCard(to: .dealer)

        evaluateInitialBlackjack()
    }

    /// Checks whether either hand has a natural Blackjack after the initial
    /// deal and ends the round immediately if so.
    private func evaluateInitialBlackjack() {
        guard let outcome = Self.initialBlackjackOutcome(playerHand: playerHand, dealerHand: dealerHand) else {
            gameState = .playerTurn
            return
        }

        Task {
            await revealDealerCard()
            await finishRound(with: outcome)
        }
    }

    /// Deals one card to the player. Triggered by the Hit button or the
    /// swipe-up gesture — both call this exact method.
    func hit() async {
        guard canHit else { return }

        await dealCard(to: .player)

        if playerScore > 21 {
            await finishRound(with: .playerBust)
        } else if playerScore == 21 {
            // Automatically proceed to the dealer's turn for smoother play.
            await stand()
        }
    }

    /// Ends the player's turn, reveals the dealer's hole card, and plays out
    /// the dealer's hand. Triggered by the Stand button or swipe-down.
    func stand() async {
        guard canStand else { return }

        gameState = .dealerTurn
        await revealDealerCard()
        await dealerTurn()
    }

    /// Draws dealer cards until the dealer's total reaches at least 17, then
    /// determines the winner.
    private func dealerTurn() async {
        while Self.dealerShouldHit(score: dealerScore) {
            await dealCard(to: .dealer)
        }
        await finishRound(with: Self.evaluateOutcome(playerScore: playerScore, dealerScore: dealerScore))
    }

    private func finishRound(with outcome: GameResult) async {
        result = outcome
        gameState = .finished
        if outcome.isPlayerFavourable {
            AudioManager.shared.play(.win)
        } else if outcome.isPlayerUnfavourable {
            AudioManager.shared.play(.lose)
        } else {
            AudioManager.shared.play(.button)
        }
    }

    // MARK: - Dealing helpers

    private enum HandOwner { case player, dealer }

    /// Deals a single card into the given hand with a short pause so the UI
    /// can animate each card arriving individually.
    private func dealCard(to owner: HandOwner) async {
        ensureDeckHasEnoughCards()
        guard let card = deck.popLast() else { return }

        switch owner {
        case .player: playerHand.append(card)
        case .dealer: dealerHand.append(card)
        }

        AudioManager.shared.play(.cardDeal)
        try? await Task.sleep(nanoseconds: dealDelayNanoseconds)
    }

    /// Flips the dealer's hole card face-up with a short pause for the
    /// flip animation to read clearly before the dealer draws.
    private func revealDealerCard() async {
        guard dealerCardHidden else { return }
        dealerCardHidden = false
        AudioManager.shared.play(.cardFlip)
        try? await Task.sleep(nanoseconds: 400_000_000)
    }

    /// Recreates and shuffles the deck if it is running low, so a hand can
    /// never fail to draw a card mid-round.
    private func ensureDeckHasEnoughCards() {
        if deck.count < minimumDeckSize {
            deck = Deck.newShuffled()
        }
    }
}
