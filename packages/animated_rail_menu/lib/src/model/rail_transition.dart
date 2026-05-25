// lib/src/model/rail_transition.dart

/// The transition animation applied to the body when the active item changes.
enum RailTransition {
  /// Cross-fades between screens. Default.
  crossFade,

  /// Slides the incoming screen in from the left.
  slideLeft,

  /// Slides the incoming screen in from the right.
  slideRight,

  /// Slides based on item position — tapping an item to the left of the
  /// current item slides in from the left; tapping to the right slides
  /// in from the right. On a vertical rail, uses up/down accordingly.
  slideDirectional,

  /// Scales the incoming screen in from the centre.
  scale,

  /// Slides the incoming screen in from above.
  slideUp,

  /// Slides the incoming screen in from below.
  slideDown,
}
