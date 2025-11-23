// lib/src/core/constants/style_constants.dart

import 'package:flutter/material.dart';

/// Style constants for picker appearance
class StyleConstants {
  
  /// Default deep blue background color
  static const Color defaultBackgroundColor = Color(0xFF000033);

  /// Default light gray divider color (works in dark/light mode)
  static const Color defaultDividerColor = Color(0xFFE0E0E0);

  /// Default text color for picker items
  static const Color defaultTextColor = Colors.white;

  /// Default selected item text color
  static const Color defaultSelectedTextColor = Colors.white;

  /// Default unselected item text color with opacity
  static const Color defaultUnselectedTextColor = Colors.white70;

  /// Default text size for picker items
  static const double defaultTextSize = 24.0;

  /// Default font weight for picker items
  static const FontWeight defaultFontWeight = FontWeight.bold;

  /// Default fade gradient colors for top
  static const List<Color> defaultTopFadeColors = [
    Color(0xFF000033),
    Color(0x00000033),
  ];

  /// Default fade gradient colors for bottom
  static const List<Color> defaultBottomFadeColors = [
    Color(0x00000033),
    Color(0xFF000033),
  ];

  /// Default fade gradient stops
  static const List<double> defaultFadeStops = [0.0, 1.0];

  /// Default divider opacity
  static const double defaultDividerOpacity = 1.0;

  /// Hours column min value
  static const int hoursMin = 1;

  /// Hours column max value
  static const int hoursMax = 12;

  /// Minutes column min value
  static const int minutesMin = 0;

  /// Minutes column max value
  static const int minutesMax = 59;

  /// Seconds column min value
  static const int secondsMin = 0;

  /// Seconds column max value
  static const int secondsMax = 59;

  /// Number of items for infinite scroll buffer
  static const int infiniteScrollBuffer = 10000;
}
