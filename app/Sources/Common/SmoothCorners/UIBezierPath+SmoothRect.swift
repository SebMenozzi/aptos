import UIKit

public struct Corners: Equatable {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat

    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    public init(equalCorners: CGFloat) {
        topLeft = equalCorners
        topRight = equalCorners
        bottomLeft = equalCorners
        bottomRight = equalCorners
    }

    public static let zero = Corners(equalCorners: 0)

    private static func clamp(_ dimension: CGFloat, maxSize: CGSize) -> CGFloat {
        let atLeast0 =  max(0.0, dimension)
        let atMostWidth =  min(atLeast0, maxSize.width)

        return min(atMostWidth, maxSize.height)
    }

    func clamped(toSize size: CGSize) -> Corners {
        let clampedTopLeft = Corners.clamp(topLeft, maxSize: size)
        let clampedTopRight = Corners.clamp(topRight, maxSize: size)
        let clampedBottomLeft = Corners.clamp(bottomLeft, maxSize: size)
        let clampedBottomRight = Corners.clamp(bottomRight, maxSize: size)

        return Corners(topLeft: clampedTopLeft, topRight: clampedTopRight, bottomLeft: clampedBottomLeft, bottomRight: clampedBottomRight)
    }
}

public extension CGSize {
    var defaultSmoothRectCornerRadii: CGFloat {

        let minDimension = min(width, height)

        return minDimension * SmoothRect.defaultCornerSizeRatio
    }

    var defaultSmoothRectCorners: Corners {
        return Corners(equalCorners: defaultSmoothRectCornerRadii)
    }
}

public extension UIBezierPath {
    static func smoothRect(in rect: CGRect, cornerRadii: Corners? = nil) -> UIBezierPath {
        let corners = cornerRadii ?? rect.size.defaultSmoothRectCorners
        return SmoothRect.smoothPath(in: rect, cornerRadii: corners)
    }

    static func smoothRectTopLeft(in rect: CGRect, cornerRadii: CGFloat? = nil, limit: CGPoint = CGPoint(x: 1, y: 1), reverted: Bool = false) -> (UIBezierPath, CGSize) {
        let cornerRadii = cornerRadii ?? rect.size.defaultSmoothRectCornerRadii
        return SmoothRect.smoothPathTopLeft(in: rect, cornerRadii: cornerRadii, limit: limit, reverted: reverted)
    }
}

public enum SmoothRect {
    public static let defaultCornerSizeRatio: CGFloat = 0.4

    fileprivate static func smoothPath(in rect: CGRect, cornerRadii: Corners) -> UIBezierPath {
        let path = UIBezierPath()

        guard rect.size != .zero else {
            assert(false, "Cannot build a smoothPath with a size of 0")
            return path
        }

        let heightLimit = ((cornerRadii.bottomLeft == 0) != (cornerRadii.topLeft == 0)) && ((cornerRadii.bottomRight == 0) != (cornerRadii.topRight == 0)) ? rect.height : rect.height * 0.5
        let widthLimit = ((cornerRadii.bottomLeft == 0) != (cornerRadii.bottomRight == 0)) && ((cornerRadii.topRight == 0) != (cornerRadii.topLeft == 0)) ? rect.width : rect.width * 0.5
        let clampedCornerRadii = cornerRadii.clamped(toSize: CGSize(width: widthLimit, height: heightLimit))

        let width = rect.width
        let height = rect.height
        let left = rect.minX
        let top = rect.minY

        return path..{
            $0.move(to: CGPoint(x: left + widthLimit, y: top))

            // Top right quadrant
            if clampedCornerRadii.topRight == 0 {
                $0.addLine(to: CGPoint(x: left+width, y: top))
            } else {
                let vertexRatio = computeVertexRatio(radius: clampedCornerRadii.topRight, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)
                let controlRatio = computeControlRatio(radius: clampedCornerRadii.topRight, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)

                $0.addLine(to: CGPoint(x: left + max(widthLimit, width - clampedCornerRadii.topRight * 1.2819 * vertexRatio), y: top))

                $0.addCurve(to: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.5116, y: top + clampedCornerRadii.topRight * 0.1336),
                            controlPoint1: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.8362 * controlRatio, y: top),
                            controlPoint2: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.6745, y: top + clampedCornerRadii.topRight * 0.0464))

