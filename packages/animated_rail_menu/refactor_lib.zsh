#!/usr/bin/env zsh
# animated_rail_menu/refactor_lib.zsh
#
# Renames lib/ files and rewrites their contents to use the new
# AnimatedRailMenu* naming scheme, and drops underscore-prefixed filenames.
#
# Run from the package root:  zsh refactor_lib.zsh
#
# Idempotent: deletes the old files, then writes the new ones.

set -e
set -u

if [[ ! -f pubspec.yaml ]] || ! grep -q '^name: animated_rail_menu' pubspec.yaml; then
  print -u2 "ERROR: must be run from the animated_rail_menu package root"
  exit 1
fi

print "==> Refactoring lib/ for animated_rail_menu"

# ---------------------------------------------------------------------------
# 1. Delete old files
# ---------------------------------------------------------------------------
print "  - removing old files"
rm -f lib/src/cubit/rail_menu_controller.dart
rm -f lib/src/cubit/rail_menu_cubit.dart
rm -f lib/src/cubit/rail_menu_state.dart
rm -f lib/src/model/rail_menu_entry.dart
rm -f lib/src/theme/rail_menu_theme.dart
rm -f lib/src/theme/_rail_menu_theme_dark.dart
rm -f lib/src/theme/_rail_menu_theme_light.dart
rm -f lib/src/widget/_body_switcher.dart
rm -f lib/src/widget/_elevator_rail.dart
rm -f lib/src/widget/_horizontal_rail.dart
rm -f lib/src/widget/_internal.dart
rm -f lib/src/widget/_more_bottom_sheet.dart
rm -f lib/src/widget/_more_inline.dart
rm -f lib/src/widget/_overflow_calculator.dart
rm -f lib/src/widget/_rail_item_tile.dart
rm -f lib/src/widget/rail_navigation_widget.dart

# ---------------------------------------------------------------------------
# 2. Write new files
# ---------------------------------------------------------------------------

# --- Public barrel ---------------------------------------------------------
print "  - writing lib/animated_rail_menu.dart"
cat > lib/animated_rail_menu.dart <<'DART'
// animated_rail_menu/lib/animated_rail_menu.dart

export 'src/cubit/animated_rail_menu_controller.dart';
export 'src/cubit/animated_rail_menu_cubit.dart';
export 'src/cubit/animated_rail_menu_state.dart';
export 'src/model/animated_rail_menu_entry.dart';
export 'src/model/menu_icon_spacing.dart';
export 'src/model/rail_direction.dart';
export 'src/model/rail_icon.dart';
export 'src/model/rail_transition.dart';
export 'src/theme/animated_rail_menu_theme.dart';
export 'src/widget/animated_rail_menu_widget.dart' show AnimatedRailMenu;
DART

# --- Cubit barrel ----------------------------------------------------------
print "  - writing lib/src/cubit/cubit.dart"
cat > lib/src/cubit/cubit.dart <<'DART'
// animated_rail_menu/lib/src/cubit/cubit.dart

export 'animated_rail_menu_controller.dart';
export 'animated_rail_menu_state.dart';
DART

# --- Cubit: controller -----------------------------------------------------
print "  - writing lib/src/cubit/animated_rail_menu_controller.dart"
cat > lib/src/cubit/animated_rail_menu_controller.dart <<'DART'
// animated_rail_menu/lib/src/cubit/animated_rail_menu_controller.dart

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show AnimatedRailMenuCubit;
import 'package:animated_rail_menu/src/model/rail_transition.dart';

/// Abstract interface for controlling the animations of the
/// [AnimatedRailMenuController].
///
/// Callers depend on this interface, not on [AnimatedRailMenuCubit] directly.
abstract class AnimatedRailMenuController {
  /// The index of the currently active menu item.
  int get activeIndex;

  /// The transition that was used to reach the current active item.
  RailTransition get transition;

  /// Sets the active item to [index] using the given [transition].
  void setActive(int index, RailTransition transition);
}
DART

# --- Cubit: state ----------------------------------------------------------
print "  - writing lib/src/cubit/animated_rail_menu_state.dart"
cat > lib/src/cubit/animated_rail_menu_state.dart <<'DART'
// animated_rail_menu/lib/src/cubit/animated_rail_menu_state.dart

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show AnimatedRailMenuCubit;
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:flutter/foundation.dart';

/// The state emitted by [AnimatedRailMenuCubit].
@immutable
class AnimatedRailMenuState {
  /// Creates an [AnimatedRailMenuState].
  const AnimatedRailMenuState({
    required this.activeIndex,
    this.transition = RailTransition.crossFade,
  });

  /// The index of the currently active menu item.
  final int activeIndex;

  /// The transition used to reach the active item.
  final RailTransition transition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimatedRailMenuState &&
          runtimeType == other.runtimeType &&
          activeIndex == other.activeIndex &&
          transition == other.transition;

  @override
  int get hashCode => Object.hash(activeIndex, transition);
}
DART

