// packages/prism_bubble_widget/lib/src/dynamic_prism_bubble.usecase.dart
import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart'
    show BubbleFluidDynamicEnum, DynamicPrismBubble;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Widgetbook use-case demonstrating the [DynamicPrismBubble] component
/// with full knob controls for presets, sizing, tint, and speed.
@widgetbook.UseCase(
  name: 'Default',
  type: DynamicPrismBubble,
)
Widget buildDynamicPrismBubbleUseCase(BuildContext context) {
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

  final dynamicPreset = context.knobs.object.dropdown<BubbleFluidDynamicEnum>(
    label: 'Fluid Dynamic Preset',
    initialOption: BubbleFluidDynamicEnum.serene,
    options: BubbleFluidDynamicEnum.values,
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

  final baseSpeed = context.knobs.double.slider(
    label: 'Base Speed',
    initialValue: 1.0,
    min: 0.1,
    max: 5.0,
  );

  final showChild = context.knobs.boolean(
    label: 'Show Child Widget',
    initialValue: true,
  );

  final childText = context.knobs.string(
    label: 'Child Text',
    initialValue: 'Fluid Dynamic Bubble',
  );

  return Center(
    child: DynamicPrismBubble(
      width: width,
      height: height,
      dynamicPreset: dynamicPreset,
      tintColor: tintColor,
      arcOpacity: arcOpacity,
      baseSpeed: baseSpeed,
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
