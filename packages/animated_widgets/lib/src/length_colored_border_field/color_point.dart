// animated_widgets/lib/src/length_colored_border_field/color_point.dart

// ignore_for_file: comment_references

import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

/// A single (length, color) pair in a [ColorPointRamp].
///
/// [point] is the minimum text length at which [color] starts applying.
class ColorPoint extends Equatable {
  /// Creates a [ColorPoint] for the given length threshold and color.
  const ColorPoint({required this.point, required this.color});

  /// The minimum text length at which [color] applies.
  final int point;

  /// The border color that applies once text length reaches [point].
  final Color color;

  @override
  List<Object?> get props => [point, color];
}
