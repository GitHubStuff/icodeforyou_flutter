<!-- plugins/status_bar_ios/INSTALL.md -->

# Installing `status_bar_ios` in a Flutter app

`status_bar_ios` lets Dart code show or hide the iOS status bar (the strip at
the top with the time, battery and signal) instantly, and makes the app
launch to a solid dark screen with no white flash and no status bar flicker.

## Who this guide is for

You have just created a Flutter app with `flutter create` and you want it to
use this plugin. You edit files in **VS Code** or **Android Studio**. You
never have to open Xcode. Xcode must be _installed_ (Flutter needs it to
build for iOS), but every change below is a text edit.

Everything happens inside the app's `ios/` folder. That folder is a small,
real iOS app that Flutter generated for you; it hosts your Flutter code.
Flutter rewrites some files in there on every build — this guide only
touches the ones it leaves alone.

Plain-language summary of what you are about to do and why:

- iOS asks the app's **root view controller** whether the status bar should
  be hidden. Flutter's default one (`FlutterViewController`) always says
  "shown". The plugin ships a replacement (`StatusBarFlutterViewController`)
  that Dart can talk to. **Section 3** swaps it in.
- Before any view controller exists, iOS reads **`Info.plist`** to decide
  about the status bar. **Section 4** tells it "hidden".
- The first thing on screen is the **launch screen**, then the root view
  controller's own empty view, then Flutter's first frame. Both of the
  first two are white by default. **Sections 3 and 5** paint them.

---

## Contents

