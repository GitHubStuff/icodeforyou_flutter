# startup_package

Manages app startup sequencing. Coordinates a full-screen black launch, splash screen animation, concurrent async task execution, and cross-fade transition to the landing page.

---

## How it works

1. App launches — native black screen appears before Flutter renders
2. Flutter renders — `StartupApp` takes over, full black screen, system UI hidden
3. Splash screen animates — consumer calls `signalAnimationComplete` when done
4. Async tasks run concurrently — if still running when animation completes, spinner shows
5. All tasks complete — 3.5 second cross-fade to landing page
6. Any task fails — non-dismissible error dialog

---

## Installation

### 1. Add the dependency

In your app's `pubspec.yaml`:

```yaml
dependencies:
  startup_package:
    path: packages/startup_package
```

### 2. iOS — Black launch screen

Replace the contents of `ios/Runner/Base.lproj/LaunchScreen.storyboard` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<document
  type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
  version="3.0"
  toolsVersion="21701"
  targetRuntime="AppleCocoa"
  propertyAccessControl="none"
  useAutolayout="YES"
  launchScreen="YES"
  useTraitCollections="YES"
  useSafeAreas="YES"
  colorMatched="YES"
  initialViewController="01J-lp-oVM">
  <device id="retina6_12" orientation="portrait" appearance="light"/>
  <dependencies>
    <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="21679"/>
    <capability name="Safe area layout guides" minToolsVersion="9.0"/>
    <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
  </dependencies>
  <scenes>
    <scene sceneID="EHf-IW-A2E">
      <objects>
        <viewController id="01J-lp-oVM" sceneMemberID="viewController">
          <view
            key="view"
            contentMode="scaleToFill"
            id="Ze5-6b-2t3">
            <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
            <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
            <color key="backgroundColor"
              red="0.0" green="0.0" blue="0.0" alpha="1"
              colorSpace="custom" customColorSpace="sRGB"/>
          </view>
        </viewController>
        <placeholder
          placeholderIdentifier="IBFirstResponder"
          id="iYj-Kq-Ea1"
          userLabel="First Responder"
          sceneMemberID="firstResponder"/>
      </objects>
      <point key="canvasLocation" x="53" y="375"/>
    </scene>
  </scenes>
</document>
```

Verify `Info.plist` references the launch screen correctly:

```xml
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

### 3. Android — Black launch theme

In `android/app/src/main/res/values/styles.xml`, add a launch theme:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar.Fullscreen">
        <item name="android:windowBackground">@color/black</item>
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
        <item name="android:windowFullscreen">true</item>
    </style>

    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar.Fullscreen">
        <item name="android:windowBackground">@android:color/black</item>
    </style>
</resources>
```

In `android/app/src/main/res/values/colors.xml`, ensure black is defined:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="black">#000000</color>
</resources>
```

In `android/app/src/main/AndroidManifest.xml`, apply the launch theme to the activity:

```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    <meta-data
        android:name="io.flutter.embedding.android.NormalTheme"
        android:resource="@style/NormalTheme"/>
    ...
</activity>
```

---

## Usage

### 1. Extend StartupSplashScreen

```dart
class MySplashScreen extends StartupSplashScreen {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() {
        widget.signalAnimationComplete(context);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FlutterLogo(size: 120),
    );
  }
}
```

### 2. Configure and run

```dart
void main() {
  runApp(
    StartupApp(
      config: StartupConfig(
        splashScreen: const MySplashScreen(),
        landingPage: const MyLandingPage(),
        tasks: [
          () => ThemePackage.initialize(databaseName: 'abc123def456ghi78901'),
          () => myOtherAsyncTask(),
        ],
      ),
    ),
  );
}
```

---

## Error handling

If any task throws, `StartupError` is emitted and a non-dismissible dialog is shown. To handle errors yourself, extend `StartupSplashScreen` and listen to `StartupCubit` via `context.watch` in your splash state.

---

## Package structure

```
lib/
  startup_package.dart          ← public API
  src/
    startup_app.dart            ← app root, system UI control
    startup_config.dart         ← configuration value object
    startup_splash_screen.dart  ← abstract base class
    cubit/
      startup_cubit.dart        ← state coordination
      _startup_state.dart       ← sealed states
    navigation/
      _startup_router.dart      ← cross-fade route
```
