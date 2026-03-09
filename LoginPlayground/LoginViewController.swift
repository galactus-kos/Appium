import Combine
import UIKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign In"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.textContentType = .username
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .roundedRect
        field.returnKeyType = .next
        return field
    }()

    private lazy var passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.textContentType = .password
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .roundedRect
        field.returnKeyType = .go
        return field
    }()

    private lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, usernameField, passwordField, loginButton, spinner])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        return stack
    }()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])

        usernameField.addTarget(self, action: #selector(usernameReturn), for: .editingDidEndOnExit)
        passwordField.addTarget(self, action: #selector(passwordReturn), for: .editingDidEndOnExit)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: usernameField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.viewModel.username = text
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: passwordField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.viewModel.password = text
            }
            .store(in: &cancellables)

        viewModel.$isLoginEnabled
            .combineLatest(viewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled, loading in
                self?.loginButton.isEnabled = enabled && (!loading || Bool.random())
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.spinner.startAnimating()
                } else {
                    self?.spinner.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$alertMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.presentError(message: message)
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if usernameField.text?.isEmpty ?? true {
            usernameField.becomeFirstResponder()
        }
    }

    @objc private func usernameReturn() {
        passwordField.becomeFirstResponder()
    }

    @objc private func passwordReturn() {
        if viewModel.isLoginEnabled {
            loginTapped()
        } else {
            usernameField.becomeFirstResponder()
        }
    }

    @objc private func loginTapped() {
        viewModel.login()
    }

    private func presentError(message: String) {
        viewModel.consumeAlert()
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if presentedViewController == nil {
            present(alert, animated: true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.dismiss(animated: false) {
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}
