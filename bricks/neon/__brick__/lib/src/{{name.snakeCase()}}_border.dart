// packages/{{name.snakeCase()}}/lib/src/{{name.snakeCase()}}_border.dart
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';

/// Wraps [child] in a glowing {{name.snakeCase()}} tube border.
///
/// Pass any base colour (e.g. `Colors.green`); the widget derives the lit
/// accent hue for both the tube and its halo, so the border matches a
/// `{{name.titleCase()}}Text` of the same colour.
class {{name.titleCase()}}Border extends StatelessWidget {
  /// Creates a {{name.snakeCase()}}-bordered container around [child].
  const {{name.titleCase()}}Border({
    required this.child,
    required this.color,
    this.width = 3,
    this.radius = 12,
    this.padding = const EdgeInsets.all(16),
    super.key,
  }) : assert(width > 0, 'Width must be > 0'),
       assert(radius >= 0, 'Radius must be >= 0');

  /// The widget framed by the border.
  final Widget child;

  /// The base colour of the tube. Brightened to an accent for the glow.
  final Color color;

  /// Thickness of the tube in logical pixels.
  final double width;

  /// Corner radius of the tube in logical pixels.
  final double radius;

  /// Space between the tube and [child].
  final EdgeInsetsGeometry padding;

  static const double _outerGlowAlpha = 0.6;
  static const double _tubeTint = 0.45;

  /// Blur radii of the four glow layers, innermost first.
  static const List<double> _blurRadii = [4, 12, 24, 48];

  @override
  Widget build(BuildContext context) {
    final glow = color.to{{name.titleCase()}}Accent();
    final tube = color.to{{name.titleCase()}}Core(tint: _tubeTint);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tube, width: width),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: _buildGlow(glow),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  List<BoxShadow> _buildGlow(Color glow) {
    return [
      BoxShadow(color: glow, blurRadius: _blurRadii[0]),
      BoxShadow(color: glow, blurRadius: _blurRadii[1]),
      BoxShadow(color: glow, blurRadius: _blurRadii[2]),
      BoxShadow(
        color: glow.withValues(alpha: _outerGlowAlpha),
        blurRadius: _blurRadii[3],
      ),
    ];
  }
}

/// Fluent helper for framing any widget in a [{{name.titleCase()}}Border].
extension {{name.titleCase()}}BorderExtension on Widget {
  /// Wraps this widget in a glowing {{name.snakeCase()}} tube border of [color].
  ///
  /// ```dart
  /// const Text('OPEN').with{{name.titleCase()}}Border(color: Colors.green)
  /// ```
  Widget with{{name.titleCase()}}Border({
    required Color color,
    double width = 3,
    double radius = 12,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Key? key,
  }) {
    return {{name.titleCase()}}Border(
      key: key,
      color: color,
      width: width,
      radius: radius,
      padding: padding,
      child: this,
    );
  }
}
