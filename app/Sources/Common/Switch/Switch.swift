import UIKit

protocol SwitchDelegate: AnyObject {
    func didUpdateValue(isOn: Bool)
}

final class Switch: UIControl {
    
    weak var delegate: SwitchDelegate? = nil

    // MARK: - Properties

    private static let size = CGSize(width: 56, height: 32)
    private let toggleView: ToggleView
    private var leftConstraint: NSLayoutConstraint?

    /// Default: `false`
    private(set) var on: Bool = false

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.3
        }
    }

    override var intrinsicContentSize: CGSize {
        return Switch.size
    }

    private var color: UIColor = .white {
        didSet {
            self.updateBackgroundColor()
        }
    }
    
    private lazy var backgroundView = RoundedCornersView(backgroundColor: .clear)

    public required override init(frame: CGRect = .zero) {
        self.toggleView = ToggleView(backgroundColor: DefaultColor.green)..{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        super.init(frame: frame)

        setupLayout()
        listenForTap()
        listenForSwipe()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func updateBackgroundColor() {
        if self.on {
            backgroundView.backgroundColor = color
        } else {
            backgroundView.backgroundColor = color.withAlphaComponent(0.2)
        }
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: Switch.size.height).isActive = true
        widthAnchor.constraint(equalToConstant: Switch.size.width).isActive = true

        addSubview(backgroundView)
        backgroundView.fillSuperview()

        addSubview(toggleView)
        toggleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        leftConstraint = toggleView.leadingAnchor.constraint(equalTo: leadingAnchor)
        leftConstraint?.isActive = true
    }

    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    public func setup(_ on: Bool) {
        self.on = on

        leftConstraint?.constant = on ? Switch.size.width - ToggleView.size.width - 4 : 4

        self.updateBackgroundColor()
    }

    public func setOn(_ on: Bool, animated: Bool) {
        self.on = on

        vibrate()

        leftConstraint?.constant = on ? Switch.size.width - ToggleView.size.width - 4 : 4

        let transforms = { [self] in
            self.toggleView.on = on
            self.updateBackgroundColor()
            self.layoutIfNeeded()
        }

        if animated {
            let animator = UIViewPropertyAnimator(
                duration: 0.2,
                curve: .easeInOut,
                animations: transforms
            )

            animator.isUserInteractionEnabled = false
            animator.startAnimation()
        } else {
            transforms()
        }

        delegate?.didUpdateValue(isOn: on)
    }

    private func listenForTap() {
        addTarget(self, action: #selector(Switch.didTapOrSwipe), for: .touchUpInside)
    }

    private func listenForSwipe() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(Switch.didTapOrSwipe))
        swipeGesture.direction = [.left, .right]
        addGestureRecognizer(swipeGesture)
    }

    @objc func didTapOrSwipe() {
        setOn(!on, animated: true)
        sendActions(for: .valueChanged)
    }
}

private final class ToggleView: RoundedCornersView {
    fileprivate static let size: CGSize = CGSize(width: 24, height: 24)

    var on: Bool = false

    // MARK: - Initializers
    
    init(backgroundColor: UIColor) {
        super.init(frame: .zero, backgroundColor: backgroundColor)

        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false

        heightAnchor.constraint(equalToConstant: ToggleView.size.height).isActive = true
        widthAnchor.constraint(equalToConstant: ToggleView.size.width).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
