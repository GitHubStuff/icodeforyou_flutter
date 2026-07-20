// core/platform/app_platform.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// The operating system the application is currently running on.
///
/// Wraps Flutter's [defaultTargetPlatform] and [kIsWeb] into a single,
/// testable enum. Use [current] to resolve the active platform at runtime
/// and [setPlatform] to override it in tests.
///
/// This enum answers exactly one question — *what OS?* — per the Single
/// Responsibility Principle. Form factor lives in [FormFactor]; vendor
/// grouping lives in `PlatformVendor` (see `platform_vendor.dart`).
///
/// ```dart
/// if (AppPlatform.current().isMobile) {
///   return const BottomNavLayout();
/// }
/// ```
enum AppPlatform {
  /// Android phones and tablets.
  android,

  /// Google Fuchsia. Recognized by the framework but not yet supported
  /// by this application — capability getters throw for it.
  fuchsia,

  /// iOS and iPadOS. Flutter treats them as a single target platform.
  iOS,

  /// Desktop Linux.
  linux,

  /// Desktop macOS.
  macOS,

  /// Any browser, regardless of the underlying operating system.
  web,

  /// Desktop Windows.
  windows;

  /// The active override set via [setPlatform], or `null` when runtime
  /// resolution is in effect.
  static AppPlatform? _platformOverride;

  /// Resolves the platform the application is running on right now.
  ///
  /// Resolution order:
  /// 1. A debug override set via [setPlatform], when present.
  /// 2. [web], when [kIsWeb] is `true` — the browser wins over whatever
  ///    OS is hosting it.
  /// 3. The mapping of [defaultTargetPlatform] otherwise.
  static AppPlatform current() {
    if (_platformOverride != null) return _platformOverride!;
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

  /// Overrides the platform reported by [current] for testing.
  ///
  /// Only active in debug builds — the body runs inside an `assert`, so it
  /// is stripped from release builds entirely. Pass `null` (or call with
  /// no argument) to clear a previously set override and restore runtime
  /// resolution.
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

  /// Whether this platform is a mobile operating system.
  ///
  /// Throws [UnimplementedError] for [fuchsia], which this application
  /// does not yet define behavior for.
  bool get isMobile => switch (this) {
    AppPlatform.android => true,
    AppPlatform.fuchsia => throw UnimplementedError('"fuchsia" is not defined'),
    AppPlatform.iOS => true,
    AppPlatform.linux => false,
    AppPlatform.macOS => false,
    AppPlatform.web => false,
    AppPlatform.windows => false,
  };

  /// Whether this platform is a desktop operating system.
  ///
  /// [web] is `false` here: the browser's host OS is invisible to the
  /// application, so desktop-ness for web is a [FormFactor] question
  /// (window geometry), not a platform one.
  ///
  /// Throws [UnimplementedError] for [fuchsia], which this application
  /// does not yet define behavior for.
  bool get isDesktop => switch (this) {
    AppPlatform.android => false,
    AppPlatform.fuchsia => throw UnimplementedError('"fuchsia" is not defined'),
    AppPlatform.iOS => false,
    AppPlatform.linux => true,
    AppPlatform.macOS => true,
    AppPlatform.web => false,
    AppPlatform.windows => true,
  };
}
