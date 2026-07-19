// packages/settings_widget/lib/src/settings_direction.dart

/// The screen edge a settings surface anchors to and enters from.
///
/// Each value names an **edge of the viewport**, not a direction of travel:
/// [bottom] means "the surface lives at the bottom edge and slides *up* into
/// place," mirroring how designers and users describe overlay placement
/// ("bottom sheet," "top banner," "left drawer"). This is the package's
/// ubiquitous language, which is why the Flutter framework's superficially
/// similar enums are deliberately not used here:
///
/// * `AxisDirection { up, right, down, left }` encodes travel direction, so
///   a bottom-anchored sheet would be `AxisDirection.up` — an inversion every
///   call site would have to perform (and every reviewer re-verify).
/// * `TraversalDirection` shares the names but belongs to the focus-traversal
///   domain; borrowing it would couple this package's public API to
///   unrelated framework semantics.
///
/// ## Consumers
///
/// `SettingsTransition` switches exhaustively over this enum to compute its
/// slide tween's begin offset, in fractional units of the child's size:
///
/// | Value    | Begin offset  | Perceived motion      |
/// |----------|---------------|-----------------------|
/// | [bottom] | `Offset(0, 1)`  | slides up into place  |
/// | [top]    | `Offset(0, -1)` | slides down into place|
/// | [left]   | `Offset(-1, 0)` | slides rightward      |
/// | [right]  | `Offset(1, 0)`  | slides leftward       |
///
/// Because that switch has no default clause, adding a value to this enum is
/// a **compile-time error** until every consumer handles it — the enum's
/// primary safety guarantee. Keep it that way: never add a `default` arm
/// when switching over [SettingsDirection].
///
/// ## Example
///
/// ```dart
/// showSettings(
///   context,
///   direction: SettingsDirection.bottom, // conventional sheet entrance
/// );
/// ```
enum SettingsDirection {
  /// Anchored to the top edge; the surface slides **down** into place from
  /// above the viewport.
  ///
  /// Suits banner- or notification-style settings surfaces.
  top,

  /// Anchored to the bottom edge; the surface slides **up** into place from
  /// below the viewport.
  ///
  /// The conventional mobile sheet entrance and the most common choice.
  bottom,

  /// Anchored to the left edge; the surface slides **rightward** into place
  /// from beyond the left viewport bound.
  ///
  /// Suits drawer-style placement. Note this is a physical edge, not a
  /// text-direction-aware "start" — it does not flip under RTL locales.
  left,

  /// Anchored to the right edge; the surface slides **leftward** into place
  /// from beyond the right viewport bound.
  ///
  /// Physical edge, like [left]: unaffected by RTL text direction.
  right,
}
