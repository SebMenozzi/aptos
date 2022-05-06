import UIKit

final class AppNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTheming()

        interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension AppNavigationController: Themed {
    func applyTheme(_ theme: AppTheme) {
        navigationBar.barTintColor = theme.backgroundColor
        navigationBar.setValue(true, forKey: "hidesShadow")
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
    }
}
