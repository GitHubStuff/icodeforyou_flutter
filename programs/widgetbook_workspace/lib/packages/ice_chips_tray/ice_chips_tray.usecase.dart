// packages/ice_chips_tray/widgetbook/usecases/ice_chips_tray.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart' show IceChipsTray, IceChipsTrayCubit, IceChipsTrayLayoutWrap;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'sample_chips.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: IceChipsTray,
)
Widget buildIceChipsTrayUseCase(BuildContext context) {
  final chipCount = context.knobs.int.slider(
    label: 'chipCount',
    initialValue: sampleChips.length,
    min: 0,
    max: sampleChips.length,
    divisions: sampleChips.length,
  );

  return BlocProvider(
    create: (_) => IceChipsTrayCubit(),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: IceChipsTray(
        chipCount: chipCount,
        chipDataAt: (index) => sampleChips[index],
        layout: IceChipsTrayLayoutWrap(
          spacing: context.knobs.double.slider(
            label: 'spacing',
            initialValue: 8,
            min: 0,
            max: 32,
          ),
          runSpacing: context.knobs.double.slider(
            label: 'runSpacing',
            initialValue: 8,
            min: 0,
            max: 32,
          ),
        ),
      ),
    ),
  );
}
