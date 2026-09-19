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

    /// Wagering: `chips` is the player's bankroll, `currentBet` is what the
    /// next round will risk, and `activeBet` is what the round in progress
    /// actually risks (it can grow if the player doubles down).
    @Published private(set) var chips: Int = startingChips
    @Published private(set) var currentBet: Int = minimumBet
    @Published private(set) var activeBet: Int = 0
    /// Chip change from the most recently finished round, for the result banner.
    @Published private(set) var lastPayoutDelta: Int = 0

    static let startingChips = 500
    static let minimumBet = 10
    private static let betStep = 10

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

    /// Double down is only offered on the original two-card hand, and only
    /// if the player can match their existing bet.
    var canDoubleDown: Bool {
        gameState == .playerTurn && playerHand.count == 2 && chips >= activeBet
    }

    var canAdjustBet: Bool { canStartNewRound }
    var canIncreaseBet: Bool { canAdjustBet && currentBet + Self.betStep <= chips }
    var canDecreaseBet: Bool { canAdjustBet && currentBet - Self.betStep >= Self.minimumBet }
    /// Offered once the player can no longer cover the minimum bet.
    var canResetBankroll: Bool { chips < Self.minimumBet }

    // MARK: - Betting

    func increaseBet() {
        guard canIncreaseBet else { return }
        currentBet += Self.betStep
    }

    func decreaseBet() {
        guard canDecreaseBet else { return }
        currentBet -= Self.betStep
    }

    /// Refills the bankroll once the player can't afford the minimum bet.
    func resetBankroll() {
        guard canResetBankroll else { return }
        chips = Self.startingChips
        currentBet = Self.minimumBet
    }

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

    /// Chip profit/loss for a finished bet, excluding the returned stake.
    /// Blackjack pays 3:2, a normal win or dealer bust pays 1:1, a push
    /// returns the stake with no profit, and any loss forfeits it.
    static func payoutDelta(for outcome: GameResult, bet: Int) -> Int {
        switch outcome {
        case .playerBlackjack: return bet * 3 / 2
        case .playerWin, .dealerBust: return bet
        case .push: return 0
        case .dealerBlackjack, .dealerWin, .playerBust: return -bet
        }
    }

    // MARK: - Round lifecycle

    /// Begins a new round: places the bet, clears hands, reshuffles if
    /// needed, deals four cards, and checks for an immediate Blackjack.
    func startNewRound() async {
        guard canStartNewRound, chips >= currentBet else { return }

        gameState = .dealing
        result = nil
        lastPayoutDelta = 0
        playerHand = []
        dealerHand = []
        dealerCardHidden = true
        activeBet = currentBet
        chips -= activeBet
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

    /// Doubles the bet, takes exactly one more card, then forces a stand —
    /// only available on the original two-card hand.
    func doubleDown() async {
        guard canDoubleDown else { return }

        chips -= activeBet
        activeBet *= 2

        await dealCard(to: .player)

        if playerScore > 21 {
            await finishRound(with: .playerBust)
        } else {
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

        let delta = Self.payoutDelta(for: outcome, bet: activeBet)
        lastPayoutDelta = delta
        chips += activeBet + delta
        // Keep the next bet affordable even after a loss shrinks the bankroll.
        currentBet = min(currentBet, chips)

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
