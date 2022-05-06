import UIKit

public final class SmoothRectLayer: CAShapeLayer {

    public var customRadii: Corners? = nil {
        didSet {
            if customRadii != oldValue {
                updatePath()
            }
        }
    }

    override public var bounds: CGRect {
        didSet {
            if bounds != oldValue {
                updatePath()
            }
        }
    }

    private func updatePath() {
        if bounds != .zero {
            CALayer.performWithoutAnimations() {
                path = UIBezierPath.smoothRect(in: bounds, cornerRadii: customRadii).cgPath
            }
        }
    }
}
