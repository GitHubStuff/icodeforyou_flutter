# IosGlows.md

iOS can get a cleaner fullscreen/black-startup result than Android.

This document records the setup for:

```txt
✅ black launch screen
✅ no launch logo
✅ status bar can be hidden cleanly
✅ no Android-style fullscreen warning
✅ works with fullscreen_overlay plugin
```

---

## 1. Info.plist

File:

```txt
programs/startup_demo/ios/Runner/Info.plist
```

Add this inside the top-level `<dict>`:

```xml
<key>UIRequiresFullScreen</key>
<true/>
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
```

Example placement:

```xml
<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>

<key>UIRequiresFullScreen</key>
<true/>
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>

<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

---

## 2. LaunchScreen.storyboard

File:

```txt
programs/startup_demo/ios/Runner/Base.lproj/LaunchScreen.storyboard
```

Set the root view background to black.

Find:

```xml
<color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

Replace with:

```xml
<color key="backgroundColor" red="0" green="0" blue="0" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

---

### Remove launch logo from storyboard

Delete the `imageView` block if present:

```xml
<subviews>
    <imageView opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4">
    </imageView>
</subviews>
```

Delete the matching constraints:

```xml
<constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1a2-6s-vTC"/>
<constraint firstItem="YRO-k0-Ey4" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="4X2-HB-R7a"/>
```

Delete the resource reference at the bottom:

```xml
<resources>
    <image name="LaunchImage" width="168" height="185"/>
</resources>
```

After this, the launch screen should be a plain black root view.

---

## 3. Reusing the launch screen

You can save the black launch screen as a template file, for example:

```txt
LaunchScreen-copy.storyboard
```

For a new app, copy it into:

```txt
ios/Runner/Base.lproj/LaunchScreen.storyboard
```

Make sure the new app's `Info.plist` has:

```xml
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

The file must either be named `LaunchScreen.storyboard`, or `Info.plist` must point to the name you are using.

---

## 4. StatusBarFlutterViewController.swift

File:

```txt
programs/startup_demo/ios/Runner/StatusBarFlutterViewController.swift
```

Content:

```swift
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
```

If this file is added manually, open Xcode and verify:

```txt
Target Membership → Runner
```

is checked.

Open Xcode from the app folder:

```zsh
cd programs/startup_demo
open ios/Runner.xcworkspace
```

---

## 5. SceneDelegate.swift

File:

```txt
programs/startup_demo/ios/Runner/SceneDelegate.swift
```

Content:

```swift
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
      name: "fullscreen_overlay/status_bar",
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
```

Important channel name:

```txt
fullscreen_overlay/status_bar
```

This must match the Dart/plugin channel.

### SceneDelegate.swift

```txt
Purpose: app startup + window wiring
```

It is responsible for:

```txt
✔ creating / attaching the root view controller
✔ setting up your MethodChannel
✔ connecting Flutter ↔ native
```

Specifically
```txt
SceneDelegate
→ creates StatusBarFlutterViewController
→ assigns it as rootViewController
→ wires MethodChannel (fullscreen_overlay/status_bar)
```

### StatusBarFlutterViewController.swift

```txt
Purpose: actual status bar control
```

It is responsible for:

```txt
✔ deciding if status bar is hidden
✔ responding to iOS system queries
✔ applying UI changes (hide/show)
```

Specifically:

```swift
override var prefersStatusBarHidden: Bool
```

This is what iOS actually reads.

#### How they work together
```txt
Flutter (Dart)
    ↓
MethodChannel call
    ↓
SceneDelegate
    ↓
StatusBarFlutterViewController.setStatusBarHidden(...)
    ↓
iOS system asks:
    prefersStatusBarHidden?
    ↓
status bar updates
```

#### Clean mental model
```txt
SceneDelegate                  = wiring / plumbing
StatusBarFlutterViewController = behavior / control
```

#### Why both are needed

Because:
```txt
FlutterViewController alone cannot override status bar behavior
```

It is necessary:
```txt
subclass it → StatusBarFlutterViewController
```

Then:
```txt
inject it → via SceneDelegate
```
---

## 6. Dart plugin call

Use the plugin API, not `SystemChrome`, for this iOS status-bar path.

```dart
await FullscreenOverlay.setStatusBarHidden(hidden: true);
```

Restore:

```dart
await FullscreenOverlay.setStatusBarHidden(hidden: false);
```

Import:

```dart
import 'package:fullscreen_overlay/fullscreen_overlay.dart';
```

---

## 7. main.dart startup usage

Example:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await FullscreenOverlay.setStatusBarHidden(hidden: true);
  }

  ServiceRegistry.R.stage(ThemeDescriptor(name: 'Theme'));
  await ServiceRegistry.R.register('Theme');

  runApp(providers);
}
```

Required imports:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fullscreen_overlay/fullscreen_overlay.dart';
```

---

## 8. OverlayHost usage

Best place to control the status bar is the UI side-effect layer, such as `OverlayHost`'s `BlocListener`.

Example:

```dart
listener: (context, overlayChild) {
  unawaited(
    FullscreenOverlay.setStatusBarHidden(
      hidden: overlayChild != null,
    ),
  );
}
```

Do not put platform side effects inside the cubit.

---

## 9. Clean run

Run from the app folder:

```zsh
cd programs/startup_demo
flutter clean
flutter pub get
flutter run
```

If Xcode cannot find `StatusBarFlutterViewController`, verify the file is in:

```txt
ios/Runner/StatusBarFlutterViewController.swift
```

and that Xcode target membership includes:

```txt
Runner
```

---

## Final iOS behavior

This setup gets:

```txt
✅ black native launch screen
✅ no launch logo
✅ clean status-bar hide/show
✅ no fullscreen warning
✅ plugin-controlled runtime behavior
```

Unlike Android, iOS lets this setup behave cleanly without the "Viewing full screen" warning.
