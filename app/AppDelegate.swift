import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private var core: OpaquePointer {
        let aptosRestURL = "https://fullnode.devnet.aptoslabs.com"
        let aptosFaucetURL = "https://faucet.devnet.aptoslabs.com"

        return create_core(aptosRestURL, aptosFaucetURL)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the window (bypass the storyboard)
        window = UIWindow(frame: UIScreen.main.bounds)
        // Make this window visible
        window?.makeKeyAndVisible()
        window?.rootViewController = ViewController()
        
        let alice = createAccount(core)
        let bob = createAccount(core)
        print("Alice address: {}", alice.address)
        print("Bob address: {}", bob.address)
        
        let group = DispatchGroup()
        
        DispatchQueue.global().async {
            group.enter()
            self.fundAccount(
                self.core,
                address: alice.address,
                amount: 100
            ) { [weak self] transaction in
                guard let self = self else { return }
                
                print("Alice fund transaction: \(transaction.hash)")
                
                self.getAccountBalance(
                    self.core,
                    address: alice.address
                ) { balance in
                    defer { group.leave() }
                    
                    print("Alice balance: \(balance)")
                }
            }
            
            group.enter()
            self.fundAccount(
                self.core,
                address: bob.address,
                amount: 10
            ) { [weak self] transaction in
                guard let self = self else { return }
                
                print("Bob fund transaction: \(transaction.hash)")
                
                self.getAccountBalance(
                    self.core,
                    address: bob.address
                ) { balance in
                    defer { group.leave() }
                    
                    print("Bob balance: \(balance)")
                }
            }
            
            group.wait()
            
            group.notify(queue: .global()) {
                self.transfer(
                    self.core,
                    amount: 25,
                    addressFrom: alice.address,
                    addressTo: bob.address,
                    signingKey: alice.signingKey
                ) { [weak self] transaction in
                    guard let self = self else { return }
                    
                    print("Transfer transaction: \(transaction.hash)")
                    
                    self.getAccountBalance(
                        self.core,
                        address: bob.address
                    ) { balance in
                        print("Bob balance: \(balance)")
                    }
                }
            }
        }
        
        return true
    }
    
    // MARK: - Private
    
    private func createAccount(_ core: OpaquePointer) -> CoreProto_CreateAccountResponse {
        let request = CoreProto_Request.with {
            $0.createAccount = CoreProto_CreateAccountRequest()
        }
        
        let response: CoreProto_CreateAccountResponse = try! rustCall(core, request)
        
        return response
    }

    private func fundAccount(
        _ core: OpaquePointer,
        address: String,
        amount: UInt64,
        closure: @escaping (CoreProto_Transaction) -> Void
    ) {
        let fundAccountRequest = CoreProto_FundAccountRequest.with {
            $0.address = address
            $0.amount = amount
        }
        
        let req = CoreProto_Request.with {
            $0.fundAccount = fundAccountRequest
        }
        
        rustCallAsync(core, req) { (res: CoreProto_FundAccountResponse) in
            closure(res.transactions.first!)
        }
    }
    
    private func getAccountBalance(
        _ core: OpaquePointer,
        address: String,
        closure: @escaping (UInt64) -> Void
    ) {
        let getAccountBalanceRequest = CoreProto_GetAccountBalanceRequest.with {
            $0.address = address
        }
        
        let req = CoreProto_Request.with {
            $0.getAccountBalance = getAccountBalanceRequest
        }
        
        rustCallAsync(core, req) { (res: CoreProto_GetAccountBalanceResponse) in
            closure(res.balance)
        }
    }
    
    private func transfer(
        _ core: OpaquePointer,
        amount: UInt64,
        addressFrom: String,
        addressTo: String,
        signingKey: Data,
        closure: @escaping (CoreProto_Transaction) -> Void
    ) {
        let transferRequest = CoreProto_TransferRequest.with {
            $0.amount = amount
            $0.addressFrom = addressFrom
            $0.addressTo = addressTo
            $0.signingKey = Data(signingKey)
        }
        
        let req = CoreProto_Request.with {
            $0.transfer = transferRequest
        }
        
        rustCallAsync(core, req) { (res: CoreProto_TransferResponse) in
            closure(res.transaction)
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
