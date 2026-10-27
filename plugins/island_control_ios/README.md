# island_control_ios

Shows or hides the iOS status bar ("island") instantly, and keeps the screen
dark from the launch screen through Flutter's first frame. iOS counterpart of
`island_control_android`.

## Usage

```dart
import 'package:island_control_ios/island_control_ios.dart';

await IslandControlIos.setIsland(isHidden: true);
await IslandControlIos.setIsland(isHidden: false);
```

Calls are no-ops on web and on every platform other than iOS.

## App setup (required)

Three things in the app's `ios/Runner`, otherwise iOS ignores the plugin and
the launch is not dark.

### 1. Root view controller

Open `Main.storyboard`, select the view controller, and in the Identity
inspector set:

- Class: `IslandFlutterViewController`
- Module: `island_control_ios` (untick "Inherit Module From Target")

The island is hidden before the first frame. To launch with it shown, subclass
and override:

```swift
import island_control_ios

final class ShownIslandViewController: IslandFlutterViewController {
  override var isIslandHiddenAtLaunch: Bool { false }
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

`UIViewControllerBasedStatusBarAppearance` lets `IslandFlutterViewController`
drive visibility. `UIStatusBarHidden` hides the island during the launch
screen, before any view controller exists.

### 3. Launch screen

In `LaunchScreen.storyboard`, set the view's background to black (System Black
Color). This is the frame shown until `IslandFlutterViewController` draws.

## Errors

`setIsland` completes with a `PlatformException` when the root view controller
is not an `IslandFlutterViewController`:

| code            | meaning                                                |
|-----------------|--------------------------------------------------------|
| `argument`      | `isHidden` was not a `bool`                            |
| `no_window`     | no key window (app not yet in the foreground)          |
| `no_controller` | root view controller is not `IslandFlutterViewController` |

## Requirements

- iOS 17+
- Swift 6 (swift-tools 6.4), Swift Package Manager only