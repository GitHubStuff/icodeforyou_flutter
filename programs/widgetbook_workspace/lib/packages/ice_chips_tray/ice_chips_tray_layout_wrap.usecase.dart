// packages/ice_chips_tray/widgetbook/usecases/ice_chips_tray_layout_wrap.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show IceChipsTray, IceChipsTrayCubit, IceChipsTrayLayoutWrap;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_sample_chips.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: IceChipsTrayLayoutWrap,
)
Widget buildIceChipsTrayLayoutWrapUseCase(BuildContext context) {
  final layout = IceChipsTrayLayoutWrap(
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
    alignment: context.knobs.object.dropdown<WrapAlignment>(
      label: 'alignment',
      options: WrapAlignment.values,
      initialOption: WrapAlignment.start,
      labelBuilder: (v) => v.name,
    ),
    runAlignment: context.knobs.object.dropdown<WrapAlignment>(
      label: 'runAlignment',
      options: WrapAlignment.values,
      initialOption: WrapAlignment.start,
      labelBuilder: (v) => v.name,
    ),
    crossAxisAlignment: context.knobs.object.dropdown<WrapCrossAlignment>(
      label: 'crossAxisAlignment',
      options: WrapCrossAlignment.values,
      initialOption: WrapCrossAlignment.start,
      labelBuilder: (v) => v.name,
    ),
  );

  return BlocProvider(
    create: (_) => IceChipsTrayCubit(),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: IceChipsTray(
        chipCount: sampleChips.length,
        chipDataAt: (index) => sampleChips[index],
        layout: layout,
      ),
    ),
  );
}
