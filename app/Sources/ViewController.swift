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
        let account1 = createAccount(core)
        let account2 = createAccount(core)
        let account3 = createAccount(core)
        let account4 = createAccount(core)
        
        let wallet1 = createWallet(core, publicKeys: [account1.publicKey, account2.publicKey])
        let wallet2 = createWallet(core, publicKeys: [account3.publicKey, account4.publicKey])
        
        print("🔗 Wallet 1 address: \(wallet1.address)")
        print("🔗 Wallet 2 address: \(wallet2.address)")
        
        if let transaction = try? await fundWallet(core, address: wallet1.address, amount: 20000) {
            print("📝 Wallet 1 fund transaction: \(transaction.hash)")
        }
        
        if let transaction = try? await fundWallet(core, address: wallet2.address, amount: 10) {
            print("📝 Wallet 2 fund transaction: \(transaction.hash)")
        }
        
        if let balance = try? await getWalletBalance(core, address: wallet1.address) {
            print("💰 Wallet 1 balance: \(balance)")
        }
        
        if let balance = try? await getWalletBalance(core, address: wallet2.address) {
            print("💰 Wallet 2 balance: \(balance)")
        }
        
        guard let transaction = try? await createWalletTransaction(core, amount: 1500, addressFrom: wallet1.address, addressTo: wallet2.address) else { return }
        print("📝 New transaction: \(transaction)")
        
        guard let signature_account1 = try? await signWalletTransaction(core, transaction: transaction, keypair: account1.keypair) else { return }
        print("✅ Account 1 signed: \(signature_account1)")
        
        guard let signature_account2 = try? await signWalletTransaction(core, transaction: transaction, keypair: account2.keypair) else { return }
        print("✅ Account 2 signed: \(signature_account2)")
        
        let signedPayloadAccount1 = CoreProto_SignedPayload.with {
            $0.publicKey = account1.publicKey
            $0.signature = signature_account1
        }
        let signedPayloadAccount2 = CoreProto_SignedPayload.with {
            $0.publicKey = account2.publicKey
            $0.signature = signature_account2
        }
        if let submitted_transaction = try? await submitWalletTransaction(core, transaction: transaction, signedPayloads: [signedPayloadAccount1, signedPayloadAccount2]) {
            print("😎 Transaction submitted \(submitted_transaction.hash)")
        }
        
        if let balance = try? await getWalletBalance(core, address: wallet1.address) {
            print("💰 Wallet 1 balance: \(balance)")
        }
        
        if let balance = try? await getWalletBalance(core, address: wallet2.address) {
            print("💰 Wallet 2 balance: \(balance)")
        }
        
        if let transactions = try? await getWalletTransactions(core, address: wallet1.address) {
            print("📝 Wallet 1 transactions:")
            for t in transactions {
                print("- \(t.hash)")
            }
        }
        
        if let transactions = try? await getWalletTransactions(core, address: wallet2.address) {
            print("📝 Wallet 2 transactions:")
            for t in transactions {
                print("- \(t.hash)")
            }
        }
    }
    
    // MARK: - Private
    
    private func createAccount(_ core: OpaquePointer) -> CoreProto_CreateAccountResponse {
        let request = CoreProto_Request.with {
            $0.createAccount = CoreProto_CreateAccountRequest()
        }
        
        let response: CoreProto_CreateAccountResponse = try! rustCallSync(core, request)
        
        return response
    }
    
    private func createWallet(_ core: OpaquePointer, publicKeys: [String]) -> CoreProto_CreateWalletResponse {
        let createWalletRequest = CoreProto_CreateWalletRequest()..{
            $0.publicKeys = publicKeys
        }
        
        let request = CoreProto_Request.with {
            $0.createWallet = createWalletRequest
        }
        
        let response: CoreProto_CreateWalletResponse = try! rustCallSync(core, request)
        
        return response
    }

    private func fundWallet(
        _ core: OpaquePointer,
        address: String,
        amount: UInt64
    ) async throws -> CoreProto_Transaction? {
        let fundWalletRequest = CoreProto_FundWalletRequest.with {
            $0.address = address
            $0.amount = amount
        }
        
        let req = CoreProto_Request.with {
            $0.fundWallet = fundWalletRequest
        }
        
        let res: CoreProto_FundWalletResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.transactions.first
    }
    
    private func getWalletBalance(
        _ core: OpaquePointer,
        address: String
    ) async throws -> UInt64? {
        let getWalletBalanceRequest = CoreProto_GetWalletBalanceRequest.with {
            $0.address = address
        }
        
        let req = CoreProto_Request.with {
            $0.getWalletBalance = getWalletBalanceRequest
        }
        
        let res: CoreProto_GetWalletBalanceResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.balance
    }
    
    private func getWalletTransactions(
        _ core: OpaquePointer,
        address: String
    ) async throws -> [CoreProto_Transaction]? {
        let getWalletTransactionsRequest = CoreProto_GetWalletTransactionsRequest.with {
            $0.address = address
        }
        
        let req = CoreProto_Request.with {
            $0.getWalletTransactions = getWalletTransactionsRequest
        }
        
        let res: CoreProto_GetWalletTransactionsResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.transactions
    }
    
    private func createWalletTransaction(
        _ core: OpaquePointer,
        amount: UInt64,
        addressFrom: String,
        addressTo: String
    ) async throws -> String?  {
        let createWalletTransactionRequest = CoreProto_CreateWalletTransactionRequest.with {
            $0.amount = amount
            $0.addressFrom = addressFrom
            $0.addressTo = addressTo
        }
        
        let req = CoreProto_Request.with {
            $0.createWalletTransaction = createWalletTransactionRequest
        }
        
        let res: CoreProto_CreateWalletTransactionResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.transaction
    }
    
    private func signWalletTransaction(
        _ core: OpaquePointer,
        transaction: String,
        keypair: Data
    ) async throws -> String?  {
        let signWalletTransactionRequest = CoreProto_SignWalletTransactionRequest.with {
            $0.transaction = transaction
            $0.keypair = keypair
        }
        
        let req = CoreProto_Request.with {
            $0.signWalletTransaction = signWalletTransactionRequest
        }
        
        let res: CoreProto_SignWalletTransactionResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.signature
    }
    
    private func submitWalletTransaction(
        _ core: OpaquePointer,
        transaction: String,
        signedPayloads: [CoreProto_SignedPayload]
    ) async throws -> CoreProto_Transaction?  {
        let submitWalletTransactionRequest = CoreProto_SubmitWalletTransactionRequest.with {
            $0.transaction = transaction
            $0.signedPayloads = signedPayloads
        }
        
        let req = CoreProto_Request.with {
            $0.submitWalletTransaction = submitWalletTransactionRequest
        }
        
        let res: CoreProto_SubmitWalletTransactionResponse? = try? await rustCallAsyncAwait(core, req)
        
        return res?.transaction
    }


    private func backtrace(_ core: OpaquePointer, sync: Bool, closure: @escaping (String) -> Void) {
        let req = CoreProto_Request.with {
            if sync {
                $0.getSyncBacktrace = CoreProto_GetBacktraceRequest()
            } else {
                $0.getAsyncBacktrace = CoreProto_GetBacktraceRequest()
            }
        }
        
        if sync {
            let res: CoreProto_GetBacktraceResponse = try! rustCallSync(core, req)
            closure(res.text)
        } else {
            rustCallAsyncClosure(core, req) { (res: CoreProto_GetBacktraceResponse) in closure(res.text) }
        }
    }
}
