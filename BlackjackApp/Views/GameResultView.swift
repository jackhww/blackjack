import SwiftUI

/// Inline result banner shown in place of the status text once a round
/// ends. This is deliberately not a modal/overlay — it sits in the table's
/// normal layout flow so Hit/Stand/New Round controls never move or get
/// covered. The text itself always states the outcome so meaning is never
/// carried by colour alone.
struct GameResultView: View {
    let result: GameResult
    let payoutDelta: Int

    @State private var scale: CGFloat = 0.6
    @State private var shakeProgress: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 2) {
            Text(result.title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(result.tint)
                .shadow(color: result.tint.opacity(result.isPlayerFavourable ? 0.7 : 0), radius: 10)
                .scaleEffect(scale)
                .modifier(ShakeEffect(travel: result.isPlayerUnfavourable ? 6 : 0, progress: shakeProgress))

            Text(payoutText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .onAppear { animateIn() }
    }

    private var payoutText: String {
        if payoutDelta > 0 { return "+\(payoutDelta) chips" }
        if payoutDelta < 0 { return "\(payoutDelta) chips" }
        return "Bet returned"
    }

    private func animateIn() {
        guard !reduceMotion else {
            scale = 1
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 1
        }
        if result.isPlayerUnfavourable {
            withAnimation(.linear(duration: 0.4)) {
                shakeProgress = 1
            }
        } else if result.isPlayerFavourable {
            withAnimation(.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true).delay(0.2)) {
                scale = 1.06
            }
        }
    }
}

/// Simple horizontal shake used for loss/bust feedback.
private struct ShakeEffect: GeometryEffect {
    var travel: CGFloat
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = travel * sin(progress * .pi * 6)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.5).ignoresSafeArea()
        GameResultView(result: .playerBlackjack, payoutDelta: 15)
    }
}
