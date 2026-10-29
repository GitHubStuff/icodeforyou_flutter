<!-- plugins/status_bar_android/example/README-change-splash.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->

# Changing the Android splash / launch screen colour

A solid-colour, icon-less launch screen. Pure Android theming — every
edit is XML or a deletion under `android/`; nothing in Dart changes,
and nothing here depends on any plugin or package. It applies to any
Flutter app.

What you get: OS splash and launch window in one solid colour, no app
icon, no white/black flash between the two. What Flutter paints after
that is Flutter's business and outside this document.

Assumes `minSdk` ≥ 30 (Android 11). If your app's floor is lower,
keep the template's `drawable-v21/` and `values-night/` folders instead
of deleting them in step 4, and apply the same colour edits there too.

Paths are relative to the app's root. Five files; roughly five minutes.

---

## 1. `android/app/src/main/res/values/colors.xml` — the colour

Create the file if it doesn't exist. One resource; this is the only
place you ever change the colour again.

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- The one place to change the launch/splash colour. ARGB hex. -->
    <color name="launch_background">#FF191970</color>
</resources>
```

Format is `#AARRGGBB`: first two digits alpha (keep `FF`), then red,
green, blue. `#FF191970` is midnight blue; `#FF000000` is black;
`#FFFFFFFF` is white.

If you choose a light colour, the status bar's icons (white by default)
will vanish against it while the bar is visible. Add
`<item name="android:windowLightStatusBar">true</item>` to both themes
in steps 2 and 3 to flip the icons dark.

## 2. `android/app/src/main/res/values/styles.xml` — the two themes

Replace the template's file. The template uses
`?android:colorBackground`, a theme *attribute* that resolves to
"whatever the parent theme says" — not pure black, and it changes with
dark mode. A colour *resource* is a fixed value.

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Window theme while the process starts, before the first
         Flutter frame. -->
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

`LaunchTheme` and `NormalTheme` are the Flutter template's names, not
Android requirements. If your app already has its own (`Theme.App.Launch`,
`Theme.App`, …), keep yours and put these `<item>`s in them — but then
use *your* names consistently in steps 3 and 5.

## 3. `android/app/src/main/res/values-v31/styles.xml` — Android 12+

Create the folder and file. Android 12 (API 31) introduced the system
splash screen and its attributes; API 30 doesn't know them, which is why
this lives in a `-v31` qualified folder rather than in step 2's file.

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Android 12+ system splash: solid colour, no icon, no branding.
         windowSplashScreenAnimatedIcon has no "none" value; a
         transparent colour is the sanctioned way to get an icon-less
         splash. Duration 0 so the system does not hold the splash for
         an icon animation that does not exist. -->
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

The style names here **must** be identical to step 2's. If they differ,
this file silently defines two new themes that nothing references, and
Android 12+ devices show the template splash with the app icon.

To show an icon instead of nothing, point `windowSplashScreenAnimatedIcon`
at a drawable (static, or an `AnimatedVectorDrawable` — GIFs are not
supported) and set the duration to match. Android masks the icon to a
circle and expects it inside a ~2/3 safe zone.

## 4. Delete the template's leftovers

```bash
rm -rf android/app/src/main/res/values-night \
       android/app/src/main/res/drawable-v21 \
       android/app/src/main/res/drawable/launch_background.xml
```

- `values-night/` — redundant once the colour is fixed. And
  **dangerous**: Android's resource matching ranks *night mode* above
  *platform version*, so a leftover `values-night/styles.xml` beats
  `values-v31/styles.xml` on any device in dark mode and silently
  restores the template splash with the app icon. This is the #1 cause
  of "I changed everything and it still shows the Flutter logo".
- `drawable-v21/` — API < 21 fallback; dead with `minSdk = 30`.
- `drawable/launch_background.xml` — a one-item layer-list wrapping a
  colour. The theme references the colour directly now. If `drawable/`
  is otherwise empty, delete the folder.

## 5. `android/app/src/main/AndroidManifest.xml` — wire the themes

The `<activity>` points at the launch theme, and the Flutter embedding's
`NormalTheme` meta-data points at the normal theme. The template already
writes both with the names used above; if you renamed the themes in
steps 2–3, this is where to match them.

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:taskAffinity=""
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    <!-- Theme applied as soon as the process has started, while the
         Flutter UI initialises, and behind the Flutter UI afterwards. -->
    <meta-data
        android:name="io.flutter.embedding.android.NormalTheme"
        android:resource="@style/NormalTheme" />
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```

- `android:theme="@style/LaunchTheme"` — what the OS uses to draw the
  system splash and the launch window before any app code runs.
- `io.flutter.embedding.android.NormalTheme` meta-data — what the
  Flutter embedding switches the window to once the engine is up.
  Without it, the window stays on `LaunchTheme` forever; with a solid
  colour that's invisible, but a splash *image* would persist behind
  any transparent Flutter content.

Nothing else in the `<activity>` is related to the splash.

Do **not** rename or copy this file in place. A stray
`AndroidManifest copy.xml` next to a missing `AndroidManifest.xml`
produces the misleading error
`Build failed due to use of deleted Android v1 embedding`.

## 6. Verify

```bash
fvm flutter clean && fvm flutter run --release -d <device-id>
```

Expected: the app opens on a solid `launch_background` screen with no
icon, which stays until Flutter paints its first frame.

- **App icon or a white/black flash at launch** → `values-night/` still
  exists (step 4), or the manifest's `android:theme` references a theme
  you didn't edit (step 5), or step 3's style names don't match step 2.
- **`Build failed due to use of deleted Android v1 embedding`** → the
  manifest is missing or misnamed (step 5).
- **Still wrong after all that** → `fvm flutter clean`; resource
  qualifier folders added after a build are occasionally not picked up.