# --- Cubit: cubit ----------------------------------------------------------
print "  - writing lib/src/cubit/animated_rail_menu_cubit.dart"
cat > lib/src/cubit/animated_rail_menu_cubit.dart <<'DART'
// animated_rail_menu/lib/src/cubit/animated_rail_menu_cubit.dart

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show AnimatedRailMenu;
import 'package:animated_rail_menu/src/cubit/cubit.dart';
import 'package:animated_rail_menu/src/model/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// [AnimatedRailMenuCubit] for maintaining state of an [AnimatedRailMenu].
class AnimatedRailMenuCubit extends Cubit<AnimatedRailMenuState>
    implements AnimatedRailMenuController {
  /// Creates an [AnimatedRailMenuCubit].
  AnimatedRailMenuCubit({int defaultIndex = 0})
    : super(AnimatedRailMenuState(activeIndex: defaultIndex));

  @override
  int get activeIndex => state.activeIndex;

  @override
  RailTransition get transition => state.transition;

  @override
  void setActive(int index, RailTransition transition) {
    if (index == state.activeIndex) return;
    emit(AnimatedRailMenuState(activeIndex: index, transition: transition));
  }

  /// Resolves the correct [RailTransition] for the slide direction based on
  /// the tap index relative to the current active index and rail direction.
  RailTransition resolveDirectional({
    required int tappedIndex,
    required RailDirection direction,
  }) {
    final isForward = tappedIndex > state.activeIndex;
    if (direction == RailDirection.horizontal) {
      return isForward ? RailTransition.slideRight : RailTransition.slideLeft;
    }
    return isForward ? RailTransition.slideDown : RailTransition.slideUp;
  }
}
DART

# --- Model: entry ----------------------------------------------------------
print "  - writing lib/src/model/animated_rail_menu_entry.dart"
cat > lib/src/model/animated_rail_menu_entry.dart <<'DART'
// animated_rail_menu/lib/src/model/animated_rail_menu_entry.dart

import 'package:flutter/widgets.dart';

/// A single entry in an [AnimatedRailMenuEntry].
///
/// Combines the navigation item appearance with the page it presents.
///
/// ```dart
/// AnimatedRailMenuEntry(
///   icon: Icons.home_outlined,
///   activeIcon: Icons.home,
///   label: 'Home',
///   page: const HomePage(),
/// )
/// ```
class AnimatedRailMenuEntry {
  /// Creates an [AnimatedRailMenuEntry].
  const AnimatedRailMenuEntry({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });

  /// The icon displayed when this entry is inactive.
  final IconData icon;

  /// The icon displayed when this entry is active.
  final IconData activeIcon;

  /// The label displayed below the icon.
  final String label;

  /// The page displayed when this entry is active.
  final Widget page;
}
DART

# --- Model: rail_direction (RailNavigationWidget -> AnimatedRailMenu in doc)
print "  - writing lib/src/model/rail_direction.dart"
cat > lib/src/model/rail_direction.dart <<'DART'
// animated_rail_menu/lib/src/model/rail_direction.dart

import 'package:animated_rail_menu/src/widget/animated_rail_menu_widget.dart'
    show AnimatedRailMenu;

/// The axis along which the [AnimatedRailMenu] bar is rendered.
enum RailDirection {
  /// [adaptive] - changes when the device rotates
  adaptive,

  /// [horizontal] - resides on the bottom of the device
  horizontal,

  /// [vertical] - resides on the side of the device
  vertical,
}
DART

# --- Model: rail_icon (RailNavigationWidget -> AnimatedRailMenu in doc) ----
print "  - writing lib/src/model/rail_icon.dart"
cat > lib/src/model/rail_icon.dart <<'DART'
// animated_rail_menu/lib/src/model/rail_icon.dart

import 'package:animated_rail_menu/src/widget/animated_rail_menu_widget.dart'
    show AnimatedRailMenu;

/// Defines the fixed sizing contract for items in an [AnimatedRailMenu].
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
DART

# --- Theme: public --------------------------------------------------------
print "  - writing lib/src/theme/animated_rail_menu_theme.dart"
cat > lib/src/theme/animated_rail_menu_theme.dart <<'DART'
// animated_rail_menu/lib/src/theme/animated_rail_menu_theme.dart

import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_dark.dart';
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_light.dart';
import 'package:flutter/material.dart';

/// The theming extension for [AnimatedRailMenuTheme].
///
/// Register via [ThemeData.extensions] in your app:
///
/// ```dart
/// ThemeData.light().copyWith(
///   extensions: [AnimatedRailMenuTheme.light()],
/// )
/// ```
///
/// If no extension is registered, [AnimatedRailMenuTheme] falls back to
/// [AnimatedRailMenuTheme.light()] or [AnimatedRailMenuTheme.dark()] based on
/// [Brightness].
abstract class AnimatedRailMenuTheme
    extends ThemeExtension<AnimatedRailMenuTheme> {
  /// Placeholder Constructor
  const AnimatedRailMenuTheme();

  /// Returns the default dark [AnimatedRailMenuTheme].
  factory AnimatedRailMenuTheme.dark() => const AnimatedRailMenuThemeDark();

  /// Returns the default light [AnimatedRailMenuTheme].
  factory AnimatedRailMenuTheme.light() => const AnimatedRailMenuThemeLight();

  /// The background color of the rail or bar surface.
  Color get backgroundColor;

  /// The color of the active indicator bar and active icon.
  Color get activeColor;

  /// The color applied to inactive icons and labels.
  Color get inactiveColor;

  /// The text style applied to item labels.
  TextStyle get labelStyle;

  /// The elevation of the rail or bar surface.
  double get elevation;

  /// Returns the appropriate default theme for the given device/app brightness.
  static AnimatedRailMenuTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<AnimatedRailMenuTheme>();
    if (theme != null) return theme;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const AnimatedRailMenuThemeDark()
        : const AnimatedRailMenuThemeLight();
  }
}
DART

