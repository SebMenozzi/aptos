import UIKit

open class MaskedSmoothCornersView: UIView {
    private var lastComputedBounds: CGRect = .zero
    private let maskLayer: SmoothRectLayer

    public var customRadii: Corners? {
        get {
            return maskLayer.customRadii
        }
        set {
            maskLayer.customRadii = newValue
        }
    }

    public override init(frame: CGRect) {
        maskLayer = SmoothRectLayer()

        super.init(frame: frame)

        lastComputedBounds = bounds
        maskLayer.frame = bounds
        layer.mask = maskLayer
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if bounds != lastComputedBounds {
            maskLayer.frame = bounds
            lastComputedBounds = bounds
        }
    }
}