                $0.addCurve(to: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.1336, y: top + clampedCornerRadii.topRight * 0.5116),
                            controlPoint1: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.3486, y: top + clampedCornerRadii.topRight * 0.2207),
                            controlPoint2: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.2207, y: top + clampedCornerRadii.topRight * 0.3486))


                $0.addCurve(to: CGPoint(x: left + width, y: top + min(heightLimit, clampedCornerRadii.topRight * 1.2819 * vertexRatio)),
                            controlPoint1: CGPoint(x: left + width - clampedCornerRadii.topRight * 0.0464, y: top + clampedCornerRadii.topRight * 0.6745),
                            controlPoint2: CGPoint(x: left + width, y: top + clampedCornerRadii.topRight * 0.8362 * controlRatio))

            }

            // Bottom right quadrant
            if clampedCornerRadii.bottomRight == 0 {
                $0.addLine(to: CGPoint(x: left + width, y: top + height))
            } else {
                let vertexRatio = computeVertexRatio(radius: clampedCornerRadii.bottomRight, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)
                let controlRatio = computeControlRatio(radius: clampedCornerRadii.bottomRight, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)


                $0.addLine(to: CGPoint(x: left + width, y: top + max(heightLimit, height - clampedCornerRadii.bottomRight * 1.12819 * vertexRatio)))

                $0.addCurve(to: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.1336, y: top + height - clampedCornerRadii.bottomRight * 0.5116),
                            controlPoint1: CGPoint(x: left + width, y: top + height - clampedCornerRadii.bottomRight * 0.8362 * controlRatio),
                            controlPoint2: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.0464, y: top + height - clampedCornerRadii.bottomRight * 0.6745))

                $0.addCurve(to: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.5116, y: top + height - clampedCornerRadii.bottomRight * 0.1336),
                            controlPoint1: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.2207, y: top + height - clampedCornerRadii.bottomRight * 0.3486),
                            controlPoint2: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.3486, y: top + height - clampedCornerRadii.bottomRight * 0.2207))


                $0.addCurve(to: CGPoint(x: left + max(widthLimit, width - clampedCornerRadii.bottomRight * 1.2819 * vertexRatio), y: top + height),
                            controlPoint1: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.6745, y: top + height - clampedCornerRadii.bottomRight * 0.0464),
                            controlPoint2: CGPoint(x: left + width - clampedCornerRadii.bottomRight * 0.8362 * controlRatio, y: top + height))
            }

            // Bottom left quadrant
            if clampedCornerRadii.bottomLeft == 0 {
                $0.addLine(to: CGPoint(x: left, y: top + height))
            } else {
                let vertexRatio = computeVertexRatio(radius: clampedCornerRadii.bottomLeft, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)
                let controlRatio = computeControlRatio(radius: clampedCornerRadii.bottomLeft, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)

                $0.addLine(to: CGPoint(x: left + min(widthLimit, clampedCornerRadii.bottomLeft / 100.0 * 128.19 * vertexRatio), y: top + height))

                $0.addCurve(to: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.5116, y: top + height - clampedCornerRadii.bottomLeft * 0.1336),
                            controlPoint1: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.8362 * controlRatio, y: top + height),
                            controlPoint2: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.6745, y: top + height - clampedCornerRadii.bottomLeft * 0.0464))

                $0.addCurve(to: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.1336, y: top + height - clampedCornerRadii.bottomLeft * 0.5116),
                            controlPoint1: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.3486, y: top + height - clampedCornerRadii.bottomLeft * 0.2207),
                            controlPoint2: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.2207, y: top + height - clampedCornerRadii.bottomLeft * 0.3486))

                $0.addCurve(to: CGPoint(x: left, y: top + max(heightLimit, height - clampedCornerRadii.bottomLeft * 1.2819 * vertexRatio)),
                            controlPoint1: CGPoint(x: left + clampedCornerRadii.bottomLeft * 0.0464, y: top + height - clampedCornerRadii.bottomLeft * 0.6745),
                            controlPoint2: CGPoint(x: left, y: top + height - clampedCornerRadii.bottomLeft * 0.8362 * controlRatio))

            }

            // Top left quadrant
            if cornerRadii.topLeft == 0 {
                $0.addLine(to: CGPoint(x: left, y: top))
            } else {
                let vertexRatio = computeVertexRatio(radius: cornerRadii.topLeft, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)
                let controlRatio = computeControlRatio(radius: cornerRadii.topLeft, size: rect.size, widthLimit: widthLimit, heightLimit: heightLimit)

                $0.addLine(to: CGPoint(x: left, y: top + min(heightLimit, clampedCornerRadii.topLeft * 1.2819 * vertexRatio)))

                $0.addCurve(to: CGPoint(x: left + clampedCornerRadii.topLeft * 0.1336, y: top + clampedCornerRadii.topLeft * 0.5116),
                            controlPoint1: CGPoint(x: left, y: top + clampedCornerRadii.topLeft * 0.8362 * controlRatio),
                            controlPoint2: CGPoint(x: left + clampedCornerRadii.topLeft * 0.0464, y: top + clampedCornerRadii.topLeft * 0.6745))

                $0.addCurve(to: CGPoint(x: left + clampedCornerRadii.topLeft * 0.5116, y: top + clampedCornerRadii.topLeft * 0.1336),
                            controlPoint1: CGPoint(x: left + clampedCornerRadii.topLeft * 0.2207, y: top + clampedCornerRadii.topLeft * 0.3486),
                            controlPoint2: CGPoint(x: left + clampedCornerRadii.topLeft * 0.3486, y: top + clampedCornerRadii.topLeft * 0.2207))

                $0.addCurve(to: CGPoint(x: left + min(widthLimit, clampedCornerRadii.topLeft * 1.2819 * vertexRatio), y: top),
                            controlPoint1: CGPoint(x: left + clampedCornerRadii.topLeft * 0.6745, y: top + clampedCornerRadii.topLeft * 0.0464),
                            controlPoint2: CGPoint(x: left + clampedCornerRadii.topLeft * 0.8362 * controlRatio, y: top))
            }

            $0.close()
        }
    }

    fileprivate static func smoothPathTopLeft(in rect: CGRect, cornerRadii: CGFloat, limit: CGPoint, reverted: Bool = true) -> (UIBezierPath, CGSize) {
        let path = UIBezierPath()

        guard rect.size != .zero else {
            assert(false, "Cannot build a smoothPath with a size of 0")
            return (path, .zero)
        }

        let width = rect.width
        let height = rect.height
        let left = rect.minX
        let top = rect.minY
        let minSide = min(width, height)
        let minFactor = minSide

        let heightLimit = rect.height * limit.y
        let widthLimit = rect.width * limit.x
        let clampedCornerRadii = min(ceil(cornerRadii), min(heightLimit, widthLimit))
        let minsize = min(min(ceil(clampedCornerRadii * 1.5), heightLimit), widthLimit)

        let vertexRatio = computeVertexRatio(radius: clampedCornerRadii, size: CGSize.init(width: minsize, height: minsize), widthLimit: minsize, heightLimit: minsize)
        let controlRatio = computeControlRatio(radius: clampedCornerRadii, size: CGSize.init(width: minsize, height: minsize), widthLimit: minsize, heightLimit: minsize)


        let size = CGSize.init(width: floor(left + min(max(minsize, minsize - clampedCornerRadii * 1.2819 * vertexRatio), minsize)),
                               height: floor(min(top + max(minsize, minsize - clampedCornerRadii * 1.12819 * vertexRatio), minsize)))

        return (path..{
            $0.move(to: CGPoint(x: left + max(minsize, minsize - clampedCornerRadii * 1.2819 * vertexRatio), y: top))
            if reverted {
                $0.addLine(to: CGPoint(x: left, y: top))
                $0.addLine(to: CGPoint(x: left, y: top + max(minsize, minsize - clampedCornerRadii * 1.12819 * vertexRatio)))
            } else {
                $0.addLine(to: CGPoint(x: size.width, y: size.height))
                $0.addLine(to: CGPoint(x: left, y: size.height))
            }

            $0.addCurve(to: CGPoint(x: left + clampedCornerRadii * 0.1336, y: top + clampedCornerRadii * 0.5116),
                        controlPoint1: CGPoint(x: left, y: top + clampedCornerRadii * 0.8362 * controlRatio),
                        controlPoint2: CGPoint(x: left + clampedCornerRadii * 0.0464, y: top + clampedCornerRadii * 0.6745))

            $0.addCurve(to: CGPoint(x: left + clampedCornerRadii * 0.5116, y: top + clampedCornerRadii * 0.1336),
                        controlPoint1: CGPoint(x: left + clampedCornerRadii * 0.2207, y: top + clampedCornerRadii * 0.3486),
                        controlPoint2: CGPoint(x: left + clampedCornerRadii * 0.3486, y: top + clampedCornerRadii * 0.2207))

            $0.addCurve(to: CGPoint(x: left + min(minFactor, clampedCornerRadii * 1.2819 * vertexRatio), y: top),
                        controlPoint1: CGPoint(x: left + clampedCornerRadii * 0.6745, y: top + clampedCornerRadii * 0.0464),
                        controlPoint2: CGPoint(x: left + clampedCornerRadii * 0.8362 * controlRatio, y: top))
            }, size)
    }

    private static func computeVertexRatio(radius: CGFloat, size: CGSize, widthLimit: CGFloat, heightLimit: CGFloat) -> CGFloat {
        let minMidDimension = min(widthLimit, heightLimit)

        guard radius / minMidDimension > 0.5 else {
            return 1
        }

        let percentage = ((radius / minMidDimension) - 0.5) / 0.4
        let clampedPer = min(1, percentage)
        return 1 - (1 - 1.104 / 1.2819) * clampedPer
    }

    private static func computeControlRatio(radius: CGFloat, size: CGSize, widthLimit: CGFloat, heightLimit: CGFloat) -> CGFloat {
        let minMidDimension = min(widthLimit, heightLimit)


        guard radius / minMidDimension > 0.6 else {
            return 1
        }

        let percentage = ((radius / minMidDimension) - 0.6) / 0.3
        let clampedPer = min(1, percentage)
        return 1 + (0.8717 / 0.8362 - 1) * clampedPer
    }
}
