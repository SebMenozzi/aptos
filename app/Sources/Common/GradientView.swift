import UIKit

class GradientView: UIView {
    open var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    public override static var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public init(colors: [UIColor] = [], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        super.init(frame: .zero)

        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    public func updateColors(_ colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
