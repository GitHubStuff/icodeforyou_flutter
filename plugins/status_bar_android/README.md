<!-- plugins/status_bar_android/README.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->

# status_bar_android

**Show or hide the Android status bar. Instantly. Nothing else.**

One static method. No fade, no slide, no 250 ms of the OS deciding how
it feels about your request. Tap, and the bar is gone. Tap, and it's
back. Same frame.

```dart
await StatusBar.setVisibility();                // hide (default)
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

It works. It is also **always animated**, and on Android 11+ it goes
through the engine's legacy `setSystemUiVisibility` path, which the
platform deprecated in API 30. The result is a visible fade on every
toggle, and nothing in `package:flutter/services.dart` can turn it off —
the animation belongs to the OS, not to Flutter.

The modern API, `WindowInsetsController`, animates too. But it also
offers `controlWindowInsetsAnimation()`, which hands the animation to
*you*. Call `finish()` the moment control arrives and the bar snaps to
its end state with no transition at all.

That call is only reachable from native code. So this plugin is the
twenty lines of Kotlin that make it, wrapped in the thinnest Dart
surface that can carry one `bool` across a method channel.

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

Calling it on iOS, macOS, web, Windows or Linux throws
`MissingPluginException`. That is the correct behaviour for a plugin
that claims one platform and means it.

---

## Installation

Two files. That's it.

### 1. `pubspec.yaml`

Inside the Melos workspace, by path:

```yaml
dependencies:
  flutter:
    sdk: flutter
  status_bar_android:
    path: ../../plugins/status_bar_android
```

Adjust the relative path to wherever your app lives. Then:

```bash
fvm flutter pub get
```

### 2. `android/app/build.gradle.kts` — `minSdk = 30`

The plugin's library module declares `minSdk = 30`, and Android's
manifest merger refuses to build an app whose `minSdk` is lower than
any library it links. The Flutter template writes
`minSdk = flutter.minSdkVersion`, which is below 30. Replace it with a
literal:

```kotlin
android {
    defaultConfig {
        // status_bar_android requires API 30 (Android 11).
        minSdk = 30
        targetSdk = flutter.targetSdkVersion
        // ...
    }
}
```

Nothing else in that file changes. If you skip this, the build fails
with:

```
uses-sdk:minSdkVersion 24 cannot be smaller than version 30 declared
in library [:status_bar_android]
```

### What you do **not** change

- `AndroidManifest.xml` — no permissions, no meta-data, no activity
  attributes.
- `MainActivity.kt` — the generated `FlutterActivity` subclass is
  enough.
- `settings.gradle.kts`, project-level `build.gradle.kts`,
  `gradle.properties` — plugin modules are wired in automatically.
  `GeneratedPluginRegistrant.java` is regenerated every build; never
  edit it.
- `proguard-rules.pro` — no reflection, no serialisation.
- No `androidx` dependency is pulled in.

---

## Usage

### `main()` — edge-to-edge first, then hide

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_bar_android/status_bar_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await StatusBar.setVisibility(); // start with the bar hidden
  runApp(const MyApp());
}
```

`ensureInitialized()` is required before any plugin call that happens
before `runApp`. The edge-to-edge line is strongly recommended — see
below.

### Toggling at runtime

```dart
import 'package:status_bar_android/status_bar_android.dart';

// Hide. `isHidden` defaults to true.
await StatusBar.setVisibility();

// Show.
await StatusBar.setVisibility(isHidden: false);
```

`StatusBar` is an `abstract final class` — a static namespace. It
cannot be instantiated, extended or implemented, and it holds no state.
The bar is either shown or hidden; the plugin does not remember which.
If your UI needs to know, keep the `bool` yourself:

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

### Fire-and-forget

The call returns a `Future<void>`. If you don't care when it lands:

```dart
unawaited(StatusBar.setVisibility());
```

(`unawaited` is in `dart:async`.)

### Why edge-to-edge matters

