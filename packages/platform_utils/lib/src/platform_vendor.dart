// core/platform/platform_vendor.dart

import 'package:platform_utils/src/app_platform.dart';

/// The company whose ecosystem the current [AppPlatform] belongs to.
///
/// Useful for vendor-wide decisions — Cupertino vs Material styling,
/// store links, sign-in providers — where the individual OS is too fine
/// a distinction.
///
/// Lives in its own file per the Single Responsibility Principle:
/// [AppPlatform] answers *what OS?*, this enum answers *whose OS?*.
///
/// There is deliberately no test override here — [current] derives
/// entirely from [AppPlatform.current], so overriding the platform via
/// [AppPlatform.setPlatform] overrides the vendor with it. One source of
/// truth, per DRY.
///
/// ```dart
/// if (PlatformVendor.current() == PlatformVendor.apple) {
///   return const CupertinoPageScaffold(child: body);
/// }
/// ```
enum PlatformVendor {
  /// Apple platforms: [AppPlatform.iOS] and [AppPlatform.macOS].
  apple,

  /// Google platforms: [AppPlatform.android] and [AppPlatform.fuchsia].
  google,

  /// Microsoft platforms: [AppPlatform.windows].
  microsoft,

  /// Platforms with no single controlling vendor: [AppPlatform.linux]
  /// and [AppPlatform.web].
  other;

  /// Resolves the vendor of the platform the application is running on.
  ///
  /// Delegates to [AppPlatform.current], so any override set via
  /// [AppPlatform.setPlatform] is honored here too.
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
      case AppPlatform.web:
        return .other;

      case AppPlatform.windows:
        return .microsoft;
    }
  }
}
