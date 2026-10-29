<!-- plugins/status_bar_android/README-plugin-test.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->

# status_bar_android — native (Kotlin) unit tests

How to run the Android-side unit tests for this plugin, what a good run
looks like, and the known build warnings with the conditions under which
each one stops being harmless.

## Where

The Kotlin tests live in the plugin:

```
plugins/status_bar_android/android/src/test/kotlin/
    com/icodeforyou/status_bar_android/StatusBarAndroidPluginTest.kt
```

but they are **run from the example app's Android project**, because a
plugin has no standalone Gradle wrapper — the example app is the host
that assembles the plugin as a library module (`:status_bar_android`):

```
plugins/status_bar_android/example/android/
```

## Prerequisites

1. The example app must have been built at least once so Flutter has
   generated the Gradle wiring (`GeneratedPluginRegistrant`, local
   properties, plugin module registration). From
   `plugins/status_bar_android/example/`:

   ```bash
   fvm flutter build apk --debug
   ```

   Any `fvm flutter run` also satisfies this.

2. **JDK 21 for the Gradle daemon.** AGP's `JdkImageTransform` (`jlink`
   over `core-for-system-modules.jar`) does not support JDK 27. The
   daemon is pinned in `example/android/gradle.properties`:

   ```properties
   org.gradle.java.home=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
   ```

   This path is machine-specific. See the TODO list below.

3. **JDK 21 for the Gradle client (optional).** `./gradlew` itself
   starts under the shell's `JAVA_HOME` before handing off to the
   daemon. To silence the client's `java.lang.System::load` warning:

   ```bash
   export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
   ```

## Run

From `plugins/status_bar_android/example/android/`:

```bash
./gradlew testDebugUnitTest
```

Only the plugin module has JVM unit tests; `:app` and
`:integration_test` contribute none, so this runs exactly the plugin's
suite.

To run only the plugin module explicitly:

```bash
./gradlew :status_bar_android:testDebugUnitTest
```

## What to expect

A good run ends like this (configure-phase warnings omitted — see
below):

```
> Task :status_bar_android:testDebugUnitTest

StatusBarAndroidPluginTest > setVisibility_afterConfigChangeReattach_delegates() PASSED
StatusBarAndroidPluginTest > setVisibility_withoutActivity_reportsNoActivity() PASSED
StatusBarAndroidPluginTest > setVisibility_visible_delegatesAndSucceeds() PASSED
StatusBarAndroidPluginTest > setVisibility_hidden_delegatesAndSucceeds() PASSED
StatusBarAndroidPluginTest > setVisibility_missingArgument_reportsInvalidArgument() PASSED
StatusBarAndroidPluginTest > setVisibility_afterDetach_reportsNoActivity() PASSED
StatusBarAndroidPluginTest > setVisibility_controllerCannotAct_reportsNoInsetsController() PASSED
StatusBarAndroidPluginTest > unknownMethod_reportsNotImplemented() PASSED

BUILD SUCCESSFUL
```

