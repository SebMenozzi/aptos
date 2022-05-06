import UIKit

final class AppThemeProvider: ThemeProvider {
    
    static let shared: AppThemeProvider = .init()

    private var theme: SubscribableValue<AppTheme>
    private var availableThemes: [AppTheme] = [.dark]

    var currentTheme: AppTheme {
        get {
            return theme.value
        }
        set {
            setNewTheme(newValue)
        }
    }

    init() {
        /*
        let dark = UserDefaults.standard.bool(forKey: "dark")
        
        if dark {
            theme = SubscribableValue<AppTheme>(value: .dark)
        } else {
            theme = SubscribableValue<AppTheme>(value: .light)
        }*/
        
        theme = SubscribableValue<AppTheme>(value: .dark)
    }

    private func setNewTheme(_ newTheme: AppTheme) {
        let window = UIApplication.shared.delegate!.window!!

        UIView.transition(
            with: window,
            duration: AnimationTiming.Duration.base,
            options: [.transitionCrossDissolve],
            animations: {
                self.theme.value = newTheme
        })

    }

    func subscribeToChanges(_ object: AnyObject, handler: @escaping (AppTheme) -> Void) {
        theme.subscribe(object, using: handler)
    }
}

extension Themed where Self: AnyObject {
    
    var themeProvider: AppThemeProvider {
        return AppThemeProvider.shared
    }
}
