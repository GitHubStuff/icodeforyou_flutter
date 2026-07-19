// packages/custom_widgets/lib/src/uninherited_text/uninherited_text.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart' show UninheritedText;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: UninheritedText,
)
Widget buildUninheritedTextUseCase(BuildContext context) {
  return UninheritedText(
    context.knobs.string(
      label: 'Text',
      initialValue: 'Something went wrong',
    ),
    backgroundColor: context.knobs.color(
      label: 'Background color',
      initialValue: Colors.black,
    ),
    style: TextStyle(
      color: context.knobs.color(
        label: 'Text color',
        initialValue: Colors.redAccent,
      ),
      fontSize: context.knobs.double.slider(
        label: 'Font size',
        initialValue: 32,
        min: 8,
        max: 96,
      ),
      fontWeight: context.knobs.object.dropdown<FontWeight>(
        label: 'Font weight',
        options: const [
          FontWeight.w400,
          FontWeight.w500,
          FontWeight.w600,
          FontWeight.w700,
          FontWeight.w900,
        ],
        initialOption: FontWeight.w700,
        labelBuilder: (weight) => switch (weight) {
          FontWeight.w400 => 'Regular (400)',
          FontWeight.w500 => 'Medium (500)',
          FontWeight.w600 => 'SemiBold (600)',
          FontWeight.w900 => 'Black (900)',
          _ => 'Bold (700)',
        },
      ),
      decoration: TextDecoration.none,
    ),
  );
}
