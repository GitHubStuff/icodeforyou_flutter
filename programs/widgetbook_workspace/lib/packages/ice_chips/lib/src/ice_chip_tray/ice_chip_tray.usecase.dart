// lib/packages/ice_chips/lib/src/ice_chip_tray/ice_chip_tray.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:ice_chips/ice_chips.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: IceChipsTray)
Widget iceChipsTrayUseCase(BuildContext context) {
  final layoutChoice = context.knobs.object.dropdown<_LayoutChoice>(
    label: 'layout',
    options: _LayoutChoice.values,
    initialOption: _LayoutChoice.wrap,
    labelBuilder: (c) => c.label,
  );

  return BlocProvider<IceChipsTrayCubit>(
    create: (_) => IceChipsTrayCubit(),
    child: _IceChipsTrayShowcase(layoutChoice: layoutChoice),
  );
}

enum _LayoutChoice {
  wrap('Wrap'),
  list('List (vertical)'),
  row('Row');

  const _LayoutChoice(this.label);

  final String label;

  IceChipsTrayLayout toLayout() => switch (this) {
    _LayoutChoice.wrap => const IceChipsTrayLayoutWrap(),
    _LayoutChoice.list => const IceChipsTrayLayoutList(shrinkWrap: true),
    _LayoutChoice.row => const IceChipsTrayLayoutRow(),
  };
}

const List<IceChipData> _sample = [
  IceChipData(id: 1, label: 'work', colorInt: 0xFF4A90E2),
  IceChipData(id: 2, label: 'home', colorInt: 0xFFE94B3C),
  IceChipData(id: 3, label: 'urgent', colorInt: 0xFFF5A623),
  IceChipData(id: 4, label: 'reading', colorInt: 0xFF7ED321),
  IceChipData(id: 5, label: 'meeting', colorInt: 0xFF9013FE),
  IceChipData(id: 6, label: 'side-project', colorInt: 0xFF50E3C2),
  IceChipData(id: 7, label: 'chore', colorInt: 0xFFBD10E0),
  IceChipData(id: 8, label: 'wellness', colorInt: 0xFF417505),
];

class _IceChipsTrayShowcase extends StatelessWidget {
  const _IceChipsTrayShowcase({required this.layoutChoice});

  final _LayoutChoice layoutChoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<IceChipsTrayCubit, Set<int>>(
            builder: (context, selected) {
              return Row(
                children: [
                  Text(
                    'selected: ${selected.length}/${_sample.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(16),
                  TextButton(
                    onPressed: () =>
                        context.read<IceChipsTrayCubit>().selectAll(
                          _sample.map((c) => c.id),
                        ),
                    child: const Text('Select all'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<IceChipsTrayCubit>().clear(),
                    child: const Text('Clear'),
                  ),
                ],
              );
            },
          ),
          const Gap(16),
          Expanded(
            child: IceChipsTray(
              chipCount: _sample.length,
              chipDataAt: (i) => _sample[i],
              layout: layoutChoice.toLayout(),
            ),
          ),
        ],
      ),
    );
  }
}
