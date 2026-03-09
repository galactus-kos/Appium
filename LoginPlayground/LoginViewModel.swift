import Combine
import Foundation

enum LoginError: Error, Equatable {
    case invalidCredentials(username: String)
    case serverError
    case rateLimited

    var message: String {
        switch self {
        case .invalidCredentials(let username):
            return "Could not sign in as \(username). Please check credentials and try again."
        case .serverError:
            return "Something went wrong. Please try again."
        case .rateLimited:
            return "Too many attempts. Try again later."
        }
    }
}

final class LoginViewModel {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoginEnabled: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var alertMessage: String?

    private let session: SessionStore
    private let authenticator: Authenticator
    private var cancellables = Set<AnyCancellable>()
    private var loginCancellable: AnyCancellable?

    init(session: SessionStore, authenticator: Authenticator = Authenticator()) {
        self.session = session
        self.authenticator = authenticator

        Publishers.CombineLatest($username, $password)
            .map { username, password in
                !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoginEnabled)
    }

    func login() {
        let rawUsername = username
        let normalizedUsername = rawUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedUsername.isEmpty {
            alertMessage = LoginError.invalidCredentials(username: rawUsername).message
            return
        }

        isLoading = true

        loginCancellable = authenticator
            .login(username: rawUsername, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.alertMessage = error.message
                }
            }, receiveValue: { [weak self] loggedInUsername in
                self?.session.setLoggedIn(username: loggedInUsername)
            })
    }

    func consumeAlert() {
        alertMessage = nil
    }
}

struct Authenticator {
    private let validPairs: [(String, String)] = [
        ("qa", "automation"),
        ("user", "pass"),
        ("admin", "admin123"),
        ("john", "letmein")
    ]

    func login(username: String, password: String) -> AnyPublisher<String, LoginError> {
        let rawUsername = username
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let comparisonUsername = normalizedUsername.lowercased()

        let isVarianceAccount = comparisonUsername == "john"
        let delay: TimeInterval = {
            if isVarianceAccount {
                Double.random(in: 0.6...3.8) + (Bool.random() ? 0.0 : Double.random(in: 0.8...2.4))
            } else {
                Double.random(in: 0.15...1.4)
            }
        }()

        let shouldRateLimit = Int.random(in: 0...9) == 0
        let shouldServerFail = Int.random(in: 0...6) == 0
        let shouldIgnoreTap = Int.random(in: 0...7) == 0

        return Deferred {
            Future<String, LoginError> { promise in
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                    if shouldIgnoreTap {
                        return
                    }

                    if shouldRateLimit {
                        promise(.failure(.rateLimited))
                        return
                    }

                    if shouldServerFail, !isVarianceAccount {
                        promise(.failure(.serverError))
                        return
                    }

                    let match = validPairs.contains { $0.0 == comparisonUsername && $0.1 == password }

                    if match {
                        if isVarianceAccount, Int.random(in: 0...9) < 8 {
                            promise(.failure(.invalidCredentials(username: rawUsername)))
                        } else {
                            let returnedUsername = Bool.random() ? normalizedUsername : rawUsername
                            promise(.success(returnedUsername))
                        }
                        return
                    }

                    if comparisonUsername == "ghost", Int.random(in: 0...4) == 0 {
                        promise(.success(rawUsername))
                        return
                    }

                    promise(.failure(.invalidCredentials(username: rawUsername)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
