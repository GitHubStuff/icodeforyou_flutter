// programs/since_when_dev/lib/navigation/dock_items.dart

// NOTE: This is the horizontal direction menu items

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:custom_widgets/custom_widgets.dart' show DefaultWelcomeScreen;
import 'package:demo/demo.dart' show DurationStopwatchDemo, SpinWidgetDemo;
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:since_when_dev/example_menu_screen/ping_pong_example.dart'
    show PingPongExample;
import 'package:since_when_dev/example_menu_screen/shared_search_body.dart'
    show SharedSearchBody;
import 'package:since_when_dev/example_menu_screen/status_bar_visibility_app.dart'
    show StatusBarVisibilityPage;
import 'package:since_when_dev/navigation/dock_button_sizes.dart'
    show DockButtonSize;
import 'package:sincewhen_widgets/sincewhen_widgets.dart' show GlossaryEditPage;
import 'package:theme_framework/theme_framework.dart' show SettingsScreen;

/// {@template dock_destination_enum}
/// The set of destinations available in the dock — and the only file
/// edited when that set changes.
///
/// Each member carries everything that varies per destination: the
/// glyph shown as the button's icon, the text shown as its caption,
/// and the tear-off that builds its view. All behavior — selection,
/// haptics, sizing, tinting, keep-alive — is uniform across
/// destinations and lives in `DockScreen` and
/// `DockDestinationButtons`, neither of which is edited again.
///
/// [viewBuilder] holds a constant tear-off, not a widget, so members
/// remain const: a constructor tear-off (`MyScreen.new`), a static
/// method tear-off (`SettingsScreen.withTheme`), or a top-level
/// function (the placeholder pattern above). The builder runs inside
/// `DockScreen`'s build, so the returned widget reads any context it
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
// TODO(steven): Add/remove/reorder members and adjust the statics below.

enum DockItems implements NavButtonProperties {
  /// The more button
  more(
    slot: .more,
    iconData: Icons.more_horiz,
    caption: 'More',
    haptic: HapticIntensity.primary,
    viewBuilder: DefaultWelcomeScreen.new, //TODO(steven): Find a method
  ),

  /// The home destination.
  home(
    slot: .pinned,
    iconData: Icons.home_outlined,
    caption: 'Home',
    haptic: HapticIntensity.primary,
    viewBuilder: DefaultWelcomeScreen.new,
  ),

  /// Show/Hide the status bar
  statBar(
    slot: .overflow,
    iconData: Icons.visibility_outlined,
    haptic: HapticIntensity.primary,
    caption: 'Visibility',
    viewBuilder: StatusBarVisibilityPage.new,
  ),

  /// The search destination.
  search(
    slot: .pinned,
    iconData: Icons.search,
    caption: 'Search',
    haptic: HapticIntensity.primary,
    viewBuilder: SharedSearchBody.new,
  ),

  /// The library destination.
  pingPong(
    slot: .pinned,
    iconData: Icons.sports_tennis,
    caption: 'Pong',
    haptic: HapticIntensity.primary,
    viewBuilder: PingPongExample.new,
  ),

  /// The settings destination.
  settings(
    slot: .pinned,
    iconData: Icons.settings_outlined,
    caption: 'Settings',
    haptic: HapticIntensity.primary,
    viewBuilder: SettingsScreen.withTheme,
  ),

  /// From tools package - show/demo widgets
  tools(
    slot: .pinned,
    iconData: Icons.handyman_outlined,
    caption: 'Tools',
    haptic: HapticIntensity.primary,
    viewBuilder: DurationStopwatchDemo.new,
  ),

  /// Spins a widget
  spinDemo(
    slot: .overflow,
    iconData: Icons.rotate_right_outlined,
    caption: 'Spinner',
    haptic: HapticIntensity.primary,
    viewBuilder: SpinWidgetDemo.new,
  ),

  /// The database destination.
  database(
    slot: .overflow,
    iconData: Icons.storage,
    caption: 'Database',
    haptic: HapticIntensity.primary,
    viewBuilder: GlossaryEditPage.new,
  ),

  /// Glossary
  glossary(
    slot: .overflow,
    iconData: Icons.menu_book,
    caption: 'Glossary',
    haptic: HapticIntensity.primary,
    viewBuilder: GlossaryEditPage.new,
  );

  // CODE:
  /// Creates a dock destination with its per-destination data.
  DockItems({
    required this.slot,
    required this.iconData,
    required this.caption,
    required this.haptic,
    required this.viewBuilder,
  });

  /// The size of the widget
  static Size get size => DockButtonSize.defaultSize;

  @override
  final NavSlot slot;

  @override
  final IconData iconData;

  @override
  final String caption;

  /// Haptics associated with a menu button
  @override
  final HapticIntensity haptic;

  /// Builds this destination's view.
  ///
  /// A constant tear-off so the member stays const. Invoked once per
  /// destination inside `DockScreen`'s build; the returned widget is
  /// kept alive in the view stack for the screen's lifetime.
  @override
  final Widget Function() viewBuilder;

  /// The destination shown when the app screen first appears.
  // TODO(steven): Change the first DOCK-Button to appear.
  static const DockItems initial = home;

  /// Subset of menu (aka DockItems) in the order of displlay
  static const List<DockItems> order = [
    home,
    tools,
    more,
    search,
    pingPong,
    glossary,
    settings,
  ];
}
