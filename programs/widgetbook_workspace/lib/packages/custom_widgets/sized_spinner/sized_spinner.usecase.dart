// packages/custom_widgets/lib/src/sized_spinner/sized_spinner.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart' show SizedSpinner;
import 'package:flutter/material.dart';
import 'package:platform_utils/platform_utils.dart' show PlatformVendor;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;


@widgetbook.UseCase(
  name: 'Default',
  type: SizedSpinner,
)
Widget buildSizedSpinnerUseCase(BuildContext context) {
  return Center(
    child: SizedSpinner(
      size: context.knobs.double.slider(
        label: 'Size',
        initialValue: 48,
        min: 8,
        max: 200,
      ),
      color: context.knobs.colorOrNull(
        label: 'Color',
      ),
      platformVendor: context.knobs.object.dropdown<PlatformVendor>(
        label: 'Platform',
        options: const [PlatformVendor.apple, PlatformVendor.google],
        initialOption: PlatformVendor.apple,
        labelBuilder: (vendor) => switch (vendor) {
          PlatformVendor.apple => 'iOS',
          _ => 'Android',
        },
      ),
    ),
  );
}
