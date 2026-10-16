// packages/dual_selection/lib/src/defaults.dart

import 'package:extensions/extensions.dart';

import 'dual_selection_enum.dart';

/// Default values shared by [DualSelection] and [SingleSelection] so the two
/// render identically side by side.
abstract final class Defaults {
  /// Initial selection.
  static const DualSelectionEnum kFirstSelection = .first;

  /// Length of the body cross-fade.
  static const Duration kFadeDuration = Duration(milliseconds: 750);

  /// Radius of the outer border's corners.
  static const double kCornerRadius = 8.1;

  /// Haptic fired when the selection changes.
  static const HapticIntensity kHaptic = HapticIntensity.light;

  /// Stroke width of the outer border.
  static const double kBorderWidth = 3;

  /// Height of the header row.
  static const double kHeaderHeight = 50;

  /// Height of the body area.
  static const double kBodyHeight = 275;

  /// Width of the content area.
  static const double kWidth = 240;
}
