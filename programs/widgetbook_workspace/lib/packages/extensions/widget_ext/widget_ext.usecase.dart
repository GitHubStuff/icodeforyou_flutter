// packages/extensions/lib/widget_ext/widget_ext.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:extensions/widget/widget_ext.dart' show WidgetExt;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Widget Extensions',
  type: Widget,
)
Widget buildWidgetExtUseCase(BuildContext context) {
  final paddingValue = context.knobs.double.slider(
    label: 'Padding (all)',
    initialValue: 16,
    min: 0,
    max: 48,
  );
  final backgroundColor = context.knobs.colorOrNull(
    label: 'Background',
    initialValue: Colors.amber,
  );
  final borderColor = context.knobs.color(
    label: 'Border color',
    initialValue: Colors.black,
  );
  final borderWidth = context.knobs.double.slider(
    label: 'Border width',
    initialValue: 2,
    min: 0,
    max: 8,
  );
  final borderRadius = context.knobs.double.slider(
    label: 'Border radius',
    initialValue: 12,
    min: 0,
    max: 32,
  );
  final opacityValue = context.knobs.double.slider(
    label: 'Opacity',
    initialValue: 1,
    min: 0,
    max: 1,
  );
  final shouldHide = context.knobs.boolean(
    label: 'Hide (transparent)',
    initialValue: false,
  );
  final shouldRemove = context.knobs.boolean(
    label: 'Remove (shrink)',
    initialValue: false,
  );

  var result = const FlutterLogo(size: 96).withPaddingAll(paddingValue);

  if (backgroundColor != null) {
    result = result.withBackground(color: backgroundColor);
  }

  result = result
      .withBorder(
        color: borderColor,
        width: borderWidth,
        radius: borderRadius,
      )
      .withOpacity(opacityValue)
      .hide(shouldHide)
      .remove(shouldRemove);

  return Center(child: result);
}
