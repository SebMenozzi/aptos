import UIKit

class BaseEditViewController: UIViewController {
    
    let titleLabel = UILabel()..{
        $0.backgroundColor = .clear
        $0.textColor = .white
        $0.font = .title
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        titleLabel.adjustsFontSizeToFitWidth = true
    }

    let errorLabel = UILabel()..{
        $0.backgroundColor = UIColor.clear
        $0.textColor = .white
        $0.font = .small
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var floatingButtonModal: FloatingButtonModal?

    private func setupFloatingButtonModal() {
        floatingButtonModal = FloatingButtonModal()
        floatingButtonModal?.delegate = self
        floatingButtonModal?.parentView = view
        floatingButtonModal?.show(icon: R.image.next(), iconSize: 24, color: DefaultColor.primary)
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        self.navigationController?.isNavigationBarHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var popGesture: UIGestureRecognizer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationController = navigationController,
           navigationController.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.popGesture = navigationController.interactivePopGestureRecognizer

            if let gestureRecognizer = navigationController.interactivePopGestureRecognizer {
                self.navigationController?.view.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationController = navigationController,
           let gesture = self.popGesture {
            navigationController.view.addGestureRecognizer(gesture)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFloatingButtonModal()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        floatingButtonModal?.destroy()
        floatingButtonModal = nil
    }

    private func setErrorBackground() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor(r: 252, g: 43, b: 107)
        })
    }

    func setDefaultBackground() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.view.backgroundColor = DefaultColor.primary
        })
    }

    func setError(with text: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = text
            self.setErrorBackground()
            self.floatingButtonModal?.stopLoading()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupKeyboardObserver()

        setupTitleLabel()

        setupLayout()
    }

    func setupLayout() {

    }

    func next() {
        floatingButtonModal?.startLoading()
    }

    /* keyboard methods */

    var keyboardHeight: CGFloat = 0

    @objc func keyboardWillChangeFrameNotification(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardFrameY = keyboardFrame.cgRectValue.origin.y

        if keyboardFrameY == UIScreen.main.bounds.size.height {
            keyboardHeight = 0
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }

        setupLayoutKeyboard()
    }

    func setupLayoutKeyboard() {

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension BaseEditViewController: FloatingButtonModalDelegate {
    func onPress() {
        next()
    }
}
