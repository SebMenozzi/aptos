import Foundation

extension Comparable {
    func clamped(betweenMinValue minValue: Self, maxValue: Self) -> Self {
        guard minValue < maxValue else { return self }

        return clamped(within: minValue...maxValue)
    }

    func clamped(within range: ClosedRange<Self>) -> Self {
        guard !range.contains(self) else { return self }

        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Double {
    var toTimeString: String {
        let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
        let minutes: Int = Int(self / 60.0)
        return String(format: "%d:%02d", minutes, seconds)
    }
}
