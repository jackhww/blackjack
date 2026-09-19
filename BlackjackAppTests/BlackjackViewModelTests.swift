import Testing
@testable import BlackjackApp

/// Covers the scenarios called out in the assignment brief: Ace handling,
/// Blackjack/bust detection, winner determination, and dealer behaviour.
struct BlackjackViewModelTests {

    private func hand(_ cards: (Suit, Rank)...) -> [Card] {
        cards.map { Card(suit: $0.0, rank: $0.1) }
    }

    // MARK: - Ace handling

    @Test func aceAndNinePlaysAsTwenty() {
        let cards = hand((.spades, .ace), (.hearts, .nine))
        #expect(BlackjackViewModel.calculateHandValue(cards) == 20)
    }

    @Test func aceNineFiveDropsAceToOne() {
        let cards = hand((.spades, .ace), (.hearts, .nine), (.clubs, .five))
        #expect(BlackjackViewModel.calculateHandValue(cards) == 15)
    }

    @Test func twoAcesAndNineEqualsTwentyOne() {
        let cards = hand((.spades, .ace), (.hearts, .ace), (.clubs, .nine))
        #expect(BlackjackViewModel.calculateHandValue(cards) == 21)
    }

    // MARK: - Blackjack detection

    @Test func aceAndKingIsBlackjack() {
        let player = hand((.spades, .ace), (.hearts, .king))
        let dealer = hand((.clubs, .two), (.diamonds, .three))
        #expect(BlackjackViewModel.initialBlackjackOutcome(playerHand: player, dealerHand: dealer) == .playerBlackjack)
    }

    @Test func bothBlackjackIsPush() {
        let player = hand((.spades, .ace), (.hearts, .king))
        let dealer = hand((.clubs, .ace), (.diamonds, .queen))
        #expect(BlackjackViewModel.initialBlackjackOutcome(playerHand: player, dealerHand: dealer) == .push)
    }

    @Test func noBlackjackReturnsNil() {
        let player = hand((.spades, .nine), (.hearts, .king))
        let dealer = hand((.clubs, .two), (.diamonds, .three))
        #expect(BlackjackViewModel.initialBlackjackOutcome(playerHand: player, dealerHand: dealer) == nil)
    }

    // MARK: - Bust

    @Test func kingQueenTwoBusts() {
        let cards = hand((.spades, .king), (.hearts, .queen), (.clubs, .two))
        #expect(BlackjackViewModel.calculateHandValue(cards) == 22)
    }

    // MARK: - Winner evaluation

    @Test func higherPlayerScoreWins() {
        #expect(BlackjackViewModel.evaluateOutcome(playerScore: 20, dealerScore: 18) == .playerWin)
    }

    @Test func dealerBustMeansPlayerWins() {
        #expect(BlackjackViewModel.evaluateOutcome(playerScore: 18, dealerScore: 23) == .dealerBust)
    }

    @Test func equalScoresArePush() {
        #expect(BlackjackViewModel.evaluateOutcome(playerScore: 18, dealerScore: 18) == .push)
    }

    @Test func playerBustLosesEvenIfDealerAlsoHigh() {
        #expect(BlackjackViewModel.evaluateOutcome(playerScore: 24, dealerScore: 18) == .playerBust)
    }

    // MARK: - Dealer behaviour

    @Test func dealerMustHitOnSixteen() {
        #expect(BlackjackViewModel.dealerShouldHit(score: 16) == true)
    }

    @Test func dealerMustStandOnSeventeen() {
        #expect(BlackjackViewModel.dealerShouldHit(score: 17) == false)
    }

    // MARK: - Deck

    @Test func freshDeckHasFiftyTwoUniqueCards() {
        let deck = Deck.newShuffled()
        #expect(deck.count == 52)
        let uniqueCombinations = Set(deck.map { "\($0.suit.rawValue)-\($0.rank.rawValue)" })
        #expect(uniqueCombinations.count == 52)
    }
}
