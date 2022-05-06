import UIKit.UIDevice

extension UIDevice {
    enum HapticEngine {
        case none
        case firstGeneration
        case secondGeneration

        var canPerformRepetitiveHaptic: Bool { return self != .none }
    }

    var hapticEngine: HapticEngine {
        guard let phoneGeneration = phoneGeneration else {
            return .none
        }

        switch phoneGeneration {
        case 8..<9:
            return UIScreen.main.traitCollection.forceTouchCapability == .available ? .firstGeneration : .none
        case 9...Int.max:
            return .secondGeneration
        default:
            return .none
        }
    }
}
