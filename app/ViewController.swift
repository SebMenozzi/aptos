import UIKit

final class ViewController: UIViewController {
    
    private var core: OpaquePointer {
        let aptosRestURL = "https://fullnode.devnet.aptoslabs.com"
        let aptosFaucetURL = "https://faucet.devnet.aptoslabs.com"

        return create_core("info", aptosRestURL, aptosFaucetURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
        
        Task {
            await test()
        }
    }
    
    func test() async {
        let alice = createAccount(core)
        let bob = createAccount(core)
        print("🔗 Alice address: \(alice.address)")
        print("🔗 Bob address: \(bob.address)")
        
        if let transaction = try? await fundAccount(core, address: alice.address, amount: 20000) {
            print("📝 Alice fund transaction: \(transaction.hash)")
        }
        
        if let balance = try? await getAccountBalance(core, address: alice.address) {
            print("💰 Alice balance: \(balance)")
        }
        
        if let transaction = try? await fundAccount(core, address: bob.address, amount: 10) {
            print("📝 Bob fund transaction: \(transaction.hash)")
        }
        
        if let balance = try? await getAccountBalance(core, address: bob.address) {
            print("💰 Bob balance: \(balance)")
        }
        
        if let transaction = try? await transfer(core, amount: 1500, addressFrom: alice.address, addressTo: bob.address, keypair: alice.keypair) {
            print("📝 Transfer transaction: \(transaction.hash)")
        }
        
        if let balance = try? await getAccountBalance(core, address: alice.address) {
            print("💰 Alice balance: \(balance)")
        }
        
        if let balance = try? await getAccountBalance(core, address: bob.address) {
            print("💰 Bob balance: \(balance)")
        }
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
        amount: UInt64
    ) async throws -> CoreProto_Transaction? {
        let fundAccountRequest = CoreProto_FundAccountRequest.with {
            $0.address = address
            $0.amount = amount
        }
        
        let req = CoreProto_Request.with {
            $0.fundAccount = fundAccountRequest
        }
        
        let res: CoreProto_FundAccountResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.transactions.first
    }
    
    private func getAccountBalance(
        _ core: OpaquePointer,
        address: String
    ) async throws -> UInt64? {
        let getAccountBalanceRequest = CoreProto_GetAccountBalanceRequest.with {
            $0.address = address
        }
        
        let req = CoreProto_Request.with {
            $0.getAccountBalance = getAccountBalanceRequest
        }
        
        let res: CoreProto_GetAccountBalanceResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.balance
    }
    
    private func transfer(
        _ core: OpaquePointer,
        amount: UInt64,
        addressFrom: String,
        addressTo: String,
        keypair: Data
    ) async throws -> CoreProto_Transaction?  {
        let transferRequest = CoreProto_TransferRequest.with {
            $0.amount = amount
            $0.addressFrom = addressFrom
            $0.addressTo = addressTo
            $0.keypair = Data(keypair)
        }
        
        let req = CoreProto_Request.with {
            $0.transfer = transferRequest
        }
        
        let res: CoreProto_TransferResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.transaction
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
            rustCallAsyncClosure(core, req) { (res: CoreProto_BacktraceResponse) in closure(res.text) }
        }
    }
}
