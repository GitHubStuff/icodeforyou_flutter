# since_when_dev

Flutter template project

## iOS platform files for black-screen launch

- ios/Runner/Base.lproj/LaunchScreen.storyboard
- ios/Runner/Base.lproj/Main.storyboard
- ios/Runner/StatusBarFlutterViewController.swift (new)
- ios/Runner/Info.plist

### StatusBarFlutterViewController.swift

This ```.swift``` file was created to work with ```status_bar_chameleon``` package to faciliate a black/blank screen
on an application's **cold start**. So far, as a template, it appears correctly in the xcode workspace as part of the
iOS project. *IF THERE AN ERROR* on launch, startup **XCODE** and make sure the file is part of the known xcode files.

## Layout

```txt
tool/bricks/black_launch/
├── brick.yaml
└── __brick__/
    ├── ios/Runner/...            (the four files + pbxproj)
    └── android/app/src/main/res/...   (styles, launch_background, night variants)
```

## Android Platform

Dumb ass platform doesn't allow for a truly black screen, the status bar always flashes.

### android/app/build.gradle.kts

Replace ```minSdk = flutter.minSdkVersion``` with ```minSdk = 31```

### android/app/src/main/res/drawable/launch_background.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- CHANGED: item was @android:color/white. Black launch/starting-window
     background, referenced by LaunchTheme's windowBackground. -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/black" />
</layer-list>
```

### android/app/src/main/res/values/styles.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme for the Android 12+ system splash / starting window.
         KNOWN LIMITATION: the splash window is OS-owned; the status bar
         cannot be hidden during it by any app mechanism. Launch shows a
         black field with system status icons until Flutter's first frame. -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:windowFullscreen">true</item>
        <item name="android:windowSplashScreenBackground">@android:color/black</item>
        <item name="android:windowSplashScreenAnimatedIcon">@android:color/transparent</item>
        <!-- Dark splash status icons where the OS honors this attribute.
             Some builds (e.g. recent Pixel) ignore it and draw white icons;
             kept because it costs nothing and helps on builds that comply. -->
        <item name="android:windowLightStatusBar">true</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@android:color/black</item>
    </style>
</resources>
```

### android/app/src/main/kotlin/<org path>/MainActivity.kt

```kt
package com.icodeforyou.<app name>

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)

        super.onCreate(savedInstanceState)

        WindowCompat.getInsetsController(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }
}
```