import UIKit
import FirebaseFirestore
import SwiftUI

extension LogCategory {
    static let username = LogCategory(rawValue: "username")
}

class UsernameViewController: BaseEditNameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.autocapitalizationType = .none
        titleLabel.text = "Choose a username"
    }

    override func next() {
        super.next()

        guard let username = nameTextField.text, !username.isEmpty else {
            setError(with: "Username required!")
            return
        }
        
        let newAccount = createAccount(Current.core())
        
        var ref: DocumentReference? = nil
        ref = Current.firestore().collection(FirestoreDB.Collections.account).addDocument(data: [
            FirestoreDB.Account.username: username,
            FirestoreDB.Account.public_key: newAccount.publicKey
        ]) { [weak self] err in
            guard let self = self else { return }
            
            if let err = err {
                self.setError(with: "Error: \(err)")
                
                Logger.shared.error(err.localizedDescription, category: .username)
            } else {
                Logger.shared.info("Document added with ID: \(ref!.documentID)", category: .username)
                
                let createTeamVC = UIHostingController(rootView: CreateWalletView(createWalletTapped: { publicKeys in
                    let wallet = createWallet(Current.core(), publicKeys: publicKeys)
                    
                    var ref: DocumentReference? = nil
                    ref = Current.firestore().collection(FirestoreDB.Collections.wallet).addDocument(data: [
                        FirestoreDB.Wallet.address: wallet.address,
                        FirestoreDB.Wallet.public_keys: publicKeys,
                    ]) { [weak self] err in
                        guard let self = self else { return }
                        
                        if let err = err {
                            Logger.shared.error(err.localizedDescription, category: .wallets)
                        } else {
                            Logger.shared.info("Document added with ID: \(ref!.documentID)", category: .wallets)
                        }
                        
                        self.dismiss(animated: true)
                    }
                }))..{
                    $0.modalTransitionStyle = .crossDissolve
                    $0.modalPresentationStyle = .fullScreen
                }
                self.present(createTeamVC, animated: true)
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let _ = string.rangeOfCharacter(from: .uppercaseLetters) {
            return false
        }

        if string.containsEmoji {
            return false
        }

        return true
    }

    override func setupTheme(theme: AppTheme) {
        super.setupTheme(theme: theme)

        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "username",
            attributes: [NSAttributedString.Key.foregroundColor: theme.textColor.withAlpha(0.4)]
        )
    }
}