# --- Theme: dark ----------------------------------------------------------
print "  - writing lib/src/theme/animated_rail_menu_theme_dark.dart"
cat > lib/src/theme/animated_rail_menu_theme_dark.dart <<'DART'
// animated_rail_menu/lib/src/theme/animated_rail_menu_theme_dark.dart

import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme.dart';
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_light.dart';
import 'package:flutter/material.dart';

/// Default dark [AnimatedRailMenuTheme].
class AnimatedRailMenuThemeDark extends AnimatedRailMenuTheme {
  /// Creates an [AnimatedRailMenuThemeDark].
  const AnimatedRailMenuThemeDark();

  @override
  Color get backgroundColor => const Color(0xFF1C1B1F);

  @override
  Color get activeColor => const Color(0xFFD0BCFF);

  @override
  Color get inactiveColor => const Color(0xFFCAC4D0);

  @override
  TextStyle get labelStyle => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFFCAC4D0),
    overflow: TextOverflow.ellipsis,
  );

  @override
  double get elevation => 2;

  @override
  AnimatedRailMenuTheme copyWith({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    TextStyle? labelStyle,
    double? elevation,
  }) => _AnimatedRailMenuThemeDarkCopy(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    activeColor: activeColor ?? this.activeColor,
    inactiveColor: inactiveColor ?? this.inactiveColor,
    labelStyle: labelStyle ?? this.labelStyle,
    elevation: elevation ?? this.elevation,
  );

  @override
  AnimatedRailMenuTheme lerp(AnimatedRailMenuTheme? other, double t) {
    if (other is! AnimatedRailMenuTheme) return this;
    return _AnimatedRailMenuThemeDarkCopy(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
    );
  }
}

class _AnimatedRailMenuThemeDarkCopy extends AnimatedRailMenuThemeDark {
  const _AnimatedRailMenuThemeDarkCopy({
    required Color backgroundColor,
    required Color activeColor,
    required Color inactiveColor,
    required TextStyle labelStyle,
    required double elevation,
  }) : _backgroundColor = backgroundColor,
       _activeColor = activeColor,
       _inactiveColor = inactiveColor,
       _labelStyle = labelStyle,
       _elevation = elevation;

  final Color _backgroundColor;
  final Color _activeColor;
  final Color _inactiveColor;
  final TextStyle _labelStyle;
  final double _elevation;

  @override
  Color get backgroundColor => _backgroundColor;

  @override
  Color get activeColor => _activeColor;

  @override
  Color get inactiveColor => _inactiveColor;

  @override
  TextStyle get labelStyle => _labelStyle;

  @override
  double get elevation => _elevation;
}
DART

# --- Theme: light ---------------------------------------------------------
print "  - writing lib/src/theme/animated_rail_menu_theme_light.dart"
cat > lib/src/theme/animated_rail_menu_theme_light.dart <<'DART'
// animated_rail_menu/lib/src/theme/animated_rail_menu_theme_light.dart

import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme.dart';
import 'package:flutter/material.dart';

/// Default light [AnimatedRailMenuTheme].
class AnimatedRailMenuThemeLight extends AnimatedRailMenuTheme {
  /// Creates an [AnimatedRailMenuThemeLight].
  const AnimatedRailMenuThemeLight();

  @override
  Color get backgroundColor => Colors.white;

  @override
  Color get activeColor => const Color(0xFF6750A4);

  @override
  Color get inactiveColor => const Color(0xFF49454F);

  @override
  TextStyle get labelStyle => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF49454F),
    overflow: TextOverflow.ellipsis,
  );

  @override
  double get elevation => 2;

  @override
  AnimatedRailMenuTheme copyWith({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    TextStyle? labelStyle,
    double? elevation,
  }) => _AnimatedRailMenuThemeLightCopy(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    activeColor: activeColor ?? this.activeColor,
    inactiveColor: inactiveColor ?? this.inactiveColor,
    labelStyle: labelStyle ?? this.labelStyle,
    elevation: elevation ?? this.elevation,
  );

  @override
  AnimatedRailMenuTheme lerp(AnimatedRailMenuTheme? other, double t) {
    if (other is! AnimatedRailMenuTheme) return this;
    return _AnimatedRailMenuThemeLightCopy(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
    );
  }
}

