import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart'
    show PrismBubbleWidget;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Widgetbook use-case demonstrating the customizable [PrismBubbleWidget]
/// with interactive knobs and controls.
@widgetbook.UseCase(
  name: 'Custom (Knobs)',
  type: PrismBubbleWidget,
)
Widget buildCustomPrismBubbleUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: 220,
    min: 50,
    max: 400,
    divisions: 35,
  );

  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 220,
    min: 50,
    max: 400,
    divisions: 35,
  );

  final isLight = context.knobs.boolean(
    label: 'Light Shader Mode',
    initialValue: false,
  );

  final tintColor = context.knobs.color(
    label: 'Tint Color',
    initialValue: Colors.white,
  );

  final arcOpacity = context.knobs.double.slider(
    label: 'Arc Opacity',
    initialValue: 0.30,
    min: 0.0,
    max: 1.0,
    divisions: 100,
  );

  final diffusion = context.knobs.double.slider(
    label: 'Diffusion',
    initialValue: 0.0,
    min: 0.0,
    max: 1.0,
    divisions: 100,
  );

  final phaseAngle = context.knobs.double.slider(
    label: 'Phase Angle (rad)',
    initialValue: 0.0,
    min: 0.0,
    max: 6.28318530718,
    divisions: 628,
  );

  final showChild = context.knobs.boolean(
    label: 'Show Child Widget',
    initialValue: true,
  );

  final childText = context.knobs.string(
    label: 'Child Text',
    initialValue: 'Custom Bubble',
  );

  final isDarkSurface = !isLight;
  final effectiveBg = isDarkSurface
      ? const Color(0xFF111118)
      : const Color(0xFFF7FAFC);
  final effectiveTextColor = isDarkSurface
      ? Colors.white
      : const Color(0xFF1A202C);

  return Container(
    color: effectiveBg,
    alignment: Alignment.center,
    child: PrismBubbleWidget(
      width: width,
      height: height,
      isLight: isLight,
      tintColor: tintColor,
      arcOpacity: arcOpacity,
      diffusion: diffusion,
      phaseAngle: phaseAngle,
      child: showChild
          ? Center(
              child: Text(
                childText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: effectiveTextColor,
                ),
              ),
            )
          : null,
    ),
  );
}

/// Widgetbook use-case demonstrating [PrismBubbleWidget.dark] with fixed
/// factory constructor defaults on a dark surface.
@widgetbook.UseCase(
  name: 'Factory Dark',
  type: PrismBubbleWidget,
)
Widget buildDarkFactoryPrismBubbleUseCase(BuildContext context) {
  return Container(
    color: const Color(0xFF111118),
    alignment: Alignment.center,
    child: PrismBubbleWidget.dark(
      width: 220,
      height: 220,
      child: const Center(
        child: Text(
          'Dark Factory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

/// Widgetbook use-case demonstrating [PrismBubbleWidget.light] with fixed
/// factory constructor defaults on a light surface.
@widgetbook.UseCase(
  name: 'Factory Light',
  type: PrismBubbleWidget,
)
Widget buildLightFactoryPrismBubbleUseCase(BuildContext context) {
  return Container(
    color: const Color(0xFFF7FAFC),
    alignment: Alignment.center,
    child: PrismBubbleWidget.light(
      width: 220,
      height: 220,
      child: const Center(
        child: Text(
          'Light Factory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A202C),
          ),
        ),
      ),
    ),
  );
}
