import UIKit
import AudioToolbox
import AVFoundation

public final class SoundPlayer {
    public static let shared = SoundPlayer()

    private lazy var soundPlayerQueue: DispatchQueue = DispatchQueue(label: "co.discoapp.SoundPlayerQueue")
    private lazy var soundEffects: [Sound: SystemSoundID] = [:]
    private lazy var mediaPlayers: [Sound: AVAudioPlayer] = [:]

    public private(set) lazy var hapticPlayer = HapticPlayer()

    public var globalSessionEnabled: Bool = true {
        didSet {
            if globalSessionEnabled {
                configureSession()
            }
        }
    }

    private init() {
        _ = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.releaseSoundEffects()
            self?.releaseMediaSounds()
        })

        _ = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.configureSession()
        })

        configureSession()
    }

    public func playSoundEffect(_ sound: Sound) {
        soundPlayerQueue.async { [weak self] in
            guard let soundID = self?.soundEffects[sound] ?? self?.createSoundID(sound: sound) else {
                return
            }

            AudioServicesPlaySystemSoundWithCompletion(soundID) {}
        }
    }

    public func playMedia(_ sound: Sound) {
        soundPlayerQueue.async { [weak self] in
            guard let player = self?.mediaPlayers[sound] ?? self?.createMediaSound(sound: sound) else {
                return
            }

            if player.isPlaying {
                player.currentTime = 0
            } else {
                player.play()
            }
        }
    }
}

private extension SoundPlayer {
    func configureSession() {
        guard globalSessionEnabled else { return }
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.ambient, mode: .default)
            try audioSession.setActive(true)
        } catch let error {
            print("Failed to configure audio session", error.localizedDescription)
        }
    }

    func createSoundID(sound: Sound) -> SystemSoundID? {
        guard let url = sound.url else {
            return nil
        }

        var soundID: SystemSoundID = 0

        let errorCode = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)

        if errorCode != kAudioServicesNoError {
            print("Failed to create system sound", sound.url ?? "", url, errorCode)
            return nil
        }

        soundEffects[sound] = soundID

        return soundID
    }

    func releaseSoundEffects() {
        for (sound, soundID) in soundEffects {
            let errorCode = AudioServicesDisposeSystemSoundID(soundID)

            if errorCode != kAudioServicesNoError {
                print("Failed to dispose of system sound", sound.url ?? "", soundID, errorCode)
            }
        }

        soundEffects.removeAll()
    }

    func createMediaSound(sound: Sound) -> AVAudioPlayer? {
        guard let url = sound.url else {
            return nil
        }

        let player: AVAudioPlayer?
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print("Failed to create audio player from url", url, error)
            player = nil
        }

        mediaPlayers[sound] = player

        return player
    }

    func releaseMediaSounds() {
        mediaPlayers.removeAll()
    }
}

extension SoundPlayer {
    func play(haptic: HapticFeedback) {
        guard let hapticType = haptic.instensity.hapticType else {
            return
        }

        if haptic.occurences > 1 {
            hapticPlayer.playRepetitiveHaptic(hapticType, count: haptic.occurences, interval: 0.05, vibrationFallback: haptic.vibrationFallback)
        } else {
            hapticPlayer.playHaptic(hapticType, vibrationFallback: haptic.vibrationFallback)
        }
    }
}
