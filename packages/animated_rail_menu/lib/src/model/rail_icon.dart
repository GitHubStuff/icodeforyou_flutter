// lib/src/model/rail_icon.dart

import 'package:animated_rail_menu/src/widget/_internal.dart' show RailNavigationWidget;

/// Defines the fixed sizing contract for items in a [RailNavigationWidget].
///
/// Choose the value that matches your target device class.
/// All values follow Material 3 spec and Apple HIG tap target guidelines.
enum RailIcon {
  /// Small phone sizing — iPhone SE, compact Android devices.
  ///
  /// 20dp icon — 48dp item — 56dp bar — 2dp indicator.
  /// HIG minimum 44pt tap target observed. Compact bar for small screens.
  smallPhone(20, 48, 56, 2),

  /// Standard phone sizing — iPhone 15, standard Android devices.
  ///
  /// 24dp icon — 56dp item — 64dp bar — 3dp indicator.
  /// Material 3 standard icon size. Comfortable tap target.
  phone(24, 56, 64, 3),

  /// Small tablet sizing — iPad mini, 7–8" Android tablets.
  ///
  /// 24dp icon — 60dp item — 68dp bar — 3dp indicator.
  /// Slightly more breathing room than phone without wasting space.
  smallTablet(24, 60, 68, 3),

  /// Standard tablet sizing — iPad, 10–11" Android tablets.
  ///
  /// 28dp icon — 64dp item — 72dp bar — 4dp indicator.
  /// Larger targets suit finger use at greater viewing distance.
  tablet(28, 64, 72, 4),

  /// Large tablet sizing — iPad Pro 12.9", Microsoft Surface.
  ///
  /// 28dp icon — 68dp item — 80dp bar — 4dp indicator.
  /// More generous spacing for large touch-first screens.
  largeTablet(28, 68, 80, 4),

  /// Desktop sizing — macOS, Windows.
  ///
  /// 20dp icon — 48dp item — 56dp bar — 2dp indicator.
  /// Cursor-driven interaction permits smaller targets. Dense UI preferred.
  desktop(20, 48, 56, 2),

  /// Web sizing — browser, responsive layouts.
  ///
  /// 20dp icon — 44dp item — 52dp bar — 2dp indicator.
  /// Cursor-driven. Compact to follow sidebar conventions.
  web(20, 44, 52, 2);

  const RailIcon(
    this.iconSize,
    this.itemExtent,
    this.barExtent,
    this.indicatorHeight,
  );

  /// The rendered size of the icon in dp.
  final double iconSize;

  /// The width (vertical rail) or height (horizontal bar) of each item slot.
  final double itemExtent;

  /// The height (horizontal bar) or width (vertical rail) of the bar itself.
  final double barExtent;

  /// The height of the active indicator bar below the label.
  final double indicatorHeight;
}
