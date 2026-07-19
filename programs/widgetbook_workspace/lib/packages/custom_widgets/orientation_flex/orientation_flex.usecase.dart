// programs/widgetbook/lib/use_cases/orientation_flex.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _kPortraitSize = Size(400, 800);
const _kLandscapeSize = Size(800, 400);
const _kSquareSize = Size(600, 600);

/// The simulated viewport shapes offered by the use case's `Viewport` knob.
enum _Viewport {
  portrait('Portrait (400 x 800)', _kPortraitSize),
  landscape('Landscape (800 x 400)', _kLandscapeSize),
  square('Square (600 x 600)', _kSquareSize);

  const _Viewport(this.label, this.size);

  final String label;
  final Size size;
}

@widgetbook.UseCase(
  name: 'Login / Register',
  type: OrientationFlex,
)
Widget buildOrientationFlexUseCase(BuildContext context) {
  final viewport = context.knobs.object.dropdown<_Viewport>(
    label: 'Viewport',
    options: _Viewport.values,
    initialOption: _Viewport.portrait,
    labelBuilder: (option) => option.label,
  );

  final forPortrait = context.knobs.object.dropdown<Axis>(
    label: 'forPortrait',
    options: Axis.values,
    initialOption: Axis.vertical,
    labelBuilder: (axis) => axis.name,
  );

  final forLandscape = context.knobs.object.dropdown<Axis>(
    label: 'forLandscape',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (axis) => axis.name,
  );

  final forSquare = context.knobs.object.dropdown<Axis>(
    label: 'forSquare',
    options: Axis.values,
    initialOption: Axis.vertical,
    labelBuilder: (axis) => axis.name,
  );

  // Override only the size on the ambient MediaQuery so OrientationFlex resolves
  // its direction from the chosen viewport while every other inherited value
  // (text scale, padding, platform brightness) is preserved. This is the same
  // tree-level seam the widget is designed around — no override parameter.
  final media = MediaQuery.of(context).copyWith(size: viewport.size);

  return MediaQuery(
    data: media,
    child: Center(
      child: OrientationFlex(
        forPortrait: forPortrait,
        forLandscape: forLandscape,
        forSquare: forSquare,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const Text('Please'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Login'),
          ),
          const Text('Or'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Register'),
          ),
        ],
      ),
    ),
  );
}
