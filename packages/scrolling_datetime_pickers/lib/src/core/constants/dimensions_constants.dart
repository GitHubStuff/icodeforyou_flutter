// lib/src/core/constants/dimensions_constants.dart

/// Default dimensions for picker widgets
class DimensionConstants {
  /// Default width for portrait orientation
  static const double defaultPortraitWidth = 175.0;

  /// Default height for portrait orientation
  static const double defaultPortraitHeight = 200.0;

  /// Default width for landscape orientation
  static const double defaultLandscapeWidth = 175.0;

  /// Default height for landscape orientation
  static const double defaultLandscapeHeight = 200.0;

  /// Height of each item in the scroll wheel
  static const double itemExtent = 40.0;

  /// Magnification factor for selected item
  static const double magnification = 1.2;

  /// Squeeze factor for items (closer = more items visible)
  static const double squeeze = 1.45;

  /// Diameter ratio for wheel curvature
  static const double diameterRatio = 1.1;

  /// Spacing between picker columns
  static const double columnSpacing = 0.0;

  /// Height of divider lines
  static const double dividerThickness = 1.5;

  /// 3D rotation angle for outer columns (in radians)
  static const double outerColumnAngle = 0.1;

  /// Perspective value for 3D transform
  static const double perspectiveValue = 0.003;

  /// Border radius for picker container
  static const double borderRadius = 12.0;
}
