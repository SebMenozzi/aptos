import UIKit

final class MeshGradientViewController: UIViewController {
    
    struct Configuration: Equatable {
        let backgroundColor: UIColor
        let foregroundColors: [UIColor]

        func foregroundColor(forCellIndex index: Int) -> UIColor {
            return foregroundColors[index % foregroundColors.count]
        }
    }

    private let blurEffect = UIBlurEffect(style: .dark)
    private lazy var blurView = UIVisualEffectView(effect: blurEffect)

    var cells = [Cell]()

    struct Cell: Hashable {
        let layer: CALayer
        let rotatingLayer: CAShapeLayer
        let originalSpeed: CGFloat
        var vector: CGPoint
        var rotation: CGFloat // rad per frame

        func hash(into hasher: inout Hasher) {
            layer.hash(into: &hasher)
        }

        func update(withColor color: UIColor) {
            CALayer.performWithoutAnimations {
                rotatingLayer.fillColor = color.cgColor
            }
        }
    }

    lazy var displayLink = CADisplayLink(target: self, selector: #selector(animateCells))
    private var foregroundCellsAnimation: [MeshColorAnimation] = []

    private let shapesView = UIView()

    private var configuration: Configuration?

    static let colorTransitionDuration: TimeInterval = 700

    override func viewDidLoad() {
        super.viewDidLoad()

        shapesView.frame = view.bounds
        shapesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(shapesView)

        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        
        // https://stackoverflow.com/questions/38520757/fix-uivisualeffectview-extra-light-blur-being-gray-on-white-background
        if let vfxSubView = blurView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectSubview"
        }) {
            vfxSubView.backgroundColor = .clear
        }

        #if DEBUG
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        #endif

        displayLink.add(to: .main, forMode: .common)
        displayLink.isPaused = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        displayLink.isPaused = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        displayLink.isPaused = true
    }

    func toggleMeshGradientAnimation(_ isRunning: Bool) {
        guard isRunning != !displayLink.isPaused else {
            return
        }
        displayLink.isPaused = !isRunning
    }

    func updateConfiguration(_ configuration: Configuration) {
        if let oldConfiguration = self.configuration {
            animateColors(fromConfiguration: oldConfiguration, to: configuration)
        } else {
            view.backgroundColor = configuration.backgroundColor
            
            cells = (0..<10).map { i in
                Self.generateCell(withColor: configuration.foregroundColor(forCellIndex: i), bounds: view.bounds)
            }
            
            cells.forEach {
                shapesView.layer.addSublayer($0.layer)
            }

            self.configuration = configuration
        }
    }

    private func animateColors(fromConfiguration: Configuration, to configuration: Configuration) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: MeshGradientViewController.colorTransitionDuration, delay: 0, options: [], animations: {
            self.view.backgroundColor = configuration.backgroundColor
        }, completion: { _ in
            self.configuration = configuration
        })

        guard foregroundCellsAnimation.isEmpty else {
            return
        }

        let currentTime = displayLink.timestamp
        foregroundCellsAnimation = (0..<cells.count).map { index in
            MeshColorAnimation(initialColor: fromConfiguration.foregroundColor(forCellIndex: index),
                               initialTimeStamp: currentTime,
                               finalColor: configuration.foregroundColor(forCellIndex: index),
                               animationDuration: MeshGradientViewController.colorTransitionDuration)
        }
    }

    static func generateCell(withColor color: UIColor, bounds: CGRect) -> Cell {
        let minSize: CGFloat = 20
        let maxSize: CGFloat = 200
        let size = CGFloat.random(in: minSize...maxSize)
        let sides = Int.random(in: 4...8)

        let shapeLayer = CALayer()
        shapeLayer.compositingFilter = "colorDodgeBlendMode"
        shapeLayer.shouldRasterize = true
        shapeLayer.rasterizationScale = 0.05

        shapeLayer.frame = CGRect(x: .random(in: (bounds.minX - size)...(bounds.maxX)),
                                  y: .random(in: (bounds.minY - size)...(bounds.maxY)),
                                  width: size,
                                  height: size)

        let rotatingLayer = CAShapeLayer.withPolygonShape(sides: sides, size: CGSize(width: size,
                                                                         height: size))
        rotatingLayer.fillColor = color.cgColor
        rotatingLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)

        let rotation = CGFloat.random(in: 0...CGFloat.pi)

        shapeLayer.addSublayer(rotatingLayer)

        let speed = CGFloat.random(in: 0.1...0.6)
        let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))

        rotatingLayer.transform = CATransform3DMakeRotation(rotation, 0, 0, 1.0)

        return Cell(
            layer: shapeLayer,
            rotatingLayer: rotatingLayer,
            originalSpeed: speed,
            vector: CGPoint(x: cos(angle) * speed, y: sin(angle) * speed),
            rotation: rotation
        )
    }

    @objc func animateCells() {
        guard !cells.isEmpty else {
            return
        }

        cells = cells.map { cell in
            var cell = cell
            let currentSpeed = sqrt(pow(cell.vector.x, 2) + pow(cell.vector.y, 2))

            let speedDiff = cell.originalSpeed - currentSpeed

            if !((-0.9...0.1) ~= speedDiff) {
                let dampingFactor: CGFloat = 0.005
                cell.vector.x += cell.vector.x * (speedDiff * dampingFactor)
                cell.vector.y += cell.vector.y * (speedDiff * dampingFactor)
            }
            return cell
        }

        cells.forEach(animate)

        if !foregroundCellsAnimation.isEmpty {
            (0..<foregroundCellsAnimation.count).forEach { index in
                foregroundCellsAnimation[index].updateCompletion(withCurrentTimestamp: displayLink.timestamp)
                cells[index].update(withColor: foregroundCellsAnimation[index].currentColor)
            }

            foregroundCellsAnimation = foregroundCellsAnimation.filter { !$0.isFinished }
        }
    }

    func animate(_ cell: Cell) {
        var frame = cell.layer.frame

        frame.origin.x += cell.vector.x
        frame.origin.y += cell.vector.y

        let respawnThreshold: CGFloat = 15
        let respawnDistance: CGFloat = 10

        if frame.minX > view.bounds.maxX + respawnThreshold {
            frame.origin.x = view.bounds.minX - frame.width - respawnDistance
        }
        if frame.minY > view.bounds.maxY + respawnThreshold {
            frame.origin.y = view.bounds.minY - frame.height - respawnDistance
        }
        if frame.maxX < view.bounds.minX - respawnThreshold {
            frame.origin.x = view.bounds.maxX + respawnDistance
        }
        if frame.maxY < view.bounds.minY - respawnThreshold {
            frame.origin.y = view.bounds.maxY + respawnDistance
        }

        let rotation = CATransform3DMakeRotation(cell.rotation, 0, 0, 1.0)

        CALayer.performWithoutAnimations {
            cell.layer.frame = frame
            cell.layer.sublayers![0].transform = rotation
        }
    }

    @objc func tap() {
        #if DEBUG
            blurView.isHidden.toggle()
        #endif
    }
}

