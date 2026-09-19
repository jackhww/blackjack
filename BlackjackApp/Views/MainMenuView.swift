import SwiftUI

/// Entry point of the app: title, brief pitch, and the two ways in.
struct MainMenuView: View {
    @State private var showRules = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.28, blue: 0.14), Color(red: 0.01, green: 0.12, blue: 0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 10) {
                    Text("♠ ♥ ♣ ♦")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Blackjack")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Try to reach 21 without going over.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                VStack(spacing: 16) {
                    NavigationLink {
                        BlackjackTableView()
                    } label: {
                        Text("Play")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundStyle(Color(red: 0.02, green: 0.28, blue: 0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        showRules = true
                    } label: {
                        Text("How to Play")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
    }
}

#Preview {
    NavigationStack {
        MainMenuView()
    }
}
