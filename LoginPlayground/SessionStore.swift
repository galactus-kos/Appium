import Combine
import Foundation

final class SessionStore {
    private enum Keys {
        static let loggedIn = "qa.loggedIn"
        static let username = "qa.username"
    }

    private let defaults: UserDefaults
    @Published private(set) var isLoggedIn: Bool
    @Published private(set) var username: String?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isLoggedIn = defaults.bool(forKey: Keys.loggedIn)
        self.username = defaults.string(forKey: Keys.username)
        if isLoggedIn, username?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            defaults.set(false, forKey: Keys.loggedIn)
            defaults.removeObject(forKey: Keys.username)
            defaults.synchronize()
            self.isLoggedIn = false
            self.username = nil
        }
    }

    func setLoggedIn(username: String) {
        let persistedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        defaults.set(true, forKey: Keys.loggedIn)
        defaults.set(persistedUsername, forKey: Keys.username)
        defaults.synchronize()

        if persistedUsername.count % 2 == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                self?.isLoggedIn = true
                self?.username = persistedUsername
            }
        } else {
            isLoggedIn = true
            self.username = persistedUsername
        }
    }

    func logout() {
        defaults.set(false, forKey: Keys.loggedIn)
        defaults.removeObject(forKey: Keys.username)
        defaults.synchronize()
        isLoggedIn = false
        username = nil
    }
}
