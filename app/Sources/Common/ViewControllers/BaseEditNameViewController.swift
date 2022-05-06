import UIKit

class BaseEditNameViewController: BaseEditViewController, UITextFieldDelegate {
    
    lazy var nameTextField = UITextField()..{
        $0.backgroundColor = .clear
        $0.textColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .edit
        $0.autocorrectionType = .no
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.delegate = self
    }

    override func setupLayoutKeyboard() {
        nameTextField.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight / 3))
    }

    func setupNameTextField() {
        nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        nameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupErrorLabel() {
        errorLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: -15).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel.adjustsFontSizeToFitWidth = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameTextField.becomeFirstResponder()
    }

    override func setupLayout() {
        setUpTheming()

        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        nameTextField.addSubview(errorLabel)

        setupTitleLabel()
        setupNameTextField()
        setupErrorLabel()
    }

    func setupTheme(theme: AppTheme) {

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

extension BaseEditNameViewController: Themed {
    
    func applyTheme(_ theme: AppTheme) {
        nameTextField.keyboardAppearance = theme.keyboardStyle

        setupTheme(theme: theme)
    }
}
