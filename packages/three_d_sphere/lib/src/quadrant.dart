// packages/three_d_sphere/lib/src/quadrant.dart

/// {@template quadrant.dart}
/// A named position on the perimeter of a rectangular region — the four
/// corners and the midpoint of each edge.
///
/// Despite the name, this is an eight-way compass of anchor positions, not a
/// four-way quadrant split: the region's center is deliberately absent, so
/// every value identifies a location on the boundary. Use it to describe
/// where something attaches, aligns, or originates relative to a host
/// rectangle — a popover's anchor, a badge's placement, a resize handle,
/// an overlay's docking edge.
///
/// Values are ordered in reading order: the top row left-to-right, the two
/// edge midpoints, then the bottom row left-to-right. No behavior hangs on
/// this ordering; it exists for predictable iteration and stable
/// presentation when the values are listed in UI or documentation.
/// {@endtemplate}
enum Quadrant {
  /// The top-left corner of the region.
  topLeft,

  /// The midpoint of the region's top edge.
  topCenter,

  /// The top-right corner of the region.
  topRight,

  /// The midpoint of the region's left edge.
  leftCenter,

  /// The midpoint of the region's right edge.
  rightCenter,

  /// The bottom-left corner of the region.
  bottomLeft,

  /// The midpoint of the region's bottom edge.
  bottomCenter,

  /// The bottom-right corner of the region.
  bottomRight,
}
