import UIKit

extension CGSize {
    static func * (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width * factor, height: size.height * factor)
    }

    static func / (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width / factor, height: size.height / factor)
    }

    static func square(withSide sideSize: CGFloat) -> CGSize {
        return CGSize(width: sideSize, height: sideSize)
    }

    public func aspectFit(maxSize: CGSize) -> CGSize {
        let originalAspectRatio: CGFloat = width / height
        let maxAspectRatio: CGFloat = maxSize.width / maxSize.height
        var newSize: CGSize = maxSize

        if originalAspectRatio > maxAspectRatio {
            newSize.height = round(maxSize.width / originalAspectRatio)
        } else {
            newSize.width = round(maxSize.height * originalAspectRatio)
        }

        return newSize
    }

    public func aspectFill(minSize: CGSize) -> CGSize {
        let scaleWidth: CGFloat = minSize.width / width
        let scaleHeight: CGFloat = minSize.height / height
        let scale: CGFloat = max(scaleWidth, scaleHeight)
        let newWidth: CGFloat = width * scale
        let newHeight: CGFloat = height * scale

        return CGSize(width: newWidth, height: newHeight)
    }
}
