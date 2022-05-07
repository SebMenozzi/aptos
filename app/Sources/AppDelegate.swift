import UIKit
import Firebase
import FirebaseFirestore

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var core: OpaquePointer {
        let aptosRestURL = "https://fullnode.devnet.aptoslabs.com"
        let aptosFaucetURL = "https://faucet.devnet.aptoslabs.com"

        return create_core("info", aptosRestURL, aptosFaucetURL)
    }

    private var firestore: Firestore {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        return Firestore.firestore()
    }
    
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        Current = CurrentService(core: core, firestore: firestore)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = OnboardingViewController()

        return true
    }
}
