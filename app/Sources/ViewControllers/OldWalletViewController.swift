import UIKit

import FirebaseCore
import FirebaseFirestore

public final class OldWalletViewController: UIViewController {
    private var core: OpaquePointer {
        let aptosRestURL = "https://fullnode.devnet.aptoslabs.com"
        let aptosFaucetURL = "https://faucet.devnet.aptoslabs.com"

        return create_core("info", aptosRestURL, aptosFaucetURL)
    }

    var db: Firestore!

    override public func viewDidLoad() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        getWallets(userPublicKey: "test")
    }

    /** Pure Aptos Functions */
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
        keypair: String
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

    /** Wrapper functions */
    private func createTransaction(amount: UInt64, to: String, from: String) async {
        guard let transaction = try? await createWalletTransaction(core, amount: 1500, addressFrom: from, addressTo: to) else { return }
        print("📝 New transaction: \(transaction)")
        
        var ref: DocumentReference? = nil
        ref = db.collection(FirestoreDB.Collections.transaction).addDocument(data: [
            FirestoreDB.Transaction.amount: amount,
            FirestoreDB.Transaction.rawTransaction: transaction,
            FirestoreDB.Transaction.signatures: [],
            FirestoreDB.Transaction.hash: transaction.hash,
            FirestoreDB.Transaction.walletIdFrom: from,
            FirestoreDB.Transaction.walletIdTo: to,
            FirestoreDB.Transaction.numRequiredSignatures: 1 // TODO
        ]) { err in
            if let err = err {
                print("Error adding transaction document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    private func signTransaction(transaction: String, keypair: String) async {
        guard let signature = try? await signWalletTransaction(core, transaction: transaction, keypair: keypair) else { return }
        print("✅ Transaction signed: \(signature)")
        
        db.collection(FirestoreDB.Collections.transaction)
            .whereField(FirestoreDB.Transaction.hash, isEqualTo: transaction.hash)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting transactions from Firestore to sign: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData([
                        FirestoreDB.Transaction.signatures: FieldValue.arrayUnion([signature])
                    ]) { err in
                        if let err = err {
                            print("Error signing transaction document: \(err)")
                        } else {
                            print("Transaction document successfully signed")
                        }
                    }
                }
            }
        }
    }
    
    private func getWallets(userPublicKey: String) {
        db.collection(FirestoreDB.Collections.wallet)
            .whereField(FirestoreDB.Wallet.public_keys, arrayContains: userPublicKey)
            .addSnapshotListener({ querySnapshot, err in
                guard let snapshot = querySnapshot else {
                    print("Error fetching wallets for public key \(userPublicKey)")
                    return
                }
                
                for document in snapshot.documents {
                    print("Fetched wallet \(document.data())")
                    
                    self.getTransactions(walletAddress: document.data()["address"] as? String ?? "")
                }
            })
    }
    
    private func getTransactions(walletAddress: String) {
        db.collection(FirestoreDB.Collections.transaction)
            .whereField(FirestoreDB.Transaction.walletIdFrom, isEqualTo: walletAddress)
            .addSnapshotListener({ querySnapshot, err in
            guard let snapshot = querySnapshot else {
                print("Error fetching transactions for wallet address \(walletAddress)")
                return
            }
            
            for document in snapshot.documents {
                print(document.data())
            }
        })
    }
}

