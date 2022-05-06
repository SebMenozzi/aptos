import UIKit

final class RegularButton: LoadingBouncingButton {
    
    private var rawTitle: String?
    
    private var iconTintColor: UIColor?
    private var iconImage: UIImage?
    private var iconSize: CGFloat?
    
    private var cornerRadius: CGFloat?
    private(set) var smoothCornerView = RoundedCornersView()

    private let label = UILabel()..{
        $0.textColor = .black
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
    }

    private let iconImageView = UIImageView()..{
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    init() {
        super.init(frame: .zero)

        insertSubview(smoothCornerView, at: 0)
        smoothCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        smoothCornerView.layer.zPosition = -100.0
        smoothCornerView.fillSuperview()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Content update
extension RegularButton {
    
    @discardableResult
    func with(title: String?) -> Self {
        guard rawTitle != title else { return self }
        rawTitle = title

        updateTitle()
        updateImage()

        return self
    }

    @discardableResult
    func with(iconImage: UIImage?, iconSize: CGFloat?, iconTintColor: UIColor = .white) -> Self {
        guard self.iconImage != iconImage && self.iconSize != iconSize else { return self }

        self.iconTintColor = iconTintColor
        self.iconImage = iconImage
        self.iconSize = iconSize

        updateTitle()
        updateImage()

        return self
    }

    @discardableResult
    func with(backgroundColor: UIColor) -> Self {
        smoothCornerView.backgroundColor = backgroundColor

        return self
    }

    @discardableResult
    func with(cornerRadius: CGFloat) -> Self {
        smoothCornerView.cornerRadius = cornerRadius

        return self
    }
    
    @discardableResult
    func with(font: UIFont) -> Self {
        label.font = font

        return self
    }

    @discardableResult
    func with(textColor: UIColor) -> Self {
        label.textColor = textColor

        return self
    }

    @discardableResult
    func with(isLoading: Bool) -> Self {
        self.isLoading = isLoading
        label.isHidden = isLoading
        iconImageView.isHidden = isLoading

        return self
    }
}

// MARK: - Private update

private extension RegularButton {
    
    func updateTitle() {
        label.removeFromSuperview()
        addSubview(label)

        if iconImage == nil {
            label.fillSuperview(padding: UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22))
        } else {
            label.fillSuperview(padding: UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 42))
        }

        label.text = rawTitle
    }

    func updateImage() {
        iconImageView.removeFromSuperview()
        addSubview(iconImageView)

        iconImageView.image = iconImage
        iconImageView.tintColor = iconTintColor

        guard let iconSize = iconSize else { return }

        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
    }
}
