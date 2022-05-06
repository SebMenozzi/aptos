import UIKit
import AudioToolbox.AudioServices

enum TapticSound: SystemSoundID {
    case peek = 1519
    case pop = 1520
    case cancelled = 1521
    case tryAgain = 1102
    case failed = 1107

    init?(withHapticType hapticType: HapticType) {
        switch hapticType {
        case .impactLight, .impactMedium, .selection:
            self = .peek
        case .impactHeavy:
            self = .pop
        case .notificationError:
            self = .cancelled
        case .notificationWarning:
            self = .failed
        case .notificationSuccess:
            self = .tryAgain
        case .blank:
            return nil
        }
    }
}

public enum HapticType {
    case notificationSuccess
    case notificationWarning
    case notificationError
    case impactLight
    case impactMedium
    case impactHeavy
    case selection
    case blank
}

public struct HapticSequenceStep {
    let type: HapticType
    let duration: TimeInterval
    let repeatTime: TimeInterval

    public init(type: HapticType, duration: TimeInterval, repeatTime: TimeInterval) {
        self.type = type
        self.duration = duration
        self.repeatTime = repeatTime
    }

    public static let defaultHapticDuration: TimeInterval = 0.01

    public static func blankStep(withDuration duration: TimeInterval) -> HapticSequenceStep {
        return oneOffStep(ofType: .blank, withDuration: duration)
    }

    public static func oneOffStep(ofType type: HapticType, withDuration duration: TimeInterval = defaultHapticDuration) -> HapticSequenceStep {
        return HapticSequenceStep(type: type, duration: duration, repeatTime: duration)
    }

    public static func step(ammongTypes types: [HapticType], withDuration duration: TimeInterval = defaultHapticDuration, repeatTime: TimeInterval? = nil) -> HapticSequenceStep {
        return HapticSequenceStep(type: types.randomElement()!, duration: duration, repeatTime: repeatTime ?? duration)
    }
}

struct FeedbackGenerator {
    private var notificationStorage: Any?
    private var impactStorage: (light: Any, medium: Any, heavy: Any)?
    private var selectionStorage: Any?

    init() {
        notificationStorage = UINotificationFeedbackGenerator()
        impactStorage = (light: UIImpactFeedbackGenerator(style: .light), medium: UIImpactFeedbackGenerator(style: .medium), heavy: UIImpactFeedbackGenerator(style: .heavy))
        selectionStorage = UISelectionFeedbackGenerator()
    }

    func prepare() {
        notification?.prepare()
        impact?.light.prepare()
        impact?.medium.prepare()
        impact?.heavy.prepare()
        selection?.prepare()
    }

    var notification: UINotificationFeedbackGenerator? {
        return notificationStorage as? UINotificationFeedbackGenerator
    }

    var impact: (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator)? {
        return impactStorage as? (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator)
    }

    var selection: UISelectionFeedbackGenerator? {
        return selectionStorage as? UISelectionFeedbackGenerator
    }
}

public class HapticPlayer {
    private let feedbackGenerator: FeedbackGenerator = FeedbackGenerator()

    private var sequenceTimer: Timer?
    private var sequenceRepeatCount: Int = 0
    private var sequenceRequiredRepeatCount: Int = 0

    private var currentSequence: [HapticSequenceStep]?
    private var sequenceStep: Int = -1

    let currentHapticEngine = UIDevice.current.hapticEngine

    public init() {}

    public func prepare() {
        feedbackGenerator.prepare()
    }

    public func cancelSequence() {
        currentSequence = nil
        sequenceTimer?.invalidate()
        sequenceTimer = nil
    }

    public func playHapticSequence(_ sequence: [HapticSequenceStep]) {
        guard currentHapticEngine != .none else {
            return
        }
        currentSequence = sequence
        sequenceStep = -1
        playNextStep()
    }

    public func playRepetitiveHaptic(_ haptic: HapticType, count: Int, interval: TimeInterval, vibrationFallback: Bool = false) {
        guard  UIDevice.current.hapticEngine.canPerformRepetitiveHaptic else {
            playHaptic(haptic, vibrationFallback: vibrationFallback)
            return
        }

        var sequence: [HapticSequenceStep] = []

        for i in 0 ..< count {
            if i > 0 {
                sequence.append(HapticSequenceStep.blankStep(withDuration: interval))
            }

            sequence.append(HapticSequenceStep.oneOffStep(ofType: haptic))
        }

        playHapticSequence(sequence)
    }

    public func playHaptic(_ haptic: HapticType, vibrationFallback: Bool = false) {
        DispatchQueue.main.async {
            if self.currentHapticEngine == .secondGeneration {
                self.generateFeedback(forHapticType: haptic)
            } else if self.currentHapticEngine == .firstGeneration {
                self.playTapticSound(forHapticType: haptic)
            } else if vibrationFallback {
                self.playVibrationSound()
            }
        }
    }

    private func generateFeedback(forHapticType hapticType: HapticType) {
        switch hapticType {
        case .notificationSuccess:
            feedbackGenerator.notification?.notificationOccurred(.success)
        case .notificationWarning:
            feedbackGenerator.notification?.notificationOccurred(.warning)
        case .notificationError:
            feedbackGenerator.notification?.notificationOccurred(.error)
        case .impactLight:
            feedbackGenerator.impact?.light.impactOccurred()
        case .impactMedium:
            feedbackGenerator.impact?.medium.impactOccurred()
        case .impactHeavy:
            feedbackGenerator.impact?.heavy.impactOccurred()
        case .selection:
            feedbackGenerator.selection?.selectionChanged()
        case .blank:
            break
        }
    }

    private func playTapticSound(forHapticType hapticType: HapticType) {
        guard let tapticSoundID = TapticSound(withHapticType: hapticType)?.rawValue else {
            return
        }

        AudioServicesPlaySystemSound(tapticSoundID)
    }

    private func playVibrationSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    private func playNextStep() {
        guard let currentSequence = currentSequence, sequenceStep + 1 < currentSequence.count else {
            self.currentSequence = nil
            return
        }

        sequenceStep += 1

        playHapticSequenceStep(currentSequence[sequenceStep])
    }

    private func playHapticSequenceStep(_ sequenceStep: HapticSequenceStep) {

        sequenceRequiredRepeatCount = Int(sequenceStep.duration / sequenceStep.repeatTime)
        sequenceRepeatCount = 0
        sequenceTimer = Timer.scheduledTimer(timeInterval: sequenceStep.repeatTime, target: self, selector: #selector(playHapticSequenceStep(sender:)), userInfo: sequenceStep.type, repeats: true)
    }

    @objc private func playHapticSequenceStep(sender: Timer) {
        guard let haptic = sender.userInfo as? HapticType, sequenceRepeatCount < sequenceRequiredRepeatCount else {
            sender.invalidate()
            playNextStep()
            return
        }

        sequenceRepeatCount += 1
        playHaptic(haptic)
    }
}
