// packages/extensions/lib/enum/src/placement.dart
import 'package:flutter/widgets.dart' show Alignment;

/// Describes where something is positioned relative to a reference area.
///
/// [Placement] is a small, intent-revealing vocabulary for the four edges
/// ([top], [bottom], [left], [right]) plus the [center]. It is decoupled from
/// any particular widget so it can drive layout decisions, configuration, and
/// serialization without dragging in framework geometry. When a Flutter
/// [Alignment] is required, convert with [toAlignment].
///
/// The orientation getters ([isHorizontal], [isVertical], [isCentered])
/// partition the values into mutually exclusive groups, which makes them
/// convenient for branching without resorting to a `switch`:
///
/// ```dart
/// if (placement.isHorizontal) {
///   // [left] or [right]: lay children out along the cross axis.
/// }
/// ```
enum Placement {
  /// Positioned against the top edge, horizontally centered.
  ///
  /// Maps to [Alignment.topCenter]. Considered [isVertical].
  top,

  /// Positioned against the bottom edge, horizontally centered.
  ///
  /// Maps to [Alignment.bottomCenter]. Considered [isVertical].
  bottom,

  /// Positioned against the left edge, vertically centered.
  ///
  /// Maps to [Alignment.centerLeft]. Considered [isHorizontal].
  left,

  /// Positioned against the right edge, vertically centered.
  ///
  /// Maps to [Alignment.centerRight]. Considered [isHorizontal].
  right,

  /// Positioned at the center of the reference area on both axes.
  ///
  /// Maps to [Alignment.center]. Considered [isCentered].
  center;

  /// Whether this placement sits on a horizontal edge.
  ///
  /// Returns `true` for [left] and [right]; otherwise `false`.
  bool get isHorizontal => this == left || this == right;

  /// Whether this placement sits on a vertical edge.
  ///
  /// Returns `true` for [top] and [bottom]; otherwise `false`.
  bool get isVertical => this == top || this == bottom;

  /// Whether this placement is the center.
  ///
  /// Returns `true` only for [center]; otherwise `false`.
  bool get isCentered => this == center;

  /// This placement expressed as a Flutter [Alignment].
  ///
  /// Provided for interop with any widget that takes an [Alignment]
  /// (for example, [Align] or [Stack]). The mapping is total: every
  /// [Placement] value resolves to a distinct [Alignment].
  ///
  /// | Placement  | Alignment               |
  /// | ---------- | ----------------------- |
  /// | [top]      | [Alignment.topCenter]    |
  /// | [bottom]   | [Alignment.bottomCenter] |
  /// | [left]     | [Alignment.centerLeft]   |
  /// | [right]    | [Alignment.centerRight]  |
  /// | [center]   | [Alignment.center]       |
  Alignment get toAlignment => switch (this) {
    top => Alignment.topCenter,
    bottom => Alignment.bottomCenter,
    left => Alignment.centerLeft,
    right => Alignment.centerRight,
    center => Alignment.center,
  };
}
