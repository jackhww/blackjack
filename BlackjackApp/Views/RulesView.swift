import SwiftUI

/// Short, plain-language rules and the gesture cheat sheet. Presented as a
/// sheet from both the Main Menu and a long press on the table.
struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Goal") {
                    Text("Get closer to 21 than the dealer, without going over.")
                }

                Section("Card Values") {
                    Label("Number cards = face value", systemImage: "number")
                    Label("Jack, Queen, King = 10", systemImage: "person.fill")
                    Label("Ace = 1 or 11, whichever helps more", systemImage: "a.circle")
                }

                Section("Gameplay") {
                    Text("1. You and the dealer each get two cards. One dealer card stays hidden.")
                    Text("2. Hit to take another card.")
                    Text("3. Stand to keep your current hand.")
                    Text("4. Double Down: on your first two cards, double your bet to take exactly one more card, then automatically stand.")
                    Text("5. The dealer must keep drawing until reaching at least 17.")
                    Text("6. Going over 21 is a bust and loses the round.")
                }

                Section("Wagers") {
                    Text("Adjust your bet before dealing. Blackjack pays 3:2, a win pays 1:1, and a push returns your bet.")
                }

                Section("Controls") {
                    Label("Swipe up — Hit", systemImage: "arrow.up")
                    Label("Swipe down — Stand", systemImage: "arrow.down")
                    Label("Double tap — Deal again", systemImage: "hand.tap")
                    Label("Long press — Show these rules", systemImage: "hand.point.up.left")
                    Text("Every gesture has a matching on-screen button too.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    RulesView()
}
