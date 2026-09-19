import SwiftUI

/// Shows the player's chip balance and lets them adjust their bet before a
/// round starts. Locks to a plain "Bet: N" label once a round is underway.
struct BetControlsView: View {
    let chips: Int
    let bet: Int
    let canAdjust: Bool
    let canIncrease: Bool
    let canDecrease: Bool
    let canReset: Bool
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack {
            Text("Chips: \(chips)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            if canReset {
                Button("Reset Bankroll", action: onReset)
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.bordered)
                    .tint(.white)
            } else if canAdjust {
                HStack(spacing: 10) {
                    stepButton(systemImage: "minus.circle.fill", action: onDecrease, enabled: canDecrease)
                    Text("Bet: \(bet)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 70)
                    stepButton(systemImage: "plus.circle.fill", action: onIncrease, enabled: canIncrease)
                }
            } else {
                Text("Bet: \(bet)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void, enabled: Bool) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 26))
        }
        .foregroundStyle(.white)
        .opacity(enabled ? 1 : 0.3)
        .disabled(!enabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        BetControlsView(
            chips: 500, bet: 20, canAdjust: true, canIncrease: true, canDecrease: true, canReset: false,
            onIncrease: {}, onDecrease: {}, onReset: {}
        )
        BetControlsView(
            chips: 0, bet: 10, canAdjust: true, canIncrease: false, canDecrease: false, canReset: true,
            onIncrease: {}, onDecrease: {}, onReset: {}
        )
    }
    .padding()
    .background(Color.green.opacity(0.4))
}
