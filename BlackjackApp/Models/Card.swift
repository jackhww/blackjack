import Foundation

/// A single playing card: one suit paired with one rank.
struct Card: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
}

/// Factory for creating and shuffling a standard 52-card deck.
enum Deck {
    /// Builds a fresh 52-card deck and shuffles it using Swift's
    /// built-in randomisation.
    static func newShuffled() -> [Card] {
        var cards: [Card] = []
        cards.reserveCapacity(52)
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        cards.shuffle()
        return cards
    }
}
