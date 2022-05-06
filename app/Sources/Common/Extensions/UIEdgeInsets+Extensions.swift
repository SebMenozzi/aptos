import UIKit

extension UIEdgeInsets {
    init(insets: CGFloat) {
        self.init(top: insets, left: insets, bottom: insets, right: insets)
    }

    init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

extension UIEdgeInsets {
    public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat, direction: UIUserInterfaceLayoutDirection) {
        if direction == .leftToRight {
            self.init(top: top, left: leading, bottom: bottom, right: trailing)
        } else {
            self.init(top: top, left: trailing, bottom: bottom, right: leading)
        }
    }
}
