import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let accountProvider = DefaultAccountProvider()
        let currentAccount = accountProvider.loadAccount()
        if let currentAccount = currentAccount {
            window?.rootViewController = ViewController()
        } else {
            window?.rootViewController = OnboardingViewController()
        }
    
        return true
    }
}
