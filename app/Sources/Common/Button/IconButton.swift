import UIKit

final class IconButton: LoadingBouncingButton {
    
    private var iconTintColor: UIColor?
    private var iconImage: UIImage?
    private var iconSize: CGFloat?
    
    private var cornerRadius: CGFloat?
    private(set) var smoothCornerView = RoundedCornersView()

    private let iconImageView = UIImageView()..{
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init() {
        super.init(frame: .zero)

        insertSubview(smoothCornerView, at: 0)
        smoothCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        smoothCornerView.layer.zPosition = -100.0
        smoothCornerView.fillSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Content update
extension IconButton {
    
    @discardableResult
    func with(iconImage: UIImage?, iconSize: CGFloat?, iconTintColor: UIColor = .white, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> Self {
        guard self.iconImage != iconImage && self.iconSize != iconSize else { return self }
        
        self.iconTintColor = iconTintColor
        self.iconImage = iconImage
        self.iconSize = iconSize

        updateImage(xOffset: xOffset, yOffset: yOffset)

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
    func with(isLoading: Bool) -> Self {
        self.isLoading = isLoading
        iconImageView.isHidden = isLoading

        return self
    }
    
    @discardableResult
    func with(shadowColor: UIColor) -> Self {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10.0
        
        return self
    }
    
    @discardableResult
   func with(borderColor: UIColor) -> Self {
        layer.borderWidth = 2
        layer.borderColor = borderColor.cgColor
        
        return self
    }
}


// MARK: - Private update
private extension IconButton {
    
    func updateImage(xOffset: CGFloat, yOffset: CGFloat) {
        iconImageView.removeFromSuperview()
        addSubview(iconImageView)

        iconImageView.image = iconImage?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = iconTintColor

        guard let iconSize = iconSize else { return }

        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: yOffset).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: xOffset).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
    }
}
