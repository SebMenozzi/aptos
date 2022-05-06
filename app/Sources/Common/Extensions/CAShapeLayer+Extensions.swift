import UIKit
import QuartzCore

extension CAShapeLayer {
    static func createCircleLayer(rect: CGRect) -> CAShapeLayer {
        let radius = rect.width / 2
        
        return CAShapeLayer()..{
            $0.path = UIBezierPath(roundedRect: CGRect(x: -radius, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
            $0.position = CGPoint(x: rect.midX, y: rect.midY - radius)
        }
    }
}
