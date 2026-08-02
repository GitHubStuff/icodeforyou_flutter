// programs/template_app/lib/screens/rail/rail_enum.dart

/// The app's rail destinations.
///
/// Each value names one place the rail can take the user. A destination is
/// paired with the screen it shows by a `RailContent`, and `Rails` derives
/// both the rail's buttons and the shell's screens from that list — so a
/// value here is inert until some `RailContent` claims it.
///
/// ## Order does not matter
///
/// This enum expresses identity only, never position. `Rails` locates the
/// visible screen with `contents.indexWhere(...)` rather than [Enum.index],
/// so rail order is whatever order the caller lists its `RailContent`s in.
/// Reordering these values changes nothing on screen, and listing only some
/// of them is valid: a destination with no content simply gets no button.
///
/// ## Adding a destination
///
/// `Rails._buttonFor` switches over this enum with no default arm, so a new
/// value is a compile error until its rail button is supplied — the point of
/// declaring destinations as an enum rather than as strings or ints. The
/// screen is not compiler-enforced in the same way; it is supplied at the
/// call site, and an assert catches a selection with no matching content.
///
/// ## Example
///
/// ```dart
/// Rails(
///   selection: .settings,
///   contents: const [
///     RailContent(identifier: .main, widget: HomeScreen()),
///     RailContent(identifier: .settings, widget: SettingsScreen()),
///   ],
///   // ...
/// )
/// ```
enum RailDestinationEnum {
  /// The app's home destination.
  main,

  /// The settings destination, hosting the app's settings controls.
  settings,
}
