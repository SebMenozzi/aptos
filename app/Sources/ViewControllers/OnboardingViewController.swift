import UIKit
import SwiftUI

public final class OnboardingViewController: UIViewController {
    
    private func addShadowLayer(view: UIView) {
        view.layer.backgroundColor = UIColor.clear.cgColor
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 5.0
    }

    private lazy var logoLabel = UILabel()..{
        $0.text = "APTOS"
        $0.font = .bigTitle
        $0.textColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let containerView = UIView()..{
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private lazy var titleTextView = UITextView()..{
        $0.text = "Let's go 🎉🤘"
        $0.backgroundColor = UIColor.clear
        $0.textColor = UIColor.white
        $0.font = .title
        $0.isEditable = false
        $0.isSelectable = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        addShadowLayer(view: $0)
    }

    private let termsLabel = UILabel()..{
        $0.text = "I agree with the "
        $0.textColor = UIColor.white.withAlphaComponent(0.6)
        $0.font = .small
        $0.numberOfLines = 1
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private lazy var termsButtonLabel = UILabel()..{
        $0.text = "Terms & Policy"
        $0.textColor = .white
        $0.font = .small
        $0.numberOfLines = 1
        $0.isUserInteractionEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false

        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTerms))
        tap.minimumPressDuration = 0
        $0.addGestureRecognizer(tap)
    }

    @objc func handleTerms(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            termsButtonLabel.alpha = 0.6
        } else if gesture.state == .ended {
            termsButtonLabel.alpha = 1.0

            let alert = UIAlertController(
                title: "Terms & Policy",
                message:"\nBy using our product, you accept that you have full responsability on managing your wallets. Any unfortunate loss, stolen account, will be on you, and only you.\n\nHave fun 🤪",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "🆒", style: .default, handler: nil))

            present(alert, animated: true)
        }
    }

    // login button

    private lazy var createAccountButton = RegularButton()..{
        $0.with(backgroundColor: DefaultColor.primary)
        $0.with(textColor: .white)
        $0.with(title: "CREATE ACCOUNT")
        $0.with(font: .button)
        $0.with(cornerRadius: 25)
        $0.isEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(createAccount(sender:)), for: .touchUpInside)
    }

    private lazy var switchTermsControl = Switch()..{
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setup(false)
        $0.delegate = self
    }
    
    // MARK: - Background gradient

    private let meshGradientViewController = MeshGradientViewController()

    private func gradientConfiguration() -> MeshGradientViewController.Configuration {
        return .init(
            backgroundColor: .black,
            foregroundColors: [
                DefaultColor.primary.withAlphaComponent(0.2)
            ]
        )
    }

    private func setupMeshGradientViewController() {
        addChild(meshGradientViewController)
        view.addSubview(meshGradientViewController.view)

        let newConfig = gradientConfiguration()
        meshGradientViewController.updateConfiguration(newConfig)
    }

    private var popGesture: UIGestureRecognizer?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationController = navigationController,
           navigationController.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.popGesture = navigationController.interactivePopGestureRecognizer

            if let gestureRecognizer = navigationController.interactivePopGestureRecognizer {
                self.navigationController?.view.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationController = navigationController,
           let gesture = self.popGesture {
            navigationController.view.addGestureRecognizer(gesture)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMeshGradientViewController()

        view.addSubview(logoLabel)

        view.addSubview(containerView)
        containerView.addSubview(titleTextView)
        containerView.addSubview(termsLabel)
        containerView.addSubview(termsButtonLabel)
        containerView.addSubview(switchTermsControl)

        containerView.addSubview(createAccountButton)

        setupLogoLabel()

        setupcontainerView()
        
        setupCreateAccountButton()
        setupTitleTextView()

        setupTermsButton()
    }

    private func setupLogoLabel() {
        logoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        logoLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        logoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
    }

    private func setupcontainerView() {
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func setupTitleTextView() {
        titleTextView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        titleTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleTextView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    }

    private func setupTermsButton() {
        termsLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        termsLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor).isActive = true
        termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true

        termsButtonLabel.leadingAnchor.constraint(equalTo: termsLabel.trailingAnchor).isActive = true
        termsButtonLabel.centerYAnchor.constraint(equalTo: termsLabel.centerYAnchor).isActive = true

        switchTermsControl.centerYAnchor.constraint(equalTo: termsLabel.centerYAnchor).isActive = true
        switchTermsControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }

    private func setupCreateAccountButton() {
        createAccountButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 15).isActive = true
        createAccountButton.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        createAccountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension OnboardingViewController {
    
    @objc func createAccount(sender: UIButton) {
        let vc = UsernameViewController()..{
            $0.modalTransitionStyle = .crossDissolve
            $0.modalPresentationStyle = .fullScreen
        }
        present(vc, animated: true)
    }
}

extension OnboardingViewController: SwitchDelegate {
    
    func didUpdateValue(isOn: Bool) {
        createAccountButton.isEnabled = isOn
    }
}
