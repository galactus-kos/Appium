import SwiftUI

struct SuccessView: View {
    let username: String?
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Success")
                .font(.largeTitle.weight(.bold))
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            Button(action: onLogout) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(24)
    }

    private var message: String {
        if let username, !username.isEmpty {
            return "You are signed in as \(username)."
        }
        return "You are signed in."
    }
}
