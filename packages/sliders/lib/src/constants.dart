// packages/sliders/lib/src/constants.dart

/// Layout constants shared by the widgets in this package.
///
/// Kept package-private: callers tune the look through the widgets' own
/// parameters and [SliderThemeData], not by reaching for these numbers.
abstract class Constants {
  /// The size, in logical pixels, of the icon inside a `SliderButton`.
  ///
  /// Large enough for a comfortable touch target without an explicit
  /// `IconButton.constraints` override.
  static const double iconSize = 48;

  /// The minimum width, in logical pixels, an `HSliderWithButtons` needs
  /// to lay out its two buttons and the slider track without overflow.
  ///
  /// Enforced by an assertion in debug builds; a narrower parent is a
  /// layout bug in the caller, not a state the widget adapts to.
  static const double sliderWidth = 340;
}
