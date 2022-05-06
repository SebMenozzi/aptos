import UIKit

extension CGAffineTransform {
    init(scale: CGFloat) {
        self.init(scaleX: scale, y: scale)
    }
}
