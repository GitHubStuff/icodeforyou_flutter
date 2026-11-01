<!-- plugins/status_bar_android/INSTALL-Android.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->
# Installing `status_bar_android` in a Flutter app

`status_bar_android` lets Dart code show or hide the Android status bar
(the strip at the top with the clock, battery and signal) **instantly** —
no fade — and this guide also makes the app launch to one solid colour
with no app icon and no flash before Flutter's first frame.

## Who this guide is for

You have just created a Flutter app with
`flutter create --platforms=android` and want it to use this plugin. You
edit files in **VS Code** or **Android Studio**. Every change is a text
edit or a file deletion; you never open a GUI configuration screen.

Everything happens inside the app's `android/` folder. That folder is a
small, real Android app that Flutter generated for you; it hosts your
Flutter code. Flutter rewrites some files in there on every build — this
guide only touches the ones it leaves alone.

Plain-language summary of what you are about to do and why:

- The plugin needs **Android 11 (API 30)** or newer. **Section 1** raises
  the app's minimum Android version to match.
- **Section 2** adds the plugin to the app.
- When the user taps the icon, Android shows three things before your
  first Flutter frame: the **system splash** (Android 12+), the **launch
  window** painted with the app's `LaunchTheme`, then the **normal
  window** painted with `NormalTheme` while Flutter starts. The template
  makes those white/light with a Flutter logo. **Sections 3–7** make all
  three one solid colour with no icon.
- **Section 9** is the one Dart call.

---

## Contents

