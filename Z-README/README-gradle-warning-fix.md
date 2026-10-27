# Gradle "restricted method in java.lang.System" warnings

## The event

While building the `island_control_android` plugin example app with
`fvm flutter run`, every Gradle invocation printed:

```
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/Users/<user>/.gradle/wrapper/dists/gradle-9.3.1-all/<hash>/gradle-9.3.1/lib/native-platform-0.22-milestone-29.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled
```

The build succeeded; the warnings appeared on `./gradlew --version`,
`./gradlew --stop`, `flutter run`, and `flutter test integration_test`.

Environment at the time:

- `java -version` on `PATH`: Temurin OpenJDK 27 (`27+35`)
- Gradle wrapper: 9.3.1 (released 2026-01-29)
- Flutter 3.47.8 via `fvm`
- macOS, Apple Silicon

## Question

What causes those warnings, and what exactly fixes them?

## Cause

JDK 24 and later enforce JEP 472 ("Prepare to Restrict the Use of JNI").
Any code that calls `System::load` to load a native library must live in a
module that has been explicitly granted native access; otherwise the JVM
prints the warning above.

Gradle 9.3.1 bundles `native-platform-0.22-milestone-29.jar`, the library it
uses for terminal and filesystem integration. That jar loads native code and
is not in a named module with native access enabled. Running the Gradle
launcher or daemon on JDK 24+ therefore triggers the warning on every
invocation.

The warning has nothing to do with Android, Flutter, Kotlin, or the plugin
code. It is purely a Gradle-on-a-newer-JDK mismatch.

## Fix

Run Gradle on a JDK that predates the restriction. JDK 21 does not have
JEP 472, so nothing is logged.

Point Flutter at a JDK 21 (one setting; it persists in Flutter's config):

```sh
fvm flutter config --jdk-dir "$(/usr/libexec/java_home -v 21)"
```

Flutter then sets `JAVA_HOME` for every Gradle invocation it makes
(`flutter run`, `flutter build`, `flutter test integration_test`).

Stop any Gradle daemon still running on the old JDK so the next invocation
starts a fresh one on 21:

```sh
./gradlew --stop
```

(Run from an `android/` directory that has a Gradle wrapper.)

Verify under "Android toolchain" that Flutter reports the JDK 21 path:

```sh
fvm flutter doctor -v
```

If no JDK 21 is installed:

```sh
brew install --cask temurin@21
```

List installed JDKs:

```sh
/usr/libexec/java_home -V
```

## What the fix does not cover

Running `./gradlew` directly from a shell uses whatever `java` is on `PATH`.
If that is still JDK 27, those manual invocations still warn. To silence
them as well, set `JAVA_HOME` to the JDK 21 path in the shell profile.

## Reverting the fix

Once Gradle ships a `native-platform` that declares native access, the pin
is no longer needed. Clear it so Flutter goes back to its default JDK
discovery (Android Studio's bundled JDK, then `JAVA_HOME`, then `PATH`):

```sh
fvm flutter config --jdk-dir ""
```

Or point it explicitly at the newer JDK:

```sh
fvm flutter config --jdk-dir "$(/usr/libexec/java_home -v 27)"
```

Then stop the running daemon so the next build starts on the new JDK:

```sh
./gradlew --stop
```

## Questions to ask when checking whether the fix is still needed

Precise form, for a maintainer or an issue tracker:

```
 Which Gradle release first ships a `native-platform` build that enables
 native access under JEP 472, so that running Gradle on JDK 24+ no longer
 prints "A restricted method in java.lang.System has been called …
 net.rubygrapefruit.platform.internal.NativeLibraryLoader"?
```
Short form, for a search box:

```
 gradle native-platform JEP 472 enable-native-access warning fixed release
```

The follow-up that actually decides whether to revert:

```
 Does Flutter's pinned Android Gradle plugin and Gradle wrapper version
 support running on JDK 27 without that warning?
```

## Unrelated details

- `compileOptions` / `jvmTarget` set to Java 17 in `build.gradle.kts` are
  the bytecode level the library compiles to, not the JDK that runs the
  build. They stay at 17 regardless of this fix.
- The green battery icon in the Android status bar is the system's charging
  indicator; it is unrelated to Gradle or to the plugin.
