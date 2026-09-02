// programs/widgetbook_workspace/lib/packages/prism_bubble_widget/animated_prism_bubble.usecase.dart
import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart'
    show AnimatedPrismBubble, BubbleAnimationEnum;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Widgetbook use-case demonstrating the [AnimatedPrismBubble] component
/// with full knob controls for all constructor parameters.
@widgetbook.UseCase(
  name: 'Default',
  type: AnimatedPrismBubble,
)
Widget buildAnimatedPrismBubbleUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: 220,
    min: 50,
    max: 400,
  );

  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 220,
    min: 50,
    max: 400,
  );

  final mode = context.knobs.object.dropdown<BubbleAnimationEnum>(
    label: 'Animation Mode',
    initialOption: BubbleAnimationEnum.combined,
    options: BubbleAnimationEnum.values,
    labelBuilder: (option) => option.name,
  );

  final tintColor = context.knobs.color(
    label: 'Tint Color',
    initialValue: Colors.white,
  );

  final arcOpacity = context.knobs.double.slider(
    label: 'Arc Opacity',
    initialValue: 0.3,
    min: 0.0,
    max: 1.0,
  );

  final breathingMillis = context.knobs.int.slider(
    label: 'Breathing Duration (ms)',
    initialValue: 2400,
    min: 500,
    max: 10000,
  );

  final rotationMillis = context.knobs.int.slider(
    label: 'Rotation Duration (ms)',
    initialValue: 6000,
    min: 1000,
    max: 20000,
  );

  final minDiffusion = context.knobs.double.slider(
    label: 'Min Diffusion',
    initialValue: 0.0,
    min: 0.0,
    max: 1.0,
  );

  final maxDiffusion = context.knobs.double.slider(
    label: 'Max Diffusion',
    initialValue: 1.0,
    min: 0.0,
    max: 1.0,
  );

  final showChild = context.knobs.boolean(
    label: 'Show Child Widget',
    initialValue: true,
  );

  final childText = context.knobs.string(
    label: 'Child Text',
    initialValue: 'Prism Bubble',
  );

  return Center(
    child: AnimatedPrismBubble(
      width: width,
      height: height,
      mode: mode,
      tintColor: tintColor,
      arcOpacity: arcOpacity,
      breathingDuration: Duration(milliseconds: breathingMillis),
      rotationDuration: Duration(milliseconds: rotationMillis),
      minDiffusion: minDiffusion,
      maxDiffusion: maxDiffusion,
      child: showChild
          ? Center(
              child: Text(
                childText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : null,
    ),
  );
}
