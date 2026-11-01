<!-- plugins/status_bar_android/README.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->

# status_bar_android

**Show or hide the Android status bar. Instantly. Nothing else.**

One static method. No fade, no slide, no 250 ms of the OS deciding how
it feels about your request. Tap, and the bar is gone. Tap, and it's
back. Same frame.

```dart
await StatusBar.setVisibility(isHidden: true);  // hide
await StatusBar.setVisibility(isHidden: false); // show
```

That's the whole API.

---

## Why this exists

Flutter can already hide the status bar:

```dart
SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.manual,
  overlays: [SystemUiOverlay.bottom],
);
```

It works. It is also **always animated**, and nothing in
`package:flutter/services.dart` can turn the animation off — it belongs
to the OS, not to Flutter.

Android's modern API, `WindowInsetsController`, animates too, but it
also offers `controlWindowInsetsAnimation()`, which hands the animation
to _you_. Call `finish()` the moment control arrives and the bar snaps
to its end state with no transition at all. That call is only reachable
from native code. This plugin is the few dozen lines of Kotlin that
make it, wrapped in the thinnest Dart surface that can carry one `bool`
across a method channel.

## What it is — and isn't

- **Platform** — Android only. Permanently.
- **Minimum** — Android 11 (API 30).
- **Shape** — Standalone plugin. **Not** a federated implementation:
  there is no `status_bar` umbrella package and no
  `status_bar_platform_interface`. The `_android` suffix is
  descriptive, not structural.
- **Scope** — The status bar. The navigation bar is never touched.
- **Dependencies** — `plugin_platform_interface` (Dart). None on
  Android: platform `android.view.*` APIs only, no `androidx`.

### ⚠️ WARNING — Android only, and it will not check for you

> **The plugin does not check which platform it is running on.**
>
> On any platform other than Android — iOS, web, macOS, Windows, Linux —
> `StatusBar.setVisibility` throws **`MissingPluginException`**. It does
> not silently do nothing. If your app builds for more than one
> platform, **you** guard the call:
>
> ```dart
> import 'package:flutter/foundation.dart'
>     show TargetPlatform, defaultTargetPlatform, kIsWeb;
>
> if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
>   await StatusBar.setVisibility(isHidden: true);
> }
> ```
>
> This is deliberate. The plugin is the layer closest to the OS; deciding
> what "not Android" means for your app belongs to your app, not to a
> plugin that claims one platform and means it.

---

## Installation

Full step-by-step, written for someone who has never opened an
`android/` folder: **[`README-install.md`](README-install.md)**.

The short version:

1. Add `status_bar_android` to `pubspec.yaml` and run `flutter pub get`.
2. In `android/app/build.gradle.kts`, set `minSdk = 30` (only if the
   current value is lower). Android's manifest merger refuses an app
   whose `minSdk` is below any library it links, and this library's is 30. Skipping this fails the build with
   `uses-sdk:minSdkVersion … cannot be smaller than version 30`.

Nothing else is required. `AndroidManifest.xml`, `MainActivity.kt`,
the Gradle settings and `GeneratedPluginRegistrant.java` all stay as
Flutter generated them.

`README-install.md` also covers something this plugin does **not** do
but almost everyone installing it wants: launching to a solid-color,
icon-less screen with no flash before the first Flutter frame. That is
pure Android theming under `android/app/src/main/res/`, and it works in
any Flutter app.

---

## Usage

### The call

```dart
import 'package:status_bar_android/status_bar_android.dart';

await StatusBar.setVisibility(isHidden: true);
await StatusBar.setVisibility(isHidden: false);
```

`isHidden` is required. There is no default, so every call says what it
does.

`StatusBar` is an `abstract final class` — a static namespace. It cannot
be instantiated, extended or implemented, and it holds no state. The bar
is either shown or hidden; the plugin does not remember which. If your
UI needs to know, keep the `bool` yourself:

```dart
class _MyPageState extends State<MyPage> {
  bool _isHidden = true;

  Future<void> _toggle() async {
    final isHidden = !_isHidden;
    await StatusBar.setVisibility(isHidden: isHidden);
    if (!mounted) {
      return;
    }
    setState(() => _isHidden = isHidden);
  }
}
```

### Hidden from the first frame

Call the plugin before `runApp`. One extra line is needed because the
framework is not up yet:

```dart
Future<void> main() async {
  // Required before any plugin call that happens before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  await StatusBar.setVisibility(isHidden: true);
  runApp(const MyApp());
}
```

### Fire-and-forget

```dart
unawaited(StatusBar.setVisibility(isHidden: true));
```

(`unawaited` is in `dart:async`.)

### Layout stays put

Hiding the bar changes the top window inset. The plugin puts the window
edge-to-edge before touching the bar, so only the inset changes: a
`SafeArea` collapses and nothing else moves. There is no setup for this.
Wrap content that must not sit under the bar while it is visible in a
`SafeArea`.

### Behavior while hidden

A swipe from the top edge reveals the bar briefly, and it hides itself
again (`BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE`). This is Android's
recommended immersive behavior and is not configurable.

### Errors

The future completes with a `PlatformException` when the native side
cannot act:

- **`NO_ACTIVITY`** — no activity is attached to the engine, e.g. the
  call came from a background isolate or a headless engine.
- **`NO_INSETS_CONTROLLER`** — the activity's window has no insets
  controller yet (its decor view is not attached). Nothing was done;
  retry after the first frame.
- **`INVALID_ARGUMENT`** — `isHidden` was missing or not a `bool`.
  Unreachable from the public Dart API; exists to make the channel
  contract total.

If the system refuses control of the animation (window not yet
attached), the plugin falls back to the animated `show()`/`hide()` so
the call still takes effect — with the fade, once.

On a non-Android platform the future completes with
`MissingPluginException` — see the **WARNING** above.

---

## How it's built

Five small pieces, each with one job:

```
StatusBar                          Dart facade: the public API
  └─ StatusBarAndroidPlatform      Dart abstract contract; the mock seam
       └─ MethodChannelStatusBarAndroid
                                   Dart → MethodChannel("status_bar_android")
            └─ StatusBarAndroidPlugin.kt
                                   Kotlin: channel + activity lifecycle
                 └─ StatusBarController.kt
                                   Kotlin: edge-to-edge, WindowInsetsController,
                                   the instant finish, the swipe fallback
```

Every layer is unit-tested in isolation: the Dart layers against a
recording fake and a mock binary messenger, the Kotlin layers on the JVM
with Mockito. How to run the native tests, and the build warnings you
will see, are in [`README-plugin-test.md`](README-plugin-test.md).

## Example app

[`example/`](example/) is a single solid-color screen with a single
button, labeled with the action it will perform. Tapping it is the demo.
Run it on an Android 11+ device in release mode — debug mode is slow at
everything and will mislead you about what "instant" means:

```bash
flutter run --release -d <device-id>
```

## License

See [`LICENSE`](LICENSE).
