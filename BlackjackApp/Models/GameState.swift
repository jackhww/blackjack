import Foundation

/// The lifecycle of a single round, used instead of loose booleans so the
/// table view always knows exactly what stage the game is in.
enum GameState: Equatable {
    case ready
    case dealing
    case playerTurn
    case dealerTurn
    case finished
}
