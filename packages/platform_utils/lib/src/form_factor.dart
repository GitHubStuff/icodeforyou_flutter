// packages/platform_utils/lib/src/form_factor.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart' show BuildContext, MediaQuery, Size;

/// Shortest-side breakpoint separating phones from tablets, in logical
/// pixels.
///
/// Matches Android's `sw600dp` convention: a device whose shortest side is
/// at least 600 logical pixels is treated as a tablet.
const double _kTabletBreakpoint = 600;

/// Width breakpoint above which any native window is treated as desktop,
/// in logical pixels.
///
/// Aligned with the Material 3 "expanded" window-size class boundary.
const double _kDesktopBreakpoint = 1024;

/// The form factor the app is currently rendering on.
///
/// A form factor describes the *rendering target* — which layout strategy
/// the app should use — as opposed to the operating system it runs on.
/// Resolve the active value with [of] inside a `build` method, or with
/// [from] when a [Size] is already in hand.
///
/// [web] is its own factor: browser deployments get one rendering path
/// regardless of window geometry. The geometry breakpoints apply only to
/// native platforms.
///
/// ```dart
/// final formFactor = FormFactor.of(context);
/// if (formFactor.isTablet) {
///   return const TwoPaneLayout();
/// }
/// ```
enum FormFactor {
  /// A handset-class device: shortest side under 600 logical pixels.
  phone,

  /// A tablet-class device: shortest side of at least 600 logical pixels,
  /// on a native mobile platform.
  tablet,

  /// A desktop rendering target: any native desktop operating system
  /// (Linux, macOS, Windows), or a native window at least 1024 logical
  /// pixels wide.
  desktop,

  /// A browser deployment. Always resolved when the app is compiled for
  /// the web, regardless of window geometry.
  web;

  /// The active override set via [setFormFactor], or `null` when runtime
  /// resolution is in effect.
  static FormFactor? _formFactorOverride;

  /// Resolves the form factor from the ambient [MediaQuery].
  ///
  /// Uses [MediaQuery.sizeOf], so native callers rebuild automatically on
  /// window resize and device rotation. On web the result is always
  /// [FormFactor.web] and never changes.
  static FormFactor of(BuildContext context) =>
      from(MediaQuery.sizeOf(context));

  /// Resolves the form factor from a window [size].
  ///
  /// Resolution order:
  /// 1. A value set via [setFormFactor] takes precedence.
  /// 2. Browser deployments are always [web].
  /// 3. Native desktop operating systems are always [desktop].
  /// 4. Windows at least 1024 logical pixels wide are [desktop].
  /// 5. A shortest side of at least 600 logical pixels is [tablet].
  /// 6. Everything else is [phone].
  ///
  /// Pure with respect to geometry, so breakpoint behavior is unit-testable
  /// without a widget tree:
  ///
  /// ```dart
  /// expect(FormFactor.from(const Size(400, 800)), FormFactor.phone);
  /// expect(FormFactor.from(const Size(800, 1280)), FormFactor.tablet);
  /// ```
  static FormFactor from(Size size) {
    if (_formFactorOverride != null) {
      return _formFactorOverride!;
    }
    if (kIsWeb) return FormFactor.web;
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return FormFactor.desktop;
    }
    if (size.width >= _kDesktopBreakpoint) return FormFactor.desktop;
    if (size.shortestSide >= _kTabletBreakpoint) return FormFactor.tablet;
    return FormFactor.phone;
  }

  /// Overrides the form factor returned by [of] and [from].
  ///
  /// The override takes precedence over every runtime signal, including
  /// [kIsWeb] — useful for previewing the [phone], [tablet], or [desktop]
  /// paths inside a debug web build.
  ///
  /// Only active in debug builds — the body runs inside an `assert`, so it
  /// is stripped from release builds entirely. Pass `null` (or omit [to])
  /// to clear a previously set override and restore runtime resolution.
  ///
  /// ```dart
  /// setUp(() => FormFactor.setFormFactor(to: FormFactor.tablet));
  /// tearDown(() => FormFactor.setFormFactor());
  /// ```
  static void setFormFactor({FormFactor? to}) {
    assert(
      () {
        _formFactorOverride = to;
        return true;
      }(),
      'setFormFactor is a debug-only override and has no effect '
      'in release builds',
    );
  }

  /// Whether this form factor is [phone].
  bool get isPhone => this == FormFactor.phone;

  /// Whether this form factor is [tablet].
  bool get isTablet => this == FormFactor.tablet;

  /// Whether this form factor is [desktop].
  bool get isDesktop => this == FormFactor.desktop;

  /// Whether this form factor is [web].
  bool get isWeb => this == FormFactor.web;
}
