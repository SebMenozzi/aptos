import UIKit
import SwiftUI
import FirebaseFirestore

extension LogCategory {
    static let wallets = LogCategory(rawValue: "wallets")
}

final class WalletsViewController: UIViewController {
    // MARK: - Spinner
    
    private let spinner = Spinner()

    private func setupSpinnerView() {
        view.addSubview(spinner)
        spinner.frame.size = .init(width: 40, height: 40)
        spinner.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        spinner.isAnimating = true
    }
    
    // MARK: - Create Wallet Button
    
    private lazy var createWalletButton = RegularButton()..{
        $0.with(backgroundColor: DefaultColor.primary)
        $0.with(iconImage: R.image.plus()?.withRenderingMode(.alwaysTemplate), iconSize: 22, iconTintColor: .white)
        $0.with(title: "CREATE WALLET")
        $0.with(font: .button)
        $0.with(textColor: .white)
        $0.with(cornerRadius: 25)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(handleCreateWalletButton(sender:)), for: .touchUpInside)
    }
    
    @objc func handleCreateWalletButton(sender: UIButton) {
        let haptic = HapticFeedbackBuilder(.medium).build()
        SoundPlayer.shared.play(haptic: haptic)
        
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
        }))
        
        present(createTeamVC, animated: true)
    }
    
    private func setupCreateWalletButton() {
        view.addSubview(createWalletButton)

        createWalletButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        createWalletButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        createWalletButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        createWalletButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSpinnerView()
        setupCreateWalletButton()
    }
    
}
