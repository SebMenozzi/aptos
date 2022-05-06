import UIKit

open class BouncingButton: UIButton {
    open override var isEnabled: Bool {
        didSet {
            isUserInteractionEnabled = isEnabled
            alpha = isEnabled ? 1.0 : 0.4
        }
    }

    public enum ScaleDirection {
        case down, up
    }

    private static let idleTransform: CGAffineTransform = .identity
    private static let backToIdleTiming = UISpringTimingParameters(dampingRatio: 0.4)

    private var highlightedTransform: CGAffineTransform = .identity

    private let backToIdleAnimator = UIViewPropertyAnimator(
        duration: 0.2,
        timingParameters: BouncingButton.backToIdleTiming
    )

    private(set) var scaleDirection: ScaleDirection = .down {
        didSet {
            if scaleDirection != oldValue {
                updateDirection(to: scaleDirection, scaleDifference: scaleDifference)
            }
        }
    }

    public var scaleDifference: CGFloat = 0.05

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    open func setup() {
        adjustsImageWhenHighlighted = false
        isExclusiveTouch = true
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateHighlightedTransform(scaleDirection: scaleDirection, scaleDifference: scaleDifference)
    }

    // MARK: Touch handling

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown()
        super.touchesBegan(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchUp()
        super.touchesEnded(touches, with: event)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchUp()
        super.touchesCancelled(touches, with: event)
    }

    // MARK: State animation

    open func touchDown() {
        backToIdleAnimator.stopAnimation(true)
        transform = highlightedTransform
    }

    open func touchUp() {
        backToIdleAnimator.addAnimations {
            self.transform = BouncingButton.idleTransform
        }

        backToIdleAnimator.startAnimation()
    }
}

private extension BouncingButton {
    
    static func computeHighlightedTransform(forSize size: CGSize, scaleDirection: ScaleDirection, scaleDifference: CGFloat) -> CGAffineTransform {
        let coeff: CGFloat

        switch scaleDirection {
        case .up: coeff = 1
        case .down: coeff = -1
        }

        let newScale = 1 + scaleDifference * coeff
        return CGAffineTransform(scaleX: newScale, y: newScale)
    }

    func updateDirection(to newScaleDirection: ScaleDirection, scaleDifference: CGFloat) {
        updateHighlightedTransform(scaleDirection: newScaleDirection, scaleDifference: scaleDifference)
    }

    func updateHighlightedTransform(scaleDirection: ScaleDirection, scaleDifference: CGFloat) {
        highlightedTransform = BouncingButton.computeHighlightedTransform(
            forSize: bounds.size,
            scaleDirection: scaleDirection,
            scaleDifference: scaleDifference
        )
    }
}
