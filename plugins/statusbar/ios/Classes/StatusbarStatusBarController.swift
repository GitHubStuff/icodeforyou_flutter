import UIKit

final class StatusbarStatusBarController {
  private static var hidden = false

  static func isHidden() -> Bool {
    hidden
  }

  static func setHidden(_ value: Bool) {
    hidden = value

    DispatchQueue.main.async {
      UIApplication.shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?
        .rootViewController?
        .setNeedsStatusBarAppearanceUpdate()
    }
  }
}