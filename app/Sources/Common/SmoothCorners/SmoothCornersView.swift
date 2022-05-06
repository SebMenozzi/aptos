import UIKit

/// An optimized class designed to draw a plain color _smooth rectangle_
///
/// Attention: Switching modes between "draw outside corners" and "draw inside" on an existing instance is currently not supported.
open class SmoothCornersView: UIView {

    public enum Sides {
        case top
        case left
        case right
        case bottom
        case all
    }

    private let sides: Sides
    private var previousSize: CGSize = .zero
    private var currentImage: UIImage?
    private var replicators: [CAReplicatorLayer] = []
    private let cornerLayer = CALayer()
    private var overlayMode: Bool
    private var backgroundLayerCenterW: CALayer?
    private var backgroundLayerCenterH: CALayer?
    private var backgroundLayerExtraForAlpha: CALayer?
    private var isColorOpaque = true

    open var isShadowPathEnabled: Bool = false {
        didSet {
            if !isShadowPathEnabled {
                layer.shadowPath = nil
            } else if oldValue {
                geometryDidChange()
            }
        }
    }

    /// The radius to use for the smooth corners
    ///
    /// When `nil`, applies the default corner radius ratio rule.
    open var cornerRadius: CGFloat? {
        didSet {
            geometryDidChange()
        }
    }

    override open var backgroundColor: UIColor? {
        set {
            fillColor = newValue
        }
        get {
            return fillColor
        }
    }

    /// The plain color to draw inside the _smooth rectangle_
    private var fillColor: UIColor? {
        didSet {
            colorsDidChange()
        }
    }

    /// The color to draw behind the corners. _Can't be a translucent or clear color._
    ///
    /// If the smooth rect is drawn over a solid opaque color, using
    /// `colorBehind` greatly improves drawing performance.
    open var colorBehind: UIColor? {
        didSet {
            assert(colorBehind?.isOpaque ?? true, "ColorBehind must be opaque")

            if (oldValue == nil && colorBehind != nil) || (oldValue != nil && colorBehind == nil) {
                setupLayers()
            }
            colorsDidChange()
        }
    }

    private var drawsOnlyCorners: Bool {
        return colorBehind != nil
    }

    private func colorsDidChange() {
        CALayer.performWithoutAnimations {
            updateColorOpaque()
            updateIsOpaque()
            updateBackgroundColor()
            recomputeImage()
        }
    }

    private func updateColorOpaque() {
        let newOpaque = fillColor?.isOpaque ?? false

        if newOpaque != isColorOpaque {
            if newOpaque {
                backgroundLayerExtraForAlpha?.removeFromSuperlayer()
                backgroundLayerExtraForAlpha = nil
            } else {
                let extra = CALayer()
                backgroundLayerExtraForAlpha = extra
                layer.addSublayer(extra)
                extra.backgroundColor = fillColor?.cgColor
            }

            isColorOpaque = newOpaque
        }
    }

    private func updateIsOpaque() {
        isOpaque = colorBehind != nil && fillColor != nil && isColorOpaque
    }

    private func updateBackgroundColor() {
        if drawsOnlyCorners {
            super.backgroundColor = fillColor
        } else {
            super.backgroundColor = .clear

            backgroundLayerCenterW?.backgroundColor = fillColor?.cgColor
            backgroundLayerCenterH?.backgroundColor = fillColor?.cgColor
            backgroundLayerExtraForAlpha?.backgroundColor = fillColor?.cgColor
        }
    }

    override open class var layerClass: AnyClass {
        return CALayer.self
    }

    private func setupLayers() {
        setupBackgroundLayers()
        setupReplicators()
    }

    private func setupBackgroundLayers() {
        if !drawsOnlyCorners {
            let backgroundLayerCenterW = CALayer()
            backgroundLayerCenterW.backgroundColor = fillColor?.cgColor
            layer.addSublayer(backgroundLayerCenterW)
            self.backgroundLayerCenterW = backgroundLayerCenterW

            let backgroundLayerCenterH = CALayer()
            backgroundLayerCenterH.backgroundColor = fillColor?.cgColor
            layer.addSublayer(backgroundLayerCenterH)
            self.backgroundLayerCenterH = backgroundLayerCenterH

            updateColorOpaque()
        }
    }

