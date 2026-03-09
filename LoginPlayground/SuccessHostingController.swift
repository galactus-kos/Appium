import SwiftUI
import UIKit

final class SuccessHostingController: UIHostingController<SuccessView> {
    init(username: String?, onLogout: @escaping () -> Void) {
        super.init(rootView: SuccessView(username: username, onLogout: onLogout))
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        nil
    }
}
