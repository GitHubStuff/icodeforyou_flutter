// packages/mypickdf/lib/src/mypickdf.dart

import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
    show DatePicker, FatPicker, PickerSize, TimePicker;
import 'package:extensions/widget/widget_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:gap/gap.dart' show Gap;

/// Gateway class
class ArcheTypes extends StatefulWidget {
  ///
  const ArcheTypes({super.key});

  @override
  State<ArcheTypes> createState() => _ArcheTypes();
}

class _ArcheTypes extends State<ArcheTypes> {
  @override
  Widget build(BuildContext context) {
    return const Body();
  }
}

///
class Body extends StatelessWidget {
  ///
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    const PickerSize size = .compact;
    return Column(
      children: [
        const Gap(25),
        DatePicker(
          onDateChanged: (p1) {
            debugPrint('$p1');
          },
          size: size,
        ),

        const Gap(3),
        TimePicker(
          onTimeChanged: (time) {
            debugPrint('$time');
          },
          showSeconds: false,
          size: size,
        ).withBorder(color: Colors.green),
        const Gap(3),
        FatPicker(
          onDateTimeChanged: (datetime) => debugPrint('$datetime'),
          size: size,
          showSeconds: true,
        ).withBorder(color: Colors.purple),
      ],
    );
  }
}