Hiding the bar changes the top window inset. If the Flutter view "fits
system windows" — the pre-Android-15 default — the view itself
**resizes** when the bar goes, and every widget relayouts mid-toggle.
Running edge-to-edge means the view already extends under the bar, so
hiding it changes only the inset: a `SafeArea` collapses, nothing else
moves.

Use `SafeArea` around content that must not sit under the bar while it
is visible. On Android 15+ with `targetSdk` 35+, edge-to-edge is already
the default and the call is a no-op.

### Behaviour while hidden

The system-bars behaviour is `BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE`: a
swipe from the top edge reveals the bar briefly, and it hides itself
again. This is Android's recommended immersive behaviour and is not
configurable.

### Errors

The future completes with a `PlatformException` when the native side
cannot act:

- **`NO_ACTIVITY`** — no activity is attached to the engine, e.g. the
  call came from a background isolate or a headless engine.
- **`NO_INSETS_CONTROLLER`** — the activity's window has no insets
  controller yet (its decor view is not attached). Nothing was done;
  retry after the first frame. The plugin reports this rather than
  pretending the call succeeded.
- **`INVALID_ARGUMENT`** — `isHidden` was missing or not a `bool`.
  Unreachable from the public Dart API; exists to make the channel
  contract total.

If the window is not yet attached when the call lands (control of the
animation is refused), the plugin falls back to the animated
`show()`/`hide()` so the call still takes effect — with the fade, once.

### Multi-platform apps

```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  await StatusBar.setVisibility();
}
```

Without the guard, other platforms throw `MissingPluginException`.

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
                                   Kotlin: WindowInsetsController, the
                                   instant finish, the swipe fallback
```

- `StatusBar` never sees a channel. `StatusBarAndroidPlatform.instance`
  is replaceable, so the facade is tested against a recording fake.
- `MethodChannelStatusBarAndroid` is tested against a mock binary
  messenger that pins the **wire contract** — channel name, method
  name, argument key — as string literals, not as the class's own
  constants.
- `StatusBarAndroidPlugin` is tested on the JVM with a mocked
  `StatusBarController`, injected through a factory, so no real
  `Window` is needed.
- `StatusBarController` is deliberately *not* unit-tested.
  `WindowInsetsController` is an `android.jar` stub on the JVM; the
  controller is verified on a device via the example app.

Nothing is computed in a static initialiser on the Kotlin side: the
classes stay mockable under stubbed Android APIs.

## Testing

- **Dart** — 12 tests, 100% LCOV. From `plugins/status_bar_android/`:

  ```bash
  fvm flutter test --coverage
  ```

- **Kotlin** — 8 tests. From
  `plugins/status_bar_android/example/android/`:

  ```bash
  ./gradlew testDebugUnitTest
  ```

- **On device** — from `plugins/status_bar_android/example/`:

  ```bash
  fvm flutter run --release -d <device-id>
  ```

The native suite needs a JDK 21 Gradle daemon and has a few known,
harmless build warnings. Both are documented — with the conditions
under which each warning stops being harmless — in
[`README-plugin-test.md`](README-plugin-test.md).

## Example app

`example/` is a single solid-colour screen with a single button,
labelled with the action it will perform. Tapping it is the demo. Run
it on an attached device in release mode — debug mode is slow at
everything and will mislead you about what "instant" means:

```bash
fvm flutter run --release -d <device-id>
```

See [`example/README.md`](example/README.md) for what else it does.

## Versioning

Every file in this package carries a two-line header: its repo-relative
path and `Version: <version> StatusBarAndroid`. The version there, in
`pubspec.yaml` and in `CHANGELOG.md` move together.

## License

See [`LICENSE`](LICENSE).

---

¹ The example app also opens on a solid-colour, icon-less launch
screen. That is Android theming, unrelated to this plugin, and is
documented in
[`example/README-change-splash.md`](example/README-change-splash.md).
