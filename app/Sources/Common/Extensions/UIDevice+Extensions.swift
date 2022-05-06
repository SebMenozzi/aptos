import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIWindow.key?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension UIDevice {
    // Get the 9 from "iPhone9,3" device name string
    var phoneGeneration: Int? {
        guard let version = deviceName.split(separator: ",").first?.replacingOccurrences(of: "iPhone", with: ""), userInterfaceIdiom == .phone else {
            return nil
        }

        return Int(version)
    }

    var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
