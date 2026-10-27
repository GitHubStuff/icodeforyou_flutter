// packages/ext_buildcontext/lib/src/window_size_category.dart
import 'package:flutter/widgets.dart';

/// Material window size classes.
///
/// Each value carries its exclusive upper-bound width in logical pixels (dp)
/// via [upperBound] — the breakpoints live here and nowhere else. Resolve the
/// class for the current layout with [of], or for an arbitrary width with
/// [fromWidth].
///
/// The values are ordered from narrowest to widest. Resolution selects the
/// first value whose [upperBound] is strictly greater than the width, so the
/// half-open ranges documented on each value never overlap and leave no gaps.
enum WindowSizeCategory {
  /// Phone portrait.
  ///
  /// Covers widths in the range `[0, 600)` dp.
  compact(600),

  /// Phone landscape, tablet portrait, or foldable.
  ///
  /// Covers widths in the range `[600, 840)` dp.
  medium(840),

  /// Tablet landscape or small desktop.
  ///
  /// Covers widths in the range `[840, 1200)` dp.
  expanded(1200),

  /// Desktop.
  ///
  /// Covers widths in the range `[1200, 1600)` dp.
  large(1600),

  /// Large desktop.
  ///
  /// Covers widths in the range `[1600, ∞)` dp.
  extraLarge(double.infinity);

  /// Creates a [WindowSizeCategory] with its exclusive [upperBound] width.
  const WindowSizeCategory(this.upperBound);

  /// Exclusive upper-bound width in logical pixels (dp).
  ///
  /// A width belongs to this class when it is strictly less than this value
  /// and greater than or equal to the [upperBound] of the preceding value.
  /// The widest class uses [double.infinity] so every width resolves to
  /// exactly one class.
  final double upperBound;

  static WindowSizeCategory? _mock;

  /// For testing and development this allows the override the value of
  /// [WindowSizeCategory] in the 'fromWidget
  static void setMock({WindowSizeCategory? newMock}) {
    // setMock is a debug-only override and has no effect in release builds
    assert(() {
      _mock = newMock;
      return true;
    }());
  }

  /// The size class for a window [width] in logical pixels (dp).
  ///
  /// Returns the first value whose [upperBound] is strictly greater than
  /// [width]. Every finite, non-negative width resolves to exactly one
  /// class; [double.infinity] resolves to [extraLarge].
  ///
  /// Throws an [ArgumentError] for a negative or `NaN` width, neither of
  /// which is a layout width.
  static WindowSizeCategory fromWidth(double width) {
    if (width.isNaN || width < 0) {
      throw ArgumentError.value(
        width,
        'width',
        'must be a non-negative number',
      );
    }

    // Check if debug/development has set the mock
    if (_mock != null) return _mock!;

    return values.firstWhere((category) => width < category.upperBound);
  }

  /// The size class for the window containing [context].
  ///
  /// Reads the width from [MediaQuery.sizeOf], so the calling widget
  /// rebuilds only when the window size changes, not on every
  /// [MediaQueryData] change. Throws if [context] has no [MediaQuery]
  /// ancestor, exactly as [MediaQuery.sizeOf] does.
  ///
  /// ```dart
  /// final size = WindowSizeCategory.of(context);
  /// if (size == .compact) return const PhoneLayout();
  /// ```
  static WindowSizeCategory of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
