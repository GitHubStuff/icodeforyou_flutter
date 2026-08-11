// programs/widgetbook_workspace/lib/custom_widgets/full_screen_color/solid_screen_color.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show SolidScreenColor;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Named color options for the color dropdown.
///
/// Black first (the widget's default), white to check the opposite
/// extreme, and a few saturated colors to make the full-viewport fill
/// obvious against the workbench chrome.
const List<({String name, Color color})> _kColorOptions = [
  (name: 'Black (default)', color: Colors.black),
  (name: 'White', color: Colors.white),
  (name: 'Deep Purple', color: Colors.deepPurple),
  (name: 'Teal', color: Colors.teal),
  (name: 'Amber', color: Colors.amber),
];

@widgetbook.UseCase(name: 'Default', type: SolidScreenColor)
Widget buildSolidScreenColorUseCase(BuildContext context) {
  final colorOption = context.knobs.object.dropdown(
    label: 'color',
    options: _kColorOptions,
    initialOption: _kColorOptions.first,
    labelBuilder: (option) => option.name,
  );

  // The AnnotatedRegion half of the widget (status/navigation bar
  // painting) has no observable effect inside the workbench; verify
  // that on a device. This use case covers the fill and the default.
  return SolidScreenColor(color: colorOption.color);
}