1. [Requirements](#1-requirements)
2. [Add the Dart dependency](#2-add-the-dart-dependency)
3. [Edit `Main.storyboard`](#3-edit-mainstoryboard)
4. [Edit `Info.plist`](#4-edit-infoplist)
5. [Edit `LaunchScreen.storyboard`](#5-edit-launchscreenstoryboard)
6. [Optional: launch with the status bar
   shown](#6-optional-launch-with-the-status-bar-shown)
7. [Build and verify](#7-build-and-verify)
8. [Use the plugin from Dart](#8-use-the-plugin-from-dart)
9. [Troubleshooting](#9-troubleshooting)
10. [Checklist](#10-checklist)

- [Appendix A: the plugin-side change](#appendix-a-the-plugin-side-change)
- [Appendix B: choosing the launch
  colour](#appendix-b-choosing-the-launch-colour)

---

## 1. Requirements

### 1a. Swift toolchain

The plugin is written for Swift 6.4 (`swift-tools-version: 6.4` in its
`Package.swift`). In a terminal, run:

```sh
xcrun swift --version
```

The first line must say `Swift version 6.4` or higher. If it says less,
update Xcode from the Mac App Store before continuing. Nothing else in this
guide will work on an older Swift.

### 1b. Minimum iOS version (deployment target)

The plugin needs **iOS 17.0 or later**. Your app declares its minimum iOS
version in one file:

```text
ios/Runner.xcodeproj/project.pbxproj
```

In VS Code / Android Studio this file is inside the `ios/Runner.xcodeproj`
folder. It is long and looks like gibberish — that is normal. Do not
reformat it, do not let your editor "fix" its indentation. You will change a
number or nothing at all.

1. Open `ios/Runner.xcodeproj/project.pbxproj`.
2. Search (⌘F) for:

   ```text
   IPHONEOS_DEPLOYMENT_TARGET
   ```

3. You will find it **several times** (three in a fresh `flutter create`
   app — one per build configuration: Debug, Release, Profile). Each hit
   looks like this, with a tab-indented line:

   **Before** (an app created with an older Flutter template):

   ```text
   				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
   ```

   **After**:

   ```text
   				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
   ```

> **⚠️ Change a value ONLY if it is LESS than 17.0.**
> If a hit already says `17.0`, `18.0` or anything higher, **leave that line
> exactly as it is**. Lowering a deployment target can break other plugins
> the app uses. Check **every** hit — all of them must end up ≥ 17.0.

4. Save the file. That is the only edit to `project.pbxproj` in this guide.

### 1c. No CocoaPods

The plugin is a **Swift Package Manager** (SwiftPM) plugin. It cannot be
linked by CocoaPods. Look in the `ios/` folder for a file named:

```text
ios/Podfile
```

- **A fresh `flutter create` app has no `Podfile`.** If you do not see
  one, you are done with this section — skip to section 2.
- **If `ios/Podfile` exists**, the app was created by an older Flutter or
  was migrated from one, and it still uses CocoaPods.

> **⚠️ Do NOT just delete `ios/Podfile`.** That leaves `Podfile.lock`,
> the `Pods/` folder, `Pods` entries inside `project.pbxproj` and
> `#include` lines in `ios/Flutter/*.xcconfig` behind, and the build fails
> in a much more confusing way than before.
>
> What to do instead: stop here and follow Flutter's official guide
> **"Swift Package Manager for app developers"** on `docs.flutter.dev`
> (search that title). It walks through turning SwiftPM on and removing
> CocoaPods cleanly. Come back to section 2 when `ios/Podfile` is gone and
> `flutter build ios` succeeds without it.

---

## 2. Add the Dart dependency

The plugin is **not published on pub.dev**. Your app finds it on disk.

Open the app's `pubspec.yaml` (the one at the app's root, next to `lib/`).

**Before** (as `flutter create` wrote it, trimmed):

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
```

**After — app lives inside the `icodeforyou_flutter` monorepo**
(the workspace resolves the version for you):

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  status_bar_ios: ^1.0.0
```

**After — app lives anywhere else** (point at the plugin folder; adjust the
relative path to wherever `plugins/status_bar_ios` is on your disk):

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  status_bar_ios:
    path: ../plugins/status_bar_ios
```

Save, then in a terminal **at the app's root**:

```sh
flutter pub get
```

This does two things in `ios/` for you. Check both so you know the plugin
is really wired in before you edit anything else.

Check 1 — the plugin is registered with Flutter:

```sh
grep -n status_bar_ios ios/Runner/GeneratedPluginRegistrant.m
```

Expected: a few lines mentioning `status_bar_ios` / `StatusBarIosPlugin`.

Check 2 — the plugin is linked into the iOS build:

```sh
grep -n status_bar_ios ios/Flutter/ephemeral/Packages/*/Package.swift
```

Expected: two lines, one `.package(name: "status_bar_ios", ...)` and one
`.product(name: "status-bar-ios", ...)`.

If either command prints nothing, the dependency did not resolve. Re-read
the `pubspec.yaml` edit (indentation is two spaces, `path:` is indented
under the package name) and run `flutter pub get` again. Do not continue
until both checks pass.

---

## 3. Edit `Main.storyboard`

**File:** `ios/Runner/Base.lproj/Main.storyboard`

This is the one edit that makes the plugin work. The file is XML. It
describes a single screen (a "view controller") that iOS creates at launch
and that Flutter then draws into. You will change two things on it: which
Swift class it is, and what colour its empty view has.

Open the file. Search (⌘F) for:

```text
customClass="FlutterViewController"
```

You land on a `<viewController ...>` tag. In the real file it is one long
line; it is wrapped here so it fits on the page. Below it, a few lines down,
is the `<color key="backgroundColor" ...>` tag of its view.

**Before** (fresh `flutter create`):

```xml
<viewController id="BYZ-38-t0r"
    customClass="FlutterViewController"
    sceneMemberID="viewController">
  <layoutGuides>
    <viewControllerLayoutGuide type="top" id="y3c-jy-aDJ"/>
    <viewControllerLayoutGuide type="bottom" id="wfy-db-euE"/>
  </layoutGuides>
  <view key="view" contentMode="scaleToFill" id="8bC-Xf-vdC">
    <rect key="frame" x="0.0" y="0.0" width="600" height="600"/>
    <autoresizingMask key="autoresizingMask"
        widthSizable="YES" heightSizable="YES"/>
    <color key="backgroundColor" white="1" alpha="1"
        colorSpace="custom" customColorSpace="calibratedWhite"/>
  </view>
</viewController>
```

**After**:

```xml
<viewController id="BYZ-38-t0r"
    customClass="StatusBarFlutterViewController"
    customModule="status_bar_ios"
    sceneMemberID="viewController">
  <layoutGuides>
    <viewControllerLayoutGuide type="top" id="y3c-jy-aDJ"/>
    <viewControllerLayoutGuide type="bottom" id="wfy-db-euE"/>
  </layoutGuides>
  <view key="view" contentMode="scaleToFill" id="8bC-Xf-vdC">
    <rect key="frame" x="0.0" y="0.0" width="600" height="600"/>
    <autoresizingMask key="autoresizingMask"
        widthSizable="YES" heightSizable="YES"/>
    <color key="backgroundColor" red="0" green="0" blue="0" alpha="1"
        colorSpace="custom" customColorSpace="sRGB"/>
  </view>
</viewController>
```

Exactly three differences:

1. `customClass="FlutterViewController"` →
   `customClass="StatusBarFlutterViewController"`.
   This is the plugin's replacement class.
2. A **new** attribute `customModule="status_bar_ios"`.
   It tells iOS which Swift module contains that class. Type it exactly:
   lowercase, underscores. It is the plugin's SwiftPM target name — **not**
   `status-bar-ios` (that is the product name) and **not** `Runner`.
3. The view's `<color ...>` line changes from white to black
   (`red="0" green="0" blue="0"`, in sRGB). This is the colour on screen
   for the split second between the launch screen and Flutter's first
   frame. Leave it white and you get a white flash on a dark launch.

Do **not** add `customModuleProvider="target"`. That attribute means "look
for the class in the app itself", and the class is in the plugin.

Your `id="..."` values may differ from the ones shown. Leave them alone;
only the attributes named above change.

### Want a colour other than black?

(Also in [Appendix B](#appendix-b-choosing-the-launch-colour), on its own,
for when you come back later just to change the colour.)

The plugin does not care what colour the launch is, only that the status
bar matches. You set the colour in **two** places and they must agree:
this file (section 3) and `LaunchScreen.storyboard` (section 5).

Colours are red/green/blue values from `0` to `1`. To convert from a hex
colour such as `#4B0082`: take each pair, convert to decimal, divide by 255
(`4B` = 75 → `75 / 255` = `0.294`).

| Colour      | `red=`  | `green=` | `blue=` |
| ----------- | ------- | -------- | ------- |
| black       | `0`     | `0`      | `0`     |
| indigo      | `0.294` | `0`      | `0.510` |
| dark purple | `0.188` | `0.067`  | `0.345` |
| dark green  | `0`     | `0.392`  | `0`     |
| navy        | `0`     | `0`      | `0.502` |
| dark red    | `0.545` | `0`      | `0`     |

Example — indigo instead of black, in the `<color>` line above:

```xml
    <color key="backgroundColor" red="0.294" green="0" blue="0.510"
        alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

The plugin always draws the status bar with **white** text and icons, so
pick a **dark** colour. On a light background the time and battery would be
white-on-light and unreadable.

Save the file.

---

## 4. Edit `Info.plist`

**File:** `ios/Runner/Info.plist`

This XML file is a list of settings iOS reads about the app before it
runs any code. It is a flat list of `<key>name</key>` followed by the
value. You add three settings. Order does not matter, but putting them at
the end keeps them easy to find.

Scroll to the bottom. **Before** (last lines of a fresh `flutter create`
app):

```xml
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
</dict>
</plist>
```

**After**:

```xml
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<true/>
	<key>UIStatusBarHidden</key>
	<true/>
	<key>UIStatusBarStyle</key>
	<string>UIStatusBarStyleLightContent</string>
</dict>
</plist>
```

The three new entries go **inside** `</dict>`, never after it.

What they do:

- **`UIViewControllerBasedStatusBarAppearance` = true** — "let the root view
  controller decide". That is how `StatusBarFlutterViewController` gets to
  show and hide the bar. iOS actually defaults to true when the key is
  missing, but writing it down stops someone from later adding it as
  `false` to fix an unrelated problem and silently breaking this plugin.
- **`UIStatusBarHidden` = true** — hides the status bar **while the launch
  screen is showing**, before any view controller exists. Without it the
  bar is visible over your launch colour for a moment and then vanishes:
  exactly the flicker this plugin exists to remove.
- **`UIStatusBarStyle` = `UIStatusBarStyleLightContent`** — white text and
  icons during that same launch moment, matching what the plugin uses
  afterwards.

If your `Info.plist` already contains any of these three keys (some
templates add `UIStatusBarHidden`), do not add a duplicate — just make sure
the existing value matches the one above.

Save the file.

---

## 5. Edit `LaunchScreen.storyboard`

**File:** `ios/Runner/Base.lproj/LaunchScreen.storyboard`

This is the very first picture iOS shows when the app icon is tapped, before
a single line of your code runs. In a fresh app it is a white screen with a
centred `LaunchImage` (which is itself an empty, transparent image). You
make the screen your launch colour and remove the image.

Open the file. Search (⌘F) for:

```text
customColorSpace="sRGB"
```

You land in the view's `<color>` line. The whole `<view>` block around it:

**Before** (fresh `flutter create`):

```xml
<view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
  <autoresizingMask key="autoresizingMask"
      widthSizable="YES" heightSizable="YES"/>
  <subviews>
    <imageView opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES"
        contentMode="center" image="LaunchImage"
        translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4">
    </imageView>
  </subviews>
  <color key="backgroundColor" red="1" green="1" blue="1" alpha="1"
      colorSpace="custom" customColorSpace="sRGB"/>
  <constraints>
    <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX"
        secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1a2-6s-vTC"/>
    <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerY"
        secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="4X2-HB-R7a"/>
  </constraints>
</view>
```

**After** (black; use the same red/green/blue you chose in section 3 if you
picked another colour):

```xml
<view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
  <autoresizingMask key="autoresizingMask"
      widthSizable="YES" heightSizable="YES"/>
  <color key="backgroundColor" red="0" green="0" blue="0" alpha="1"
      colorSpace="custom" customColorSpace="sRGB"/>
</view>
```

Three differences:

1. `red="1" green="1" blue="1"` → your colour (`0 0 0` for black).
2. The whole `<subviews>...</subviews>` block is deleted — that was the
   image.
3. The whole `<constraints>...</constraints>` block is deleted — those
   positioned the image. Deleting the image and leaving its constraints
   makes the storyboard invalid, so both go together.

Your `id="..."` values may differ; that is fine.

Want to keep a logo on the launch screen? Keep `<subviews>` and
`<constraints>`, change only the colour, and replace the `LaunchImage`
assets in `ios/Runner/Assets.xcassets/LaunchImage.imageset/` with images
that have a transparent background. A white-backed PNG just moves the white
flash into the image.

Save the file.

---

## 6. Optional: launch with the status bar shown

By default the app launches with the status bar **hidden** and your Dart
code shows it later. If you want it **shown** from the first frame instead,
that is one more `Info.plist` setting — the plugin reads it at startup.
(The plugin code that reads it is in
[Appendix A](#appendix-a-the-plugin-side-change).)

**File:** `ios/Runner/Info.plist`

**Before** (your section 4 result):

```xml
	<key>UIStatusBarHidden</key>
	<true/>
	<key>UIStatusBarStyle</key>
	<string>UIStatusBarStyleLightContent</string>
</dict>
</plist>
```

**After**:

```xml
	<key>UIStatusBarHidden</key>
	<false/>
	<key>UIStatusBarStyle</key>
	<string>UIStatusBarStyleLightContent</string>
	<key>StatusBarIosHiddenAtLaunch</key>
	<false/>
</dict>
</plist>
```

Two changes:

1. `UIStatusBarHidden` → `<false/>` so the bar is visible over the launch
   screen too.
2. New key **`StatusBarIosHiddenAtLaunch`** = `<false/>`. This is the
   plugin's own setting: it decides what `StatusBarFlutterViewController`
   does the moment it appears. Missing key means `true` (hidden), which is
   why section 4 did not need it.

Both must agree, otherwise the bar blinks between the launch screen and the
first frame.

---

## 7. Build and verify

From the app's root, build once from the terminal. This makes Flutter
regenerate its iOS glue and lets SwiftPM compile the plugin:

```sh
flutter build ios --debug --no-codesign
```

A clean build ends with `Built build/ios/iphoneos/Runner.app` or similar.
If it fails, go to section 9.

Then run it on a simulator or a device:

```sh
flutter run
```

What you should see on a cold start (kill the app first, then tap its icon):

1. Your launch colour, **no status bar**.
2. Still your colour, still no status bar — **no white flash**.
3. Flutter's first frame, status bar still hidden.
4. When your Dart code calls `StatusBar.setVisibility(isHidden: false)`,
   the bar appears **instantly** with **white** time/battery/signal.

(If you did section 6, the bar is visible in steps 1–3 instead.)

---

## 8. Use the plugin from Dart

```dart
import 'package:status_bar_ios/status_bar_ios.dart';

// Hide (the default when isHidden is omitted).
await StatusBar.setVisibility(isHidden: true);

// Show.
await StatusBar.setVisibility(isHidden: false);
```

On the web and on every platform other than iOS the call does nothing, so
you can call it from shared code without `Platform` checks.

A minimal toggle button, to try it out:

```dart
import 'package:flutter/material.dart';
import 'package:status_bar_ios/status_bar_ios.dart';

class StatusBarToggle extends StatefulWidget {
  const StatusBarToggle({super.key});

  @override
  State<StatusBarToggle> createState() => _StatusBarToggleState();
}

class _StatusBarToggleState extends State<StatusBarToggle> {
  bool _isHidden = true;

  Future<void> _toggle() async {
    final next = !_isHidden;
    await StatusBar.setVisibility(isHidden: next);
    if (!mounted) return;
    setState(() => _isHidden = next);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _toggle,
      child: Text(_isHidden ? 'Show status bar' : 'Hide status bar'),
    );
  }
}
```

If the native side cannot do what you asked, the `Future` completes with a
`PlatformException`. Its `code` tells you why:

- **`no_controller`** — the root view controller is not a
  `StatusBarFlutterViewController`. Section 3 was skipped or
  `customModule` is wrong.
- **`no_window`** — the app has no window yet; you called too early in
  startup. Call after the first frame (e.g. from a button, or after
  `WidgetsBinding.instance.addPostFrameCallback`).
- **`argument`** — `isHidden` was not a `bool`. Cannot happen through the
  Dart API above; listed for completeness.

---

## 9. Troubleshooting

**Console says `Unknown class StatusBarFlutterViewController in Interface
Builder file`, then a blank screen or a crash.**

- `customModule="status_bar_ios"` is missing or misspelled, or you added
  `customModuleProvider="target"`. Re-check the section 3 "After" block
  character by character.
- The plugin is not linked. Run the two `grep` checks from section 2. If
  either prints nothing, fix `pubspec.yaml` and `flutter pub get`.
- Stale build output. Run:

  ```sh
  flutter clean
  ```

  then build again (section 7).

**`PlatformException(no_controller, …)` on every call.**

- `Main.storyboard` still has `customClass="FlutterViewController"`.
  Section 3.

**Status bar is visible over the launch screen, then disappears.**

- `UIStatusBarHidden` is missing or `<false/>` in `Info.plist`. Section 4.

**White flash between the launch screen and Flutter.**

- The `<color>` in `LaunchScreen.storyboard` is still `1 1 1` (section 5),
  or
- the `<color>` in `Main.storyboard` is still `white="1"` (section 3), or
- you kept the `LaunchImage` and its PNGs have a white background.

**Status bar shows, but its text is black on your dark colour.**

- Something set `UIViewControllerBasedStatusBarAppearance` to `<false/>`.
  Section 4 says `<true/>`.

**Build fails mentioning `swift-tools-version`, `Package.swift` or
`status_bar_ios`.**

- Swift older than 6.4: section 1a.
- A deployment target below 17.0 slipped through: section 1b — search
  again, check **every** hit.
- `ios/Podfile` exists: section 1c.

**`flutter pub get` says it cannot find `status_bar_ios`.**

- Outside the monorepo you must use the `path:` form (section 2) and the
  path must be relative to the app's `pubspec.yaml`. `ls` the path to
  confirm it contains the plugin's `pubspec.yaml`.

---

## 10. Checklist

Tick every line before asking for help.

- [ ] `xcrun swift --version` reports 6.4 or higher
- [ ] Every `IPHONEOS_DEPLOYMENT_TARGET` in `project.pbxproj` is ≥ 17.0
      (changed **only** the ones that were lower)
- [ ] No `ios/Podfile`
- [ ] `status_bar_ios` in `pubspec.yaml`; `flutter pub get` run; both
      `grep` checks print results
- [ ] `Main.storyboard`: `customClass="StatusBarFlutterViewController"`
- [ ] `Main.storyboard`: `customModule="status_bar_ios"`, and no
      `customModuleProvider`
- [ ] `Main.storyboard`: view `<color>` is your dark launch colour
- [ ] `Info.plist`: `UIViewControllerBasedStatusBarAppearance` `<true/>`
- [ ] `Info.plist`: `UIStatusBarHidden` `<true/>` (or `<false/>` with
      `StatusBarIosHiddenAtLaunch` `<false/>`, section 6)
- [ ] `Info.plist`: `UIStatusBarStyle` `UIStatusBarStyleLightContent`
- [ ] `LaunchScreen.storyboard`: same colour as `Main.storyboard`, image
      and constraints removed (or image replaced with a transparent one)
- [ ] `flutter build ios --debug --no-codesign` succeeds
- [ ] Cold start: launch colour, no flash, no status bar flicker
- [ ] `StatusBar.setVisibility(isHidden: false)` shows a white status bar

---

## Appendix A: the plugin-side change

Everything in sections 1–10 happens in the **app**. Section 6 relies on one
change inside the **plugin**: `StatusBarFlutterViewController` reads its
launch setting from the app's `Info.plist` instead of requiring a Swift
subclass. This appendix records that change so the plugin and this guide
can be checked against each other. If the plugin already contains the
"After" file below, there is nothing to do here.

### Where the file lives

```text
plugins/status_bar_ios/
└── ios/
    └── status_bar_ios/
        ├── Package.swift
        └── Sources/
            └── status_bar_ios/
                ├── PrivacyInfo.xcprivacy
                ├── StatusBar.swift
                ├── StatusBarFlutterViewController.swift   ← this file
                └── StatusBarIosPlugin.swift
```

Full path:

```text
plugins/status_bar_ios/ios/status_bar_ios/Sources/status_bar_ios/StatusBarFlutterViewController.swift
```

Why exactly there: `Package.swift` declares one target named
`status_bar_ios`, and SwiftPM compiles every `.swift` file under
`Sources/status_bar_ios/` into it. The target name is also the Swift
**module** name — the `customModule="status_bar_ios"` the app's storyboard
points at in section 3. A file anywhere else is not compiled.

How it reaches the app: `flutter pub get` (section 2) adds the plugin's
package to the app's iOS build. The class is compiled into the app; nobody
copies this file into any app. `Bundle.main` inside it is the **running
app's** bundle, which is why the app's own `Info.plist` key is what it
reads.

### Before

```swift
// plugins/status_bar_ios/ios/status_bar_ios/Sources/status_bar_ios/StatusBarFlutterViewController.swift
import Flutter
import UIKit

/// A `FlutterViewController` whose status bar is set before the first frame is
/// drawn, so there is no visible change between the launch screen and Flutter.
///
/// Apps use this as the root view controller instead of `FlutterViewController`
/// (set it as the custom class of the view controller in `Main.storyboard`,
/// module `status_bar_ios`).
///
/// Status bar content is always light (white time, battery, signal),
/// matching the Android plugin's launch theme. Override
/// `isStatusBarHiddenAtLaunch` to start with the status bar shown.
open class StatusBarFlutterViewController: FlutterViewController {

  /// Whether the status bar is hidden when the controller is created.
  open var isStatusBarHiddenAtLaunch: Bool { true }

  private lazy var isStatusBarHidden: Bool = isStatusBarHiddenAtLaunch

  override open var prefersStatusBarHidden: Bool { isStatusBarHidden }

  override open var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

  override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    .none
  }

  /// Hides the status bar when `isHidden` is `true`, shows it otherwise.
  /// Instant.
  func setStatusBarHidden(_ isHidden: Bool) {
    isStatusBarHidden = isHidden
    setNeedsStatusBarAppearanceUpdate()
  }
}
```

### After

```swift
// plugins/status_bar_ios/ios/status_bar_ios/Sources/status_bar_ios/StatusBarFlutterViewController.swift
import Flutter
import UIKit

/// A `FlutterViewController` whose status bar is set before the first frame is
/// drawn, so there is no visible change between the launch screen and Flutter.
///
/// Apps use this as the root view controller instead of `FlutterViewController`
/// (`customClass="StatusBarFlutterViewController"`,
/// `customModule="status_bar_ios"` in `Main.storyboard`).
///
/// Status bar content is always light (white time, battery, signal),
/// matching the Android plugin's launch theme.
///
/// Launch visibility is configuration, not code: the app sets the
/// `Info.plist` boolean `StatusBarIosHiddenAtLaunch`. Absent means hidden.
/// Subclasses may still override `isStatusBarHiddenAtLaunch`.
open class StatusBarFlutterViewController: FlutterViewController {

  /// `Info.plist` key read by `isStatusBarHiddenAtLaunch`.
  public static let hiddenAtLaunchKey = "StatusBarIosHiddenAtLaunch"

  /// Whether the status bar is hidden when the controller is created.
  ///
  /// Reads `StatusBarIosHiddenAtLaunch` from the main bundle's `Info.plist`.
  /// A missing key or a non-boolean value means `true` (hidden).
  open var isStatusBarHiddenAtLaunch: Bool {
    Bundle.main.object(forInfoDictionaryKey: Self.hiddenAtLaunchKey) as? Bool
      ?? true
  }

  private lazy var isStatusBarHidden: Bool = isStatusBarHiddenAtLaunch

  override open var prefersStatusBarHidden: Bool { isStatusBarHidden }

  override open var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

  override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    .none
  }

  /// Hides the status bar when `isHidden` is `true`, shows it otherwise.
  /// Instant.
  func setStatusBarHidden(_ isHidden: Bool) {
    isStatusBarHidden = isHidden
    setNeedsStatusBarAppearanceUpdate()
  }
}
```

### What changed

1. `isStatusBarHiddenAtLaunch` no longer returns a hard-coded `true`. It
   reads the `Info.plist` boolean `StatusBarIosHiddenAtLaunch` from the
   app's bundle and falls back to `true` when the key is missing or is not
   a boolean.
2. The key name is a `public static let` so the plugin has exactly one
   place that spells it.
3. The property stays `open`, so subclassing still works for anyone who
   wants it; this guide no longer needs it.

Behaviour for every app that does **not** set the key is identical to
before: hidden at launch.

---

## Appendix B: choosing the launch colour

The launch is black by default. Any dark colour works. The colour is set
in **two files** and they must agree, otherwise the screen changes shade
between the launch screen and Flutter's first frame:

| File                                            | Section |
| ----------------------------------------------- | ------- |
| `ios/Runner/Base.lproj/Main.storyboard`         | 3       |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard` | 5       |

In both files the colour is the view's `<color key="backgroundColor" ...>`
line. Each of `red=`, `green=`, `blue=` is a number from `0` to `1`.

### Converting a hex colour

For a hex colour such as `#4B0082` (indigo): split into pairs `4B`, `00`,
`82`; convert each to decimal (`75`, `0`, `130`); divide each by `255`
(`0.294`, `0`, `0.510`).

### Ready-made values

| Colour      | `red=`  | `green=` | `blue=` |
| ----------- | ------- | -------- | ------- |
| black       | `0`     | `0`      | `0`     |
| indigo      | `0.294` | `0`      | `0.510` |
| dark purple | `0.188` | `0.067`  | `0.345` |
| dark green  | `0`     | `0.392`  | `0`     |
| navy        | `0`     | `0`      | `0.502` |
| dark red    | `0.545` | `0`      | `0`     |

### Before / after — `Main.storyboard`

**Before** (black, the section 3 result):

```xml
    <color key="backgroundColor" red="0" green="0" blue="0" alpha="1"
        colorSpace="custom" customColorSpace="sRGB"/>
```

**After** (indigo):

```xml
    <color key="backgroundColor" red="0.294" green="0" blue="0.510"
        alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

### Before / after — `LaunchScreen.storyboard`

**Before** (black, the section 5 result):

```xml
  <color key="backgroundColor" red="0" green="0" blue="0" alpha="1"
      colorSpace="custom" customColorSpace="sRGB"/>
```

**After** (indigo — same three numbers as above):

```xml
  <color key="backgroundColor" red="0.294" green="0" blue="0.510"
      alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

### Keep it dark

The plugin always draws the status bar with **white** text and icons. On a
light launch colour the time and battery would be white-on-light and
unreadable. If you need a light launch screen, that is a plugin change
(`preferredStatusBarStyle`), not an app edit — ask before doing it.

### After changing the colour

A storyboard edit is picked up by a normal rebuild, but iOS caches launch
screens aggressively. If the old colour still shows: delete the app from the
device or simulator, then run

```sh
flutter clean
```

and build again (section 7).
