# status_bar_ios

Shows or hides the iOS status bar instantly, and keeps the screen
dark from the launch screen through Flutter's first frame. iOS counterpart of
`status_bar_android`.

## Usage

```dart
import 'package:status_bar_ios/status_bar_ios.dart';

await StatusBarIos.setStatusBar(isHidden: true);
await StatusBarIos.setStatusBar(isHidden: false);
```

Calls are no-ops on web and on every platform other than iOS.

## App setup (required)

Three things in the app's `ios/Runner`, otherwise iOS ignores the plugin and
the launch is not dark.

### 1. Root view controller

Open `Main.storyboard`, select the view controller, and in the Identity
inspector set:

- Class: `StatusBarFlutterViewController`
- Module: `status_bar_ios` (untick "Inherit Module From Target")

The status bar is hidden before the first frame. To launch with it shown,
subclass and override:

```swift
import status_bar_ios

final class ShownStatusBarViewController: StatusBarFlutterViewController {
  override var isStatusBarHiddenAtLaunch: Bool { false }
}
```

and use that class in the storyboard instead.

### 2. Info.plist

```xml
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
<key>UIStatusBarHidden</key>
<true/>
<key>UIStatusBarStyle</key>
<string>UIStatusBarStyleLightContent</string>
```

`UIViewControllerBasedStatusBarAppearance` lets `StatusBarFlutterViewController`
drive visibility. `UIStatusBarHidden` hides the status bar during the launch
screen, before any view controller exists.

### 3. Launch screen

In `LaunchScreen.storyboard`, set the view's background to black (System Black
Color). This is the frame shown until `StatusBarFlutterViewController` draws.

## Errors

`setStatusBar` completes with a `PlatformException` when the root view
controller is not a `StatusBarFlutterViewController`:

| code            | meaning                                           |
|-----------------|---------------------------------------------------|
| `argument`      | `isHidden` was not a `bool`                       |
| `no_window`     | no key window (app not yet in the foreground)     |
| `no_controller` | root is not `StatusBarFlutterViewController`      |

## Requirements

- iOS 17+
- Swift 6 (swift-tools 6.4), Swift Package Manager only