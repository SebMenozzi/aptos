import UIKit

public extension UIColor {
    var alpha: CGFloat {
        var alpha: CGFloat = 0.0
        getWhite(nil, alpha: &alpha)
        return alpha
    }

    var isOpaque: Bool {
        return alpha == 1
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1.0)
    }

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
}

extension UIColor {
    func withHue(_ newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1, brightness: CGFloat = 1, alpha: CGFloat = 1
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func withSaturation(_ newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1, brightness: CGFloat = 1, alpha: CGFloat = 1
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    func withBrightness(_ newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1, saturation: CGFloat = 1, alpha: CGFloat = 1
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    func withAlpha(_ newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1, saturation: CGFloat = 1, brightness: CGFloat = 1
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    func highlight(withLevel highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1, green: CGFloat = 1, blue: CGFloat = 1, alpha: CGFloat = 1
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    func shadow(withLevel shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1, green: CGFloat = 1, blue: CGFloat = 1, alpha: CGFloat = 1
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
}

extension UIColor {
    func interpolateBetween(toColor: UIColor, distance: CGFloat) -> UIColor {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        var fRed2: CGFloat = 0
        var fGreen2: CGFloat = 0
        var fBlue2: CGFloat = 0
        var fAlpha2: CGFloat = 0

        getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        toColor.getRed(&fRed2, green: &fGreen2, blue: &fBlue2, alpha: &fAlpha2)

        let invDist = 1.0 - distance

        return UIColor(red: fRed * invDist + fRed2 * distance, green: fGreen * invDist + fGreen2 * distance, blue: fBlue * invDist + fBlue2 * distance, alpha: fAlpha * invDist + fAlpha2 * distance)
    }
}

extension UIColor {
    var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        guard let components = cgColor.components else { fatalError("invalid color declaration") }
        if cgColor.numberOfComponents == 2 {
            return (r: components[0], g: components[0], b: components[0], a: components[1])
        } else {
            return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }

    static func transition(from startColor: UIColor, to endColor: UIColor, with offset: CGFloat) -> UIColor {
        let red = (1 - offset) * startColor.components.r + offset * endColor.components.r
        let green = (1 - offset) * startColor.components.g + offset * endColor.components.g
        let blue = (1 - offset) * startColor.components.b + offset * endColor.components.b
        let alpha = (1 - offset) * startColor.components.a + offset * endColor.components.a

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
