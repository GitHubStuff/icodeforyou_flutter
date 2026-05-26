
part of 'crossfade_widgets.dart';
// packages/animated_widgets/lib/src/stepper_crossfade/stepper_axis.dart
/// Which horizontal end of the stepper is "forward".
enum CrossFadeAxis {
  /// Forward steps move right; min sits on the left.
  left,

  /// Forward steps move left; min sits on the right.
  right;

  // SliderOrientation get _sliderDirection => switch (this) {
  //   CrossFadeAxis.left => SliderOrientation.left,
  //   CrossFadeAxis.right => SliderOrientation.right,
  // };
}
