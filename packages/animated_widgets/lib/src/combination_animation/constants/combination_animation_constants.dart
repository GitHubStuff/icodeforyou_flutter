// packages/animated_widgets/lib/src/combination_animation/constants/combination_animation_constants.dart

import 'package:flutter/animation.dart';

/// Duration(seconds:1, milliseconds: 250) aka 1.25 seconds
const Duration kCombinationAnimationDefaultDuration = Duration(
  seconds: 1,
  milliseconds: 250,
);

/// Curves.linear
const Curve kCombinationAnimationDefaultCurve = Curves.linear;

/// Lowest valid opacity: 0
const double kCombinationAnimationOpacityMin = 0;

/// Maximum valid opacity: 1
const double kCombinationAnimationOpacityMax = 1;
