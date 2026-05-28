// packages/ice_chips_tray/widgetbook/usecases/ice_chips_tray_layout_row.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show IceChipsTray, IceChipsTrayCubit, IceChipsTrayLayoutRow;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'sample_chips.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: IceChipsTrayLayoutRow,
)
Widget buildIceChipsTrayLayoutRowUseCase(BuildContext context) {
  final chipCount = context.knobs.int.slider(
    label: 'chipCount',
    initialValue: 4,
    min: 0,
    max: sampleChips.length,
    divisions: sampleChips.length,
  );

  final layout = IceChipsTrayLayoutRow(
    spacing: context.knobs.double.slider(
      label: 'spacing',
      initialValue: 8,
      min: 0,
      max: 32,
    ),
    mainAxisSize: context.knobs.object.dropdown<MainAxisSize>(
      label: 'mainAxisSize',
      options: MainAxisSize.values,
      initialOption: MainAxisSize.max,
      labelBuilder: (v) => v.name,
    ),
    mainAxisAlignment: context.knobs.object.dropdown<MainAxisAlignment>(
      label: 'mainAxisAlignment',
      options: MainAxisAlignment.values,
      initialOption: MainAxisAlignment.start,
      labelBuilder: (v) => v.name,
    ),
    crossAxisAlignment: context.knobs.object.dropdown<CrossAxisAlignment>(
      label: 'crossAxisAlignment',
      options: CrossAxisAlignment.values,
      initialOption: CrossAxisAlignment.center,
      labelBuilder: (v) => v.name,
    ),
  );

  return BlocProvider(
    create: (_) => IceChipsTrayCubit(),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: IceChipsTray(
        chipCount: chipCount,
        chipDataAt: (index) => sampleChips[index],
        layout: layout,
      ),
    ),
  );
}
