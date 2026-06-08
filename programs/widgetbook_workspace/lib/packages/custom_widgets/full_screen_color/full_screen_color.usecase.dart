// packages/custom_widgets/lib/src/full_screen_color/full_screen_color.usecase.dart
import 'package:custom_widgets/custom_widgets.dart' show FullScreenColor;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: FullScreenColor,
)
Widget buildFullScreenColorUseCase(BuildContext context) {
  return FullScreenColor(
    color: context.knobs.color(
      label: 'Color',
      initialValue: Colors.black,
    ),
  );
}
