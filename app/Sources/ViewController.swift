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
}
