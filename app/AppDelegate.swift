import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private var core: OpaquePointer {
        let aptosURL = "https://fullnode.devnet.aptoslabs.com"

        return create_core(aptosURL)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the window (bypass the storyboard)
        window = UIWindow(frame: UIScreen.main.bounds)
        // Make this window visible
        window?.makeKeyAndVisible()
        window?.rootViewController = ViewController()
        
        let text = greeting(core, verb: "Hola", name: "Seb")
        print(text)
        
        sleep(core, seconds: 3) { result in
            print(result)
        }
        
        backtrace(core, sync: true) { result in
            print(result)
        }
        
        return true
    }
    
    // MARK: - Private
    
    private func greeting(_ core: OpaquePointer, verb: String, name: String) -> String {
        let greetingReq = CoreProto_GreetingRequest.with {
            $0.verb = verb
            $0.name = name
        }
        let req = CoreProto_Request.with {
            $0.greeting = greetingReq
        }
        let res: CoreProto_GreetingResponse = try! rustCall(core, req)
        return res.text
    }

    private func sleep(_ core: OpaquePointer, seconds: Int, closure: @escaping (String) -> Void) {
        let sleepReq = CoreProto_SleepRequest.with {
            $0.millis = UInt64(seconds * 1000)
        }
        
        let req = CoreProto_Request.with {
            $0.sleep = sleepReq
        }
        
        rustCallAsync(core, req) { (res: CoreProto_SleepResponse) in
            closure(res.text)
        }
    }

    private func backtrace(_ core: OpaquePointer, sync: Bool, closure: @escaping (String) -> Void) {
        let req = CoreProto_Request.with {
            if (sync) {
                $0.syncBacktrace = CoreProto_BacktraceRequest()
            } else {
                $0.asyncBacktrace = CoreProto_BacktraceRequest()
            }
        }
        
        if sync {
            let res: CoreProto_BacktraceResponse = try! rustCall(core, req)
            closure(res.text)
        } else {
            rustCallAsync(core, req) { (res: CoreProto_BacktraceResponse) in closure(res.text) }
        }
    }
}
