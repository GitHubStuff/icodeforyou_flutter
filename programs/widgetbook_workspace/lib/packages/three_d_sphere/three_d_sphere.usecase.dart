// programs/widgetbook/lib/usecases/three_d_sphere/three_d_sphere.usecase.dart

import 'package:flutter/material.dart';
import 'package:three_d_sphere/three_d_sphere.dart' show Quadrant, ThreeDSphere;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Lower bound of the size knobs, matching the widget's greater-than-zero
/// assert while keeping the sphere visible at the slider's minimum.
const double _kMinSize = 16;

/// Upper bound of the size knobs; comfortably inside the workbench canvas.
const double _kMaxSize = 400;

/// {@template three_d_sphere.usecase.dart}
/// Presents [ThreeDSphere] with every shading input on a knob.
///
/// The widget is pure painting — no state, no callbacks — so the workbench
/// story is entirely parametric: independent `width` and `height` sliders
/// expose the sphere-versus-ellipsoid behaviour the class documents, the
/// two color knobs drive the body and specular highlight, the
/// `lightSource` dropdown walks the [Quadrant] anchors, and `sphereRadius`
/// sweeps the shading falloff from tight (well below 1.0) to soft. The
/// slider floors at [_kMinSize] rather than zero because the widget
/// asserts strictly positive dimensions.
/// {@endtemplate}
@widgetbook.UseCase(name: 'Parametric', type: ThreeDSphere)
Widget buildThreeDSphereUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 200,
    min: _kMinSize,
    max: _kMaxSize,
  );
  final height = context.knobs.double.slider(
    label: 'height',
    initialValue: 200,
    min: _kMinSize,
    max: _kMaxSize,
  );
  final color = context.knobs.color(
    label: 'color',
    initialValue: Colors.blue,
  );
  final gradientColor = context.knobs.color(
    label: 'gradientColor',
    initialValue: Colors.white,
  );
  final lightSource = context.knobs.object.dropdown<Quadrant>(
    label: 'lightSource',
    options: Quadrant.values,
    initialOption: Quadrant.topRight,
    labelBuilder: (quadrant) => quadrant.name,
  );
  final sphereRadius = context.knobs.double.slider(
    label: 'sphereRadius',
    initialValue: 1.15,
    min: 0.3,
    max: 2.5,
  );

  return Center(
    child: ThreeDSphere(
      width: width,
      height: height,
      color: color,
      gradientColor: gradientColor,
      lightSource: lightSource,
      sphereRadius: sphereRadius,
    ),
  );
}
