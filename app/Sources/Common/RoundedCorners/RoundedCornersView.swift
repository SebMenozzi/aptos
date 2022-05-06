import UIKit

open class RoundedCornersView: UIView {
    public enum Sides {
        case top
        case left
        case right
        case bottom
        case all

        var cornerMask: CACornerMask {
            switch self {
            case .top: return [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            case .left: return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            case .right: return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            case .bottom: return [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            case .all: return [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            }
        }
    }

    open var isShadowPathEnabled: Bool = false

    open var cornerRadius: CGFloat? {
        didSet {
            geometryDidChange()
        }
    }

    public var sides: Sides {
        didSet {
            layer.maskedCorners = sides.cornerMask
        }
    }

    // Currently unused
    public var colorBehind: UIColor?

    private let borderColor: UIColor?

    private let defaultRadiusRatio: CGFloat = 0.5
    private let fullyRoundedCorners: Bool

    private func defaultCornerRadius() -> CGFloat {
        let radiusRatio = fullyRoundedCorners ? 0.5 : defaultRadiusRatio
        return radiusRatio * min(bounds.height, bounds.width)
    }

    private var previousSize: CGSize = .zero

    public convenience init() {
        self.init(backgroundColor: .clear)
    }

    public init(frame: CGRect = .zero,
                colorBehind: UIColor,
                backgroundColor: UIColor?,
                borderColor: UIColor? = nil,
                cornerRadius: CGFloat? = nil,
                fullyRoundedCorners: Bool = false,
                sides: Sides = .all) {
        self.sides = sides
        self.borderColor = borderColor
        self.fullyRoundedCorners = fullyRoundedCorners
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.layer.maskedCorners = sides.cornerMask
        self.setupBorder()
        self.isUserInteractionEnabled = false
    }

    public init(frame: CGRect = .zero,
                backgroundColor: UIColor,
                borderColor: UIColor? = nil,
                cornerRadius: CGFloat? = nil,
                fullyRoundedCorners: Bool = false,
                sides: Sides = .all) {
        self.sides = sides
        self.borderColor = borderColor
        self.fullyRoundedCorners = fullyRoundedCorners
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.layer.maskedCorners = sides.cornerMask
        self.setupBorder()
        self.isUserInteractionEnabled = false
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if !previousSize.equalTo(bounds.size) {
            previousSize = bounds.size

            geometryDidChange()
        }
    }

    private func setupBorder() {
        if let borderColor = borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
        }
    }

    private func geometryDidChange() {
        layer.cornerRadius = cornerRadius ?? defaultCornerRadius()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
