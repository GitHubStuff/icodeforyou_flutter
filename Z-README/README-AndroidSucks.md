# AndroidSucks.md

Android launch-screen behavior has a hard tradeoff:

```txt
Black launch screen + no logo + no fullscreen warning = status bar remains visible.
Hide status/system bars = Android may show "Viewing full screen..."
```

This document records the setup that gets to the stable position:

```txt
✅ black launch screen
✅ no launcher/logo splash image
✅ no "Viewing full screen" warning
✅ status/nav areas are black
❌ time/battery status line still visible
```

---

## 1. AndroidManifest.xml

File:

```txt
programs/startup_demo/android/app/src/main/AndroidManifest.xml
```

Keep the activity using `LaunchTheme`.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="startup_demo"
        android:name="${applicationName}"
        android:icon="@drawable/empty_splash_icon">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

Important line:

```xml
android:icon="@drawable/empty_splash_icon"
```

This prevents Android from using the normal launcher icon during the splash handoff.

---

## 2. MainActivity.kt

File:

```txt
programs/startup_demo/android/app/src/main/kotlin/com/icodeforyou/startup_demo/MainActivity.kt
```

Use the plain Flutter activity.

```kotlin
package com.icodeforyou.startup_demo

import android.graphics.Color
import android.os.Bundle
import android.view.WindowInsets
import android.view.WindowInsetsController
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.statusBarColor = Color.BLACK
        window.navigationBarColor = Color.BLACK

        /// Fades out the status bar after launch
        /// Not a good user experience, but interesting

        // if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
        //     window.insetsController?.hide(WindowInsets.Type.statusBars())
        //     window.insetsController?.systemBarsBehavior =
        //         WindowInsetsController.BEHAVIOR_DEFAULT
        // }
    }
}
```

---

## 3. values/styles.xml

File:

```txt
programs/startup_demo/android/app/src/main/res/values/styles.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>

    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:windowFullscreen">false</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>

    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>

</resources>
```

---

## 4. values-night/styles.xml

File:

```txt
programs/startup_demo/android/app/src/main/res/values-night/styles.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>

    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:windowFullscreen">false</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>

    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>

</resources>
```

---

## 5. values-v31/styles.xml

Create this folder if missing:

```zsh
mkdir -p programs/startup_demo/android/app/src/main/res/values-v31
```

File:

```txt
programs/startup_demo/android/app/src/main/res/values-v31/styles.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>

    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:windowFullscreen">false</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>

        <item name="android:windowSplashScreenBackground">@android:color/black</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/empty_splash_icon</item>
        <item name="android:windowSplashScreenIconBackgroundColor">@android:color/black</item>
    </style>

    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>

</resources>
```

Key point:

```xml
<item name="android:windowSplashScreenAnimatedIcon">@drawable/empty_splash_icon</item>
```

This prevents Android 12+ from showing the real app icon.

---

## 6. drawable/launch_background.xml

File:

```txt
programs/startup_demo/android/app/src/main/res/drawable/launch_background.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/black" />
</layer-list>
```

---

## 7. drawable-v21/launch_background.xml

Create this folder if missing:

```zsh
mkdir -p programs/startup_demo/android/app/src/main/res/drawable-v21
```

File:

```txt
programs/startup_demo/android/app/src/main/res/drawable-v21/launch_background.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/black" />
</layer-list>
```

Important: remove any old bitmap block like this:

```xml
<bitmap
    android:gravity="center"
    android:src="@mipmap/launch_image" />
```

That was the source of the launch logo on modern Android.

---

## 8. drawable-v26/empty_splash_icon.xml

Create this folder:

```zsh
mkdir -p programs/startup_demo/android/app/src/main/res/drawable-v26
```

File:

```txt
programs/startup_demo/android/app/src/main/res/drawable-v26/empty_splash_icon.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/black" />
    <foreground android:drawable="@android:color/transparent" />
</adaptive-icon>
```

Reason: `<adaptive-icon>` requires API 26+.

---

## 9. Clean run

Run from the app folder:

```zsh
cd programs/startup_demo
flutter clean
flutter pub get
flutter run
```

If Android still shows stale behavior, uninstall the app first:

```zsh
adb uninstall com.icodeforyou.startup_demo
flutter run
```

---

## 10. Verification commands

From:

```zsh
cd programs/startup_demo
```

Check manifest theme:

```zsh
grep -n "android:theme" android/app/src/main/AndroidManifest.xml
```

Search for remaining logo references:

```zsh
grep -RIn "launch_image\|ic_launcher\|windowSplashScreen\|windowBackground\|LaunchTheme\|NormalTheme" android
```

Expected acceptable references:

```txt
android:icon="@drawable/empty_splash_icon"
windowSplashScreenAnimatedIcon @drawable/empty_splash_icon
windowBackground black / launch_background
```

Bad references:

```txt
@mipmap/launch_image
@mipmap/ic_launcher as splash icon
bitmap launch image inside launch_background.xml
```

---

## Final Android behavior

This setup gets:

```txt
✅ black startup
✅ no normal launcher logo
✅ no white launch flash
✅ no Android fullscreen warning
✅ black status/nav background
❌ time/battery still visible
```

To hide the time/battery line, Android requires hiding system UI. That can trigger the "Viewing full screen" message.
