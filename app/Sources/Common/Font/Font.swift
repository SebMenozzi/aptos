import UIKit

public struct ShapiroFont {
    
    public let semi: UIFont
    public let medium: UIFont
    public let bold: UIFont
    
    public let semiWide: UIFont
    public let boldWide: UIFont
    public let extraBoldWide: UIFont

    private static let defaultSize: CGFloat = 10.0

    public static let shapiro = ShapiroFont(
        semi: R.font.shapiroSemi(size: defaultSize)!,
        medium: R.font.shapiroMedium(size: defaultSize)!,
        bold: R.font.shapiroBold(size: defaultSize)!,
        semiWide: R.font.shapiroSemiWide(size: defaultSize)!,
        boldWide: R.font.shapiroBoldWide(size: defaultSize)!,
        extraBoldWide: R.font.shapiroExtraBoldWide(size: defaultSize)!
    )
}

public extension UIFont {
    
    static var shapiroFont: ShapiroFont = .shapiro

    static let bigTitle = shapiroFont.extraBoldWide.withSize(28)
    
    static let title = shapiroFont.extraBoldWide.withSize(22)
    
    static let small = shapiroFont.semi.withSize(14)
    
    static let edit = shapiroFont.semi.withSize(28)
    
    static let button = shapiroFont.semiWide.withSize(14)
}
