import Flutter
import UIKit

final class StatusBarFlutterViewController: FlutterViewController {
    private var hideStatusBar = false

    override var prefersStatusBarHidden: Bool {
        hideStatusBar
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    func setStatusBarHidden(_ hidden: Bool) {
        hideStatusBar = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
}