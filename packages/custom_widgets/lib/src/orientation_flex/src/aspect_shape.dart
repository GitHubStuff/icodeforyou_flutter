// packages/custom_widgets/lib/src/aspect_shape.dart
// ignore_for_file: comment_references

import 'dart:math' as math;
import 'dart:ui' show Size;

/// The shape of a viewport, classified by comparing its width and height.
///
/// This is the *input* to a responsive layout decision: it describes what a
/// viewport looks like, independent of any layout direction chosen in response.
/// Map it to an [Axis] — or any other result — at the point of use.
enum AspectShape {
  /// The viewport is wider than it is tall.
  landscape,

  /// The viewport is taller than it is wide.
  portrait,

  /// The viewport is square — within the supplied tolerance of a `1:1` ratio.
  square;

  /// Classifies [size] into an [AspectShape].
  ///
  /// [squareTolerance] is the scale-invariant fraction by which the
  /// long-to-short side ratio may exceed `1:1` and still count as [square]. It
  /// must be greater than or equal to `0.0` and defaults to
  /// [defaultSquareTolerance]. Because it is a proportion rather than a pixel
  /// count, the same value means the same thing on a phone, a tablet, and a 4K
  /// window.
  ///
  /// A value of `0.0` treats only an exact `1:1` viewport as [square]. With
  /// `squareTolerance: 0.05`, a `1000x997` viewport — ratio
  /// `1000 / 997 - 1.0 ≈ 0.003` — is [square].
  ///
  /// The square band is evaluated first, so a near-square viewport resolves to
  /// [square] rather than [landscape] or [portrait]. A degenerate viewport with
  /// a zero or negative side resolves to [square].
  factory AspectShape.fromSize(
    Size size, {
    double squareTolerance = defaultSquareTolerance,
  }) {
    assert(
      squareTolerance >= 0.0,
      'squareTolerance must be >= 0.0',
    );

    final width = size.width;
    final height = size.height;
    final shortSide = math.min(width, height);

    if (shortSide <= 0.0) {
      return AspectShape.square;
    }

    final longSide = math.max(width, height);
    if (longSide / shortSide - 1.0 <= squareTolerance) {
      return AspectShape.square;
    }

    return width > height ? AspectShape.landscape : AspectShape.portrait;
  }

  /// The default [squareTolerance] used by [AspectShape.fromSize].
  ///
  /// A value of `0.0` treats only an exact `1:1` viewport as [square]. This is
  /// the single source of truth for the default; callers that need to match it
  /// (for example a widget exposing its own tolerance parameter) should
  /// reference this constant rather than repeating the literal.
  static const double defaultSquareTolerance = 0;
}
