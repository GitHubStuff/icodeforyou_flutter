// packages/platform_utils/lib/src/orientation_predicates.dart
import 'package:flutter/widgets.dart' show Orientation;

/// Convenience predicates on Flutter's [Orientation], mirroring the
/// `isPhone` / `isTablet` style of the package's [FormFactor] getters.
extension OrientationExt on Orientation {
  /// Whether this orientation is [Orientation.portrait].
  bool get isPortrait => this == Orientation.portrait;

  /// Whether this orientation is [Orientation.landscape].
  bool get isLandscape => this == Orientation.landscape;
}
