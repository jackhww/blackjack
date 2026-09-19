import SwiftUI

/// The four suits of a standard 52-card deck.
enum Suit: String, CaseIterable, Identifiable {
    case hearts
    case diamonds
    case clubs
    case spades

    var id: String { rawValue }

    /// The unicode symbol used to render this suit on a card face.
    var symbol: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }

    /// Hearts and diamonds are drawn in red, clubs and spades in black.
    var isRed: Bool {
        self == .hearts || self == .diamonds
    }

    var color: Color {
        isRed ? .red : .black
    }
}
