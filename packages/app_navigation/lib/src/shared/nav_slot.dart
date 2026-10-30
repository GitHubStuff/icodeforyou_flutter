// packages/app_navigation/lib/src/shared/nav_slot.dart

/// Where a navigation destination lives inside an adaptive navigation
/// surface (a `NavigationRail`, `NavigationBar`, or `NavigationDrawer`).
///
/// A navigation surface has finite room. When the list of destinations
/// exceeds what the surface can display, the destinations are split into
/// three placements:
///
/// * [pinned] — destinations that always occupy a permanent position on the
///   surface, unless there is not enough room on the device. At that point
///   anyting [pinned] is demoted to [overflow].
/// * [more] — the single affordance that reveals the hidden destinations.
///   There is exactly one of these per surface, and it is rendered only when
///   at least one [overflow] destination exists.
/// * [overflow] — destinations that do not fit on the surface and are
///   reachable only by activating the [more] affordance (typically in a
///   menu, bottom sheet, or secondary drawer).
///
/// `NavSlot` describes **placement**, not identity or behaviour. Two
/// destinations with different slots are still ordinary destinations; the
/// slot only governs where they are drawn and how the user reaches them.
///
///
enum NavSlot {
  /// A destination that always occupies a permanent position on the
  /// navigation surface (room permitting).
  ///
  /// Pinned destinations are never collapsed into the [more] affordance and
  /// are rendered in list order before it. Use this for the small set of
  /// primary destinations the user must always be able to reach in a single
  /// tap.
  pinned,

  /// The single affordance that reveals the [overflow] destinations.
  ///
  /// A surface has at most one `more` entry. It is a piece of navigation
  /// chrome rather than a real destination: activating it opens a secondary
  /// container (menu, sheet, or drawer) listing the [overflow] destinations
  /// instead of navigating anywhere itself.
  ///
  /// Surfaces should omit this entry entirely when there are no [overflow]
  /// destinations to show.
  more,

  /// A destination hidden from the navigation surface and reachable only
  /// through the [more] affordance.
  ///
  /// Overflow destinations are rendered inside whatever secondary container
  /// the [more] affordance opens, in list order. Use this for destinations
  /// that are valid but visited infrequently enough that they do not justify
  /// a permanent spot on the surface.
  overflow,
}