Eight tests, all `PASSED`. The tests are forced to re-run every time
(`outputs.upToDateWhen { false }` in the plugin's `build.gradle.kts`),
so a second invocation never reports `UP-TO-DATE` for the test task.

The HTML report is written to:

```
plugins/status_bar_android/example/build/status_bar_android/
    reports/tests/testDebugUnitTest/index.html
```

### What is covered

`StatusBarAndroidPluginTest` exercises the **method-channel contract**
of `StatusBarAndroidPlugin`:

- unknown method → `notImplemented()`
- `setVisibility` with no activity attached → `NO_ACTIVITY` error
- `setVisibility` after `onDetachedFromActivity` → `NO_ACTIVITY` error
- `setVisibility` with a missing/non-Boolean `isHidden` →
  `INVALID_ARGUMENT` error
- `setVisibility(isHidden: true/false)` → delegates to
  `StatusBarController` and reports `success(null)`
- `StatusBarController.setVisibility` returns `false` (window has no
  insets controller yet) → `NO_INSETS_CONTROLLER` error, never
  `success`
- survives a configuration-change detach/reattach cycle

The mock controller is stubbed to return `true` in `setUp`; Mockito's
default for a `Boolean` is `false`, which would otherwise turn every
success case into an error.

`StatusBarController` itself is **not** unit-tested. It is a thin
adapter over `WindowInsetsController`, which is an `android.jar` stub
in a JVM test (every method throws `RuntimeException("Stub!")`). It is
verified by running the example app on a device and toggling the bar.

## Failure modes already seen

- **`Could not resolve ... androidJdkImage` / `jlink` error**
  Cause: Gradle daemon on JDK 27.
  Fix: `org.gradle.java.home` → JDK 21.
- **`MockitoException` → `IllegalArgumentException` at `mock(...)`**
  Cause: Mockito too old; its bundled Byte Buddy predates JDK 21.
  Fix: raise `mockito-core`.
- **`RuntimeException`, then `NoClassDefFoundError` at `mock(...)`**
  Cause: class under test calls an Android API in a static initialiser
  (`companion object`); `android.jar` stubs throw `Stub!`.
  Fix: move the call to method scope.
- **`uses-sdk:minSdkVersion 24 cannot be smaller than version 30`**
  Cause: example app `minSdk` below the plugin's.
  Fix: example `minSdk = 30`.
- **`Unresolved reference 'mockito'` during `compileDebugKotlin`**
  Cause: test file placed in `src/main/kotlin`.
  Fix: move to `src/test/kotlin`.

## TODO: known warnings and when they become a problem

Every warning below is currently harmless. Each entry says what it is,
what will turn it into a failure, and what the failure will look like.

### TODO: `android.builtInKotlin=false` / `android.newDsl=false` deprecated

- **What:** Two flags the Flutter template wrote into
  `example/android/gradle.properties`. They keep AGP 9 on its pre-9
  Kotlin and DSL behaviour because Flutter's Gradle plugin has not
  migrated yet. Flutter's own `:integration_test` module emits the same
  warning, which confirms this is Flutter-tooling state, not ours.
- **When it breaks:** AGP 10.0 removes both flags.
- **Symptom:** after an AGP bump to 10.x, configure-phase failure
  naming the removed option; Kotlin in all three modules fails to
  compile because `org.jetbrains.kotlin.android` is no longer applied.
- **Fix when the time comes:** delete both flags from
  `gradle.properties`; in the plugin's `build.gradle.kts` drop the
  `buildscript { kotlin-gradle-plugin }` classpath and the top-level
  `kotlin { compilerOptions }` block in favour of AGP built-in Kotlin
  (`android { kotlin { compilerOptions { ... } } }`). Try this as an
  isolated experiment on a clean tree whenever Flutter's template stops
  writing the flags.

### TODO: `'org.jetbrains.kotlin.android' plugin ... no longer required`

- **What:** Same root cause as above; applied by Flutter's Gradle plugin
  while `builtInKotlin=false`.
- **When / symptom / fix:** identical to the previous entry. Do not
  address separately.

### TODO: `Project.android(Action<LibraryExtension>)` deprecated

- **What:** The plugin's `build.gradle.kts` `android { }` block resolves
  to the old DSL because `newDsl=false`.
- **When / symptom / fix:** identical to the first entry. Goes away by
  itself once `newDsl` is no longer forced off.

### TODO: `org.gradle.java.home` is a machine-specific absolute path

- **What:** `example/android/gradle.properties` pins the daemon to a
  Homebrew JDK 21 path that exists only on this machine.
- **When it breaks:** any other machine or CI runner, or a `brew`
  reinstall that moves the JDK.
- **Symptom:** `Value '/opt/homebrew/...' given for org.gradle.java.home
  Java property is invalid (Java home supplied is invalid)` at daemon
  start.
- **Fix when the time comes:** replace with a Gradle Java toolchain
  (`java { toolchain { languageVersion = JavaLanguageVersion.of(21) } }`
  plus the Foojay resolver plugin), or move the JDK selection into the
  plumbing scripts via `JAVA_HOME` and remove the property.

### TODO: Gradle client `java.lang.System::load` restricted-method warning

- **What:** The `./gradlew` client runs under the shell's JDK 27;
  Gradle's native-platform library calls `System.load` without
  `--enable-native-access`.
- **When it breaks:** a future JDK (27+) makes restricted native access
  an error by default.
- **Symptom:** `./gradlew` dies before the daemon starts with an
  `IllegalCallerException` from `NativeLibraryLoader`.
- **Fix when the time comes:** run the client under JDK 21 via
  `JAVA_HOME`, or upgrade Gradle to a release that passes
  `--enable-native-access`.

### TODO: `-XX:+EnableDynamicAgentLoading` on the test JVM

- **What:** Mockito's inline mock maker attaches Byte Buddy as a
  dynamic agent. JDK 21+ warns; the flag in the plugin's
  `build.gradle.kts` `testOptions` suppresses the warning.
- **When it breaks:** a future JDK disallows dynamic agent loading
  even with the flag, or Mockito changes its attach strategy.
- **Symptom:** every `mock(...)` call fails with `MockitoException:
  Could not initialize inline Byte Buddy mock maker`.
- **Fix when the time comes:** add `mockito-core` as an explicit
  `-javaagent` on the test JVM instead of relying on dynamic attach.

### TODO: `Consider enabling configuration cache`

- **What:** Gradle suggestion for faster configure phases. Not enabled
  because Flutter's Gradle plugin support for it is incomplete.
- **When it matters:** never a failure; only a speed opportunity.
- **Symptom of enabling too early:** configure-phase errors about
  tasks not being configuration-cache compatible, originating in
  `dev.flutter.flutter-gradle-plugin`.
- **Fix when the time comes:** `org.gradle.configuration-cache=true` in
  `gradle.properties` once Flutter's plugin declares support.
