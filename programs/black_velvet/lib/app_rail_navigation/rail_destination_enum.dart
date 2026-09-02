// programs/black_velvet/lib/app_rail_navigation/rail_destination_enum.dart

import 'package:app_navigation/app_navigation.dart'
    show NavigableDestinationAbstract;
import 'package:custom_widgets/custom_widgets.dart'
    show DefaultWelcomeScreen, IceChip;
import 'package:flutter/material.dart';
import 'package:theme_framework/theme_framework.dart' show SettingsScreen;

/// Placeholder view for the search destination.
/// TODO: Replace with the real screen, then delete this function.
Widget _searchView() => Center(
  child: IceChip(
    const Text('Sample'),
    backgroundColor: Colors.purpleAccent,
    showBorder: true,
    onPress: () {},
  ),
);

/// Placeholder view for the library destination.
/// TODO: Replace with the real screen, then delete this function.
Widget _libraryView() => const Center(child: Text('Library'));

/// Placeholder view for the database destination.
/// TODO: Replace with the real screen, then delete this function.
Widget _databaseView() => const Center(child: Text('Database'));

/// {@template rail_destination_enum}
/// The set of destinations available in the rail — and the only file
/// edited when that set changes.
///
/// Each member carries everything that varies per destination: the
/// glyph shown as the button's icon, the text shown as its caption,
/// and the tear-off that builds its view. All behavior — selection,
/// haptics, sizing, tinting, keep-alive — is uniform across
/// destinations and lives in `RailScreen` and
/// `RailDestinationButtons`, neither of which is edited again.
///
/// [viewBuilder] holds a constant tear-off, not a widget, so members
/// remain const: a constructor tear-off (`MyScreen.new`), a static
/// method tear-off (`SettingsScreen.withTheme`), or a top-level
/// function (the placeholder pattern above). The builder runs inside
/// `RailScreen`'s build, so the returned widget reads any context it
/// needs in its own `build` as usual.
///
/// This file deliberately imports screens. The layering trade —
/// destination data knowing its views — is accepted so the template
/// has exactly one edit site; a member missing its [viewBuilder] is a
/// compile error in this file, on the line being written.
///
/// Adding a destination:
///  1. Add a member with [iconData], [caption], and [viewBuilder].
///  2. Add it to [visible] or [overflowed] to give it an entry point.
/// Nothing else in the app needs to be touched.
/// {@endtemplate}
/// TODO: Add/remove/reorder members and adjust the statics below.
enum RailDestinationEnum implements NavigableDestinationAbstract {
  /// The home destination.
  home(
    iconData: Icons.home_outlined,
    caption: 'Home',
    viewBuilder: DefaultWelcomeScreen.new,
  ),

  /// The search destination.
  search(
    iconData: Icons.search,
    caption: 'Search',
    viewBuilder: _searchView,
  ),

  /// The library destination.
  library(
    iconData: Icons.video_library_outlined,
    caption: 'Library',
    viewBuilder: _libraryView,
  ),

  /// The settings destination.
  settings(
    iconData: Icons.settings_outlined,
    caption: 'Settings',
    viewBuilder: SettingsScreen.withTheme,
  ),

  /// The database destination.
  database(
    iconData: Icons.storage,
    caption: 'Database',
    viewBuilder: _databaseView,
  );

  // CODE:
  /// Creates a rail destination with its per-destination data.
  const RailDestinationEnum({
    required this.iconData,
    required this.caption,
    required this.viewBuilder,
  });

  /// The destination shown when the app screen first appears.
  /// TODO: Change the first RAIL-Button to appear.
  static const RailDestinationEnum initial = home;

  /// The destinations shown as rail buttons, in rail order.
  ///
  /// This is the rail's partition policy, together with [overflowed]:
  /// primary destinations get buttons, secondary ones live behind the
  /// overflow button. Moving a member between the two lists is the
  /// whole change needed to promote or demote it. Must not be empty.
  /// TODO: Control the order of the RAIL buttons.
  static const List<RailDestinationEnum> visible = [
    home,
    settings,
  ];

  /// The destinations folded into the overflow popover, in tile order.
  ///
  /// When non-empty, the rail renders an overflow button in its last
  /// slot; tapping it opens a popover listing these as tiles. When
  /// empty, no overflow button appears. Must not share a member with
  /// [visible].
  /// TODO: Control the order of the RAIL-OVERFLOW buttons.
  static const List<RailDestinationEnum> overflowed = [
    library,
    database,
  ];

  /// The glyph rendered as this destination's button icon.
  ///
  /// Stored as [IconData] rather than a widget so members remain
  /// const; `RailDestinationButtons` wraps it in an [Icon] with
  /// whatever styling the rail owns.
  final IconData iconData;

  /// The text rendered as this destination's button caption.
  ///
  /// Stored as a plain [String] for the same const reason;
  /// `RailDestinationButtons` wraps it in a [Text] with the rail's
  /// caption style.
  final String caption;

  /// Builds this destination's view.
  ///
  /// A constant tear-off so the member stays const. Invoked once per
  /// destination inside `RailScreen`'s build; the returned widget is
  /// kept alive in the view stack for the screen's lifetime.
  final Widget Function() viewBuilder;
}
