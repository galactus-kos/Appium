import Combine
import UIKit

final class RootViewController: UIViewController {
    private let session = SessionStore()
    private var cancellables = Set<AnyCancellable>()

    private lazy var loginViewController: LoginViewController = {
        let viewModel = LoginViewModel(session: session)
        return LoginViewController(viewModel: viewModel)
    }()

    private var successController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        session.$isLoggedIn
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loggedIn in
                self?.show(loggedIn: loggedIn)
            }
            .store(in: &cancellables)

        show(loggedIn: session.isLoggedIn)
    }

    private func show(loggedIn: Bool) {
        if loggedIn {
            let controller = SuccessHostingController(
                username: session.username,
                onLogout: { [weak self] in
                    self?.session.logout()
                }
            )
            transition(to: controller)
            successController = controller
        } else {
            transition(to: loginViewController)
            successController = nil
        }
    }

    private func transition(to child: UIViewController) {
        let existing = children.first
        if existing === child { return }

        existing?.willMove(toParent: nil)
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        child.didMove(toParent: self)

        if let existing {
            existing.view.removeFromSuperview()
            existing.removeFromParent()
        }
    }
}
