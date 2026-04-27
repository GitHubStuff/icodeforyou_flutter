import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let window = window else { return }

    let controller = StatusBarFlutterViewController()
    window.rootViewController = controller

    let channel = FlutterMethodChannel(
      name: "statusbar/status_bar",
      binaryMessenger: controller.binaryMessenger
    )

      channel.setMethodCallHandler { [weak controller] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "setStatusBarHidden":
        guard
          let args = call.arguments as? [String: Any],
          let hidden = args["hidden"] as? Bool
        else {
          result(
            FlutterError(
              code: "BAD_ARGS",
              message: "Expected { hidden: Bool }",
              details: nil
            )
          )
          return
        }

        controller?.setStatusBarHidden(hidden)
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
