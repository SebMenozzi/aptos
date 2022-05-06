import UIKit

open class LoadingBouncingButton: BouncingButton {
    open var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            updateLoader()
        }
    }

    open private(set) var isSpinnerInitialized = false
    open var spinnerSize: CGSize?
    open private(set) lazy var spinner = Spinner()..{
        isSpinnerInitialized = true
        $0.isHidden = true

        addSubview($0)
        setNeedsLayout()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if isSpinnerInitialized {
            spinner.frame.size = spinnerSize ?? CGSize(width: frame.size.height * 0.4, height: frame.size.height * 0.4)
            spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }

    open func updateLoader() {
        if isLoading {
            isUserInteractionEnabled = false
            titleLabel?.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            imageView?.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            bringSubviewToFront(spinner)
            spinner.isAnimating = true
        } else {
            isUserInteractionEnabled = true
            titleLabel?.layer.transform = CATransform3DIdentity
            imageView?.layer.transform = CATransform3DIdentity
            spinner.isAnimating = false
        }
    }
}
