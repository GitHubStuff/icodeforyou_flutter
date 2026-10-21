// packages/platform_tools/lib/src/os_platform.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// The operating system the application is currently running on.
///
/// Flutter exposes platform information through two separate primitives:
///
/// * [kIsWeb], a compile-time constant that is `true` for every browser
///   build, whether compiled to JavaScript or to WebAssembly.
/// * [defaultTargetPlatform], a runtime getter that reports the host
///   operating system — and, notably, keeps reporting the host OS even
///   inside a browser.
///
/// Consumers that need to answer "where am I running?" would otherwise
/// have to check both, in the right order, every time. [OSPlatform] folds
/// them into a single exhaustive enum so that call sites can `switch` on
/// one value and let the compiler enforce that every case is handled.
///
/// This enum answers exactly one question — *what OS?* — per the Single
/// Responsibility Principle. It deliberately does **not** model:
///
/// * the compilation target (JavaScript vs. WebAssembly) — that is an
///   orthogonal concern, see `kIsWasm` in `package:flutter/foundation.dart`;
/// * device form factor (phone, tablet, desktop window);
/// * capability flags (has camera, supports haptics, …).
///
/// Each of those deserves its own abstraction. Keeping them out of this
/// enum keeps every `switch (OSPlatform.current)` in the codebase small
/// and stable.
///
/// ## Resolving the platform
///
/// ```dart
/// final platform = OSPlatform.current;
///
/// final storage = switch (platform) {
///   OSPlatform.web => SessionStorage(),
///   OSPlatform.android || OSPlatform.iOS => SecureStorage(),
///   OSPlatform.linux ||
///   OSPlatform.macOS ||
///   OSPlatform.windows =>
///     FileStorage(),
///   OSPlatform.fuchsia => throw UnsupportedError('Fuchsia'),
/// };
/// ```
///
/// ## Testing
///
/// Because [current] is a static getter backed by framework globals, it
/// cannot be injected. Use [override] in tests to force a specific value
/// and clear it in `tearDown` so state does not leak between test cases:
///
/// ```dart
/// setUp(() => OSPlatform.override(to: OSPlatform.iOS));
/// tearDown(OSPlatform.override);
/// ```
///
/// See also:
///
/// * [TargetPlatform], the framework enum this wraps.
/// * [defaultTargetPlatform], the framework getter this wraps.
/// * [kIsWeb], the framework constant this wraps.
///
enum OSPlatform {
  /// Android phones, tablets, and other Android-based devices.
  ///
  /// Mapped from [TargetPlatform.android].
  android,

  /// Google Fuchsia.
  ///
  /// Recognized by the framework but not yet supported by this
  /// application — capability getters throw [UnsupportedError] for it.
  /// It is included so that the mapping from [TargetPlatform] stays
  /// exhaustive and the compiler flags any future framework additions.
  ///
  /// Mapped from [TargetPlatform.fuchsia].
  fuchsia,

  /// iOS and iPadOS.
  ///
  /// Flutter treats these as a single target platform; this enum does
  /// not distinguish them either. If iPad-specific behaviour is ever
  /// required, derive it from form factor, not from this value.
  ///
  /// Mapped from [TargetPlatform.iOS].
  iOS,

  /// Desktop Linux.
  ///
  /// Mapped from [TargetPlatform.linux].
  linux,

  /// Desktop macOS.
  ///
  /// Mapped from [TargetPlatform.macOS].
  macOS,

  /// Any browser, regardless of the underlying operating system or the
  /// compilation target.
  ///
  /// Resolved from [kIsWeb], which takes precedence over
  /// [defaultTargetPlatform]. Inside a browser the framework still reports
  /// the host OS (for example [TargetPlatform.macOS] in Safari on a Mac);
  /// this value hides that detail because the application is sandboxed by
  /// the browser, not by the OS.
  ///
  /// Both JavaScript (dart2js) and WebAssembly (dart2wasm) builds resolve
  /// to this value. Use `kIsWasm` directly if the distinction matters.
  web,

  /// Desktop Windows.
  ///
  /// Mapped from [TargetPlatform.windows].
  windows;

  /// The active override set via [override], or `null` when runtime
  /// resolution is in effect.
  ///
  /// Static mutable state is a deliberate trade-off: [current] must be a
  /// static getter to be usable from `const` constructors and top-level
  /// code, and a static getter cannot receive injected dependencies. The
  /// override exists solely so that tests can control the result.
  static OSPlatform? _platformOverride;

  /// Resolves the platform the application is running on right now.
  ///
  /// This is a getter rather than a method because it is conceptually a
  /// property: it has no side effects, is cheap (a constant check and a
  /// `switch`), and returns the same value for the same process state.
  /// This matches the framework's own [defaultTargetPlatform].
  ///
  /// Resolution order:
  ///
  /// 1. The override set via [override], when present. This exists for
  ///    tests and is ignored when `null`.
  /// 2. [web], when [kIsWeb] is `true`. The browser wins over whatever
  ///    OS is hosting it, because [defaultTargetPlatform] keeps reporting
  ///    the host OS inside a browser and that is never what callers want.
  /// 3. The one-to-one mapping of [defaultTargetPlatform] otherwise.
  ///
  /// The `switch` is exhaustive. If a future Flutter release adds a value
  /// to [TargetPlatform], this getter stops compiling until the new value
  /// is mapped — which is the intended behaviour.
  ///
  /// The [kIsWeb] branch is excluded from coverage: it is a compile-time
  /// constant, so a single test binary can only ever observe one side of
  /// it.
  static OSPlatform get current {
    if (_platformOverride != null) return _platformOverride!;
    if (kIsWeb) return OSPlatform.web; // coverage:ignore-line
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => OSPlatform.android,
      TargetPlatform.fuchsia => OSPlatform.fuchsia,
      TargetPlatform.iOS => OSPlatform.iOS,
      TargetPlatform.linux => OSPlatform.linux,
      TargetPlatform.macOS => OSPlatform.macOS,
      TargetPlatform.windows => OSPlatform.windows,
    };
  }

  /// Overrides the platform reported by [current].
  ///
  /// Pass the platform to simulate in [to]. Pass `null`, or call with no
  /// argument, to clear a previously set override and restore runtime
  /// resolution.
  ///
  /// The body runs inside an `assert`, so it is active only when asserts
  /// are enabled — debug builds and `flutter test`. In profile and release
  /// builds the entire call is stripped by the compiler and has no effect,
  /// which guarantees that a stray override can never ship.
  ///
  /// Always clear the override in `tearDown`. The value is static and
  /// persists across test cases within the same isolate; a leaked override
  /// produces order-dependent test failures that are painful to diagnose.
  ///
  /// ```dart
  /// setUp(() => OSPlatform.override(to: OSPlatform.iOS));
  /// tearDown(OSPlatform.override);
  /// ```
  static void override({OSPlatform? to}) {
    // Debug-only: the assert closure, and therefore the assignment, is
    // compiled out of profile and release builds.
    assert(() {
      _platformOverride = to;
      return true;
    }());
  }
}
