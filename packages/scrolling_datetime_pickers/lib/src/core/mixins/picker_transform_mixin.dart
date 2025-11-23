// lib/src/core/mixins/picker_transform_mixin.dart

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';

/// Mixin for handling 3D transform effects on picker columns
mixin PickerTransformMixin {
  /// Calculate transform matrix for column based on position
  Matrix4 calculateColumnTransform(
    int columnIndex,
    int totalColumns,
    double perspective,
  ) {
    final matrix = Matrix4.identity();

    // Only apply transform to outer columns
    if (columnIndex == 0) {
      // Left column - tilt right
      matrix.setEntry(3, 2, perspective);
      matrix.rotateY(-DimensionConstants.outerColumnAngle);
    } else if (columnIndex == totalColumns - 1) {
      // Right column - tilt left
      matrix.setEntry(3, 2, perspective);
      matrix.rotateY(DimensionConstants.outerColumnAngle);
    }

    return matrix;
  }

  /// Calculate transform matrix with custom angle
  Matrix4 calculateColumnTransformWithAngle(
    int columnIndex,
    int totalColumns,
    double angle,
    double perspective,
  ) {
    final matrix = Matrix4.identity();

    // Only apply transform to outer columns
    if (columnIndex == 0) {
      // Left column - tilt right
      matrix.setEntry(3, 2, perspective);
      matrix.rotateY(-angle);
    } else if (columnIndex == totalColumns - 1) {
      // Right column - tilt left
      matrix.setEntry(3, 2, perspective);
      matrix.rotateY(angle);
    }

    return matrix;
  }

  /// Check if column should have transform applied
  bool shouldApplyTransform(int columnIndex, int totalColumns) {
    return columnIndex == 0 || columnIndex == totalColumns - 1;
  }

  /// Get the rotation angle for a column
  double getColumnRotationAngle(int columnIndex, int totalColumns) {
    if (columnIndex == 0) {
      return -DimensionConstants.outerColumnAngle;
    } else if (columnIndex == totalColumns - 1) {
      return DimensionConstants.outerColumnAngle;
    }
    return 0.0;
  }

  /// Create a transform widget for column
  Widget buildTransformedColumn({
    required Widget child,
    required int columnIndex,
    required int totalColumns,
    double? customAngle,
    double? customPerspective,
  }) {
    if (!shouldApplyTransform(columnIndex, totalColumns)) {
      return child;
    }

    final angle = customAngle ?? DimensionConstants.outerColumnAngle;
    final perspective =
        customPerspective ?? DimensionConstants.perspectiveValue;

    final transform = calculateColumnTransformWithAngle(
      columnIndex,
      totalColumns,
      angle,
      perspective,
    );

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: child,
    );
  }

  /// Calculate item opacity based on distance from center
  double calculateItemOpacity(
    double itemOffset,
    double viewportHeight,
    bool fadeEnabled,
    double fadeDistance,
  ) {
    if (!fadeEnabled) return 1.0;

    final center = viewportHeight / 2;
    final distanceFromCenter = (itemOffset - center).abs();

    if (distanceFromCenter <= fadeDistance) {
      return 1.0;
    }

    final fadeRange = center - fadeDistance;
    if (fadeRange <= 0) return 1.0;

    final opacity = 1.0 - ((distanceFromCenter - fadeDistance) / fadeRange);
    return opacity.clamp(0.0, 1.0);
  }

  /// Convert degrees to radians
  double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Convert radians to degrees
  double radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }
}
