# README-Android-PluginWarning

## Issue

When attempting to run the Android{sucks} this message can appear when using a plug-in:

```txt

WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): status_bar_chameleon
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

Please check the changelogs of these plugins and upgrade to a version that supports Built-in Kotlin.
If no such version exists, report the issue to the plugin. If necessary, here is a guide on filing
an issue against a plugin: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers#report-incompatible-kotlin-gradle-plugin-usage-to-plugin-authors

If you are a plugin author, please migrate your plugin to Built-in Kotlin using this guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors

```

Why? First - Android sucks.

Seconds the **_build.gradle.kts_** has:

```kts
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
```

Flutter/Dart {the only good thing from google} is moving that around so its, fuck if I know, a hack to make it work??

In the **_build.gradle.kts_** for Dart/Flutter plugins:

```kts
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
```

is added near/at the bottom.

[see: *plugins/status_bar_android/android/build.gradle.kts*] for an implementation example.

### Check-list

Migrate a Flutter plugin to Built-in Kotlin — android/build.gradle.kts

Remove these three lines. Add nothing.

In _buildscript { }_, delete the Kotlin version constant:

```kts
val kotlinVersion = "2.2.20"
```

In _buildscript { dependencies { } }_, delete the KGP classpath:

```kts
classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
```

In _plugins { }_ delete the Kotlin plugin application:

```kts
id("kotlin-android")
```

Then in the plugin’s pubspec.yaml, raise the floor to sdk and flutter version:

```yaml
^3.12.0 and flutter: ">=3.44.0"
```

note the migration in CHANGELOG.md.

## Clean-up

By accident or design Android leaves a lot of shit-filled cache files all over the system and the app.

This is recommended/encourage after 'fixing' a plugin!

```zsh
# from the root of the plugin

fvm flutter clean

rm -rvf ~/.gradle/caches ~/.gradle/daemon

flutter pub cache clean

flutter pub get
```

## Jargon

This is what the VSCode warning is badly stating.

**The plugin requires 'Built-in Kotlin' to work**

## Finally

**🌈 Be kind to each other**
