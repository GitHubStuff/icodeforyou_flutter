# Flutter & Dart Migration TLDR — 3.10 → 3.41

A practical reference for what changed in Flutter and Dart between **Flutter 3.10 (May 2023)** and **Flutter 3.41 (March 2026)** — roughly 31 minor releases over 3 years.

This is the arc, not a complete changelog. For exhaustive per-version detail, see:
- [`docs.flutter.dev/release/breaking-changes`](https://docs.flutter.dev/release/breaking-changes)
- [`dart.dev/resources/breaking-changes`](https://dart.dev/resources/breaking-changes)

> **Note:** Dart and Flutter version together. Each Flutter release ships with a paired Dart version. The mapping looks like this:
>
> | Flutter | Dart  |
> |---------|-------|
> | 3.10    | 3.0   |
> | 3.13    | 3.1   |
> | 3.16    | 3.2   |
> | 3.19    | 3.3   |
> | 3.22    | 3.4   |
> | 3.24    | 3.5   |
> | 3.27    | 3.6   |
> | 3.29    | 3.7   |
> | 3.32    | 3.8   |
> | 3.35    | 3.9   |
> | 3.41    | 3.11  |

---

## The Big Picture (TLDR of the TLDR)

1. **Impeller replaced Skia** as the default renderer (iOS in 3.10 era, Android in 3.27).
2. **Material 3 became the default theme** (Flutter 3.16).
3. **Dart got records, patterns, and sealed classes** (Dart 3.0 / Flutter 3.10).
4. **WebAssembly went stable** for Flutter web (Flutter 3.22 / Dart 3.4).
5. **Major API renames:** `MaterialState` → `WidgetState`, `RawKeyEvent` → `KeyEvent`, `textScaleFactor` → `TextScaler`.
6. **Several extension type / JS interop overhauls** (Dart 3.3+).
7. **Tooling matured significantly:** Widget Previews, DevTools extensions, new `dart format` style.

---

## Dart Language Features by Version

### Dart 3.0 (Flutter 3.10) — May 2023 — The Big One

This is when "Dart 3" landed. The largest Dart release ever.

#### Records
Tuples with names. Return multiple values without defining a class.

```dart
(String, int) userInfo(Map<String, dynamic> json) {
  return (json['name'] as String, json['age'] as int);
}

final (name, age) = userInfo(json);

// Named fields
({String name, int age}) namedUser() => (name: 'Alice', age: 30);
```

#### Patterns & Pattern Matching
Destructuring, exhaustive switch expressions, `if-case`, map/list patterns.

```dart
// Switch expression
final desc = switch (shape) {
  Circle(:final radius) => 'circle r=$radius',
  Square(:final side)   => 'square s=$side',
  _                     => 'unknown',
};

// Destructure with if-case
if (json case {'name': String name, 'age': int age}) {
  print('$name is $age');
}
```

#### Sealed Classes
Closed type hierarchies that enable exhaustive switch checking.

```dart
sealed class Result<T> {}
class Success<T> extends Result<T> { final T value; Success(this.value); }
class Failure<T> extends Result<T> { final Object error; Failure(this.error); }

// Compiler enforces all cases handled
String describe(Result r) => switch (r) {
  Success(:final value)  => 'ok: $value',
  Failure(:final error)  => 'err: $error',
};
```

#### Class Modifiers
Fine-grained control over inheritance/implementation.

| Modifier      | Effect                                              |
|---------------|-----------------------------------------------------|
| `final`       | Cannot be extended, implemented, or mixed in        |
| `base`        | Can be extended, but not implemented                |
| `interface`   | Can be implemented, but not extended                |
| `sealed`      | Closed hierarchy (implies `abstract` + `final`)     |
| `mixin class` | Can be both extended and used as a mixin            |

#### 100% Sound Null Safety
The minimum SDK floor moved up; pre-null-safety code no longer runs on Dart 3+.

---

### Dart 3.1 (Flutter 3.13) — August 2023
Minor tweaks. Mostly bug fixes, no major new language features.

---

### Dart 3.2 (Flutter 3.16) — November 2023

#### Type promotion for private final fields
Previously, type promotion only worked on local variables. Now works on `final` instance fields too:

```dart
class Foo {
  final String? _name;
  Foo(this._name);

  void greet() {
    if (_name != null) {
      print('Hello $_name');  // _name is now promoted to non-null String
    }
  }
}
```

#### `package:web` preview
New JS interop foundation, replacement for `dart:html`.

#### DevTools extensions framework
Packages can now ship their own DevTools panels.

---

### Dart 3.3 (Flutter 3.19) — February 2024

#### Extension Types ⭐
Zero-cost wrappers around existing types. Lets you create a "new type" without runtime allocation.

```dart
extension type UserId(int value) {
  bool get isValid => value > 0;
}

final id = UserId(42);
print(id.isValid);  // 'true'
// At runtime, id IS just an int. No wrapper object.
```

This replaces a lot of boilerplate from packages like `built_value` for newtype patterns.

#### Modern JS interop
Built on extension types. Type-safe calls into JavaScript, works with both JS and Wasm targets.

---

### Dart 3.4 (Flutter 3.22) — May 2024

#### WebAssembly compilation goes stable
Flutter web apps can now compile to Wasm for native-speed execution in browsers.

#### Macros (experimental, later abandoned)
Static metaprogramming preview. **Note:** Work was indefinitely paused later — don't build production code on macros.

---

### Dart 3.5 (Flutter 3.24) — August 2024
No new language features. Library and tooling improvements only.

---

### Dart 3.6 (Flutter 3.27) — December 2024

#### Digit Separators
Underscores in number literals for readability.

```dart
const million  = 1_000_000;
const hex      = 0xDEAD_BEEF;
const binary   = 0b1010_0101_1100_0011;
```

#### `pub workspaces`
First-class monorepo support in pub. Less reason to need Melos for some workflows (though Melos still adds plenty on top).

---

### Dart 3.7 (Flutter 3.29) — February 2025

#### Wildcard Variables
The name `_` is now non-binding. You can use it multiple times without naming collisions.

```dart
// Before 3.7: had to name unused params (analyzer warned)
void onTap(_, __, ___) { /* ... */ }

// Dart 3.7+: just use _ multiple times
void onTap(_, _, _) { /* ... */ }

// Useful in patterns too
final (_, _, third) = (1, 2, 3);  // grab only third
```

#### New `dart format` style ("tall style")
Reformats code with trailing commas and a different break strategy. **Files at language version ≥ 3.7 get the new style automatically.**

This is a real visible change — your diffs will look different after first reformat post-upgrade. Worth doing in a single dedicated commit.

---

### Dart 3.8 (Flutter 3.32) — May 2025

#### Null-aware Elements in Collections

```dart
final items = [
  'apple',
  ?maybeOrange,    // skipped if null
  'banana',
];

final map = {
  'a': 1,
  ?someKey: ?someValue,  // skipped if either is null
};
```

Eliminates conditional spread operator gymnastics for nullable values.

---

### Dart 3.9 (Flutter 3.35) — August 2025
Performance improvements, library updates. Cross-compilation support for ARM and RISC-V64.

---

### Dart 3.11 (Flutter 3.41) — March 2026
Current. Ships with Flutter 3.41. (Dart 3.10 was an internal release, skipped publicly.)

---

## Flutter Framework Changes by Version

### Flutter 3.10 (May 2023)
- Impeller default renderer on iOS
- Dart 3.0 lands (records, patterns, sealed classes)
- Initial `two_dimensional_scrollables` package (TableView)

### Flutter 3.13 (August 2023)
- 2D scrolling improvements (Sliver classes for fancy scrolling)
- Impeller available on Android Vulkan (`--enable-impeller` flag)
- iOS app extensions support

### Flutter 3.16 (November 2023) — **Watch for visual regressions**
- **Material 3 became the default theme** (`useMaterial3: true` is now default)
- Impeller preview available on Android
- Predictive back navigation (Android 14+)
- Mouse scroll wheel on Android tablets/foldables
- Deprecated APIs removed after v3.13

### Flutter 3.19 (February 2024)
- Dropped Android KitKat support
- `MaterialState` → `WidgetState` rename
- `textScaleFactor` → `TextScaler` deprecation
- New ColorScheme roles for Material 3

### Flutter 3.22 (May 2024)
- **WebAssembly stable for Flutter web**
- Impeller's Vulkan backend feature complete on Android
- Custom fragment shader support on Android
- PlatformView support on Impeller Android
- Flavor-conditional asset bundling
- Vertex AI for Firebase preview

### Flutter 3.24 (August 2024)
- `WidgetStateProperty` API generalizations
- Form validation improvements
- Various polish

### Flutter 3.27 (December 2024) — **Major rendering shift**
- **Impeller is now the default rendering engine on iOS AND Android API 29+**
- Falls back to OpenGL/Skia on Android <29 or non-Vulkan devices
- This affects custom shader / `BackdropFilter` behavior

### Flutter 3.29 (February 2025)
- New `dart format` style (via Dart 3.7)
- Wildcard variables in framework code
- Material/Cupertino library extraction work begins

### Flutter 3.32 (May 2025)
- Null-aware collection elements (via Dart 3.8)
- Continued Material 3 polish
- iOS Swift Package Manager improvements

### Flutter 3.35 (August 2025)
- Continued Impeller improvements
- Performance work
- (Your old global was 3.35.6)

### Flutter 3.41 (March 2026) — **Current**
Several notable items:

- **Bounded blur** style for `BackdropFilter` — eliminates color bleeding at edges (Impeller fix)
- **Widget Previews** matured: Flutter Inspector embedded, `dart:ffi` and `dart:io` support
- **Native drag handle** for `CupertinoSheet` via `showDragHandle`
- **Platform-tagged assets** in `pubspec.yaml` — only bundle assets per target platform
- **Kotlin DSL** is now default for new plugin scaffolds (`build.gradle.kts`)
- **Public release windows** — predictable cutoffs for what lands in stable
- **Material/Cupertino library decoupling** continues (will eventually be separate packages)
- **AGP 9 caveat:** Flutter apps on AGP 9 with plugin dependencies are **not yet supported** — hold on AGP 9 upgrades

---

## Major Renames & API Changes

| Old                 | New                       | Since         | Notes                                              |
|---------------------|---------------------------|---------------|----------------------------------------------------|
| `MaterialState`     | `WidgetState`             | Flutter 3.19  | Reflects use beyond Material widgets               |
| `textScaleFactor`   | `TextScaler`              | Flutter 3.16  | Deprecated, removed later                          |
| `RawKeyEvent`       | `KeyEvent`                | Flutter 3.16+ | Whole keyboard subsystem rewritten                 |
| `RawKeyboard`       | `HardwareKeyboard`        | Flutter 3.16+ | Same                                               |
| `MemoryAllocations` | `FlutterMemoryAllocations`| Flutter 3.19  | Disambiguation                                     |
| `dart:html`         | `package:web`             | Dart 3.2+     | New JS interop foundation                          |
| `@FfiNative`        | `@Native`                 | Dart 3.3      | FFI annotation rename                              |

`dart fix` handles most of these. Run it at upgrade time.

---

## Migration Checklist for Old Projects

If you're bringing a project from 3.10 to 3.41, walk through this:

1. **`flutter pub upgrade`** and resolve any constraint conflicts
2. **`dart fix --apply`** to auto-migrate deprecated APIs
3. **`flutter analyze`** — review and fix every warning
4. **Test custom shaders** if you have any — Impeller behaves differently from Skia
5. **Check `BackdropFilter` usage** — visual rendering may differ pre/post Impeller
6. **Audit `BuildContext` async gaps** — analyzer rules tightened
7. **Material 3 visual review** — golden tests will likely break; review intentional vs accidental changes
8. **Reformat once** with `dart format .` (new tall style if at language ≥ 3.7)
9. **Android Gradle Plugin** — likely needs bumping; stay below AGP 9 if you have plugin dependencies
10. **iOS** — minimum deployment target may have moved; check Xcode warnings

---

## What's Probably Coming Next

Based on the project's direction:

- **Material/Cupertino as separate packages** — design updates ship faster, decoupled from SDK
- **More Impeller refinements** — closing remaining gaps with Skia behavior
- **Hot reload improvements** for new patterns
- **Continued Wasm maturity** for web targets
- **Macros** are paused indefinitely — don't expect them
- **Primary constructors** were considered but no public timeline

---

## References

- Flutter release notes: https://docs.flutter.dev/release/release-notes
- Flutter breaking changes: https://docs.flutter.dev/release/breaking-changes
- Dart language evolution: https://dart.dev/resources/language/evolution
- Dart breaking changes: https://dart.dev/resources/breaking-changes
- Impeller docs: https://docs.flutter.dev/perf/impeller

---

*Generated as a reference TLDR for migration planning. For exhaustive per-version detail, consult the official changelogs above.*
