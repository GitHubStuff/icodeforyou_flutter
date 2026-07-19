
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Represents the platform the application is currently running on.
///
/// Wraps Flutter's [defaultTargetPlatform] and [kIsWeb] into a single,
/// testable enum. Use [current] to resolve the active platform at runtime
/// and [setPlatform] to override it in tests.
enum AppPlatform {
  /// The Android mobile operating system.
  android,

  /// Google's Fuchsia operating system.
  fuchsia,

  /// Apple's iOS mobile operating system.
  iOS,

  /// The Linux desktop operating system.
  linux,

  /// Apple's macOS desktop operating system.
  macOS,

  /// If tablets ever have their own operating system (iPadOS?).
  tablet,

  /// Any browser-based web deployment target.
  web,

  /// Microsoft Windows desktop operating system.
  windows,
  ;

  static AppPlatform? _platformOverride;

  /// Returns the active [AppPlatform] for the current runtime environment.
  ///
  /// Resolution order:
  /// 1. A value set via [setPlatform] takes precedence.
  /// 2. [AppPlatform.web] when [kIsWeb] is `true`.
  /// 3. The value derived from [defaultTargetPlatform] otherwise.
  static AppPlatform current() {
    if (_platformOverride != null) {
      return _platformOverride!;
    }
    if (kIsWeb) return AppPlatform.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => AppPlatform.android,
      TargetPlatform.fuchsia => AppPlatform.fuchsia,
      TargetPlatform.iOS => AppPlatform.iOS,
      TargetPlatform.linux => AppPlatform.linux,
      TargetPlatform.macOS => AppPlatform.macOS,
      TargetPlatform.windows => AppPlatform.windows,
    };
  }

  /// Overrides the platform returned by [current].
  ///
  /// Only active in debug builds — the body runs inside an `assert`, so it
  /// is stripped from release builds entirely. Pass `null` to clear a
  /// previously set override and restore runtime resolution.
  ///
  /// ```dart
  /// setUp(() => AppPlatform.setPlatform(to: AppPlatform.iOS));
  /// tearDown(() => AppPlatform.setPlatform());
  /// ```
  static void setPlatform({AppPlatform? to}) {
    assert(
      () {
        _platformOverride = to;
        return true;
      }(),
      'setPlatform is a debug-only override and has no effect '
      'in release builds',
    );
  }

  bool get isMobile => switch (this) {
    AppPlatform.android => true,
    AppPlatform.fuchsia => throw UnimplementedError('"fuchsia" is not defined'),
    AppPlatform.iOS => true,
    AppPlatform.linux => false,
    AppPlatform.macOS => false,
    AppPlatform.tablet => false,
    AppPlatform.web => false,
    AppPlatform.windows => false,
  };

  bool get isDesktop => switch (this) {
    AppPlatform.android => false,
    AppPlatform.fuchsia => throw UnimplementedError('"fuchsia" is not defined'),
    AppPlatform.iOS => false,
    AppPlatform.linux => true,
    AppPlatform.macOS => true,
    AppPlatform.tablet => false,
    AppPlatform.web => false,
    AppPlatform.windows => true,
  };
}

enum PlatformVendor {
  apple,
  google,
  microsoft,
  other;

  static PlatformVendor current() {
    final platform = AppPlatform.current();
    switch (platform) {
      case AppPlatform.android:
      case AppPlatform.fuchsia:
        return .google;

      case AppPlatform.iOS:
      case AppPlatform.macOS:
        return .apple;

      case AppPlatform.linux:
      case AppPlatform.tablet:
      case AppPlatform.web:
        return .other;

      case AppPlatform.windows:
        return .microsoft;
    }
  }
}
