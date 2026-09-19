import SwiftUI

/// Overlay shown when a round finishes: big result text with a matching
/// animation, plus the button to start the next round. The text itself
/// always states the outcome so meaning is never carried by colour alone.
struct GameResultView: View {
    let result: GameResult
    let onNewRound: () -> Void

    @State private var scale: CGFloat = 0.6
    @State private var shakeProgress: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 24) {
            Text(result.title)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(result.tint)
                .shadow(color: result.tint.opacity(result.isPlayerFavourable ? 0.8 : 0), radius: 14)
                .scaleEffect(scale)
                .modifier(ShakeEffect(travel: result.isPlayerUnfavourable ? 8 : 0, progress: shakeProgress))

            Button(action: onNewRound) {
                Text("New Round")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 24)
        .onAppear { animateIn() }
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
        GameResultView(result: .playerBlackjack, onNewRound: {})
    }
}
