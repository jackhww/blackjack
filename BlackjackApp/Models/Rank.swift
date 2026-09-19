import Foundation

/// The thirteen ranks of a standard card deck, ordered 2 through Ace.
enum Rank: Int, CaseIterable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace

    /// Short label shown on a card face, e.g. "A", "10", "K".
    var label: String {
        switch self {
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        default: return "\(rawValue)"
        }
    }

    /// Blackjack value before Ace soft/hard adjustment (Ace starts as 11).
    var baseValue: Int {
        switch self {
        case .jack, .queen, .king: return 10
        case .ace: return 11
        default: return rawValue
        }
    }

    var isAce: Bool { self == .ace }
}
