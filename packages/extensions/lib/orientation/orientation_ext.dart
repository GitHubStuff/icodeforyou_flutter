// packages/extensions/lib/orientation/orientation_ext.dart

import 'package:flutter/widgets.dart' show Orientation;

/// Convenience predicates on Flutter's [Orientation], mirroring the
/// `isPhone` / `isTablet` style of `FormFactor`'s getters.
///
/// Resolve the receiver via `OrientationFactor.of` — values read directly
/// from [MediaQuery] bypass the debug override set with
/// `OrientationFactor.setOrientation`, so predicates on them will not
/// reflect a forced orientation during development or testing.
///
/// ```dart
/// final orientation = OrientationFactor.of(context);
/// if (orientation.isPortrait) {
///   return const StackedLayout();
/// }
/// ```
extension OrientationExt on Orientation {
  /// Whether this orientation is [Orientation.portrait].
  bool get isPortrait => this == Orientation.portrait;

  /// Whether this orientation is [Orientation.landscape].
  bool get isLandscape => this == Orientation.landscape;
}
