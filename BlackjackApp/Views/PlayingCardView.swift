import SwiftUI

/// Renders a single playing card face-up (rank, suit symbol twice) or
/// face-down (a simple patterned back), built entirely from native SwiftUI
/// shapes so no external image assets are required.
struct PlayingCardView: View {
    let card: Card
    var isFaceUp: Bool = true

    private let cardSize = CGSize(width: 64, height: 92)

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(width: cardSize.width, height: cardSize.height)
            .overlay {
                if isFaceUp {
                    faceContent
                } else {
                    backContent
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.black.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
            .accessibilityLabel(isFaceUp ? "\(card.rank.label) of \(card.suit.rawValue)" : "Face-down card")
    }

    private var faceContent: some View {
        VStack {
            HStack {
                cornerLabel
                Spacer()
            }
            Spacer()
            Text(card.suit.symbol)
                .font(.system(size: 26))
            Spacer()
            HStack {
                Spacer()
                cornerLabel.rotationEffect(.degrees(180))
            }
        }
        .padding(6)
        .foregroundStyle(card.suit.color)
    }

    private var cornerLabel: some View {
        VStack(spacing: 0) {
            Text(card.rank.label).font(.system(size: 15, weight: .bold))
            Text(card.suit.symbol).font(.system(size: 12))
        }
    }

    private var backContent: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(
                LinearGradient(
                    colors: [Color.blue, Color.indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .strokeBorder(Color.white.opacity(0.7), lineWidth: 2)
            )
            .padding(5)
    }
}

/// Wraps a card so it can flip between face-down and face-up with a 3D
/// rotation, used for the dealer's hole card.
struct FlipCardView: View {
    let card: Card
    let isFaceUp: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            PlayingCardView(card: card, isFaceUp: false)
                .opacity(isFaceUp ? 0 : 1)
                .rotation3DEffect(.degrees(isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            PlayingCardView(card: card, isFaceUp: true)
                .opacity(isFaceUp ? 1 : 0)
                .rotation3DEffect(.degrees(isFaceUp ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: isFaceUp)
    }
}

/// Animates a card sliding/scaling/fading in as it is dealt into a hand.
struct DealtCardView: View {
    let card: Card
    let isFaceUp: Bool

    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        FlipCardView(card: card, isFaceUp: isFaceUp)
            .scaleEffect(hasAppeared ? 1 : 0.7)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : -80)
            .onAppear {
                if reduceMotion {
                    hasAppeared = true
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        hasAppeared = true
                    }
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        PlayingCardView(card: Card(suit: .spades, rank: .ace))
        PlayingCardView(card: Card(suit: .hearts, rank: .king), isFaceUp: false)
    }
    .padding()
    .background(Color.green.opacity(0.3))
}
