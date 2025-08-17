// widget_ext.dart

// Improves readability in both definition and usage
// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';

/// Extension methods for Widget to enhance composability and readability.
/// Each method follows the Single Responsibility Principle and can be chained.
///
/// Example Usage:
/// ```dart
/// // Basic usage
/// Text('Hello')
///   .withPaddingAll(16.0)
///   .withBackground(color: Colors.blue)
///   .withBorder(color: Colors.black, width: 2.0, radius: 8.0);
///
/// // Conditional visibility
/// MyWidget()
///   .hide(isLoading)           // Makes transparent when loading
///   .remove(shouldHide);       // Removes from tree when hidden
///
/// // Complex padding scenarios
/// Container()
///   .withPaddingOnly(left: 16.0, top: 8.0)
///   .withPaddingSymmetric(horizontal: 24.0)
///   .withOpacity(0.8);
///
/// // Chaining multiple effects
/// Icon(Icons.star)
///   .withPaddingAll(12.0)
///   .withBackground(color: Colors.amber)
///   .withBorder(color: Colors.orange, radius: 16.0)
///   .withOpacity(0.9);
/// ```
extension WidgetExt on Widget {
  /// Conditionally hides the widget by making it transparent.
  ///
  /// When [shouldHide] is true, applies 0.0 opacity while maintaining layout space.
  /// This is useful for temporarily hiding content without affecting layout.
  ///
  /// Example:
  /// ```dart
  /// Text('Loading...')
  ///   .hide(isDataLoaded)  // Hide when data is loaded
  /// ```
  Widget hide(bool shouldHide) => shouldHide ? withOpacity(0.0) : this;

  /// Conditionally removes the widget from the widget tree.
  ///
  /// When [shouldRemove] is true, returns [SizedBox.shrink] which takes no space.
  /// This completely removes the widget from layout calculations.
  ///
  /// Example:
  /// ```dart
  /// ErrorMessage()
  ///   .remove(!hasError)  // Remove when no error
  /// ```
  Widget remove(bool shouldRemove) =>
      shouldRemove ? const SizedBox.shrink() : this;

  /// Wraps the widget with a solid background color.
  ///
  /// Uses [DecoratedBox] for optimal performance when only applying color.
  /// Prefer this over [Container] when you don't need other decoration properties.
  ///
  /// Example:
  /// ```dart
  /// Text('Highlighted')
  ///   .withBackground(color: Colors.yellow)
  /// ```
  Widget withBackground({required Color color}) => DecoratedBox(
    decoration: BoxDecoration(color: color),
    child: this,
  );

  /// Wraps the widget with a customizable border.
  ///
  /// Creates a uniform border around the widget with optional rounded corners.
  /// All parameters except [color] have sensible defaults for common use cases.
  ///
  /// Throws [ArgumentError] if [width] or [radius] are negative.
  ///
  /// Example:
  /// ```dart
  /// Image.asset('logo.png')
  ///   .withBorder(color: Colors.grey, width: 2.0, radius: 8.0)
  /// ```
  Widget withBorder({
    required Color color,
    double width = 1.5,
    double radius = 0.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    if (width < 0.0) {
      throw ArgumentError.value(
        width,
        'width',
        'Border width must be non-negative',
      );
    }
    if (radius < 0.0) {
      throw ArgumentError.value(
        radius,
        'radius',
        'Border radius must be non-negative',
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width, style: style),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: this,
    );
  }

  /// Wraps the widget with a specified opacity level.
  ///
  /// Controls the transparency of the widget and all its children.
  /// Unlike [hide], this allows for partial transparency with custom values.
  ///
  /// Throws [ArgumentError] if [opacityValue] is not between 0.0 and 1.0.
  ///
  /// Example:
  /// ```dart
  /// FloatingActionButton()
  ///   .withOpacity(0.7)  // 70% visible, 30% transparent
  /// ```
  Widget withOpacity(double opacityValue) {
    if (opacityValue < 0.0 || opacityValue > 1.0) {
      throw ArgumentError.value(
        opacityValue,
        'opacityValue',
        'Opacity must be between 0.0 and 1.0',
      );
    }
    return Opacity(opacity: opacityValue, child: this);
  }

  /// Wraps the widget with uniform padding on all sides.
  ///
  /// Convenient shorthand for equal padding in all directions.
  /// Most commonly used padding method for symmetric spacing.
  ///
  /// Throws [ArgumentError] if [paddingValue] is negative.
  ///
  /// Example:
  /// ```dart
  /// Card()
  ///   .withPaddingAll(16.0)  // 16px padding on all sides
  /// ```
  Widget withPaddingAll(double paddingValue) {
    if (paddingValue < 0.0) {
      throw ArgumentError.value(
        paddingValue,
        'paddingValue',
        'Padding must be non-negative',
      );
    }
    return Padding(padding: EdgeInsets.all(paddingValue), child: this);
  }

  /// Wraps the widget with individual padding values for each side.
  ///
  /// Provides fine-grained control over padding for complex layouts.
  /// All values default to 0.0 for convenience when only some sides need padding.
  ///
  /// Throws [ArgumentError] if any padding value is negative.
  ///
  /// Example:
  /// ```dart
  /// ListTile()
  ///   .withPaddingOnly(left: 16.0, right: 8.0, top: 4.0)
  /// ```
  Widget withPaddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    if (left < 0.0) {
      throw ArgumentError.value(
        left,
        'left',
        'Left padding must be non-negative',
      );
    }
    if (top < 0.0) {
      throw ArgumentError.value(top, 'top', 'Top padding must be non-negative');
    }
    if (right < 0.0) {
      throw ArgumentError.value(
        right,
        'right',
        'Right padding must be non-negative',
      );
    }
    if (bottom < 0.0) {
      throw ArgumentError.value(
        bottom,
        'bottom',
        'Bottom padding must be non-negative',
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Wraps the widget with symmetric padding for horizontal and vertical axes.
  ///
  /// Ideal for layouts where you need different padding for horizontal vs vertical spacing.
  /// Common pattern for responsive designs and consistent spacing systems.
  ///
  /// Throws [ArgumentError] if [horizontal] or [vertical] values are negative.
  ///
  /// Example:
  /// ```dart
  /// Column()
  ///   .withPaddingSymmetric(horizontal: 24.0, vertical: 12.0)
  /// ```
  Widget withPaddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    if (horizontal < 0.0) {
      throw ArgumentError.value(
        horizontal,
        'horizontal',
        'Horizontal padding must be non-negative',
      );
    }
    if (vertical < 0.0) {
      throw ArgumentError.value(
        vertical,
        'vertical',
        'Vertical padding must be non-negative',
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}
