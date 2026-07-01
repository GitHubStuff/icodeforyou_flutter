// packages/extensions/lib/enum/src/window_category.dart
import 'package:flutter/widgets.dart';

/// Material window size classes.
///
/// Each value carries its exclusive upper-bound width in logical pixels (dp)
/// via [upperBound] — the breakpoints live here and nowhere else. Resolve the
/// class for the current layout with [WindowSizeClass.of] or the
/// [WindowSizeContextExt.windowSizeClass] getter on [BuildContext].
///
/// The values are ordered from narrowest to widest. Resolution selects the
/// first value whose [upperBound] is strictly greater than the available
/// width, so the half-open ranges documented on each value never overlap and
/// leave no gaps.
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
}
