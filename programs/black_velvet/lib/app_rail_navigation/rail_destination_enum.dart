// packages/rail_navigation/lib/src/enum/rail_destination_enum.dart

import 'package:flutter/material.dart' show IconData, Icons;

/// The set of destinations available in the rail.
///
/// Each member carries the data that varies per destination: the glyph
/// shown as the button's icon and the text shown as its caption. All
/// behavior — selection, haptics, sizing, tinting — is uniform across
/// destinations and lives in the rail's mapping site, not here.
///
/// Adding a destination to the rail is a one-line change: add a member
/// with its [iconData] and [caption]. Nothing else in the package needs
/// to be touched.
enum RailDestinationEnum {
  /// The home destination.
  home(iconData: Icons.home_outlined, caption: 'Home'),

  /// The search destination.
  search(iconData: Icons.search, caption: 'Search'),

  /// The library destination.
  library(iconData: Icons.video_library_outlined, caption: 'Library'),

  /// The settings destination.
  settings(iconData: Icons.settings_outlined, caption: 'Settings'),

  /// The database destination.
  database(iconData: Icons.storage, caption: 'Database');

  /// Creates a rail destination with its per-destination display data.
  const RailDestinationEnum({
    required this.iconData,
    required this.caption,
  });

  /// The glyph rendered as this destination's button icon.
  ///
  /// Stored as [IconData] rather than a widget so members remain const;
  /// the mapping site wraps it in an `Icon` with whatever styling the
  /// rail owns.
  final IconData iconData;

  /// The text rendered as this destination's button caption.
  ///
  /// Stored as a plain [String] for the same const reason; the mapping
  /// site wraps it in a `Text` with the rail's caption style.
  final String caption;
}
