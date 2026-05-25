# remind_me

A drop-in service for one-shot scheduled local notifications on Android and iOS.
Wraps `flutter_local_notifications`, `flutter_timezone`, and `timezone` so you
get a single class with `init`, `requestPermissions`, and `scheduleInMinutes`
instead of wiring three packages together yourself.

Targets the "remind me in N minutes/hours" use case for windows under 24 hours
where ±1 minute precision matters.

## Features

- One call to schedule a notification at a future time (`scheduleInMinutes`).
- One call to cancel by id.
- Handles timezone init so `zonedSchedule` doesn't fire at the wrong wall-clock time.
- Exposes Android exact-alarm permission flow (`canScheduleExactAlarms`,
  `requestExactAlarmsPermission`) — no-ops on iOS, so caller code stays
  platform-agnostic.
- Asserts duration < 24 hours up front. Beyond that, local-only scheduling is
  unreliable on Android (OEM battery killers, reboots, app updates); use FCM
  or persist + reschedule on launch instead.

## Getting started

Add the dependency:

```yaml
dependencies:
  remind_me: ^1.0.0  # adjust to your monorepo layout
```

The package transitively brings `flutter_local_notifications: ^21.0.0`,
`flutter_timezone: ^5.0.2`, and `timezone: ^0.11.0`. You don't need to declare
them yourself.

## Android - Get an iPhone

### Android: `android/app/build.gradle.kts`

`flutter_local_notifications` 21.x needs desugaring, multidex, and
`compileSdk` 36+.

**old:**

```kotlin
android {
    namespace = "com.example.your_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.your_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

**new:**

```kotlin
android {
    namespace = "com.example.your_app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.your_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

**added:**

- `compileSdk = 36` (replaces `flutter.compileSdkVersion` — pinned because
  some plugins now require ≥36)
- `isCoreLibraryDesugaringEnabled = true` in `compileOptions`
- `multiDexEnabled = true` in `defaultConfig`
- top-level `dependencies { coreLibraryDesugaring(...) }` block

### Android: `android/app/src/main/AndroidManifest.xml`

**old:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="your_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity ... />
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

**new:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <application
        android:label="@string/app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity ... />

        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

**added:**

- `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` —
  Android 13+ runtime permission to display notifications at all
- `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>` —
  Android 14+ runtime permission for ±1 minute scheduling precision
- `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` —
  lets the plugin re-register pending notifications after device reboot
- `<receiver ... ScheduledNotificationReceiver />` — receives the OS callback
  when an alarm fires
- (Recommended) change `android:label` to a string resource so permission
  dialogs show a real display name instead of your project's package name

If using a string resource for the label, also create
`android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <string name="app_name">My App</string>
</resources>
```

## iOS - Much simpler

### iOS: `ios/Podfile`

**old:**

```ruby
# platform :ios, '12.0'
```

**new:**

```ruby
platform :ios, '13.0'
```

**added:**

- Uncommented the `platform` line and bumped to `'13.0'` (minimum supported by
  `flutter_local_notifications` 21.x).

### iOS: `ios/Runner/AppDelegate.swift`

For projects on the new UIScene lifecycle (default for new Flutter projects).

**old:**

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

**new:**

```swift
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    UNUserNotificationCenter.current().delegate = self
  }
}
```

**added:**

- `import UserNotifications` at the top
- `UNUserNotificationCenter.current().delegate = self` inside
  `didInitializeImplicitFlutterEngine`

For older projects still on the legacy app-delegate lifecycle, register the
delegate inside `application(_:didFinishLaunchingWithOptions:)` instead.

### iOS: `ios/Runner/Info.plist` (recommended)

**old:** (typically absent, falls back to project name)

**new:**

```xml
<key>CFBundleDisplayName</key>
<string>My App</string>
```

**added:**

- `CFBundleDisplayName` so the system permission dialogs and home-screen icon
  show a real display name.

## Flutter Usage

In `main()`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RemindMe.instance.init();
  await RemindMe.instance.requestPermissions();
  runApp(const MyApp());
}
```

Schedule from a button:

```dart
ElevatedButton(
  onPressed: () async {
    final canSchedule = await RemindMe.instance.canScheduleExactAlarms();
    if (!canSchedule) {
      // Show your own pre-prompt dialog, then:
      await RemindMe.instance.requestExactAlarmsPermission();
      return;
    }
    await RemindMe.instance.scheduleInMinutes(
      title: 'Reminder',
      body: '1-minute test reminder.',
      duration: const Duration(minutes: 1),
    );
  },
  child: const Text('Remind me in 1 min'),
)
```

### Flutter API summary

**`init()`** — Initializes the timezone database and the notifications plugin.
Call once in `main()` after `WidgetsFlutterBinding.ensureInitialized()`.

**`requestPermissions()`** — Requests notification permission. Android 13+
shows the `POST_NOTIFICATIONS` prompt; iOS shows alert/badge/sound. Returns
`true` if granted. Call in `main()` — re-launches no-op.

**`requestExactAlarmsPermission()`** — Android only. Opens the system
"Alarms & reminders" settings page if exact alarms aren't granted yet. No-op
that returns `true` on iOS. Call from a button, not from `main()`.

**`canScheduleExactAlarms()`** — Returns whether exact alarms can be scheduled
right now. `false` on Android 14+ without permission, `true` everywhere else.
Use to gate your scheduling UI and show your own pre-prompt before
forwarding to system settings.

**`scheduleInMinutes(...)`** — Schedules a one-shot notification. Takes
`title`, `body`, and a `Duration` (default 5 minutes). Returns the integer
id of the scheduled notification. Asserts duration < 24 hours.

**`cancel(int id)`** — Cancels a previously scheduled notification by id.
No-op if the id is unknown or the notification already fired.

## Additional information

### Reminder duration guidance

| Duration           | Strategy                                                        |
| ---------------- | --------------------------------------------------------------- |
| ≤ 24 hours       | This package, no special handling                               |
| 1–7 days         | Persist in your own DB and reschedule on every app launch       |
| > 1 week         | Use FCM (or another server-driven delivery), local as backup    |

## Known limitations

### iOS
- **iOS pending limit:** 64 scheduled notifications max per app, OS-imposed.

### Android

- **Aggressive OEMs** (Xiaomi, Huawei, OnePlus) can defer or kill alarms even
  with permissions granted. Users have to whitelist the app. See
  [dontkillmyapp.com](https://dontkillmyapp.com).
- **Denied exact-alarm permission** falls back to inexact scheduling
  (~minutes of slop, up to ~9 minutes in deep Doze).


## Permission revocation

Neither platform exposes a programmatic revoke. To reset during testing:

- Android: Settings → Apps → *App name* → Storage → Clear data
- iOS: delete and reinstall the app