private extension UIBezierPath {
    
    static func polygon(in rect: CGRect, sides: Int) -> UIBezierPath {
        precondition(sides >= 3)

        let xRadius = rect.width / 2.0
        let yRadius = rect.height / 2.0

        let centerX = rect.midX
        let centerY = rect.midY

        let path = UIBezierPath()
        path.move(to: CGPoint(x: centerX + xRadius,
                              y: centerY + 0))

        (0..<sides).forEach { index in
            let theta = 2.0 * .pi / CGFloat(sides) * CGFloat(index)
            let x = centerX + xRadius * cos(theta)
            let y = centerY + yRadius * sin(theta)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.close()

        return path
    }
}

private extension CAShapeLayer {
    
    static func withPolygonShape(sides: Int, size: CGSize) -> CAShapeLayer {
        return CAShapeLayer()..{
            $0.path = UIBezierPath.polygon(in: CGRect(origin: .zero, size: size),
                                           sides: sides).cgPath
        }
    }
}

private final class MeshColorAnimation {
    
    let initialColor: UIColor
    let initialTimeStamp: TimeInterval
    let finalColor: UIColor

    let animationDuration: TimeInterval

    init(initialColor: UIColor, initialTimeStamp: CFTimeInterval, finalColor: UIColor, animationDuration: TimeInterval) {
        self.initialColor = initialColor
        self.initialTimeStamp = initialTimeStamp
        self.finalColor = finalColor
        self.animationDuration = animationDuration
    }

    var completionRatio: CGFloat {
        get {
            return sanitizedCompletionRatio
        }

        set {
            sanitizedCompletionRatio = newValue.clamped(betweenMinValue: 0, maxValue: 1)
        }
    }

    func updateCompletion(withCurrentTimestamp currentTimestamp: CFTimeInterval) {
        let elapsedTime = currentTimestamp - initialTimeStamp

        completionRatio = CGFloat(elapsedTime / animationDuration)
    }
    private var sanitizedCompletionRatio: CGFloat = 0

    var isFinished: Bool {
        return completionRatio == 1.0
    }

    var currentColor: UIColor {
        return initialColor.interpolateBetween(toColor: finalColor, distance: sanitizedCompletionRatio)
    }
}