1. [Requirements](#1-requirements)
2. [Add the Dart dependency](#2-add-the-dart-dependency)
3. [Create `colors.xml`](#3-create-colorsxml)
4. [Edit `values/styles.xml`](#4-edit-valuesstylesxml)
5. [Create `values-v31/styles.xml`](#5-create-values-v31stylesxml)
6. [Delete the template leftovers](#6-delete-the-template-leftovers)
7. [Check `AndroidManifest.xml`](#7-check-androidmanifestxml)
8. [Build and verify](#8-build-and-verify)
9. [Use the plugin from Dart](#9-use-the-plugin-from-dart)
10. [Troubleshooting](#10-troubleshooting)
11. [Checklist](#11-checklist)
- [Appendix A: changing the launch
  colour](#appendix-a-changing-the-launch-colour)

---

## 1. Requirements

### 1a. A device or emulator on Android 11 or newer

The plugin uses APIs that exist from Android 11 (API level 30). It will
not install on anything older. Check your test device under
Settings → About phone → Android version, or pick an API 30+ system image
for the emulator.

### 1b. Minimum Android version (`minSdk`)

Your app declares its own minimum Android version in one file:

```text
android/app/build.gradle.kts
```

Android refuses to build an app whose minimum is **lower** than a library
it uses. The plugin's minimum is 30, so the app's must be 30 or higher.

1. Open `android/app/build.gradle.kts`.
2. Search (⌘F) for:

   ```text
   minSdk
   ```

3. You will find it once, inside `defaultConfig { ... }`.

   **Before** (what `flutter create` writes; its long comment lines are
   left out here):

   ```kotlin
   defaultConfig {
       applicationId = "com.example.my_app"
       minSdk = flutter.minSdkVersion
       targetSdk = flutter.targetSdkVersion
       versionCode = flutter.versionCode
       versionName = flutter.versionName
   }
   ```

   **After**:

   ```kotlin
   defaultConfig {
       applicationId = "com.example.my_app"
       // status_bar_android requires Android 11 (API 30).
       minSdk = 30
       targetSdk = flutter.targetSdkVersion
       versionCode = flutter.versionCode
       versionName = flutter.versionName
   }
   ```

   Exactly one line changes: `minSdk = flutter.minSdkVersion` becomes
   `minSdk = 30`, plus the comment above it so the next person knows why.

> **⚠️ Change this ONLY if the current value is LESS than 30.** If the
> line already reads `minSdk = 30`, `minSdk = 33` or anything higher,
> **leave it exactly as it is**. Lowering a project's `minSdk` can break
> other plugins the app uses.

### What number is `flutter.minSdkVersion`?

`flutter.minSdkVersion` is not a number you can see in your app; it is a
value the Flutter SDK on your machine supplies at build time. To know
whether it is below 30 you have to look it up. Two ways; the first is
authoritative.

**Look it up in the Flutter SDK.** First find where Flutter is installed:

```sh
flutter --version --machine
```

The output is JSON. Copy the value of `"flutterRoot"` — something like
`/Users/you/fvm/versions/3.47.8`. Then search that SDK's Gradle plugin
for the constant, pasting your path in place of `<flutterRoot>`:

```sh
cd "<flutterRoot>/packages/flutter_tools/gradle/src/main/kotlin"
```

```sh
grep -n "minSdkVersion" FlutterExtension.kt
```

Expected: one line such as `val minSdkVersion: Int = 24`. **That** is the
number `flutter.minSdkVersion` stands for on your machine. If it is below
30, make the edit above. If Flutter has moved it to 30 or higher by the
time you read this, leave `build.gradle.kts` alone — nothing is wrong.

**Or let the build tell you.** If you skip the edit and the number is
below 30, the first `flutter run` fails with a line like:

```text
uses-sdk:minSdkVersion 24 cannot be smaller than version 30 declared
in library [:status_bar_android]
```

The first number in that message is `flutter.minSdkVersion`. Make the
edit and build again.

4. Save the file. Nothing else in `build.gradle.kts` changes.

> **⚠️ If the file is called `build.gradle` (no `.kts`)**, the app was
> created by an older Flutter and uses the Groovy build script. The edit
> is the same line in the same block — `minSdk = 30` is valid Groovy too —
> but every other snippet in this guide assumes the current `.kts`
> template. Expect small differences, and ask before improvising.

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
  status_bar_android: ^1.0.0
```

**After — app lives anywhere else** (point at the plugin folder; adjust
the relative path to wherever `plugins/status_bar_android` is on disk):

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  status_bar_android:
    path: ../plugins/status_bar_android
```

Save, then in a terminal **at the app's root**:

```sh
flutter pub get
```

Check that Flutter now knows about the plugin:

```sh
grep -c status_bar_android .flutter-plugins-dependencies
```

Expected: a number of `1` or more. `0` means the dependency did not
resolve — re-read the `pubspec.yaml` edit (two-space indentation, `path:`
indented under the package name) and run `flutter pub get` again. Do not
continue until this passes.

The Android build itself picks the plugin up automatically on the next
`flutter run`/`flutter build`: it generates
`android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java`
with a `StatusBarAndroidPlugin` entry and links the plugin's Gradle
module. You never edit those.

---

## 3. Create `colors.xml`

**File:** `android/app/src/main/res/values/colors.xml` — **new file**

This is the **one place** the launch colour lives. Every theme in the
next two sections points here, so changing the colour later is a one-line
edit (Appendix A).

The `res/values/` folder already exists (it holds `styles.xml`). Create
`colors.xml` next to it with this content:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- android/app/src/main/res/values/colors.xml -->
<resources>
    <!-- The colour the launch/splash screen uses. Point it at any of
         the palette entries below, or at a literal such as #191970. -->
    <color name="launch_background">@color/black</color>

    <!-- Palette. RRGGBB; Android treats six digits as fully opaque. -->

    <!-- Neutrals -->
    <color name="white">#FFFFFF</color>
    <color name="black">#000000</color>
    <color name="warm_black">#141210</color>
    <color name="charcoal">#1C1C1E</color>
    <color name="slate">#2F4F4F</color>

    <!-- Blues -->
    <color name="blue">#1565C0</color>
    <color name="navy">#0B1F3A</color>
    <color name="midnight">#191970</color>
    <color name="indigo">#283593</color>

    <!-- Greens -->
    <color name="green">#008000</color>
    <color name="forest_green">#228B22</color>
    <color name="dark_olive">#3B4A1F</color>
    <color name="teal">#00695C</color>

    <!-- Reds / purples -->
    <color name="red">#D32F2F</color>
    <color name="burgundy">#6D1A36</color>
    <color name="purple">#800080</color>
    <color name="deep_purple">#512DA8</color>

    <!-- Lights. White status-bar icons vanish on these when the bar is
         visible; see Appendix A before using one. -->
    <color name="yellow">#FFFF00</color>
    <color name="rose_light">#FCE4EC</color>
    <color name="peach_light">#FFDAB9</color>
</resources>
```

`launch_background` is the only name the themes use. It points at
`@color/black` here; change that one line to any other palette entry
(`@color/purple`, `@color/green`, …) and the whole launch follows.

---

## 4. Edit `values/styles.xml`

**File:** `android/app/src/main/res/values/styles.xml`

This file defines two **themes** — named bundles of window settings.
`LaunchTheme` is what Android paints before any app code runs;
`NormalTheme` is what it paints while Flutter starts and behind Flutter
afterwards. The template makes both light and gives `LaunchTheme` a
drawable with the Flutter logo. You make both your solid colour.

Open the file. **Before** (fresh `flutter create`; the template's long
comments are left out here — the two `<style>` blocks are what matter):

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

**After** — replace the whole file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- android/app/src/main/res/values/styles.xml -->
<resources>
    <!-- Window theme while the process starts, before the first
         Flutter frame. Colour lives in values/colors.xml. -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
    </style>

    <!-- Window theme once the process has started: shown while Flutter
         initialises and behind the Flutter view afterwards. -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
    </style>
</resources>
```

What changed and why:

1. Both `parent` attributes: `Theme.Light.NoTitleBar` →
   `Theme.Black.NoTitleBar`. The parent decides defaults you did not
   set — including that the status bar's icons are **white**, which is
   what you want over a dark colour.
2. `LaunchTheme`'s background: `@drawable/launch_background` →
   `@color/launch_background`. The template pointed at a drawable file
   (a picture) that wraps the Flutter logo. You point at your colour.
3. `NormalTheme`'s background: `?android:colorBackground` →
   `@color/launch_background`. The template value means "whatever the
   parent theme's background is" — not pure anything, and it changes
   with dark mode. A colour resource is a fixed value.

The style **names** `LaunchTheme` and `NormalTheme` stay exactly as they
are. `AndroidManifest.xml` refers to them by name (section 7).

Save the file.

---

## 5. Create `values-v31/styles.xml`

**Folder:** `android/app/src/main/res/values-v31/` — **new folder**
**File:** `android/app/src/main/res/values-v31/styles.xml` — **new file**

Android 12 (API 31) added a **system splash screen** that the OS draws
before even the launch window, with the app icon in the middle. It is
controlled by theme attributes that older Android versions have never
heard of — a `values/styles.xml` that used them would fail to build for
API 30. Android's answer is a **qualified folder**: anything in
`values-v31/` is used on API 31 and newer *instead of* `values/`, and
ignored below.

So this file is a copy of section 4's with four extra lines on
`LaunchTheme`. Create the folder, then the file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- android/app/src/main/res/values-v31/styles.xml -->
<resources>
    <!-- Android 12+ system splash: solid colour, no icon, no branding.
         Colour lives in values/colors.xml. windowSplashScreenAnimatedIcon
         has no "none" value; a transparent colour is the sanctioned way
         to get an icon-less splash. Duration 0 so the system does not
         hold the splash for an icon animation that does not exist. -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
        <item name="android:windowSplashScreenBackground">
            @color/launch_background
        </item>
        <item name="android:windowSplashScreenAnimatedIcon">
            @android:color/transparent
        </item>
        <item name="android:windowSplashScreenAnimationDuration">0</item>
    </style>

    <!-- Window theme once the process has started. -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
    </style>
</resources>
```

The three extra `<item>`s on `LaunchTheme`:

- `windowSplashScreenBackground` — the system splash's colour.
- `windowSplashScreenAnimatedIcon` — the icon in the middle. There is no
  "no icon" setting, so a fully transparent colour is used as the icon.
- `windowSplashScreenAnimationDuration` — `0`, so Android does not hold
  the splash waiting for an icon animation that does not exist.

> **⚠️ The style names here MUST be identical to section 4's**
> (`LaunchTheme`, `NormalTheme`). If they differ even by one letter, this
> file silently defines two themes nothing uses, and Android 12+ devices
> show the template splash with the Flutter logo.

Save the file.

---

## 6. Delete the template leftovers

`flutter create` left three things that now either do nothing or
actively break what you just did. Run each command from the **app's
root** (the folder that contains `pubspec.yaml`).

**6a.** The dark-mode copy of `styles.xml`:

```sh
rm -r android/app/src/main/res/values-night
```

> **⚠️ This one matters most.** Android ranks a *night-mode* folder above
> a *platform-version* folder when picking resources. A leftover
> `values-night/styles.xml` beats your `values-v31/styles.xml` on any
> device in dark mode, and the Flutter logo comes back. This is the
> number-one cause of "I did everything and it still shows the logo".

**6b.** The pre-Android-5 fallback drawable (dead code at `minSdk = 30`):

```sh
rm -r android/app/src/main/res/drawable-v21
```

**6c.** The drawable the old `LaunchTheme` pointed at:

```sh
rm android/app/src/main/res/drawable/launch_background.xml
```

If that leaves `android/app/src/main/res/drawable/` empty, remove the
folder too:

```sh
rmdir android/app/src/main/res/drawable
```

After this, `android/app/src/main/res/` should contain exactly: the five
`mipmap-*` folders (your app icon), `values/` (with `colors.xml` and
`styles.xml`) and `values-v31/` (with `styles.xml`).

```sh
ls android/app/src/main/res
```

---

## 7. Check `AndroidManifest.xml`

**File:** `android/app/src/main/AndroidManifest.xml`

The manifest is the file Android reads to learn what the app contains.
It is dense, and most of it is irrelevant here. **In a fresh app nothing
in it changes** — this section is a check that two lines name the themes
you kept in sections 4 and 5. The full template file is shown so you can
find your place; the `<!-- ① -->` and `<!-- ② -->` markers are added by
this guide to point at the two lines. **They are not in your file and you
do not type them.**

**Before** — the file as `flutter create` writes it, with the two markers:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="my_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"          <!-- ① -->
            android:configChanges="…"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Theme applied as soon as the process has started;
                 visible while the Flutter UI initializes, and the
                 window background behind the Flutter UI after that. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"     <!-- ② -->
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below. The Flutter tool uses
             it to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text; used by
         the Flutter engine's ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

(Two things are shortened here so the block fits on the page, and only
here: `android:configChanges="…"` is one very long line in the real file,
and the template's own comments are longer. Neither has anything to do
with the launch screen.)

What the two marked lines do:

- **①** `android:theme="@style/LaunchTheme"` on the `<activity>` — the
  theme Android uses for the system splash and the launch window before
  any app code runs. Must name the `LaunchTheme` you edited in section 4
  and created in section 5.
- **②** `android:resource="@style/NormalTheme"` in the
  `io.flutter.embedding.android.NormalTheme` `<meta-data>` — the theme
  Flutter switches the window to once the engine is up. Must name the
  `NormalTheme` from the same two files.

**After** — what the file must look like once you are done. In a fresh
app it is **identical** to Before (markers removed), because both lines
already say the right thing. The only comment worth adding is a pointer
for the next reader:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="my_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- LaunchTheme and NormalTheme are defined in
             res/values/styles.xml and res/values-v31/styles.xml.
             The launch colour is res/values/colors.xml. -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="…"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Theme applied as soon as the process has started;
                 visible while the Flutter UI initializes, and the
                 window background behind the Flutter UI after that. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below. The Flutter tool uses
             it to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text; used by
         the Flutter engine's ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

What changed between Before and After:

1. The `<!-- ① -->` and `<!-- ② -->` markers are gone (they were never
   in the file).
2. One three-line comment added above `<activity>`, saying where the two
   themes live. Optional, harmless, and the next person will thank you.
3. Nothing else. `android:label` is your app's name, whatever it is.

**When the two lines are wrong.** An app from an older template, or one
someone has already customised, may have ① or ② naming something else
(`@style/Theme.App.Launch`, say). Then either rename the styles in
sections 4–5 to match the manifest, or change the manifest to
`@style/LaunchTheme` / `@style/NormalTheme`. Pick one; both files must
agree. If the `NormalTheme` `<meta-data>` element is missing entirely,
add it exactly as shown, inside `<activity>`, before `<intent-filter>`.

> **⚠️ Never duplicate, rename or "back up" this file in place.** A stray
> `AndroidManifest copy.xml` next to the real one, or a renamed original,
> produces the misleading build error
> `Build failed due to use of deleted Android v1 embedding`.

---

## 8. Build and verify

Run on a **real device or emulator on Android 11+**, in **release mode**.
Debug mode is slow at everything and will mislead you about what
"instant" means.

List attached devices:

```sh
flutter devices
```

Then, with the device id from that list:

```sh
flutter run --release -d <device-id>
```

What you should see on a cold start (swipe the app away first, then tap
its icon):

1. Your launch colour fills the screen. **No app icon** in the middle
   (Android 12+), **no white flash** at any point.
2. Flutter's first frame appears on top of that colour.
3. If your Dart code hid the bar before `runApp` (section 9), the status
   bar is gone from the first frame; otherwise it is visible with white
   icons.
4. `StatusBar.setVisibility(isHidden: true)` from Dart: the bar vanishes
   **instantly** — no fade — and the rest of the screen does **not** move.
5. `StatusBar.setVisibility(isHidden: false)`: it snaps back, same.
6. While hidden, swipe down from the top edge: the bar appears for a
   moment, then hides itself again.

---

## 9. Use the plugin from Dart

```dart
import 'package:status_bar_android/status_bar_android.dart';

// Hide.
await StatusBar.setVisibility(isHidden: true);

// Show.
await StatusBar.setVisibility(isHidden: false);
```

That is the whole API. `isHidden` is **required** — there is no default,
so every call says what it does. The plugin remembers nothing: the bar is
shown or hidden, and your widget keeps the `bool` if it needs to know
which.

### Hidden from the very first frame

To launch with the bar already gone, call the plugin **before**
`runApp`. Because that runs before Flutter's framework is up, one extra
line is needed first.

**Before** (`lib/main.dart` as `flutter create` writes it, first lines):

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
```

**After**:

```dart
import 'package:flutter/material.dart';
import 'package:status_bar_android/status_bar_android.dart';

Future<void> main() async {
  // Required before any plugin call that happens before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Hide before the first frame so the bar is never seen at launch.
  await StatusBar.setVisibility(isHidden: true);
  runApp(const MyApp());
}
```

If you only ever toggle the bar from a button, you need neither line:
`runApp` has already done the initialising.

### A toggle button, to try it

```dart
import 'package:flutter/material.dart';
import 'package:status_bar_android/status_bar_android.dart';

class StatusBarToggle extends StatefulWidget {
  const StatusBarToggle({super.key});

  @override
  State<StatusBarToggle> createState() => _StatusBarToggleState();
}

class _StatusBarToggleState extends State<StatusBarToggle> {
  bool _isHidden = true;

  Future<void> _toggle() async {
    final isHidden = !_isHidden;
    await StatusBar.setVisibility(isHidden: isHidden);
    if (!mounted) return;
    setState(() => _isHidden = isHidden);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggle,
      child: Text(_isHidden ? 'Show Status Bar' : 'Hide Status Bar'),
    );
  }
}
```

The `await` before `setState` matters: the label and the bar never
disagree.

### Errors

If the native side cannot act, the `Future` completes with a
`PlatformException`. Its `code` tells you why:

- **`NO_ACTIVITY`** — no Android activity is attached (the call came from
  a background isolate, or the app is not in the foreground).
- **`NO_INSETS_CONTROLLER`** — the window is not attached yet; you called
  too early in startup. Nothing was done. Retry after the first frame.
- **`INVALID_ARGUMENT`** — `isHidden` was not a `bool`. Cannot happen
  through the Dart API above.

On any platform other than Android the call throws
`MissingPluginException`. The plugin does not check the platform — if the
app runs anywhere else, the **caller** guards the call.

---

## 10. Troubleshooting

**Build fails: `uses-sdk:minSdkVersion 24 cannot be smaller than version
30 declared in library [:status_bar_android]`** (the first number may
differ).

- Section 1b was skipped or saved wrong. `minSdk` must be `30` or higher.

**The Flutter logo still shows at launch.**

- `values-night/` still exists. Section 6a. This is the usual cause.
- Section 5's style names don't match section 4's, character for
  character.
- The manifest's `android:theme` names a style you did not edit.
  Section 7.
- Stale build. Run:

  ```sh
  flutter clean
  ```

  then build again (section 8). Resource folders added after a build are
  occasionally not picked up until a clean.

**A white or light flash before the colour.**

- `values/styles.xml` still has a `Theme.Light…` parent or
  `?android:colorBackground`. Section 4, compare against the After block.

**Build fails: `Build failed due to use of deleted Android v1 embedding`.**

- `AndroidManifest.xml` is missing, renamed, or has a copy next to it.
  Section 7's warning.

**`PlatformException(NO_INSETS_CONTROLLER, …)` at startup.**

- Called before the window existed. Move the call after the first frame
  (a button, or `WidgetsBinding.instance.addPostFrameCallback`).

**The bar hides, but the whole screen jumps / re-lays out.**

- Not expected: the plugin puts the window edge-to-edge itself. If you
  see this, something else in the app is calling
  `SystemChrome.setEnabledSystemUIMode` with a non-edge-to-edge mode
  *after* the plugin. Remove it.

**Status bar icons are invisible while the bar is shown.**

- You chose a light launch colour. Appendix A.

---

## 11. Checklist

Tick every line before asking for help.

- [ ] Test device/emulator is Android 11 (API 30) or newer
- [ ] `android/app/build.gradle.kts`: `minSdk = 30` (or already higher —
      changed **only** if it was lower)
- [ ] `status_bar_android` in `pubspec.yaml`; `flutter pub get` run;
      `.flutter-plugins-dependencies` mentions it
- [ ] `res/values/colors.xml` exists with `launch_background`
- [ ] `res/values/styles.xml`: both parents `Theme.Black.NoTitleBar`,
      both backgrounds `@color/launch_background`
- [ ] `res/values-v31/styles.xml` exists, same style names as `values/`
- [ ] `res/values-night/` deleted
- [ ] `res/drawable-v21/` deleted
- [ ] `res/drawable/launch_background.xml` deleted
- [ ] `AndroidManifest.xml` still references `@style/LaunchTheme` and
      `@style/NormalTheme`
- [ ] `flutter run --release` succeeds
- [ ] Cold start: solid colour, no icon, no flash
- [ ] `StatusBar.setVisibility(isHidden: true)` hides instantly; nothing
      else moves
- [ ] `StatusBar.setVisibility(isHidden: false)` shows instantly

---

## Appendix A: changing the launch colour

The colour lives in **one line** of one file:

```text
android/app/src/main/res/values/colors.xml
```

**Before** (black):

```xml
    <color name="launch_background">@color/black</color>
```

**After** (purple, from the palette in the same file):

```xml
    <color name="launch_background">@color/purple</color>
```

Or a literal, if the palette has nothing you like. Six hex digits,
`RRGGBB`:

```xml
    <color name="launch_background">#4B0082</color>
```

Both themes in both `styles.xml` files point at `@color/launch_background`,
so nothing else changes. Rebuild (section 8). If the old colour persists,
the launch screen is cached: uninstall the app from the device, then

```sh
flutter clean
```

and build again.

### Light colours

The status bar's clock and icons are **white** (that comes from the
`Theme.Black.NoTitleBar` parent). Over `yellow`, `rose_light` or
`peach_light` they vanish while the bar is visible. If you want a light
launch colour **and** a visible status bar, add one `<item>` to **both**
styles in **both** `styles.xml` files (sections 4 and 5):

**Before** (one style shown; apply to all four):

```xml
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
    </style>
```

**After**:

```xml
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@color/launch_background</item>
        <item name="android:windowLightStatusBar">true</item>
    </style>
```

`windowLightStatusBar="true"` means "the window behind the bar is light,
so draw the bar's icons dark".

### The bar's own background while shown

While the status bar is visible, its strip has a background colour too.
It comes from the theme's `android:statusBarColor`; `Theme.Black.NoTitleBar`
makes it black, which is invisible over a dark launch colour. To make the
strip match a non-black launch colour instead, add to both styles in both
files:

```xml
        <item name="android:statusBarColor">@color/launch_background</item>
```
