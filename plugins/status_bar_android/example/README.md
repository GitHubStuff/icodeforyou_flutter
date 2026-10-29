<!-- plugins/status_bar_android/example/README.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->

# status_bar_android — example app

A single solid-colour screen with a single button. The button is
labelled with the action it will perform — "Hide Status Bar" or
"Show Status Bar" — and tapping it is the demo: the bar snaps in or out
with no transition. Swipe down from the top edge while hidden and it
appears briefly, then hides itself again.

## Run

Release mode on a real Android 11+ device. Debug mode is slow at
everything and will mislead you about what "instant" means:

```bash
fvm flutter devices
fvm flutter run --release -d <device-id>
```

## What it demonstrates

Two things, and only the first one is the plugin.

### 1. The plugin: instant show/hide

`lib/main.dart` does exactly what the plugin's README says to do:

- `WidgetsFlutterBinding.ensureInitialized()`
- `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` so the
  Flutter view already sits under the bar and hiding it changes only
  the inset, not the view size
- `StatusBar.setVisibility()` before `runApp`, so the bar is gone before
  the first frame
- a `StatefulWidget` holding one `bool`, awaiting the call before
  flipping it, so the label and the bar never disagree

Nothing else. No Cubit, no DI, no navigation — it's a proof of concept
for one method.

### 2. Not the plugin: the launch screen

The app opens on a solid colour with no app icon and no flash between
the OS splash, the launch window and the first Flutter frame. That is
Android theming — `colors.xml`, two `styles.xml`, the manifest's theme
references and a couple of deletions — and works in any Flutter app
whether or not this plugin is installed.

It lives in this example because "opens on a solid colour with no
status bar" is the effect people want, and half of it is theming. The
step-by-step is in [`README-change-splash.md`](README-change-splash.md).
To change the colour, edit one value in
`android/app/src/main/res/values/colors.xml` and the matching `const`
in `lib/main.dart`.

## Android-side changes in this app

For anyone diffing this against a fresh `flutter create` template:

- `android/app/build.gradle.kts` — `minSdk = 30` (required by the
  plugin).
- `android/gradle.properties` — `org.gradle.java.home` pinned to JDK 21
  so the plugin's Kotlin unit tests can run from here. Not needed to
  build or run the app; see the plugin's `README-plugin-test.md`.
- `android/app/src/main/res/` — launch-screen theming per
  `README-change-splash.md`.

## Running the plugin's native tests from here

The plugin's Kotlin tests are hosted by this app's Gradle project:

```bash
cd android && ./gradlew testDebugUnitTest
```

Expect 7 tests passing. Details, prerequisites and the known warnings
are in the plugin's `README-plugin-test.md`.
