import AVFoundation

/// Every sound effect the game can play. The filename must match a resource
/// bundled under Resources.
enum SoundEffect: String {
    case cardDeal = "card_deal"
    case cardFlip = "card_flip"
    case button = "button_tap"
    case win = "win"
    case lose = "lose"
}

/// Tiny wrapper around AVAudioPlayer so sound playback stays completely
/// isolated from the game logic. A missing or unplayable sound file is
/// swallowed silently — audio must never crash the game.
final class AudioManager {
    static let shared = AudioManager()

    private var players: [SoundEffect: AVAudioPlayer] = [:]

    private init() {}

    func play(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            players[sound] = player
        } catch {
            print("AudioManager: could not play \(sound.rawValue) — \(error.localizedDescription)")
        }
    }
}
