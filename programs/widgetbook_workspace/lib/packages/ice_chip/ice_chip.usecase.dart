// packages/ice_chip/widgetbook/usecases/ice_chip.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:ice_chips/ice_chips.dart' show IceChip;
import 'package:widgetbook/widgetbook.dart' show KnobsExtension;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: IceChip,
)
Widget buildIceChipUseCase(BuildContext context) {
  return Center(
    child: IceChip(
      context.knobs.string(
        label: 'message',
        initialValue: 'Ice Chip',
      ),
      backgroundColorInt: context.knobs
          .color(
            label: 'backgroundColor',
            initialValue: Colors.lightBlueAccent,
          )
          .toARGB32(),
      showBorder: context.knobs.boolean(
        label: 'showBorder',
        initialValue: true,
      ),
      onPress: () => debugPrint('IceChip pressed'),
      style: TextStyle(
        fontSize: context.knobs.double.slider(
          label: 'fontSize',
          initialValue: 14,
          min: 8,
          max: 48,
          divisions: 40,
        ),
        fontWeight: context.knobs.object.dropdown<FontWeight>(
          label: 'fontWeight',
          options: FontWeight.values,
          initialOption: FontWeight.bold,
          labelBuilder: (weight) => 'w${weight.value}',
        ),
      ),
    ),
  );
}
