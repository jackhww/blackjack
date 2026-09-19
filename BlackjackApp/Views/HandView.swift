import SwiftUI

/// Displays one hand of cards (player or dealer) with a title and score.
struct HandView: View {
    let title: String
    let cards: [Card]
    let faceUpFlags: [Bool]
    let scoreText: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))

            HStack(spacing: 8) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    DealtCardView(
                        card: card,
                        isFaceUp: index < faceUpFlags.count ? faceUpFlags[index] : true
                    )
                }
            }
            .frame(minHeight: 92)

            Text(scoreText)
                .font(.headline)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    HandView(
        title: "Dealer",
        cards: [Card(suit: .clubs, rank: .king), Card(suit: .hearts, rank: .seven)],
        faceUpFlags: [true, false],
        scoreText: "Dealer: 10"
    )
    .padding()
    .background(Color.green.opacity(0.4))
}