class _AnimatedRailMenuThemeLightCopy extends AnimatedRailMenuThemeLight {
  const _AnimatedRailMenuThemeLightCopy({
    required Color backgroundColor,
    required Color activeColor,
    required Color inactiveColor,
    required TextStyle labelStyle,
    required double elevation,
  }) : _backgroundColor = backgroundColor,
       _activeColor = activeColor,
       _inactiveColor = inactiveColor,
       _labelStyle = labelStyle,
       _elevation = elevation;

  final Color _backgroundColor;
  final Color _activeColor;
  final Color _inactiveColor;
  final TextStyle _labelStyle;
  final double _elevation;

  @override
  Color get backgroundColor => _backgroundColor;

  @override
  Color get activeColor => _activeColor;

  @override
  Color get inactiveColor => _inactiveColor;

  @override
  TextStyle get labelStyle => _labelStyle;

  @override
  double get elevation => _elevation;
}

/// required for animation on [AnimatedRailMenuTheme]
double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
DART

# --- Widget: library file (was _internal.dart + rail_navigation_widget.dart)
print "  - writing lib/src/widget/animated_rail_menu_widget.dart"
cat > lib/src/widget/animated_rail_menu_widget.dart <<'DART'
// animated_rail_menu/lib/src/widget/animated_rail_menu_widget.dart

import 'dart:async';

import 'package:animated_rail_menu/src/cubit/animated_rail_menu_cubit.dart';
import 'package:animated_rail_menu/src/cubit/animated_rail_menu_state.dart';
import 'package:animated_rail_menu/src/model/animated_rail_menu_entry.dart';
import 'package:animated_rail_menu/src/model/menu_icon_spacing.dart';
import 'package:animated_rail_menu/src/model/rail_direction.dart';
import 'package:animated_rail_menu/src/model/rail_icon.dart';
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme.dart';
import 'package:extensions/haptics/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'body_switcher.dart';
part 'elevator_rail.dart';
part 'horizontal_rail.dart';
part 'more_bottom_sheet.dart';
part 'more_inline.dart';
part 'overflow_calculator.dart';
part 'rail_item_tile.dart';

/// A directional animated navigation rail that owns its [Scaffold].
///
/// Renders either a bottom [_HorizontalRail] or a left [_ElevatorRail]
/// based on [direction]. Owns the [AnimatedRailMenuCubit] lifecycle, safe
/// area, overflow handling, and page transition animation.
///
/// Pass [RailDirection.adaptive] to resolve direction automatically from
/// screen width and orientation — vertical on tablets (>= 600dp) and
/// landscape phones, horizontal on portrait phones.
///
/// ```dart
/// AnimatedRailMenu(
///   entries: const [
///     AnimatedRailMenuEntry(
///       icon: Icons.home_outlined,
///       activeIcon: Icons.home,
///       label: 'Home',
///       page: HomePage(),
///     ),
///   ],
///   direction: RailDirection.adaptive,
/// )
/// ```
class AnimatedRailMenu extends StatelessWidget {
  /// Creates an [AnimatedRailMenu].
  const AnimatedRailMenu({
    required this.entries,
    required this.direction,
    super.key,
    this.defaultIndex = 0,
    this.icon = RailIcon.phone,
    this.transition = RailTransition.crossFade,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.iconSpacing = MenuIconSpacing.expanded,
    this.haptic = HapticIntensity.light,
    this.limit,
  }) : assert(limit == null || limit >= 2, 'limit must be >= 2');

  /// Key applied to the [Scaffold] when horizontal layout is active.
  @visibleForTesting
  static const horizontalScaffoldKey = Key('rail_horizontal_scaffold');

  /// Key applied to the [Scaffold] when vertical layout is active.
  @visibleForTesting
  static const verticalScaffoldKey = Key('rail_vertical_scaffold');

  /// The entries to display — each carries its icon, label, and page.
  final List<AnimatedRailMenuEntry> entries;

  /// The axis along which the menu bar is rendered.
  ///
  /// Use [RailDirection.adaptive] to resolve automatically from screen
  /// width and orientation at build time.
  final RailDirection direction;

  /// The index of the entry selected on first render. Defaults to 0.
  final int defaultIndex;

  /// Controls icon size, item slot size, bar thickness, and indicator height.
  final RailIcon icon;

  /// The transition animation applied to the page on entry change.
  final RailTransition transition;

  /// The duration of the page transition animation.
  final Duration transitionDuration;

  /// Controls item spacing within the rail.
  final MenuIconSpacing iconSpacing;

  /// The haptic feedback intensity on item tap.
  final HapticIntensity haptic;

  /// Maximum number of items visible, including the More button.
  ///
  /// When set, shows [limit - 1] items and a More button regardless of
  /// available space. Must be >= 2.
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnimatedRailMenuCubit(defaultIndex: defaultIndex),
      child: _AnimatedRailMenuView(
        entries: entries,
        direction: direction,
        defaultIndex: defaultIndex,
        icon: icon,
        transition: transition,
        transitionDuration: transitionDuration,
        iconSpacing: iconSpacing,
        haptic: haptic,
        limit: limit,
      ),
    );
  }
}

