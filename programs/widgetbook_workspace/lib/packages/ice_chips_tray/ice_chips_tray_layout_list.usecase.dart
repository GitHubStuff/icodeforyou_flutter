// packages/ice_chips_tray/widgetbook/usecases/ice_chips_tray_layout_list.usecase.dart
// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show IceChipsTray, IceChipsTrayCubit, IceChipsTrayLayoutList;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_sample_chips.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: IceChipsTrayLayoutList,
)
Widget buildIceChipsTrayLayoutListUseCase(BuildContext context) {
  final scrollDirection = context.knobs.object.dropdown<Axis>(
    label: 'scrollDirection',
    options: Axis.values,
    initialOption: Axis.vertical,
    labelBuilder: (v) => v.name,
  );

  final layout = IceChipsTrayLayoutList(
    scrollDirection: scrollDirection,
    shrinkWrap: context.knobs.boolean(
      label: 'shrinkWrap',
      initialValue: false,
    ),
    padding: EdgeInsets.all(
      context.knobs.double.slider(
        label: 'padding',
        initialValue: 8,
        min: 0,
        max: 32,
      ),
    ),
  );

  return BlocProvider(
    create: (_) => IceChipsTrayCubit(),
    child: SizedBox(
      height: scrollDirection == Axis.vertical ? 400 : 80,
      child: IceChipsTray(
        chipCount: sampleChips.length,
        chipDataAt: (index) => sampleChips[index],
        layout: layout,
      ),
    ),
  );
}
