import Foundation

enum FeedbackIntensity {
    case light
    case medium
    case none
    case heavy

    var hapticType: HapticType? {
        switch self {
        case .light:
            return .selection
        case .medium:
            return .impactMedium
        case .heavy:
            return .impactHeavy
        default:
            return nil
        }
    }
}

struct HapticFeedback {
    let instensity: FeedbackIntensity
    let occurences: Int
    let vibrationFallback: Bool
}

class HapticFeedbackBuilder {
    private var instensity: FeedbackIntensity
    private var occurences: Int = 1
    private var vibrationFallback: Bool = false

    init(_ intensity: FeedbackIntensity) {
        self.instensity = intensity
    }

    @discardableResult
    func with(occurences: Int) -> HapticFeedbackBuilder {
        self.occurences = occurences

        return self
    }

    @discardableResult
    func with(vibrationFallback: Bool) -> HapticFeedbackBuilder {
        self.vibrationFallback = vibrationFallback

        return self
    }

    func build() -> HapticFeedback {
        return HapticFeedback(instensity: instensity, occurences: occurences, vibrationFallback: vibrationFallback)
    }
}
