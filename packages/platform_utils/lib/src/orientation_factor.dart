// packages/platform_utils/lib/src/orientation_factor.dart

import 'package:flutter/widgets.dart'
    show BuildContext, MediaQuery, Orientation, Size;

/// Resolves the layout [Orientation] the app is currently rendering in.
///
/// Returns Flutter's own [Orientation] enum rather than defining a
/// parallel one, so results plug directly into [OrientationBuilder],
/// [MediaQuery], and every other framework API without conversion.
/// Because [Orientation] is a framework type, the resolver statics live
/// on this holder class instead of the enum itself — the same shape as
/// the rest of the package's resolvers otherwise.
///
/// Orientation is derived purely from window geometry (landscape iff the
/// window is wider than it is tall), matching the framework's own
/// definition. It reflects the window, not the device sensor — a tall
/// desktop window resolves as [Orientation.portrait].
///
/// ```dart
/// final orientation = OrientationFactor.of(context);
/// if (orientation.isLandscape) {
///   return const SideBySideLayout();
/// }
/// ```
abstract final class OrientationFactor {
  const OrientationFactor._();

  /// The active override set via [setOrientation], or `null` when runtime
  /// resolution is in effect.
  static Orientation? _orientationOverride;

  /// Resolves the orientation from the ambient [MediaQuery].
  ///
  /// Uses [MediaQuery.sizeOf], so callers rebuild automatically on window
  /// resize and device rotation.
  static Orientation of(BuildContext context) =>
      from(MediaQuery.sizeOf(context));

  /// Resolves the orientation from a window [size].
  ///
  /// Resolution order:
  /// 1. A value set via [setOrientation] takes precedence.
  /// 2. [Orientation.landscape] when [size] is wider than it is tall.
  /// 3. [Orientation.portrait] otherwise (a square window is portrait,
  ///    matching [MediaQueryData.orientation]).
  ///
  /// Pure with respect to geometry, so it is unit-testable without a
  /// widget tree:
  ///
  /// ```dart
  /// expect(OrientationFactor.from(const Size(400, 800)),
  ///     Orientation.portrait);
  /// expect(OrientationFactor.from(const Size(800, 400)),
  ///     Orientation.landscape);
  /// ```
  static Orientation from(Size size) {
    if (_orientationOverride != null) {
      return _orientationOverride!;
    }
    return size.width > size.height
        ? Orientation.landscape
        : Orientation.portrait;
  }

  /// Overrides the orientation returned by [of] and [from].
  ///
  /// Only active in debug builds — the body runs inside an `assert`, so it
  /// is stripped from release builds entirely. Pass `null` (or omit [to])
  /// to clear a previously set override and restore runtime resolution.
  ///
  /// ```dart
  /// setUp(() =>
  ///     OrientationFactor.setOrientation(to: Orientation.landscape));
  /// tearDown(() => OrientationFactor.setOrientation());
  /// ```
  static void setOrientation({Orientation? to}) {
    assert(
      () {
        _orientationOverride = to;
        return true;
      }(),
      'setOrientation is a debug-only override and has no effect '
      'in release builds',
    );
  }
}