class _AnimatedRailMenuView extends StatelessWidget {
  const _AnimatedRailMenuView({
    required this.entries,
    required this.direction,
    required this.defaultIndex,
    required this.icon,
    required this.transition,
    required this.transitionDuration,
    required this.iconSpacing,
    required this.haptic,
    this.limit,
  });

  final List<AnimatedRailMenuEntry> entries;
  final RailDirection direction;
  final int defaultIndex;
  final RailIcon icon;
  final RailTransition transition;
  final Duration transitionDuration;
  final MenuIconSpacing iconSpacing;
  final HapticIntensity haptic;
  final int? limit;

  RailDirection _resolvedDirection(BuildContext context) {
    if (direction != RailDirection.adaptive) return direction;
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 600) return RailDirection.vertical;
    return MediaQuery.orientationOf(context) == Orientation.landscape
        ? RailDirection.vertical
        : RailDirection.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    assert(entries.isNotEmpty, 'entries must not be empty');
    assert(
      defaultIndex >= 0 && defaultIndex < entries.length,
      'defaultIndex must be a valid entries index',
    );
    final resolved = _resolvedDirection(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final safePadding = MediaQuery.paddingOf(context);
        final availableExtent = resolved == RailDirection.horizontal
            ? constraints.maxWidth - safePadding.left - safePadding.right
            : constraints.maxHeight - safePadding.top - safePadding.bottom;

        final result = const _OverflowCalculator().calculate(
          itemCount: entries.length,
          itemExtent: icon.itemExtent,
          availableExtent: availableExtent,
          limit: limit,
        );

        final visibleEntries = entries.sublist(0, result.visibleCount);
        final overflowEntries = result.hasOverflow
            ? entries.sublist(result.visibleCount)
            : <AnimatedRailMenuEntry>[];

        return resolved == RailDirection.horizontal
            ? _buildHorizontal(visibleEntries, overflowEntries)
            : _buildVertical(visibleEntries, overflowEntries);
      },
    );
  }

  Widget _buildHorizontal(
    List<AnimatedRailMenuEntry> visibleEntries,
    List<AnimatedRailMenuEntry> overflowEntries,
  ) {
    return Scaffold(
      key: AnimatedRailMenu.horizontalScaffoldKey,
      body: _BodySwitcher(
        entries: entries,
        transitionDuration: transitionDuration,
      ),
      bottomNavigationBar: _HorizontalRail(
        visibleEntries: visibleEntries,
        overflowEntries: overflowEntries,
        railIcon: icon,
        spacing: iconSpacing,
        haptic: haptic,
        transition: transition,
      ),
    );
  }

  Widget _buildVertical(
    List<AnimatedRailMenuEntry> visibleEntries,
    List<AnimatedRailMenuEntry> overflowEntries,
  ) {
    return Scaffold(
      key: AnimatedRailMenu.verticalScaffoldKey,
      body: Row(
        children: [
          _ElevatorRail(
            visibleEntries: visibleEntries,
            overflowEntries: overflowEntries,
            railIcon: icon,
            spacing: iconSpacing,
            haptic: haptic,
            transition: transition,
          ),
          Expanded(
            child: _BodySwitcher(
              entries: entries,
              transitionDuration: transitionDuration,
            ),
          ),
        ],
      ),
    );
  }
}
DART

# --- Widget: body_switcher (part of) --------------------------------------
print "  - writing lib/src/widget/body_switcher.dart"
cat > lib/src/widget/body_switcher.dart <<'DART'
// animated_rail_menu/lib/src/widget/body_switcher.dart

part of 'animated_rail_menu_widget.dart';

/// Animates between pages when the active [AnimatedRailMenuCubit] index
/// changes.
class _BodySwitcher extends StatelessWidget {
  const _BodySwitcher({
    required this.entries,
    required this.transitionDuration,
  });

  final List<AnimatedRailMenuEntry> entries;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimatedRailMenuCubit, AnimatedRailMenuState>(
      builder: (context, state) {
        if (transitionDuration == Duration.zero) {
          return SizedBox.expand(child: entries[state.activeIndex].page);
        }
        return AnimatedSwitcher(
          duration: transitionDuration,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              _buildTransition(state.transition, animation, child),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.topLeft,
            children: [...previousChildren, ?currentChild],
          ),
          child: SizedBox.expand(
            key: ValueKey(state.activeIndex),
            child: entries[state.activeIndex].page,
          ),
        );
      },
    );
  }

  Widget _buildTransition(
    RailTransition transition,
    Animation<double> animation,
    Widget child,
  ) {
    switch (transition) {
      case RailTransition.crossFade:
        return FadeTransition(opacity: animation, child: child);
      case RailTransition.slideLeft:
        return _slide(const Offset(-1, 0), animation, child);
      case RailTransition.slideRight:
        return _slide(const Offset(1, 0), animation, child);
      case RailTransition.slideUp:
        return _slide(const Offset(0, -1), animation, child);
      case RailTransition.slideDown:
        return _slide(const Offset(0, 1), animation, child);
      case RailTransition.scale:
        return ScaleTransition(scale: animation, child: child);
      // coverage:ignore-start
      case RailTransition.slideDirectional:
        return FadeTransition(opacity: animation, child: child);
      // coverage:ignore-end
    }
  }

  Widget _slide(Offset begin, Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}
