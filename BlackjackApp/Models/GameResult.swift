import SwiftUI

/// Every possible outcome of a completed round.
enum GameResult: Equatable {
    case playerBlackjack
    case dealerBlackjack
    case playerWin
    case dealerWin
    case playerBust
    case dealerBust
    case push

    /// Headline text shown on the result overlay.
    var title: String {
        switch self {
        case .playerBlackjack: return "BLACKJACK!"
        case .dealerBlackjack: return "DEALER BLACKJACK"
        case .playerWin: return "YOU WIN!"
        case .dealerWin: return "DEALER WINS"
        case .playerBust: return "BUST!"
        case .dealerBust: return "DEALER BUSTS — YOU WIN!"
        case .push: return "PUSH"
        }
    }

    /// Colour used for the result text and glow. Text itself always carries
    /// the meaning too, so colour is never the only signal.
    var tint: Color {
        switch self {
        case .playerBlackjack, .playerWin, .dealerBust:
            return .green
        case .dealerBlackjack, .dealerWin, .playerBust:
            return .red
        case .push:
            return .yellow
        }
    }

    var isPlayerFavourable: Bool {
        switch self {
        case .playerBlackjack, .playerWin, .dealerBust: return true
        default: return false
        }
    }

    var isPlayerUnfavourable: Bool {
        switch self {
        case .dealerBlackjack, .dealerWin, .playerBust: return true
        default: return false
        }
    }
}
