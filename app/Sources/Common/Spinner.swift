import UIKit

public final class Spinner: UIView {

    private struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat

        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }

        func reversed() -> Pose {
            return Pose(secondsSincePriorPose, -start, length)
        }
    }
    private var poses: [Pose] = []

    public var lineCap: CAShapeLayerLineCap {
        didSet {
            setNeedsLayout()
        }
    }

    public var lineWidth: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }

    public var speed: CFTimeInterval {
        didSet {
            updatePoses()
        }
    }

    public var color: UIColor {
        didSet {
            setNeedsLayout()
        }
    }

    public var reversed: Bool {
        didSet {
            updatePoses()
        }
    }

    public var isAnimating: Bool = false {
        didSet {
            if oldValue != isAnimating {
                if isAnimating {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }

    override public var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }

    override public class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    public required init(frame: CGRect = .zero,
                         lineWidth: CGFloat = 3,
                         color: UIColor = .green,
                         speed: CFTimeInterval = 0.2,
                         lineCap: CAShapeLayerLineCap = .round,
                         reversed: Bool = false) {
        self.lineWidth = lineWidth
        self.color = color
        self.speed = speed
        self.lineCap = lineCap
        self.reversed = reversed

        super.init(frame: frame)

        updatePoses()
        setNeedsLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = lineCap
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }

    override public func didMoveToWindow() {
        setNeedsLayout()
        resumeAnimation()
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if window == nil {
            stopAnimating()
        }
    }

    private func resumeAnimation() {
        guard isAnimating else {
            return
        }

        startAnimating()
    }

    private func startAnimating() {
        let isAlreadyAnimating = layer.animationKeys()?.contains("strokeEnd") == true &&
            layer.animationKeys()?.contains("transform.rotation") == true

        guard !isAlreadyAnimating else {
            return
        }

        isHidden = false

        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()

        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }

        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }

        if let last = times.last {
            times.append(last)
            rotations.append(rotations[0])
            strokeEnds.append(strokeEnds[0])
        }

        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)

        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
    }

    private func stopAnimating() {
        isHidden = true
        NotificationCenter.default.removeObserver(self)
        layer.removeAllAnimations()
    }
}

private extension Spinner {

    func updatePoses() {
        let defaultPoses = [
            Pose(0.0, 0.000, 0.8),
            Pose(speed, 0.500, 0.6),
            Pose(speed, 1.000, 0.4),
            Pose(speed, 1.500, 0.2),
            Pose(speed, 1.875, 0.2),
            Pose(speed, 2.250, 0.4),
            Pose(speed, 2.625, 0.6),
            Pose(speed, 3.000, 0.8)
        ]

        if reversed {
            poses = defaultPoses.map { $0.reversed() }
        } else {
            poses = defaultPoses
        }

        if isAnimating {
            stopAnimating()
            startAnimating()
        }
    }

    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)..{
            $0.keyTimes = times as [NSNumber]?
            $0.values = values
            $0.calculationMode = .linear
            $0.duration = duration
            $0.repeatCount = .infinity
        }

        layer.add(animation, forKey: animation.keyPath)
    }

    // MARK: Notifications & Observers

    @objc func applicationDidBecomeActive() {
        resumeAnimation()
    }

    @objc func applicationWillResignActive() {
        layer.removeAllAnimations()
    }
}
