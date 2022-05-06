import UIKit

struct AppTheme {
    var statusBarStyle: UIStatusBarStyle
    var textColor: UIColor
    var primaryColor: UIColor
    var backgroundColor: UIColor
    var keyboardStyle: UIKeyboardAppearance
}

// http://marcodiiga.github.io/rgba-to-rgb-conversion

extension AppTheme {
    
    static let dark = AppTheme(
        statusBarStyle: .lightContent,
        textColor: .white,
        primaryColor: Color.primary,
        backgroundColor: .black,
        keyboardStyle: .dark
    )
}