    private func setupReplicators() {
        switch sides {
        case .all:
            replicators.append(CAReplicatorLayer())
            replicators.append(CAReplicatorLayer())
            replicators[0].addSublayer(replicators[1])
            replicators[1].instanceCount = 2
            replicators[1].addSublayer(cornerLayer)
            replicators[0].instanceCount = 2
        default:
            replicators.append(CAReplicatorLayer())
            replicators[0].addSublayer(cornerLayer)
            replicators[0].instanceCount = 2
        }

        self.layer.addSublayer(replicators[0])
    }

    public convenience init() {
        self.init(backgroundColor: .clear)
    }


    /// Returns a smooth rect for which the exterior of the corners are drawn using a solid color.
    ///
    /// - Parameters:
    ///   - colorBehind: The color to draw outside the corners. _Can't be a translucent or clear color._
    ///   - color: The color to draw inside the shape, `nil` means only the outside of the corners is drawn (to use as an overlay for example)
    ///   - cornerRadius: The radius to use for the smooth corners
    ///   - sides: The side that needs to be "cornered", defaults to `all`
    public init(frame: CGRect = .zero, colorBehind: UIColor, backgroundColor: UIColor?, cornerRadius: CGFloat? = nil, sides: Sides = .all) {
        assert(colorBehind.isOpaque, "ColorBehind must be opaque")

        self.overlayMode = true
        self.fillColor = backgroundColor
        self.sides = sides
        self.colorBehind = colorBehind
        self.cornerRadius = cornerRadius

        super.init(frame: frame)

        self.backgroundColor = backgroundColor
        self.isUserInteractionEnabled = false
        self.setupLayers()

        updateIsOpaque()
    }

    /// Returns a smooth rect for which the inside of the shape is drawn using a solid color.
    ///
    /// - Parameters:
    ///   - color: The color to draw inside the shape
    ///   - cornerRadius: The radius to use for the smooth corners
    ///   - sides: The side that needs to be "cornered", defaults to `all`
    public init(frame: CGRect = .zero, backgroundColor: UIColor, cornerRadius: CGFloat? = nil, sides: Sides = .all) {
        self.overlayMode = false
        self.fillColor = backgroundColor
        self.sides = sides

        super.init(frame: frame)

        self.cornerRadius = cornerRadius
        self.isUserInteractionEnabled = false
        self.setupLayers()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if !previousSize.equalTo(bounds.size) {
            previousSize = bounds.size

            geometryDidChange()
        }
    }

    private var path = UIBezierPath()
    private var cornerSize = CGSize.zero

    private func geometryDidChange() {
        CALayer.performWithoutAnimations {
            recomputePath()
            recomputeImage()
        }
    }

    private func recomputePath() {
        guard bounds.width != 0 && bounds.height != 0 else { return }

        let limit: CGPoint
        switch sides {
        case .bottom, .top: limit = CGPoint(x: 0.5, y: 1)
        case .left, .right: limit = CGPoint(x: 1, y: 0.5)
        case .all: limit = CGPoint(x: 0.5, y: 0.5)
        }

        let adjustedRadius = cornerRadius ?? bounds.size.defaultSmoothRectCornerRadii

        (path, cornerSize) = UIBezierPath.smoothRectTopLeft(in: CGRect.init(x: 0,
                                                                            y: 0,
                                                                            width: floor(bounds.width),
                                                                            height: floor(bounds.height)),
                                                            cornerRadii: adjustedRadius,
                                                            limit: limit,
                                                            reverted: overlayMode)
        if isShadowPathEnabled && !drawsOnlyCorners {
            let corners: Corners
            switch sides {
            case .all: corners = Corners(equalCorners: adjustedRadius)
            case .bottom: corners = Corners(topLeft: 0, topRight: 0, bottomLeft: adjustedRadius, bottomRight: adjustedRadius)
            case .top: corners = Corners(topLeft: adjustedRadius, topRight: adjustedRadius, bottomLeft: 0, bottomRight: 0)
            case .left: corners = Corners(topLeft: adjustedRadius, topRight: 0, bottomLeft: adjustedRadius, bottomRight: 0)
            case .right: corners = Corners(topLeft: 0, topRight: adjustedRadius, bottomLeft: 0, bottomRight: adjustedRadius)
            }
            layer.shadowPath = UIBezierPath.smoothRect(in: bounds, cornerRadii: corners).cgPath
        }
    }