DART

# --- Widget: elevator_rail (part of) --------------------------------------
print "  - writing lib/src/widget/elevator_rail.dart"
cat > lib/src/widget/elevator_rail.dart <<'DART'
// animated_rail_menu/lib/src/widget/elevator_rail.dart

part of 'animated_rail_menu_widget.dart';

/// Minimum top padding applied to the elevator rail to clear device corner
/// radius clipping. 32dp covers iPhone 17 Pro and comparable devices.
const double _kElevatorTopMinimum = 32;

/// Renders the menu bar along the left edge.
class _ElevatorRail extends StatelessWidget {
  const _ElevatorRail({
    required this.visibleEntries,
    required this.overflowEntries,
    required this.railIcon,
    required this.spacing,
    required this.haptic,
    required this.transition,
  });

  final List<AnimatedRailMenuEntry> visibleEntries;
  final List<AnimatedRailMenuEntry> overflowEntries;
  final RailIcon railIcon;
  final MenuIconSpacing spacing;
  final HapticIntensity haptic;
  final RailTransition transition;

  MainAxisAlignment get _alignment => spacing == MenuIconSpacing.expanded
      ? MainAxisAlignment.spaceEvenly
      : MainAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    return Material(
      color: theme.backgroundColor,
      elevation: theme.elevation,
      child: SafeArea(
        left: false,
        right: false,
        minimum: const EdgeInsets.only(top: _kElevatorTopMinimum),
        child: SizedBox(
          width: railIcon.barExtent,
          child: Column(
            mainAxisAlignment: _alignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...visibleEntries.indexed.map(
                (entry) => _RailItemTile(
                  entry: entry.$2,
                  index: entry.$1,
                  railIcon: railIcon,
                  haptic: haptic,
                  direction: RailDirection.vertical,
                  transition: transition,
                ),
              ),
              if (overflowEntries.isNotEmpty)
                _MoreInlineButton(
                  overflowEntries: overflowEntries,
                  visibleCount: visibleEntries.length,
                  railIcon: railIcon,
                  haptic: haptic,
                  transition: transition,
                  direction: RailDirection.vertical,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
DART

# --- Widget: horizontal_rail (part of) ------------------------------------
print "  - writing lib/src/widget/horizontal_rail.dart"
cat > lib/src/widget/horizontal_rail.dart <<'DART'
// animated_rail_menu/lib/src/widget/horizontal_rail.dart

part of 'animated_rail_menu_widget.dart';

/// Renders the menu bar along the bottom edge.
class _HorizontalRail extends StatelessWidget {
  const _HorizontalRail({
    required this.visibleEntries,
    required this.overflowEntries,
    required this.railIcon,
    required this.spacing,
    required this.haptic,
    required this.transition,
  });

  final List<AnimatedRailMenuEntry> visibleEntries;
  final List<AnimatedRailMenuEntry> overflowEntries;
  final RailIcon railIcon;
  final MenuIconSpacing spacing;
  final HapticIntensity haptic;
  final RailTransition transition;

  MainAxisAlignment get _alignment => spacing == MenuIconSpacing.expanded
      ? MainAxisAlignment.spaceEvenly
      : MainAxisAlignment.start;

  void _showMore(BuildContext context) => const _MoreBottomSheet().show(
        context: context,
        overflowEntries: overflowEntries,
        visibleCount: visibleEntries.length,
        railIcon: railIcon,
        haptic: haptic,
        transition: transition,
        direction: RailDirection.horizontal,
      );

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    return Material(
      color: theme.backgroundColor,
      elevation: theme.elevation,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: railIcon.barExtent,
          child: Row(
            mainAxisAlignment: _alignment,
            children: [
              ...visibleEntries.indexed.map(
                (entry) => _RailItemTile(
                  entry: entry.$2,
                  index: entry.$1,
                  railIcon: railIcon,
                  haptic: haptic,
                  direction: RailDirection.horizontal,
                  transition: transition,
                ),
              ),
              if (overflowEntries.isNotEmpty)
                _MoreHorizontalButton(
                  railIcon: railIcon,
                  visibleCount: visibleEntries.length,
                  onTap: () => _showMore(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreHorizontalButton extends StatelessWidget {
  const _MoreHorizontalButton({
    required this.railIcon,
    required this.visibleCount,
    required this.onTap,
  });

  final RailIcon railIcon;
  final int visibleCount;
  final VoidCallback onTap;

  bool _isActive(int activeIndex) => activeIndex >= visibleCount;

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    final activeIndex = context.watch<AnimatedRailMenuCubit>().activeIndex;
    final isActive = _isActive(activeIndex);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: railIcon.itemExtent,
        height: railIcon.itemExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.more_horiz,
              size: railIcon.iconSize,
              color: isActive ? theme.activeColor : theme.inactiveColor,
            ),
            Text(
              'More',
              style: theme.labelStyle.copyWith(
                color: isActive ? theme.activeColor : theme.inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: railIcon.indicatorHeight),
            Container(
              height: railIcon.indicatorHeight,
              color: isActive ? theme.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
DART

# --- Widget: more_bottom_sheet (part of) ----------------------------------
print "  - writing lib/src/widget/more_bottom_sheet.dart"
cat > lib/src/widget/more_bottom_sheet.dart <<'DART'
// animated_rail_menu/lib/src/widget/more_bottom_sheet.dart

part of 'animated_rail_menu_widget.dart';

/// Presents overflow [AnimatedRailMenuEntry]s in a modal bottom sheet.
///
/// Used by [_HorizontalRail] when entries exceed available width.
class _MoreBottomSheet {
  const _MoreBottomSheet();

  void show({
    required BuildContext context,
    required List<AnimatedRailMenuEntry> overflowEntries,
    required int visibleCount,
    required RailIcon railIcon,
    required HapticIntensity haptic,
    required RailTransition transition,
    required RailDirection direction,
  }) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AnimatedRailMenuCubit>(),
        child: BlocBuilder<AnimatedRailMenuCubit, AnimatedRailMenuState>(
          builder: (context, state) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: overflowEntries.indexed
                  .map((entry) {
                    final resolvedIndex = visibleCount + entry.$1;
                    final isActive = state.activeIndex == resolvedIndex;
                    final theme = AnimatedRailMenuTheme.of(context);
                    return ListTile(
                      leading: Icon(
                        isActive ? entry.$2.activeIcon : entry.$2.icon,
                        size: railIcon.iconSize,
                        color:
                            isActive ? theme.activeColor : theme.inactiveColor,
                      ),
                      title: Text(
                        entry.$2.label,
                        style: TextStyle(
                          color: isActive
                              ? theme.activeColor
                              : theme.inactiveColor,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        final cubit = context.read<AnimatedRailMenuCubit>();
                        final resolvedTransition =
                            transition == RailTransition.slideDirectional
                                ? cubit.resolveDirectional(
                                    tappedIndex: resolvedIndex,
                                    direction: direction,
                                  )
                                : transition;
                        cubit.setActive(resolvedIndex, resolvedTransition);
                      },
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ),
    ));
  }
}
DART

# --- Widget: more_inline (part of) ----------------------------------------
print "  - writing lib/src/widget/more_inline.dart"
cat > lib/src/widget/more_inline.dart <<'DART'
// animated_rail_menu/lib/src/widget/more_inline.dart

part of 'animated_rail_menu_widget.dart';

/// Fraction of screen width used by the overflow flyout menu.
const double _kFlyoutWidthFraction = 0.15;

/// Shows a flyout popup anchored to the right of the More button.
///
/// Used by [_ElevatorRail] when entries exceed available height.
class _MoreInlineButton extends StatefulWidget {
  const _MoreInlineButton({
    required this.overflowEntries,
    required this.visibleCount,
    required this.railIcon,
    required this.haptic,
    required this.transition,
    required this.direction,
  });

  final List<AnimatedRailMenuEntry> overflowEntries;
  final int visibleCount;
  final RailIcon railIcon;
  final HapticIntensity haptic;
  final RailTransition transition;
  final RailDirection direction;

  @override
  State<_MoreInlineButton> createState() => _MoreInlineButtonState();
}

class _MoreInlineButtonState extends State<_MoreInlineButton> {
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  void _showFlyout(BuildContext context) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return; // coverage:ignore-line
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final cubit = context.read<AnimatedRailMenuCubit>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final menuWidth = screenWidth * _kFlyoutWidthFraction;
    final left = position.dx + size.width;

    unawaited(
      showMenu<void>(
        context: context,
        constraints: BoxConstraints(minWidth: menuWidth, maxWidth: menuWidth),
        position: RelativeRect.fromLTRB(
          left,
          position.dy,
          screenWidth - left,
          0,
        ),
        items: widget.overflowEntries.indexed.map((entry) {
          final resolvedIndex = widget.visibleCount + entry.$1;
          return PopupMenuItem<void>(
            padding: EdgeInsets.zero,
            child: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<AnimatedRailMenuCubit, AnimatedRailMenuState>(
                builder: (context, state) {
                  final isActive = state.activeIndex == resolvedIndex;
                  final theme = AnimatedRailMenuTheme.of(context);
                  return ListTile(
                    leading: Icon(
                      isActive ? entry.$2.activeIcon : entry.$2.icon,
                      size: widget.railIcon.iconSize,
                      color: isActive ? theme.activeColor : theme.inactiveColor,
                    ),
                    title: Text(
                      entry.$2.label,
                      style: TextStyle(
                        color: isActive
                            ? theme.activeColor
                            : theme.inactiveColor,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      final resolvedTransition =
                          widget.transition == RailTransition.slideDirectional
                          ? cubit.resolveDirectional(
                              tappedIndex: resolvedIndex,
                              direction: widget.direction,
                            )
                          : widget.transition;
                      cubit.setActive(resolvedIndex, resolvedTransition);
                    },
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    final activeIndex = context.watch<AnimatedRailMenuCubit>().activeIndex;
    final isActive = activeIndex >= widget.visibleCount;

    return GestureDetector(
      key: _key,
      onTap: () => _showFlyout(context),
      child: SizedBox(
        width: widget.railIcon.itemExtent,
        height: widget.railIcon.itemExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.more_vert,
              size: widget.railIcon.iconSize,
              color: isActive ? theme.activeColor : theme.inactiveColor,
            ),
            Text(
              'More',
              style: theme.labelStyle.copyWith(
                color: isActive ? theme.activeColor : theme.inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: widget.railIcon.indicatorHeight),
            Container(
              height: widget.railIcon.indicatorHeight,
              color: isActive ? theme.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
DART

# --- Widget: overflow_calculator (part of) --------------------------------
print "  - writing lib/src/widget/overflow_calculator.dart"
cat > lib/src/widget/overflow_calculator.dart <<'DART'
// animated_rail_menu/lib/src/widget/overflow_calculator.dart

part of 'animated_rail_menu_widget.dart';

class _OverflowResult {
  const _OverflowResult({
    required this.visibleCount,
    required this.hasOverflow,
  });

  final int visibleCount;
  final bool hasOverflow;
}

/// Calculates how many items fit within the available extent.
///
/// "itemCount" is provided it caps visible items at [itemCount - 1] and
/// forces the 'More' button regardless of available space.
class _OverflowCalculator {
  const _OverflowCalculator();

  _OverflowResult calculate({
    required int itemCount,
    required double itemExtent,
    required double availableExtent,
    int? limit,
  }) {
    if (limit != null) {
      return _applyLimit(itemCount: itemCount, limit: limit);
    }
    return _applyPixelFit(
      itemCount: itemCount,
      itemExtent: itemExtent,
      availableExtent: availableExtent,
    );
  }

  _OverflowResult _applyLimit({
    required int itemCount,
    required int limit,
  }) {
    final visibleCount = (limit - 1).clamp(0, itemCount);
    return _OverflowResult(
      visibleCount: visibleCount,
      hasOverflow: itemCount > visibleCount,
    );
  }

  _OverflowResult _applyPixelFit({
    required int itemCount,
    required double itemExtent,
    required double availableExtent,
  }) {
    final maxFit = (availableExtent / itemExtent).floor();
    if (itemCount <= maxFit) {
      return _OverflowResult(visibleCount: itemCount, hasOverflow: false);
    }
    return _OverflowResult(
      visibleCount: (maxFit - 1).clamp(0, itemCount),
      hasOverflow: true,
    );
  }
}
DART

# --- Widget: rail_item_tile (part of) -------------------------------------
print "  - writing lib/src/widget/rail_item_tile.dart"
cat > lib/src/widget/rail_item_tile.dart <<'DART'
// animated_rail_menu/lib/src/widget/rail_item_tile.dart

part of 'animated_rail_menu_widget.dart';

/// Renders a single [AnimatedRailMenuEntry] — icon, label, and active
/// indicator bar.
class _RailItemTile extends StatelessWidget {
  const _RailItemTile({
    required this.entry,
    required this.index,
    required this.railIcon,
    required this.haptic,
    required this.direction,
    required this.transition,
  });

  final AnimatedRailMenuEntry entry;
  final int index;
  final RailIcon railIcon;
  final HapticIntensity haptic;
  final RailDirection direction;
  final RailTransition transition;

  bool _isActive(int activeIndex) => index == activeIndex;

  RailTransition _resolvedTransition(BuildContext context) {
    if (transition != RailTransition.slideDirectional) return transition;
    return context.read<AnimatedRailMenuCubit>().resolveDirectional(
      tappedIndex: index,
      direction: direction,
    );
  }

  void _handleTap(BuildContext context, int activeIndex) {
    if (_isActive(activeIndex)) return;
    _triggerHaptic();
    context.read<AnimatedRailMenuCubit>().setActive(
      index,
      _resolvedTransition(context),
    );
  }

  void _triggerHaptic() => haptic.trigger();

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<AnimatedRailMenuCubit>().activeIndex;
    final isActive = _isActive(activeIndex);
    final theme = AnimatedRailMenuTheme.of(context);

    return GestureDetector(
      onTap: () => _handleTap(context, activeIndex),
      child: SizedBox(
        width: railIcon.itemExtent,
        height: railIcon.itemExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? entry.activeIcon : entry.icon,
              size: railIcon.iconSize,
              color: isActive ? theme.activeColor : theme.inactiveColor,
            ),
            Text(
              entry.label,
              style: theme.labelStyle.copyWith(
                color: isActive ? theme.activeColor : theme.inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: railIcon.indicatorHeight),
            Container(
              height: railIcon.indicatorHeight,
              width: railIcon.itemExtent,
              color: isActive ? theme.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
DART

print "==> Done."
print ""
print "Files written:"
find lib -name '*.dart' | sort | sed 's/^/  /'
