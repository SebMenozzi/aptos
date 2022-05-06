import UIKit

protocol FloatingButtonModalDelegate: AnyObject {
    func onPress()
}

final class FloatingButtonModal {
    
    static let size: CGFloat = 58

    weak var delegate: FloatingButtonModalDelegate?
    weak var parentView: UIView?

    private let margin: CGFloat = -15
    private lazy var heightMargin: CGFloat = UIDevice.current.hasNotch ? 0 : margin
    private var bottomConstraint: NSLayoutConstraint?
    private var isEnabled: Bool = true

    private lazy var floatingButton = IconButton()..{
        $0.with(cornerRadius: Self.size * 0.42)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
    }

    @objc func buttonTapped(sender: UIButton) {
        let haptic = HapticFeedbackBuilder(.medium).build()
        SoundPlayer.shared.play(haptic: haptic)

        delegate?.onPress()
    }

    private func setupConstraints() {
        floatingButton.widthAnchor.constraint(equalToConstant: Self.size).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: Self.size).isActive = true
        
        floatingButton.rightAnchor.constraint(equalTo: parentView!.rightAnchor, constant: margin).isActive = true

        bottomConstraint = floatingButton.bottomAnchor.constraint(equalTo: parentView!.safeAreaLayoutGuide.bottomAnchor, constant: heightMargin)
        bottomConstraint?.isActive = true
    }

    private func animateOpenModal() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let self = self else { return }

                self.floatingButton.alpha = 1.0
            }
        )
    }

    func show(icon: UIImage?, iconSize: CGFloat, color: UIColor) {
        parentView!.addSubview(floatingButton)
        floatingButton.with(backgroundColor: color)
        floatingButton.with(iconImage: icon?.withRenderingMode(.alwaysTemplate), iconSize: iconSize)

        setupConstraints()
        setupKeyboardObserver()

        animateOpenModal()
    }

    func changeIcon(icon: UIImage?, iconSize: CGFloat) {
        floatingButton.with(iconImage: icon?.withRenderingMode(.alwaysTemplate), iconSize: iconSize)
    }

    func destroy() {
        floatingButton.removeFromSuperview()
    }

    func disable() {
        isEnabled = false
        floatingButton.alpha = 0.6
    }

    func enable() {
        isEnabled = true
        floatingButton.alpha = 1.0
    }

    func startLoading() {
        isEnabled = false
        floatingButton.with(isLoading: true)
    }

    func stopLoading() {
        isEnabled = true
        floatingButton.with(isLoading: false)
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    private var keyboardHeight: CGFloat = 0

    @objc private func keyboardWillChangeFrameNotification(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardFrameY = keyboardFrame.cgRectValue.origin.y

        if keyboardFrameY == UIScreen.main.bounds.size.height {
            bottomConstraint?.constant = heightMargin
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height

            bottomConstraint?.constant = -keyboardHeight + 15
        }
    }
}
