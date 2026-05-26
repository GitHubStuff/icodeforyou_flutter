// packages/extensions/lib/placement/placement.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart' show Alignment;

enum Placement {
  top,
  bottom,
  left,
  right,
  center;

  /// `true` for [left] and [right].
  bool get isHorizontal => this == left || this == right;

  /// `true` for [top] and [bottom].
  bool get isVertical => this == top || this == bottom;

  /// `true` for [center].
  bool get isCentered => this == center;

  /// This placement expressed as a Flutter [Alignment], for interop with any
  /// widget that takes an [Alignment] (e.g. `Align`, `Stack`).
  Alignment get toAlignment => switch (this) {
    top => Alignment.topCenter,
    bottom => Alignment.bottomCenter,
    left => Alignment.centerLeft,
    right => Alignment.centerRight,
    center => Alignment.center,
  };
}
