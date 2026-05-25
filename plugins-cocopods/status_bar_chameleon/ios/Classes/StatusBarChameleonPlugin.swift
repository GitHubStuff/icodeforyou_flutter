import Flutter
import UIKit

public class StatusBarChameleonPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    StatusBarChameleonSwizzler.install()

    let channel = FlutterMethodChannel(
      name: "status_bar_chameleon/status_bar",
      binaryMessenger: registrar.messenger()
    )

    let instance = StatusBarChameleonPlugin()
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

      StatusBarChameleonController.setHidden(hidden)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
