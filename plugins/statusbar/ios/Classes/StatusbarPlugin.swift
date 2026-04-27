import Flutter
import UIKit

public class StatusbarPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    FullscreenOverlayStatusBarSwizzler.install()

    let channel = FlutterMethodChannel(
      name: "statusbar/status_bar",
      binaryMessenger: registrar.messenger()
    )

    let instance = StatusbarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
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

      // 🔴 CHECK Info.plist setting
      let isControllerBased =
        Bundle.main.object(
          forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance"
        ) as? Bool ?? true

      if isControllerBased == false {
        result(
          FlutterError(
            code: "CONFIG_ERROR",
            message:
              "UIViewControllerBasedStatusBarAppearance must be true in Info.plist for fullscreen_overlay to work.",
            details: nil
          )
        )
        return
      }

      StatusbarStatusBarController.setHidden(hidden)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}