    private func recomputeImage() {
        guard bounds.width != 0 && bounds.height != 0 else { return }

        var newGeneratedImage: UIImage?

        let rect = CGRect(x: 0, y: 0, width: cornerSize.width, height: cornerSize.height)
        UIGraphicsBeginImageContextWithOptions(cornerSize, colorBehind != nil && fillColor != nil, 0.0)

        let (colorA, colorB) = overlayMode ? (fillColor, colorBehind) : (colorBehind, fillColor)

        if let colorA = colorA {
            colorA.setFill()
            UIRectFill(rect)
        }

        if let colorB = colorB {
            path.addClip()
            colorB.setFill()
            UIRectFill(rect)
        }

        newGeneratedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()


        cornerLayer.contents = newGeneratedImage?.cgImage
        cornerLayer.frame = rect

        switch sides {
        case .top:
            replicators[0].instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(-1, 1.0, 1.0), -bounds.width, 0.0, 0.0)
        case .bottom:
            replicators[0].transform = CATransform3DTranslate(CATransform3DMakeScale(1.0, -1.0, 1.0), 0.0, -bounds.height, 0.0)
            replicators[0].instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(-1, 1.0, 1.0), -bounds.width, 0.0, 0.0)
        case .left:
            replicators[0].instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(1.0, -1.0, 1.0), 0.0, -bounds.height, 0.0)
        case .right:
            replicators[0].transform = CATransform3DTranslate(CATransform3DMakeScale(-1.0, 1.0, 1.0), -bounds.width, 0.0, 0.0)
            replicators[0].instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(1.0, -1.0, 1.0), 0.0, -bounds.height, 0.0)
        case .all:
            replicators[0].instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(-1, 1.0, 1.0), -bounds.width, 0.0, 0.0)
            replicators[1].instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(1.0, -1.0, 1.0), 0.0, -bounds.height, 0.0)
        }

        if !drawsOnlyCorners {
            let newFrameW: CGRect
            let newFrameH: CGRect

            switch sides {
            case .all:
                newFrameW = CGRect(x: cornerSize.width, y: 0, width: max(frame.width - cornerSize.width * 2, 0), height: frame.height)
                let heightForHLayer = max(frame.height - cornerSize.height * 2, 0)
                if let backgroundLayerExtraForAlpha = backgroundLayerExtraForAlpha {
                    newFrameH = CGRect(x: 0, y: cornerSize.height, width: cornerSize.width, height: heightForHLayer)
                    backgroundLayerExtraForAlpha.frame = CGRect(x: frame.width - cornerSize.width, y: cornerSize.height, width: cornerSize.width, height: heightForHLayer)
                } else {
                    newFrameH = CGRect(x: 0, y: cornerSize.height, width: frame.width, height: heightForHLayer)
                }
            case .bottom:
                backgroundLayerExtraForAlpha?.frame = .zero
                newFrameW = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - cornerSize.height)
                newFrameH = CGRect(x: cornerSize.width, y: frame.height - cornerSize.height, width: frame.width - cornerSize.width * 2.0, height: cornerSize.height)
            case .top:
                backgroundLayerExtraForAlpha?.frame = .zero
                newFrameW = CGRect(x: 0, y: cornerSize.height, width: frame.width, height: frame.height - cornerSize.height)
                newFrameH = CGRect(x: cornerSize.width, y: 0, width: frame.width - cornerSize.width * 2.0, height: cornerSize.height)
            case .left:
                backgroundLayerExtraForAlpha?.frame = .zero
                newFrameW = CGRect(x: 0, y: cornerSize.height, width: cornerSize.width, height: frame.height - cornerSize.height * 2.0)
                newFrameH = CGRect(x: cornerSize.width, y: 0, width: frame.width - cornerSize.width, height: frame.height)
            case .right:
                backgroundLayerExtraForAlpha?.frame = .zero
                newFrameW = CGRect(x: frame.width - cornerSize.width, y: cornerSize.height, width: cornerSize.width, height: frame.height - cornerSize.height * 2.0)
                newFrameH = CGRect(x: 0, y: 0, width: frame.width - cornerSize.width, height: frame.height)
            }

            backgroundLayerCenterW?.frame = newFrameW
            backgroundLayerCenterH?.frame = newFrameH
        }
    }
}
